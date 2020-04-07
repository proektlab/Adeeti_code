%% Semi Offline processing for VEPs
clear
clc

dateToday = '2020-02-18';

%dirIn = ['D:\adeetiData\' dateToday, '\'];
%dirOut = ['D:\adeetiData\', dateToday, '\matlab\'];
dirIn = ['Y:\adeeti\plexonData_adeeti\' dateToday, '\'];
dirOut = ['Y:\adeeti\plexonData_adeeti\', dateToday, '\matlab\'];

addpath(genpath('C:\Users\Plexon\Dropbox\ProektLab_code\Adeeti_code'))

identifier = '*.pl2';
START_AT= 1;
eventsChan{1} = 'EVT01';
numChan = 64;

mkdir(dirOut)

cd(dirIn)
allData = dir(identifier);

before = 1; %in seconds amount of prestim data
l = 3; %total length in seconds of the trial 
startBaseline = 0; %0 if want to make chan by trials by timepoints, 1 if want to extract intial baseline sequence 
LFPcutOff = 325;
finalSampR = 1000;

loadingWindow = waitbar(0, 'Converting data...');
totalExp = length(allData);

addpath('C:\Users\Plexon\Google Drive\NEURA_codeShare\Adeeti_code')

for experiment = START_AT:length(allData)
    
    [LFPData, lfpSampRate, allStartTimes, fullTraceTime, plexInfoStuffs] = ExtractPL2_LFP_data_Plexon(allData(experiment).name,eventsChan, 64, 1);
    %[LFPData, ogSampRate, allStartTimes, fullTraceTime, plexInfoStuffs] = ExtractPL2_LFP_from_WB_Plexon(allData(experiment).name,eventsChan, numChan, LFPcutOff, finalSampR);
    % Extract segments of data and save

    disp(['Breaking up file file ', allData(experiment).name])
    
    if length(allStartTimes) ==1
        onTime = allStartTimes{1};
    end 
    
    [dataSnippits, finalTime] = extractSnippets_Plexon(LFPData, onTime, before, l, finalSampR, startBaseline);
    
    save([dirOut, allData(experiment).name(1:end-4), '.mat'], 'dataSnippits', 'finalTime', 'finalSampR', 'LFPData', 'allStartTimes', 'fullTraceTime','plexInfoStuffs')

    
    clearvars -except allData before l experiment totalExp dirIn dirOut eventsChan startBaseline numChan LFPcutOff finalSampR dateToday START_AT
    loadingWindow = waitbar(experiment/totalExp);
end

close(loadingWindow);

%% Making info files

cd(dirOut)
identifier = '*.mat';
allData = dir(identifier);

noiseChannels = [16 28 42 43 44 48 64];

bregmaOffsetX = 1;
bregmaOffsetY = 1;

numStim = 1;
interPulseInterval = [3,5];

AnesLevel = [1.2,1.2, 0.6 , 0 ,0];
%drugType = [{'Isoflurane'}, {'Isoflurane'}]

for experiment = START_AT:length(allData)
    dirName = allData(experiment).name;
    info = [];
    
    info.AnesType = 'Isoflurane'; %'Ketamine';
    info.AnesLevel = AnesLevel(experiment);
    info.TypeOfTrial = 'full screen flashes';
    
    info.expName = dirName;
    info.date = dateToday;
    info.channels = 64;
    info.notes = nan;
    info.noiseChannels = noiseChannels;
    info.exp = 1;
    info.interPulseInterval = interPulseInterval;
    info.interStimInterval = nan;
    info.bregmaOffsetX = bregmaOffsetX;
    info.bregmaOffsetY = bregmaOffsetX;
    
    info.ecogGridName = 'E64-500-200-60';
    info.ecogChannels = [1:64];
    
%     info.forkName = 'A2x16-10mm-50-500-177';
%     info.forkPosition = nan;
%     info.forkChannels = [[81:96]; [65:80]];
    
    info.numberStim = numStim;
    
    % for stimuli parameters
    modCounter =0;
    if info.numberStim >= 1
        info.Stim1 = 'flash';
        info.Stim1ID= 1;
        info.LengthStim1 = 0.01;
        info.IntensityStim1 = 10;
    end
    
    if info.numberStim >= 2
        info.Stim2 = 'whisker';
        info.Stim2ID= 2;
        info.LengthStim2 = 0.030;
        info.IntensityStim2 = 20;
    end
    
    if info.numberStim >= 3
        info.Stim3 = 'electrical';
        info.Stim3ID= 3;
        info.LengthStim3 = 0.0001;
        info.IntensityStim3 = 10;
    end
    
    if info.numberStim >= 3
        info.Stim4 = 'opto';
        info.Stim4ID= 4;
        info.LengthStim4 = 0.01;
        info.IntensityStim4 = 10;
    end
    
    gridIndicies = [[32 21 10 58 37 48 ];... %bregma is at top right corner
        [31 20 9 57 36 47 ];...
        [30 19 8 56 35 46 ];...
        [29 18 7 55 34 45 ];...
        [22 17 6 54 33 38 ];...
        [23 11 1 49 59 39 ];...
        [24 12 2 50 60 40 ];...
        [25 13 3 51 61 41 ];...
        [26 14 4 52 62 42 ];...
        [27 15 5 53 63 43 ];...
        [28 16 0 0 64 44 ]];
    
    info.gridIndicies = fliplr(flipud(gridIndicies));
%     NNShank2 = [9 8 10 7 11 6 12 5 13 4 14 3 15 2 16 1];
%     NNShank1 = NNShank2+16;
%     NNChannels = [NNShank1;NNShank2];
%     [ADChannels] = convertNNchan2PlexADChanAcute32(NNChannels);
%     info.forkIndicies = (ADChannels+64)'; %anterior shank is in column 1
    
    %info.noiseChannels = [16, 25:32, 39, 40. 44:47,58,64];
    % info.V1 = 27; %V1 or stim site
    % info.noiseChannels = noiseChannels; %vector with the number of channels that are noise free
    %info.polarity = 'pos';
    save([dirOut, dirName], 'info', '-append')
end
close all

%% mean subtraction and making averages and unique series/index series 

uniqueSeries = [0,inf];
%START_AT = 1;
identifier = '*.mat';

flashOn = [0,0];
before = 1;
after = 2;
markTime = -before:.1:after;
screensize=get(groot, 'Screensize');

cd(dirOut)
allData = dir(identifier);

for experiment = START_AT:length(allData)
    
    dirName = allData(experiment).name;
    load(dirName)
    disp(['Converting data ', allData(experiment).name])
    
    % Cleaning data and subtracting the mean
    
    noiseChannels = info.noiseChannels;
    cleanedData = dataSnippits;
    cleanedFullTrace = LFPData;
    meanSubData = nan(size(dataSnippits));
    meanSubFullTrace = nan(size(LFPData));
    
    indexSeries = ones(size(meanSubData,2), 1);
    info.stimIndex = uniqueSeries;
    
    for n = 1:length(noiseChannels)
        if isempty(noiseChannels)
            continue
        end
        cleanedData(noiseChannels(n), :, :) = NaN(size(dataSnippits,2), size(dataSnippits, 3));
        cleanedFullTrace(noiseChannels(n), :) = NaN(1, size(LFPData, 2));
    end
    
    % to mean subtract ecog data only 
    eCoGMean = nanmean(cleanedData(info.ecogChannels,:, :),1);
    LFPeCoGMean = nanmean(cleanedFullTrace(info.ecogChannels, :),1);
    
    meanSubData(info.ecogChannels,:,:) = cleanedData(info.ecogChannels,:,:) - repmat(eCoGMean, [size(info.ecogChannels,2), 1, 1]);
    meanSubFullTrace(info.ecogChannels,:) = cleanedFullTrace(info.ecogChannels,:) - repmat(LFPeCoGMean, [size(info.ecogChannels,2), 1]);  


    %meanSubData = cleanedData - repmat(nanmean(cleanedData,1), [size(cleanedData,1), 1, 1]);
    aveTrace = nan(size(uniqueSeries, 1), size(meanSubData,1), size(meanSubData,3));
    standError = nan(size(uniqueSeries, 1), size(meanSubData,1), size(meanSubData,3));
    
    for i = 1:size(uniqueSeries, 1)
        [indices] = getStimIndices(uniqueSeries(i,:), indexSeries, uniqueSeries);
        useMeanSubData = meanSubData(:,indices,:);
        parfor ch = 1:size(meanSubData,1)
            aveTrace(i, ch, :) = squeeze(nanmean(meanSubData(ch,:,:), 2));
            standError(i, ch,:) = squeeze(nanstd(meanSubData(ch,:,:), 1, 2)/sqrt(size(meanSubData(ch,:,:), 2)));
        end
    end
    
    info.startOffSet = round(finalSampR*(allStartTimes{1}(1)-before));
    info.endOffSet = round(finalSampR*(allStartTimes{1}(end)+after));
    
    save([dirOut, dirName], 'meanSubFullTrace', 'uniqueSeries', 'indexSeries', 'meanSubData', 'aveTrace', 'standError', 'info',  '-append')
    %save([dirOut, dirName], 'cleanedData', 'meanSubFullTrace' 'meanSubData', 'aveTrace', 'standError', 'info', 'dataSnippits','finalTime', 'finalSampR', 'LFPData', 'eventTimes', 'fullTraceTime','plexInfoStuffs','uniqueSeries', 'indexSeries')
      
    % Single trial images
    
    %[currentFig] = plotSingleTrials(meanSubData, finalTime, info);

    %saveas(currentFig, [dirPic, dirName, 'singletrials.png'])
    %close all;
    
    % Flash triggered average images
    
    %[currentFig] = plotAverages(aveTrace, finalTime, info, [], [], [], [], before, after, flashOn);
    
    %[currentFig] = plotAverages(plotData, finalTime, info, yAxis, lowerCIBound, upperCIBound, latency,  before, after, flashOn, finalSampR)
    
    %saveas(currentFig, [dirPic, allData(experiment).name, 'average.png'])
    close all;
end

%% Finding latency 

%START_AT = 1;
identifier = '*.mat';

before=1;
l = 3;
flashOn = [0,0];
thresh=4;
maxThresh = 8;
consistent = 4;
endMeasure = 0.35;

VEPthresh = 30;

cd(dirOut)
allData = dir(identifier);

for experiment = START_AT:length(allData)
    close all
    disp(['Finding latency for experiment ', num2str(experiment), ' out of ', num2str(length(allData))])
    
    dirName = allData(experiment).name;
    load(allData(experiment).name, 'finalSampR', 'aveTrace', 'finalTime', 'info', 'uniqueSeries')
    if isempty(aveTrace)
        continue
    end
    
    useAve = aveTrace(:, info.ecogChannels,:);
    latency = nan(size(useAve,1), size(useAve,2));
    
    % Gettting Latencies
    for i = 1:size(aveTrace,1)
    [ zData, stimTypeLat ] = normalizedThreshold(squeeze(useAve(i,:,:)), thresh, maxThresh, consistent, endMeasure, 1.025, finalSampR);

    latency(i,:) = stimTypeLat; 
    
    sortLatency = sort(latency);
    onset = find(sortLatency>=VEPthresh, 1, 'first');
    info.lowLat= find(latency == sortLatency(onset), 1, 'first');
    save([dirOut, allData(experiment).name], 'latency', 'info', '-append')
    
    end
end

%%

figure 
plot(squeeze(aveTrace)')
