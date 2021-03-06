%% Processing for Open-Ephys code MultiStim Preprocessing code
% 08/07/18 AA editted to make it compatible with multistim data 

clear
clc

dirIn = '/data/adeeti/ecog/2019-07-12/';
dirOut1 = '/data/adeeti/ecog/mat_OpenEphys_WhiskerTesting/';

identifier = '2019*';
START_AT= 1; % starting experiment
excelSheet = 1; % sheet in the excel file that has the information
finalSampR = 1000; %in Hz

mkdir(dirOut1);
cd(dirIn)
allData = dir(identifier);

dropboxLocation = '/data/adeeti/Dropbox/'; 
%dropboxLocation= '/Users/adeetiaggarwal/Dropbox/'; %dropbox location for excel file and saving

% loading excel sheet for info data

excelFileName = 'KelzLab/ECogJunk/preprocessing/WhiskerTesting.xlsx';

[num, ~, raw] = xlsread([dropboxLocation, excelFileName], excelSheet); %reads excel sheet

%%

loadingWindow = waitbar(0, 'Converting data...');
totalExp = length(allData);

for experiment = START_AT:length(allData)
    dirName = allData(experiment).name;
    rowInd = experiment+1;
    info = [];
    info.AnesType = raw{rowInd, 2};
    info.AnesLevel = raw{rowInd,3};
    info.TypeOfTrial = raw{rowInd, 4};
    
    info.expName = dirName;
    info.date = dirName(1:10);
    info.channels = raw{rowInd,5};
    info.notes = raw{rowInd, 6};
    noiseChannels = raw{rowInd,7};
    
    if ~(isnan(noiseChannels))
        info.noiseChannels = str2num(raw{rowInd,7});
    else
        info.noiseChannels = noiseChannels;
    end
    
    info.exp = raw{rowInd,8};
    info.interPulseInterval = raw{rowInd,10};
    info.interStimInterval = raw{rowInd, 11};
    info.bregmaOffsetX = raw{rowInd, 12};
    info.bregmaOffsetY = raw{rowInd, 13};
    
    gridPresent = raw{rowInd, 14};
    if ~(isnan(gridPresent))
        info.ecogGridName = raw{rowInd, 14};
        info.ecogChannels = str2num(raw{rowInd, 15});
    else
        info.ecogGridName = raw{rowInd, 14};
        info.ecogChannels = raw{rowInd, 15};
    end
    
    
    forkPresent = raw{rowInd, 16};
    if ~(isnan(forkPresent))
        info.forkName = raw{rowInd, 16};
        info.forkPosition = str2num(raw{rowInd, 17});
        info.forkChannels = str2num(raw{rowInd, 18});
    else
        info.forkName = raw{rowInd, 16};
        info.forkPosition = raw{rowInd, 17};
        info.forkChannels = raw{rowInd, 18};
    end
    
    if ischar(info.interStimInterval)
        info.interStimInterval = NaN;
    end
    info.numberStim = raw{rowInd,9};
    
    info.gridIndicies = [[17    28     7    55    44    33];...
        [18    29     8    56    45    34];...
        [19    30     9    57    46    35];...
        [20    31    10    58    47    36];...
        [27    32    11    59    48    43];...
        [26     6    16    64    54    42];...
        [25     5    15    63    53    41];...
        [24     4    14    62    52    40];...
        [23     3    13    61    51    39];...
        [22     2    12    60    50    38];...
        [21     1     0     0    49    37]];
    
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
    
    
    save([dirOut1, dirName], 'info')
    clearvars -except allData exp totalExp dirIn dirOut1 raw num START_AT experiment
    loadingWindow = waitbar(experiment/totalExp);
    
end
close(loadingWindow);


%% Extract ontimes for all trials

dirIn = '/data/adeeti/ecog/2019-07-12/';
dirOut1 = '/data/adeeti/ecog/mat_OpenEphys_WhiskerTesting/';

identifier = '2019*';
START_AT= 2; % starting experiment

before = 1;
l = 3;
finalSampR= 1000;
Fs = 30000;
startBaseline = 0;

cd(dirIn)
allData = dir(identifier);
loadingWindow = waitbar(0, 'Converting data...');
totalExp = length(allData);

for experiment = START_AT:length(allData)
    dirName = allData(experiment).name;
    load([dirOut1, dirName, '.mat'], 'info');
    
    cd([dirIn, allData(experiment).name])
    load('events.mat')
    
%     if unique(eveID) == 0
%         continue
%     end
    
    stimIDs = [];
    i = 1;
    while i <= info.numberStim
        eval(['stimIDs = [ stimIDs, info.Stim', num2str(i), 'ID];'])
        i = i +1;
    end
    %stimIDs = [1, 2];
    
    interPulseInterval = info.interPulseInterval/finalSampR;
    %interPulseInterval = 3;
    
    % Extract ontimes for all trials
    
    disp(['Starting file ', allData(experiment).name])
    
    %[allStimStarts, allStartTimes, stimOffSet, uniqueSeries, indexSeries] = findAllStartsAndSeries_Neuralynx(eveID, eveTime, stimIDs, interPulseInterval, l-before);

    [dataSnippits, finalTime] = extractSnippets_OpenEphys(startTTL, before, l, Fs, finalSampR, startBaseline);
    
    [LFPData, fullTraceTime] = extractLFPTrace_OpenEphys(Fs, finalSampR);
%     [uniStimStarts, multiStimStarts, multiStimIDs] = breakIntoUniAndMultiStarts(allStartTimes, uniqueSeries, indexSeries, stimIDs);
%     
%     uniSnippits = {};
%     for i = 1:size(uniStimStarts,2)
%         onTime = uniStimStarts{:,i};
%         uniSnippits{i} = [];
%         dataSnippits = [];
%         if isempty(onTime)
%             continue
%         end
%         [dataSnippits, ~, ~, finalTime, ~] = extractSnippets(onTime, before, l, finalSampR, startBaseline);
%         uniSnippits{i} = dataSnippits;
%     end
%     
%     multiSnippits = {};
%     for i = 1:size(multiStimStarts,2)
%         onTime = multiStimStarts{:,i};
%         multiSnippits{i} = [];
%         dataSnippits = [];
%         if isempty(onTime)
%             continue
%         end
%         [dataSnippits, ~, ~, finalTime, ~] = extractSnippets(onTime, before, l, finalSampR, startBaseline);
%         multiSnippits{i} = dataSnippits;
%     end
    
    info.numTrials = size(dataSnippits,2);
    save([dirOut1, allData(experiment).name, '.mat'], 'dataSnippits', 'LFPData', 'fullTraceTime', 'finalTime', 'finalSampR', 'startTTL', 'info', '-append')
    
    clearvars -except allData totalExp dirIn dirOut1 before l finalSampR startBaseline experiment Fs
    loadingWindow = waitbar(experiment/totalExp);
end

close(loadingWindow);

%% Finding noise Channels

dirOut1 = '/data/adeeti/ecog/mat_OpenEphys_WhiskerTesting/';
numbOfSamp = 8;
identifier = '2019*';
START_AT = 2;
ANALYZE_IND = 1;

cd(dirOut1)

allData = dir(identifier);
exDate = 'start';

for i = START_AT:length(allData)
    dirName = allData(i).name;
    disp(['Openning experiment: ', dirName])
    load(dirName);
    data = [];
    
    if ANALYZE_IND ==0 && contains(info.date, exDate)
        info.noiseChannels = noiseChannels;
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

%% Creating big ass matrix

dirIn =  '/data/adeeti/ecog/mat_OpenEphys_WhiskerTesting/';
cd(dirIn)
allData = dir('2019*mat');
electStim = 0; %0 if sensory, 1 if electrical

creatingBigAssMatrix

%% Adding unique series id to info files and big ass matrix

dirIn =  '/data/adeeti/ecog/mat_OpenEphys_WhiskerTesting/';
cd(dirIn)

identifier = '2019*.mat';

allData = dir(identifier);
load('dataMatrixFlashes.mat');

uniqueSeries = [0,inf];


for i = 1:length(allData)
    load(allData(i).name, 'info', 'dataSnippits', 'info')
    indexSeries = ones(size(dataSnippits,2), 1);
    y =  mode(indexSeries);
    info.stimIndex = uniqueSeries(y,:);
    dataMatrixFlashes(i).stimIndex = info.stimIndex;
    save(allData(i).name, 'uniqueSeries', 'indexSeries', 'info', '-append')
end

save('dataMatrixFlashes.mat', 'dataMatrixFlashes')

%% Creating stimIndexMatrix
dirIn =  '/data/adeeti/ecog/mat_OpenEphys_WhiskerTesting/';
cd(dirIn)

load('dataMatrixFlashes.mat')

if isfield(dataMatrixFlashes, 'numberStim')
    numStim = unique([dataMatrixFlashes.numberStim]);
    if numel(numStim) > 1
        disp('There is at least one file that does not have the same stimulation paradigm as the others. This may be a mistake in info file and dataMatrixFlashes generation');
    elseif numel(numStim) == 0
        disp('You have recorded that there are no stimuli in this file; will treat as baseline measurement.');
    else
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
clear

dirOut1 = '/data/adeeti/ecog/mat_OpenEphys_WhiskerTesting/';
dirPic = '/data/adeeti/ecog/images/mat_OpenEphys_WhiskerTesting/preProcessing/';

identifier = '2019*.mat';
START_AT = 1;

flashOn = [0,0];
before = 1;
after = 2;
markTime = -before:.1:after;
screensize=get(groot, 'Screensize');

mkdir(dirPic)

cd(dirOut1)
allData = dir(identifier);

loadingWindow = waitbar(0, 'Converting data...');
totalExp = length(allData);

for experiment = START_AT:length(allData)
    
    dirName = allData(experiment).name;
    load(dirName, 'info', 'dataSnippits', 'finalTime', 'finalSampR', 'indexSeries', 'uniqueSeries')
    %load(dirName, 'info', 'meanSubData', 'indexSeries', 'uniqueSeries', 'aveTrace', 'standError')
    disp(['Converting data ', allData(experiment).name])
    
    aveTrace = [];
    standError = [];
    
    % Cleaning data and subtracting the mean
    
    noiseChannels = info.noiseChannels;
    
    cleaned = [];
    cleaned = dataSnippits;
    for n = 1:length(noiseChannels)
        if isempty(noiseChannels)
            continue
        end
        cleaned(noiseChannels(n), :, :) = NaN(size(dataSnippits,2), size(dataSnippits, 3));
    end
    meanSubData = cleaned - repmat(nanmean(cleaned,1), [size(cleaned,1), 1, 1]);
    
    for i = 1:size(uniqueSeries, 1)
        
    [indices] = getStimIndices(uniqueSeries(i,:), indexSeries, uniqueSeries);
    useMeanSubData = meanSubData(:,indices,:);
    
        parfor ch = 1:size(useMeanSubData,1)
            aveTrace(i, ch, :) = squeeze(nanmean(useMeanSubData(ch,:,:), 2)); %aveTrace and standardError matrixes are in the same indexing order as unique Series 
            standError(i, ch,:) = squeeze(nanstd(useMeanSubData(ch,:,:), 1, 2)/sqrt(size(useMeanSubData(ch,:,:), 2)));
            %lower1CIBound(ch,:) = squeeze(quantile(meanSubUni{u}(ch,:,:), 0.05, 2));
            %upper1CIBound(ch,:) =  squeeze(quantile(meanSubUni{u}(ch,:,:), 0.95, 2));
        end
        save([dirOut1, dirName], 'meanSubData', 'aveTrace', 'standError', '-append')
    end
    [currentFig] = plotAverages(squeeze(aveTrace(1,:,:)), finalTime, info, [], [], [], [],  before, after, flashOn, finalSampR);
    saveas(currentFig, [dirPic, allData(experiment).name, 'average.png'])
    
    waitbar(experiment/totalExp)
end

close(loadingWindow);
