% Preprocessing code

% Making snippits for each experiment
clear
clc

%% Making info files

driveLocation = '/home/adeeti/googleDrive/NEURA_codeShare/Adeeti_code/';
%dropboxLocation = '/data/adeeti/Dropbox/';  %'/data/adeeti/Dropbox/'; %dropbox location for excel file and saving

excelFileName = 'preprocessing/testing_Viv_Neurogrid_ECOG.xlsx';
CSDWITHGRID = 0; %if one, will add fork indicies and mapping, if 0, will add nans in the fields
excelSheet = 1;

[num, text, raw] = xlsread([driveLocation, excelFileName], excelSheet); %reads excel sheet

dirIn =  'D:\Brenna\Rats\2019-03-07\matlab\';

cd(dirIn)
identifier = '*.mat';
allData = dir(identifier);

for experiment = 1:length(allData)
    dirName = allData(experiment).name;
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
        info.noiseChannels = [];
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
    
    if raw{rowInd,9} >= 2
        info.Stim2 = raw{rowInd,19+modCounter};
        info.Stim2ID= raw{rowInd,20+modCounter};
        info.LengthStim2 = raw{rowInd,21+modCounter};
        info.IntensityStim2 = raw{rowInd,22+modCounter};
        modCounter = modCounter + 4;
    end
    
    if raw{rowInd,9} >= 3
        info.Stim3 = raw{rowInd,19+modCounter};
        info.Stim3ID= raw{rowInd,20+modCounter};
        info.LengthStim3 = raw{rowInd,21+modCounter};
        info.IntensityStim3 = raw{rowInd,22+modCounter};
        modCounter = modCounter + 4;
    end
    
    if raw{rowInd,9} >= 3
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
    
    
    NNShank2 = [9 8 10 7 11 6 12 5 13 4 14 3 15 2 16 1];
    NNShank1 = NNShank2+16;
    NNChannels = [NNShank1;NNShank2];
    [ADChannels] = convertNNchan2PlexADChanAcute32_Plexon(NNChannels);
    if CSDWITHGRID == 1
        info.forkIndicies = (ADChannels+64)'; %anterior shank is in column 1
    else
        forkIndicies = [];
    end
    
    %info.noiseChannels = [38, 61];
    % info.V1 = 27; %V1 or stim site
    % info.noiseChannels = noiseChannels; %vector with the number of channels that are noise free
    %info.polarity = 'pos';
    save(dirName, 'info', '-append')
end

%% Finding noise Channels

dirIn =  '/data/adeeti/ecog/testing_Viv_Neurogrid_ECOG/';

numbOfSamp = 8;
identifier = '2019*.mat';
START_AT = 8;

sameNoiseChanOnDay = 0; %if 1, will apply the same noise channels to all recordings on the same date, 0 will assume that all recordings are seperate

cd(dirIn)

allData = dir(identifier);
date = 'start';

for experiment = START_AT:length(allData)
    dirName = allData(experiment).name;
    load(dirName, 'dataSnippits', 'finalTime', 'info');
    
    if sameNoiseChanOnDay ==1
        if strcmpi(info.date, date)
            info.noiseChannels = noiseChannels;
            save(dirName, 'info', '-append')
        else
            data = dataSnippits;
            upperBound = max(data(:));
            lowerBound = min(data(:));
            noiseChannelsManual = examChannelSnippits(data, finalTime, numbOfSamp, upperBound, lowerBound);
            nC = info.noiseChannels;
            if ~iscolumn(nC)
                nC = nC';
            end
            if ~iscolumn(noiseChannelsManual)
                noiseChannelsManual = noiseChannelsManual';
            end
            noiseChannels = unique([nC; noiseChannelsManual]);
            prompt = ['NoiseChannels =', mat2str(noiseChannels), ' Enter other bad channels, if there are none, put []'];
            exNoise = input(prompt);
            noiseChannels = sort([noiseChannels', exNoise]);
            
            info.noiseChannels = noiseChannels;
            save(dirName, 'info', '-append')
            date = info.date;
        end
    else
        data = dataSnippits;
        upperBound = max(data(:));
        lowerBound = min(data(:));
        noiseChannelsManual = examChannelSnippits(data, finalTime, numbOfSamp, upperBound, lowerBound);
        nC = info.noiseChannels;
        if ~iscolumn(nC)
            nC = nC';
        end
        if ~iscolumn(noiseChannelsManual)
            noiseChannelsManual = noiseChannelsManual';
        end
        noiseChannels = unique([nC; noiseChannelsManual]);
        prompt = ['NoiseChannels =', mat2str(noiseChannels), ' Enter other bad channels, if there are none, put []'];
        exNoise = input(prompt);
        noiseChannels = sort([noiseChannels', exNoise]);
        
        info.noiseChannels = noiseChannels;
        save(dirName, 'info', '-append')
        date = info.date;
    end
    
end

%% Removing artifact region in LFP singal and interpolating over signal

dirIn =  '/data/adeeti/ecog/testing_Viv_Neurogrid_ECOG/';
%dirIn = '/Users/adeetiaggarwal/Google Drive/NEURA_codeShare/Adeeti_code/1x2Shank_with_ECoG/'
cd(dirIn)
allData = dir('2019*.mat');

for experiment = 1:5%length(allData)
    load(allData(experiment).name, 'dataSnippits');
    
    data = dataSnippits;
    
    artifactRegion = 1000:1015;
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

%% Creating big ass matrix

dirIn =  '/data/adeeti/ecog/testing_Viv_Neurogrid_ECOG/';
cd(dirIn)
allData = dir('*2019*.mat');
electStim = 0; %0 if sensory, 1 if electrical

creatingBigAssMatrix

%% Adding Unique Series and Index Series to plexon data

clear
close all

dirIn = '/data/adeeti/ecog/testing_Viv_Neurogrid_ECOG/';
cd(dirIn)

identifier = '2019*.mat';
allData = dir(identifier);

uniqueSeries = [0,inf];

for experiment = 1:length(allData)
    load(allData(experiment).name, 'dataSnippits', 'info')
    data = dataSnippits;
    uniqueSeries = stimIndex;
    indexSeries = ones(size(dataSnippits,2), 1);
    if size(dataSnippits,2)>100
        indexSeries(1) =2;
        uniqueSeries(2,:) = [Inf, Inf];
    end
    save(allData(experiment).name, 'uniqueSeries', 'indexSeries', 'info', '-append')
end

%% Adding unique series id to info files and big ass matrix

dirIn =   '/data/adeeti/ecog/testing_Viv_Neurogrid_ECOG/';
cd(dirIn)
allData = dir('*2.mat');
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
dirIn =  '/data/adeeti/ecog/testing_Viv_Neurogrid_ECOG/';
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
%dirPic = '/data/adeeti/ecog/flashes_depth_1x2Shank_ECoG_2018/';
%dirIn = '/data/adeeti/ecog/flashes_depth_ECoG_2018/1x2Shank_with_ECoG/';

identifier = '2019*.mat';
START_AT = 1;
CSDWITHGRID = 0; %if one, will add fork indicies and mapping, if 0, will add nans in the fields

flashOn = [0,0];
before = 1;
after = 2;
markTime = -before:.1:after;
screensize=get(groot, 'Screensize');

if exist('dirPic')
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
    eCoGMean = nanmean(cleanedData(info.ecogChannels,:, :),1);
    LFPeCoGMean = nanmean(cleanedFullTrace(info.ecogChannels, :),1);
    
    meanSubData(info.ecogChannels,:,:) = cleanedData(info.ecogChannels,:,:) - repmat(eCoGMean, [size(info.ecogChannels,2), 1, 1]);
    meanSubFullTrace(info.ecogChannels,:) = cleanedFullTrace(info.ecogChannels,:) - repmat(LFPeCoGMean, [size(info.ecogChannels,2), 1]);
    
    % to mean subtract shanks data only
    if CSDWITHGRID ==1
        for f = 1:size(info.forkChannels,1)
            forkMean = nanmean(cleanedData(info.forkChannels(f,:),:, :),1);
            LFPforkMean = nanmean(cleanedFullTrace(info.forkChannels(f,:), :),1);
            
            meanSubData(info.forkChannels(f,:),:,:) = cleanedData(info.forkChannels(f,:),:,:) - repmat(forkMean, [size(info.forkChannels(f,:),2), 1, 1]);
            meanSubFullTrace(info.forkChannels(f,:),:) = cleanedFullTrace(info.forkChannels(f,:),:) - repmat(LFPforkMean, [size(info.forkChannels(f,:),2), 1]);
        end
    end
    
    %meanSubData = cleanedData - repmat(nanmean(cleanedData,1), [size(cleanedData,1), 1, 1]);
    aveTrace = nan(size(uniqueSeries, 1), size(meanSubData,1), size(meanSubData,3));
    standError = nan(size(uniqueSeries, 1), size(meanSubData,1), size(meanSubData,3));
    
    for i = 1:size(uniqueSeries, 1)
        [indices] = getStimIndices(uniqueSeries(i,:), indexSeries, uniqueSeries);
        useMeanSubData = meanSubData(:,indices,:);
        parfor ch = 1:size(meanSubData,1)
            aveTrace(i, ch, :) = squeeze(nanmean(meanSubData(ch,:,:), 2));
            
            standError(i, ch,:) = squeeze(nanstd(meanSubData(ch,:,:), 1, 2)/sqrt(size(meanSubData(ch,:,:), 2)));
            
            %lowerCIBound(i, ch,:) = squeeze(quantile(meanSubData(ch,:,:), 0.05, 2));
            %upperCIBound(i, ch,:) =  squeeze(quantile(meanSubData(ch,:,:), 0.95, 2));
        end
    end
    
    info.startOffSet = round(finalSampR*(allStartTimes{1}(1)-before));
    info.endOffSet = round(finalSampR*(allStartTimes{1}(end)+after));
    
    save([dirIn, dirName], 'cleanedData', 'meanSubFullTrace', 'meanSubData', 'aveTrace', 'standError', 'info',  '-append')
    %save([dirIn, dirName], 'cleanedData', 'meanSubFullTrace' 'meanSubData', 'aveTrace', 'standError', 'info', 'dataSnippits','finalTime', 'finalSampR', 'LFPData', 'eventTimes', 'fullTraceTime','plexInfoStuffs','uniqueSeries', 'indexSeries')
    
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



