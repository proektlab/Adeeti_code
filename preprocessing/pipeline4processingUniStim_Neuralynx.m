%% Preprocessing code

%% Making snippits for each experiment

dirIn = '/data/adeeti/ecog/rawPropFlashes2018/';
dirOut1 = '/data/adeeti/ecog/matPropFlashes2018/';

identifier = '2018-06*';
START_AT= 1;

mkdir(dirOut1)

cd(dirIn)
allData = dir(identifier);

before = 1;
l = 3;

loadingWindow = waitbar(0, 'Converting data...');
totalExp = length(allData);

for exp = START_AT:length(allData)
    
    cd([dirIn, allData(exp).name])
    load('Events.mat')
    
    if unique(eveID) == 0
        continue
    end
    
    % Extract segments of data and save
    
    disp(['Starting file ', allData(exp).name])
    [dataSnippits, ~, ogTime, finalTime, finalSampR] = extractSnippets_Neuralynx(eveTime(find(eveID == eveID(find(eveID~=0,1, 'first')))), before, l);
    

    save([dirOut1, allData(exp).name, '.mat'], 'dataSnippits', 'finalTime', 'finalSampR')

    
    clearvars -except allData before l flashOn markTime screensize exp totalExp dirIn dirOut1 dirOut2 dirPic
    loadingWindow = waitbar(exp/totalExp);
end

close(loadingWindow);

%% Making info files

cd(dirOut1)
identifier = '2018-01-22*';
allData = dir(identifier);

for i = 1:length(allData)
    dirName = allData(i).name;
    load(dirName, 'dataSnippits');
    info = [];
    info.TypeOfTrial = 'flashes';
    info.AnesType = 'iso';
    info.AnesLevel = 1;
    info.LengthPulse = 0.1; %in msec
    info.IntensityPulse = 5;
    info.NumberPulses = 1;
    info.InterTrainPulseInterval = NaN;
    info.TimeBtwnPulses = 3200;
    
    info.trials = size(dataSnippits, 2);
    info.channels = size(dataSnippits, 1);
    info.expName = dirName(1:end-4);
    info.date = dirName(1:10);
    info.exp = 2;
    info.gridIndicies = [[ 37    49     0     0     1    21];... %this is 2018 config - look in addGridInd2allInfo.m for 2017 config
    [38    50    60    12     2    22];...
    [39    51    61    13     3    23];...
    [40    52    62    14     4    24];...
    [41    53    63    15     5    25];...
    [42    54    64    16     6    26];...
    [43    48    59    11    32    27];...
    [36    47    58    10    31    20];...
    [35    46    57     9    30    19];...
    [34    45    56     8    29    18];...
    [33    44    55     7    28    17]];
    % info.V1 = 27; %V1 or stim site
    % info.noiseChannels = noiseChannels; %vector with the number of channels that are noise free
    %info.polarity = 'pos';
    save(dirName, 'info', '-append')
end

%% Finding noise Channels

numbOfSamp = 8;
identifier = '2018-01*';

cd(dirOut1)

allData = dir(identifier);
date = 'start';

for experiment = 1:length(allData)
   dirName = allData(experiment).name;
    load(dirName, 'dataSnippits', 'finalTime', 'info');
    
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
end

%% Clean data, mean subtract make average pictures 

close all
dirPic = '/data/adeeti/ecog/images/2018IsoFlashes/preProcessing/';
dirOut = dirOut1;

identifier = '2018-01*.mat';
START_AT = 1;

flashOn = [0,0];
before = 1;
after = 2;
markTime = -before:.1:after;
screensize=get(groot, 'Screensize');

mkdir(dirPic)

cd(dirOut)
allData = dir(identifier);

loadingWindow = waitbar(0, 'Converting data...');
totalExp = length(allData);

for exp = START_AT:length(allData)
    
    dirName = allData(exp).name;
    load(dirName, 'info', 'finalTime', 'dataSnippits')
    disp(['Converting data ', allData(exp).name])
    
    % Cleaning data and subtracting the mean
    
    noiseChannels = info.noiseChannels;
    cleanedData = dataSnippits;
    
    for n = 1:length(noiseChannels)
        if isempty(noiseChannels)
            continue
        end
        cleanedData(noiseChannels(n), :, :) = NaN(size(dataSnippits,2), size(dataSnippits, 3));
    end
    
    meanSubData = cleanedData - repmat(nanmean(cleanedData,1), [size(cleanedData,1), 1, 1]);
    
    parfor ch = 1:size(meanSubData,1)
        aveTrace(ch, :) = squeeze(nanmean(meanSubData(ch,:,:), 2));
 
        standError(ch,:) = squeeze(nanstd(meanSubData(ch,:,:), 1, 2)/sqrt(size(meanSubData(ch,:,:), 2)));
        
        lowerCIBound(ch,:) = squeeze(quantile(meanSubData(ch,:,:), 0.05, 2));
        upperCIBound(ch,:) =  squeeze(quantile(meanSubData(ch,:,:), 0.95, 2));
    end
    
    save([dirOut, dirName], 'cleanedData', 'meanSubData', 'aveTrace', 'standError', 'lowerCIBound', 'upperCIBound','-append')
      
    % Single trial images
    
    [currentFig] = plotSingleTrials(meanSubData, finalTime, info);

    saveas(currentFig, [dirPic, dirName, 'singletrials.png'])
    close all;
    
    % Flash triggered average images
    
    [currentFig] = plotAverages(aveTrace, finalTime, info, [], [], [],  before, after, flashOn);
    
    saveas(currentFig, [dirPic, allData(exp).name, 'average.png'])
    close all;
    waitbar(exp/totalExp)
end

close(loadingWindow);
