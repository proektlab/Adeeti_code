% Preprocessing code on workstation 
% snippits already made from convertPL2intoMat_Plexon or
% convertPL2intoMat_Plexon_LinuxWS

% clear
% clc
% 
% dirIn = '/synology/adeeti/ecog/iso_awake_VEPs/GL7/';
% dirPic = '/synology/adeeti/ecog/images/Iso_Awake_VEPs/GL7/preprocessing/';
% dirOut = dirIn;
% 
% driveLocation = '/home/adeeti/Dropbox/';  %'/data/adeeti/Dropbox/'; %'/home/adeeti/googleDrive/'; %dropbox location for excel file and saving
% 
% excelFileName = 'ProektLab_code/Adeeti_code/preprocessing/Iso_Awake_VEPs.xlsx';
% excelSheet = 4;
% 
% MAXSTIM = 1;
% ADD_MAN_NOISE_CHANNELS = 0;
% ANALYZE_IND = 0;
% REMOVE_STIM_ARTIFACT = 0;
% 
% PicByTrialType = 0;
% PicByAnesType = 1;
% PicByAnesAndTrial = 0;
% 
% identifier = '2019*.mat';
% START_AT= 1;
mkdir(dirOut)
mkdir(dirPic)

%% Making info files
[num, text, raw] = xlsread([driveLocation, excelFileName], excelSheet); %reads excel sheet

cd(dirIn)
allData = dir(identifier);
loadingWindow = waitbar(0, 'Converting data...');
totalExp = length(allData);

for experiment = 1:length(allData)
    dirName = allData(experiment).name;
    %load(dirName);
    info = [];
    rowInd = experiment+1;
    info = [];
    info.AnesType = raw{rowInd, 2};
    info.AnesLevel = raw{rowInd,3};
    info.TypeOfTrial = raw{rowInd, 4};
    
    info.expName = dirName;
    info.date = dirName(1:10);
    info.channels = raw{rowInd,5};
    info.notes = raw{rowInd, 6};
    noiseChan = raw{rowInd,7};
    if isnan(noiseChan)
        info.noiseChannel = nan;
    elseif isnumeric(noiseChan)
        info.noiseChannels = noiseChan;
    else
        info.noiseChannels = str2num(raw{rowInd,7});
    end
    info.exp = raw{rowInd,8};
    info.interPulseInterval = raw{rowInd,10};
    info.interStimInterval = raw{rowInd, 11};
    info.bregmaOffsetX = raw{rowInd, 12};
    info.bregmaOffsetY = raw{rowInd, 13};
    
    info.ecogGridName = raw{rowInd, 14};
    info.ecogChannels = str2num(raw{rowInd, 15});
    
    info.forkName = raw{rowInd, 16};
    if isnan(raw{rowInd, 17})
        info.forkPosition = nan;
        info.forkChannels = nan;
    else
        info.forkPosition = str2num(raw{rowInd, 17});
        info.forkChannels = str2num(raw{rowInd, 18});
    end
    
    if ischar(info.interStimInterval)
        info.interStimInterval = NaN;
    end
    info.numberStim = raw{rowInd,9};
    
    % for stimuli parameters
    modCounter =0;
    if raw{rowInd,9} >= 1
        info.Stim1 = raw{rowInd,19+modCounter};
        info.Stim1ID= raw{rowInd,20+modCounter};
        info.LengthStim1 = raw{rowInd,21+modCounter};
        info.IntensityStim1 = raw{rowInd,22+modCounter};
        modCounter = modCounter + 4;
    end
    
    if MAXSTIM >= 2
        info.Stim2 = raw{rowInd,19+modCounter};
        info.Stim2ID= raw{rowInd,20+modCounter};
        info.LengthStim2 = raw{rowInd,21+modCounter};
        info.IntensityStim2 = raw{rowInd,22+modCounter};
        modCounter = modCounter + 4;
    end
    
    if MAXSTIM >= 3
        info.Stim3 = raw{rowInd,19+modCounter};
        info.Stim3ID= raw{rowInd,20+modCounter};
        info.LengthStim3 = raw{rowInd,21+modCounter};
        info.IntensityStim3 = raw{rowInd,22+modCounter};
        modCounter = modCounter + 4;
    end
    
    if MAXSTIM >= 4
        info.Stim4 = raw{rowInd,19+modCounter};
        info.Stim4ID= raw{rowInd,20+modCounter};
        info.LengthStim4 = raw{rowInd,21+modCounter};
        info.IntensityStim4 = raw{rowInd,22+modCounter};
        modCounter = modCounter + 4;
    end
    
    %     info.gridIndicies = [[32 21 10 58 37 48 ];... %bregma is at top right corner
    %         [31 20 9 57 36 47 ];...
    %         [30 19 8 56 35 46 ];...
    %         [29 18 7 55 34 45 ];...
    %         [22 17 6 54 33 38 ];...
    %         [23 11 1 49 59 39 ];...
    %         [24 12 2 50 60 40 ];...
    %         [25 13 3 51 61 41 ];...
    %         [26 14 4 52 62 42 ];...
    %         [27 15 5 53 63 43 ];...
    %         [28 16 0 0 64 44 ]];
    %
    info.gridIndicies =     [[44    64     0     0    16    28];...
        [43    63    53     5    15    27];...
        [42    62    52     4    14    26];...
        [41    61    51     3    13    25];...
        [40    60    50     2    12    24];...
        [39    59    49     1    11    23];...
        [38    33    54     6    17    22];...
        [45    34    55     7    18    29];...
        [46    35    56     8    19    30];...
        [47    36    57     9    20    31];...
        [48    37    58    10    21    32 ]];
    
    %     NNShank2 = [9 8 10 7 11 6 12 5 13 4 14 3 15 2 16 1];
    %     NNShank1 = NNShank2+16;
    %     NNChannels = [NNShank1;NNShank2];
    %     [ADChannels] = convertNNchan2PlexADChanAcute32_Plexon(NNChannels);
    %     info.forkIndicies = (ADChannels+64)'; %anterior shank is in column 1
    
    info
    save([dirOut, dirName], 'info','-append')
    clearvars info
    loadingWindow = waitbar(experiment/totalExp);
    
end
close(loadingWindow);

%% Finding noise Channels
if ADD_MAN_NOISE_CHANNELS ==1
    numbOfSamp = 8;
    START_AT = 1;
    
    cd(dirOut)
    
    allData = dir(identifier);
    exDate = 'start';
    
    for i = START_AT:length(allData)
        dirName = allData(i).name;
        disp(['Openning experiment: ', dirName])
        load(dirName);
        data = [];
        
        if ANALYZE_IND ==0 && contains(info.date, exDate)
            info.noiseChannels = noiseChannels
            save(dirName, 'info', '-append')
            
        else
            clear noiseChannels
            data = dataSnippits;
            if size(dataSnippits, 2) < numbOfSamp
                data = [];
            end
            
            if isempty(data)
                disp(['This experiment has less than ', num2str(numbOfSamp), ' trials'])
                continue
            end
            
            upperBound = max(data(:));
            lowerBound = min(data(:));
            noiseChannelsManual = examChannelSnippits(data, finalTime, numbOfSamp, upperBound, lowerBound);
            noiseChannels = unique([info.noiseChannels, noiseChannelsManual']);
            prompt = ['NoiseChannels =', mat2str(noiseChannels), ' Enter other bad channels, if there are none, put []'];
            exNoise = input(prompt);
            noiseChannels = sort([noiseChannels', exNoise]);
            
            info.noiseChannels = noiseChannels;
            
            save(dirName, 'info', '-append')
            info
            exDate = info.date(6:end);
        end
    end
end

%% Removing artifact region in LFP singal and interpolating over signal

if REMOVE_STIM_ARTIFACT == 1
    for experiment = 1:length(allData)
        load(allData(experiment).name, 'dataSnippits')
        
        data = dataSnippits;
        
        artifactRegion = 1000:1015;
        bufferPoints = [artifactRegion(1)-10:artifactRegion(1), artifactRegion(end):artifactRegion(end)+10];
        data(:,:,artifactRegion) = [];
        
        time1 = [1:999, 1016:3001];
        time2 = 1:size(dataSnippits,3);
        
        for i = 1:size(data, 1)
            for j = 1:size(data,2)
                dataSnippits(i,j,:) = interp1(time1, squeeze(data(i, j, :)), time2, 'spline');
            end
        end
        save(allData(experiment).name, 'dataSnippits', '-append')
    end
end

%% Creating big ass matrix

cd(dirIn)
allData = dir(identifier);
electStim = 0; %0 if sensory, 1 if electrical

creatingBigAssMatrix


%% Adding Unique Series and Index Series to plexon data 
allData = dir(identifier);

uniqueSeries = stimIndex;

for experiment = 1:length(allData)
    load(allData(experiment).name, 'dataSnippits', 'info')
    indexSeries = ones(size(dataSnippits,2), 1);
    save(allData(experiment).name, 'uniqueSeries', 'indexSeries', 'info', '-append')
end

%% Adding unique series id to info files and big ass matrix

cd(dirIn)
allData = dir(identifier);
load('dataMatrixFlashes.mat');

for experiment = 1:length(allData)
    load(allData(experiment).name, 'info', 'uniqueSeries', 'indexSeries')
    y =  mode(indexSeries);
    info.stimIndex = uniqueSeries(y,:);
    dataMatrixFlashes(experiment).stimIndex = info.stimIndex;
    save(allData(experiment).name, 'info', '-append')
end

save('dataMatrixFlashes.mat', 'dataMatrixFlashes')

%% Creating stimIndexMatrix

cd(dirIn)
load('dataMatrixFlashes.mat')

if isfield(dataMatrixFlashes, 'numberStim')
    numStim = unique([dataMatrixFlashes.numberStim]);
    if numel(numStim) > 1
        disp('There is at least one file that does not have the same stimulation paradigm as the others. This may be a mistake in info file and dataMatrixFlashes generation');
    elseif numel(numStim) == 0
        disp('You have recorded that there are no stimuli in this file; will treat as baseline measurement.');
    else
        if numStim ==1
            numStim = 2;
        end
        matStimIndex = (reshape([dataMatrixFlashes.stimIndex], [numStim, size(dataMatrixFlashes,2)]))';
        matStimIndex = unique(matStimIndex, 'rows');
    end
else 
    disp('You have recorded that there are no stimuli in this file; will treat as baseline measurement.');
end

if exist('matStimIndex')
    save([dirIn, 'matStimIndex.mat'], 'matStimIndex')
end

%% Clean data, mean subtract make average pictures

close all

START_AT = 1;

flashOn = [0,0];
before = 1;
after = 2;
markTime = -before:.1:after;
screensize=get(groot, 'Screensize');

if ~exist('dirPic')
    mkdir(dirPic)
end

cd(dirIn)
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
    
    for n = 1:length(noiseChannels)
        if isempty(noiseChannels)
            continue
        end
        cleanedData(noiseChannels(n), :, :) = NaN(size(dataSnippits,2), size(dataSnippits, 3));
        cleanedFullTrace(noiseChannels(n), :) = NaN(1, size(LFPData, 2));
    end
    
    % to mean subtract ecog data only
    if ~isnan(info.ecogChannels)
        eCoGMean = nanmean(cleanedData(info.ecogChannels,:, :),1);
        LFPeCoGMean = nanmean(cleanedFullTrace(info.ecogChannels, :),1);
        
        meanSubData(info.ecogChannels,:,:) = cleanedData(info.ecogChannels,:,:) - repmat(eCoGMean, [size(info.ecogChannels,2), 1, 1]);
        meanSubFullTrace(info.ecogChannels,:) = cleanedFullTrace(info.ecogChannels,:) - repmat(LFPeCoGMean, [size(info.ecogChannels,2), 1]);
    end
    % to mean subtract shanks data only
    if ~isnan(info.forkChannels)
        for f = 1:size(info.forkChannels,1)
            forkMean = nanmean(cleanedData(info.forkChannels(f,:),:, :),1);
            LFPforkMean = nanmean(cleanedFullTrace(info.forkChannels(f,:), :),1);
            
            meanSubData(info.forkChannels(f,:),:,:) = cleanedData(info.forkChannels(f,:),:,:) - repmat(forkMean, [size(info.forkChannels(f,:),2), 1, 1]);
            meanSubFullTrace(info.forkChannels(f,:),:) = cleanedFullTrace(info.forkChannels(f,:),:) - repmat(LFPforkMean, [size(info.forkChannels(f,:),2), 1]);
        end
    end
    
    aveTrace = nan(size(uniqueSeries, 1), size(meanSubData,1), size(meanSubData,3));
    standError = nan(size(uniqueSeries, 1), size(meanSubData,1), size(meanSubData,3));
    
    for i = 1:size(uniqueSeries, 1)
        [indices] = getStimIndices(uniqueSeries(i,:), indexSeries, uniqueSeries);
        useMeanSubData = meanSubData(:,indices,:);
        parfor ch = 1:size(useMeanSubData,1)
            aveTrace(i, ch, :) = squeeze(nanmean(useMeanSubData(ch,:,:), 2));
            standError(i, ch,:) = squeeze(nanstd(useMeanSubData(ch,:,:), 1, 2)/sqrt(size(useMeanSubData(ch,:,:), 2)));
            
            %lowerCIBound(i, ch,:) = squeeze(quantile(meanSubData(ch,:,:), 0.05, 2));
            %upperCIBound(i, ch,:) =  squeeze(quantile(meanSubData(ch,:,:), 0.95, 2));
        end
    end
    
    if exist('allStartTimes')
        if iscell(allStartTimes) && length(allStartTimes) ==1
            allStartTimes = allStartTimes{1};
        end
            
        info.startOffSet = round(finalSampR*(allStartTimes(1)-before));
        info.endOffSet = round(finalSampR*(allStartTimes(end)+after));
    end
    
    save([dirIn, dirName], 'cleanedData', 'meanSubFullTrace', 'meanSubData', 'aveTrace', 'standError', 'info',  '-append')
    %save([dirIn, dirName], 'cleanedData', 'meanSubFullTrace' 'meanSubData', 'aveTrace', 'standError', 'info', 'dataSnippits','finalTime', 'finalSampR', 'LFPData', 'eventTimes', 'fullTraceTime','plexInfoStuffs','uniqueSeries', 'indexSeries')
    
    % making images
    for stimIndexLoop= 1:size(uniqueSeries, 1)
        strStimInd = uniqueSeries(stimIndexLoop,:);
        [stimIndexSeriesString] = stimIndex2string4saving(strStimInd, finalSampR);
        
        %Single trial images
        [indices] = getStimIndices(uniqueSeries(stimIndexLoop,:), indexSeries, uniqueSeries);
        useMeanSubData = meanSubData(:,indices,:); 
        
        [currentFig] = plotSingleTrials(useMeanSubData, finalTime, info);
        suptitle(['Single trials, Experiment ', num2str(info.exp), ', ', info.TypeOfTrial, ', Drug: ',  info.AnesType, ', Conc: ', num2str(info.AnesLevel), ', Series ', strrep(stimIndexSeriesString, '_', '\_')]);
        if PicByTrialType ==1
            saveas(currentFig, [dirPic, info.expName(1:end-4), '_', info.TypeOfTrial, stimIndexSeriesString, '_singletrials.png'])
        elseif PicByAnesType ==1
            saveas(currentFig, [dirPic, info.expName(1:end-4), '_', info.AnesType, stimIndexSeriesString, '_singletrials.png'])
        elseif PicByAnesAndTrial ==1
            saveas(currentFig, [dirPic, info.expName(1:end-4), '_', info.TypeOfTrial, info.AnesType, StimIndexSeriesString, '_singletrials.png'])
        end

        close all;
        
        % Plot on onset of latency on averages        
        [currentFig] = plotAverages(squeeze(aveTrace(stimIndexLoop,:,:)), finalTime, info, [], [], [],[], before, after, flashOn, finalSampR);
        suptitle(['Average, Experiment ', num2str(info.exp), ',  Drug: ', info.AnesType, ', Conc: ', num2str(info.AnesLevel), ', Series ', strrep(stimIndexSeriesString, '_', '\_')])
        if PicByTrialType ==1
            saveas(currentFig, [dirPic, info.expName(1:end-4), '_', info.TypeOfTrial, stimIndexSeriesString, '_ave.png'])
        elseif PicByAnesType ==1
            saveas(currentFig, [dirPic, info.expName(1:end-4), '_', info.AnesType, stimIndexSeriesString, '_ave.png'])
        elseif PicByAnesAndTrial ==1
            saveas(currentFig, [dirPic, info.expName(1:end-4), '_', info.TypeOfTrial, info.AnesType, StimIndexSeriesString, '_ave.png'])
        end
   
        close all
    end
end


