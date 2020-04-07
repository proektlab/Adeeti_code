function [LFPData, ogSampRate, eventTimes, fullTraceTime, plexInfoStuffs] = ExtractPL2_LFP_from_WB_Plexon(myExperiment,eventsChan, numChan, LFPcutOff, finalSampR)
% [gridDataWB, ogSampRate, eventTimes, fullTraceTime, plexInfoStuffs] = ExtractPL2_LFP_from_WB(myExperiment,eventsChan, numChan, LFPcutOff, finalSampR)
% Converts .pl2 files into .mat and extracts wideband data for future
% referene; first extracts wideband data, then uses a FIR filter to filter
% data to LFP data with filtfilt - no phase lags introduced. If want to
% just extract LFP from FP from plexon, use ExtractPL2_LFP_data.m
% myExperiment = string with the name of the experiment that you would like
% eventsChan = structure with list of channels with events (default is
% 'EVT01')
% LFPcutOff = cut off for low pass filter for LFP (using FIR filter for
% full data then decimating, default is 325)
% finalSampR = final sampling rate you want for the LFP (defualt is 1000)
% 09/05/18 AA
if nargin <5
    finalSampR = 1000;
end
if nargin <4
LFPcutOff = 325;
end
if nargin <3
    numChan = 96;
end
if nargin <2
    eventsChan = [];
end

% info from plexon about recording
plexInfoStuffs = PL2GetFileIndex(myExperiment);

% extract event times (in seconds)
if isempty(eventsChan)
    eventTimes = [];
end

for i = 1:length(eventsChan)
    events = PL2EventTs(myExperiment,eventsChan{i});
    eventTimes{i} = events.Ts;
end

% setting up for WB extraction
% ad = PL2AdBySource(myExperiment, 'WB',1);
% lengthOfRecording = size(ad.Values,1);
%LFPData = nan(numChan, round(lengthOfRecording/(Fs/finalSampR)));
infomationExp = PL2GetFileIndex(myExperiment);
Fs = infomationExp.TimestampFrequency; % ad.ADFreq = sampling rate
totTimeStamps = infomationExp.DurationOfRecordingSec*Fs;
allFreq = [];

% setting up for low pass FIR filtering
nyquist = Fs/2;
filtbound = [LFPcutOff LFPcutOff*1.15]; % Hz
filt_order = 50;
ffrequencies = [0 filtbound(1)/nyquist filtbound(2)/nyquist 1];
idealresponse = [1 1 0 0];
filterweights= firls(filt_order,ffrequencies,idealresponse,[100 1]);

% Extract one channel at a time
for chan = 1:numChan
    ad = PL2AdBySource(myExperiment, 'WB',chan);
    disp(['Filtering and decimating channel ', num2str(chan)]);
    data = ad.Values; % ad.Values = data
    % filtering data
    if isempty(data)
        continue
    end
    fir_filtered_data = zeros(size(ad.Values));
    fir_filtered_data = filtfilt(filterweights,1,double(data));
    LFPData(chan,:) = decimate(fir_filtered_data, Fs/finalSampR);
allFreq = [allFreq, ad.ADFreq];
end

% Check to make sure the aquisition system didnt fuck up
if numel(unique(allFreq)) ==1
    ogSampRate = unique(allFreq);
else
    disp('You gotta problem');
end

% time vector for the full trace
fullTraceTime = (1:size(LFPData,2))./finalSampR;



