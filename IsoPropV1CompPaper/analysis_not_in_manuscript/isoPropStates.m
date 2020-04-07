%% Propofol and Isoflurane States for V1 iso vs prop paper

%% general loading
clc
clear
close all

dirIn = '/data/adeeti/ecog/matIsoPropMultiStim/';
dirFiltData = '/data/adeeti/ecog/matIsoPropMultiStim/Wavelets/FiltData/';
dirOut1 = '/data/adeeti/ecog/images/IsoPropCompV1Paper/';
dirDropbox = '/data/adeeti/Dropbox/';

cd(dirIn)
load('dataMatrixFlashes.mat')
load('matStimIndex.mat')

lowestLatVariable = 'lowLat';

stimIndex = [0, Inf]; %if want all, stimIndex = matStimIndex; % if want
%all uniStimIndexes/multiStimIndexes, use [uniStimIndex, multiStimIndex] =
%findUniMutliStimIndex(matStimIndex), [stimIndex, ~] = findUniMutliStimIndex(matStimIndex)

% Setting up new data set for just visual only stim
expLabel =unique(vertcat(dataMatrixFlashes(:).exp));
allExp = {};
if exist('stimIndex')  && ~isempty(stimIndex)
    for i = 1:length(expLabel)
        for j = 1:size(stimIndex,1)
            [MFE] = findMyExpMulti(dataMatrixFlashes, expLabel(i), [], [], stimIndex(j,:));
            allExp{i}(:) = MFE;
        end
    end
else
    [MFE] = 1:length(dataMatrixFlashes);
end

numSubjects = size(allExp,2);
maxExposuresPerSubject = max(cellfun(@length, allExp));
% Parameters for multitaper spectral analysis and shits
win = 5; % size of window (secs) for spectrum
win_step = 0.5; % size of window step (secs) for spectrum (in this case we are taking 10sec windows, stepping by 1sec)
ktapers = 10;  % number of tapers for mutlitaper analysis
NW = 19;  % constant for multitaper analysis


expLabel =unique(vertcat(dataMatrixFlashes(:).exp));
allExp = {};
if exist('stimIndex')  && ~isempty(stimIndex)
    for i = 1:length(expLabel)
        for j = 1:size(stimIndex,1)
            [MFE] = findMyExpMulti(dataMatrixFlashes, expLabel(i), [], [], stimIndex(j,:));
            allExp{i}(:) = MFE;
        end
    end
else
    [MFE] = 1:length(dataMatrixFlashes);
end

numSubjects = size(allExp,2);
maxExposuresPerSubject = max(cellfun(@length, allExp));

addpath('/home/alex/MatlabCode/Spectra');
    
    %perform spectral analysis on one of the frontal channels
    data = USE_DATA{i};
    noiseChannels = info.noiseChannels;
    
    [out, taper, concentration]=swTFspecAnalog(data(USE_CHANNEL,:), sf, ktapers, [], win*sf, win_step*sf, NW,[],[],[],[]); %multitaper spectral analysis on the entire length of data
    disp(['Spectral analysis of channel ', num2str(USE_CHANNEL)])
    













oneChanFullTrace = [];

for i = 1:length(MFE)
    load(dataMatrixFlashes(MFE(i)).expName, 'meanSubFullTrace', 'info', 'finalSampR', 'finalTimeFullTrace')
    fullTrace{i} = meanSubFullTrace(:,info.startOffSet:info.endOffSet);
    expID{i} = info.exp;
    anesType{i}= info.AnesType;
    anesLevel{i}= info.AnesLevel;
    oneChanFullTrace{i} = fullTrace{i}(USE_CHANNEL,:);
end

USE_DATA = fullTrace;
sf = finalSampR;

% Compute spectrum for each experiment and concatonate together and shits
mySpectrum = [];
myTotalSpectrum = [];
indexLength = [];
startTimes = [];
endTimes =[];
expLabel = [];
drugLabel = [];
doseLabel = [];

for i = 1:length(MFE)
    
    % high pass filter the data -- Neuralynx data is already high pass
    % 	filtered at 0.1Hz
    % 	high_cutoff = 0.1;
    % 	[b,a] = butter(4,high_cutoff/sf,'high');
    % 	for i = 1:size(data,1)
    % 		data(i,:) = filtfilt(b,a,double(data(i,:)));
    % 	end
    
    addpath('/home/alex/MatlabCode/Spectra');
    
    %perform spectral analysis on one of the frontal channels
    data = USE_DATA{i};
    noiseChannels = info.noiseChannels;
    
    [out, taper, concentration]=swTFspecAnalog(data(USE_CHANNEL,:), sf, ktapers, [], win*sf, win_step*sf, NW,[],[],[],[]); %multitaper spectral analysis on the entire length of data
    disp(['Spectral analysis of channel ', num2str(USE_CHANNEL)])
    
    freq=out.freq_grid; %extract freq evaluated
    T=out.time_grid; %extract time windows evaluated
    spectrum=squeeze(out.tfse); % size = 1 x windows x freq; tfse = power at each freq and time point
    
    %Normalize the spectra
    
    % load('freq.mat')
    % load('allSpectrum.mat')
    
    totalPower = sum(spectrum,2);  %add up the power at each freq for every time window ==> time windows x 1
    totalSpectrum = spectrum./repmat(totalPower,1, length(freq));   % normalizing power at each freq by the total power: replicate the total power at all freq and then divide each power at each time window by the total
    mySpectrum = vertcat(mySpectrum, spectrum);
    myTotalSpectrum= vertcat(myTotalSpectrum, totalSpectrum);
    indexLength = [indexLength, ones(1, size(spectrum,1))*i];
    expLabel = [expLabel, ones(1, size(spectrum,1))*expID{i}];
    %drugLabel = [drugLabel, ones(1, size(spectrum,1))anesType{i}];
    doseLabel = [doseLabel, ones(1, size(spectrum,1))*anesLevel{i}];
    startTimes = [startTimes, win_step*(0:(size(spectrum,1)-1))];
end

endTimes = startTimes+win;






