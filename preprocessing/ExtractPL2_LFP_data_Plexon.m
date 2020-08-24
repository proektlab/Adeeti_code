function [gridData, lfpSampRate, eventTimes, fullTraceTime, plexInfoStuffs] = ExtractPL2_LFP_data_Plexon(myExperiment,eventsChan, numChannels, startChan)
% [gridData, finalSampR, eventTimes, plexInfoStuffs] = ExtractPL2data(myExperiment,eventsChan, numChannels, startChan)
% Converts .pl2 files into mad
% myExperiment = string with the name of the experiment that you would like
% eventsChan = structure with list of channels with events
% 08/31/18 AA
if nargin < 4
    startChan =1;
end

if nargin < 3
    numChannels = 64;
end 

%% Pull ECoG files from .pl2 files into MATLAB

% info from plexon about recording
plexInfoStuffs = PL2GetFileIndex(myExperiment);

% extract event times (in seconds)
for i = 1:length(eventsChan)
    try
        events = PL2EventTs(myExperiment,eventsChan{i});
        eventTimes{i} = events.Ts;
    catch
        warning(['No events in ', myExperiment, 'will process as baseline'])
        eventTimes{i} = [];
    end
end

allFreq = [];

% Extract one channel at a time
% ad.Values = data
% ad.ADFreq = sampling rate
for chan = startChan:startChan+numChannels-1
    try
    ad = PL2AdBySource(myExperiment, 'FP',chan);
    catch
        warning('Dis file be fucked')
        data = [];
        gridData = [];
        
        break 
        
    end
    
       data = ad.Values; % ad.Values = data 
    % filtering data
    if isempty(data)
        continue
    end
    gridData(chan,:) = ad.Values;
    allFreq = [allFreq, ad.ADFreq];
end

% Check to make sure the aquisition system didnt fuck up 
if numel(unique(allFreq)) ==1
    lfpSampRate = unique(allFreq);
else
    disp('You gotta problem');
end

% time vector for the full trace
if ~isempty(gridData)
    fullTraceTime = (1:size(gridData,2))./lfpSampRate;
else
    fullTraceTime = [];
    lfpSampRate = [];
end




