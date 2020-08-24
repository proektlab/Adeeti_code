%% Preprocessing Full Trace code
% Use this code to extract the full trace from .mat files and format them
% into the correct sampling rate without detrending
% Will take the info files from the preprocessed data into trials 
% If wanting to process files that have only baseline data, use
% pipeline4processingBaselineOnlyData_Neuralynx.m, this will make the info files and
% let you find the noise channels

%% Setting up
clear
clc
close all

dirIn = '/data/adeeti/ecog/rawIsoPropMultiStim/';
dirOut1 = '/data/adeeti/ecog/matIsoPropMultiStim/';
%dirOut1 = '/data/adeeti/ecog/matIsoPropMultiStim/FullTrace/';

identifier = '2018*';
START_AT= 1; % starting experiment
before = 1;
l = 3;
finalSampR= 1000;

mkdir(dirOut1);
cd(dirIn)
allData = dir(identifier);

%% Grabbing info files and formating data 

for e = START_AT:length(allData)
    dirName = [allData(e).name, '.mat'];
    disp(['Starting file ', dirName])
    load([dirOut1, dirName], 'info', 'meanSubData')
    
    cd([dirIn, allData(e).name])
    load('Events.mat')
    if unique(eveID) == 0
        continue
    end
    stimIDs = [];
    i = 1;
    while i <= info.numberStim
        eval(['stimIDs = [ stimIDs, info.Stim', num2str(i), 'ID];'])
        i = i +1;
    end
    interPulseInterval = info.interPulseInterval/finalSampR;
    
    [fullTrace, finalTimeFullTrace] = extractFullTrace_Neuralynx(finalSampR); %extracts and formats full trace data - does not detrend it!
    
    [~, allStartTimes, ~, ~, ~] = findAllStartsAndSeries_Neuralynx(eveID, eveTime, stimIDs, min(interPulseInterval), l-before);
    info.startOffSet = round(finalSampR*(allStartTimes(1)-before));
    info.endOffSet = size(meanSubData,2)*size(meanSubData,3);
    info.trials = size(meanSubData,2);
    
    noiseChannels = info.noiseChannels;
    cleanedFullTrace = fullTrace;
    
    for n = 1:length(noiseChannels)
        if isempty(noiseChannels)
            continue
        end
        cleanedFullTrace(noiseChannels(n),:) = NaN(1, size(fullTrace,2));
    end
    meanSubFullTrace = cleanedFullTrace - repmat(nanmean(cleanedFullTrace,1), [size(cleanedFullTrace,1), 1]);
    
    
    save([dirOut1, dirName], 'fullTrace','finalTimeFullTrace', 'info', 'meanSubFullTrace', '-append')
    clearvars -except allData e dirInfo dirIn dirOut1 finalSampR identifier START_AT before l
end
