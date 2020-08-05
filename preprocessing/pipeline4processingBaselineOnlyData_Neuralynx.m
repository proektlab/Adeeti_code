%% MultiStim Preprocessing code
% for data that only has baseline and no events- if want to extract trace
% with events, use pipeline4preprocessingFullTrace_Neuralynx.m - this will
% allow you to properly align the trace with time stamps 

% 10/08/18 
%% Setting up
clear

%%%%% Code for loading in Prop States first

dirIn = '/data/adeeti/ecog/rawPropStates2018/';
dirOut1 = '/data/adeeti/ecog/matPropStates2018/';

identifier = '2018*';
START_AT= 10; % starting experiment
excelSheet = 2; % sheet in the excel file that has the information 
finalSampR = 1000; %in Hz

mkdir(dirOut1);
cd(dirIn)
allData = dir(identifier);

dropboxLocation = '/data/adeeti/Dropbox/';  %'/data/adeeti/Dropbox/'; %dropbox location for excel file and saving 

%% loading excel sheet for info data

excelFileName = 'KelzLab/ECogJunk/preprocessing/PropIsoExpJuneJuly2018.xlsx';

[num, text, raw] = xlsread([dropboxLocation, excelFileName], excelSheet); %reads excel sheet 


%% Making info files

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
    info.noiseChannels = str2num(raw{rowInd,7});
    info.exp = raw{rowInd,8};
    info.interPulseInterval = raw{rowInd,10};
    info.interStimInterval = raw{rowInd, 11};
    info.bregmaOffsetX = raw{rowInd, 12};
    info.bregmaOffsetY = raw{rowInd, 13};
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
    %save([dirOut1, allData(experiment).name, '.mat'], 'info', '-append')
    % Extract ontimes for all trials
    
    cd([dirIn, allData(experiment).name])
    disp(['Starting file ', allData(experiment).name])
    [dataSnippits, finalTime] = extractFullTrace_Neuralynx(finalSampR);
    
    save([dirOut1, allData(experiment).name, '.mat'], 'dataSnippits','finalTime', 'finalSampR', 'info')
    clearvars -except allData experiment totalExp dirIn dirOut1 finalSampR num text raw START_AT
    loadingWindow = waitbar(experiment/totalExp);
end

close(loadingWindow);



%% Finding noise Channels

dirOut1 = '/data/adeeti/ecog/matPropStates2018/';
numbOfSamp = 8;
identifier = '2018*';
START_AT= 10;

cd(dirOut1)

allData = dir(identifier);
date = 'start';

for i = START_AT:length(allData)
    dirName = allData(i).name;
    load(dirName, 'info', 'dataSnippits', 'finalTime');
    
    if strcmpi(info.date, date)
        info.noiseChannels = noiseChannels;
        save(dirName, 'info', '-append')
    else
        
    clearvars noiseChannels
    data = dataSnippits;
    
    upperBound = max(data(:));
    lowerBound = min(data(:));
    [ noiseChannelsManual ] = examChannelBaseline(dataSnippits, finalTime);
    noiseChannels = unique([info.noiseChannels, noiseChannelsManual']);
    prompt = ['NoiseChannels =', mat2str(noiseChannels), ' Enter other bad channels, if there are none, put []'];
    exNoise = input(prompt);
    noiseChannels = sort([noiseChannels, exNoise]);
    
    info.noiseChannels = noiseChannels;
    
    save(dirName, 'info', '-append')
   
    
    date = info.date;
    end
    %
end

%% Clean data, mean subtract make average pictures

close all
dirOut1 = '/data/adeeti/ecog/matPropStates2018/';
dirPic = '/data/adeeti/ecog/images/PropStates2018/preProcessing/';

identifier = '2018*.mat';
START_AT = 10;

screensize=get(groot, 'Screensize');

mkdir(dirPic)

cd(dirOut1)
allData = dir(identifier);

loadingWindow = waitbar(0, 'Converting data...');
totalExp = length(allData);

for experiment = START_AT:length(allData)
    
    dirName = allData(experiment).name;
    load(dirName)
    disp(['Converting data ', allData(experiment).name])
    
    % Cleaning data and subtracting the mean
    
    noiseChannels = info.noiseChannels;
    cleanedData = dataSnippits;
    fullTrace = dataSnippits;
    
    for n = 1:length(noiseChannels)
        if isempty(noiseChannels)
            continue
        end
        cleanedData(noiseChannels(n),:) = NaN(1, size(dataSnippits,2));
    end
    meanSubFullTrace= cleanedData - repmat(nanmean(cleanedData,1), [size(cleanedData,1), 1]);
    
    save([dirOut1, allData(experiment).name], 'meanSubFullTrace', 'cleanedData', 'fullTrace', '-append')
    
    % make picture of data
%     currentFig = figure('Position', screensize);
%     clf
%     imagesc(finalTime,1:size(meanSubFullTrace,1),squeeze(meanSubFullTrace))
%     ylabel('Channels')
%     xlabel('Time in seconds')
%     title(['Full Trace Propofol Concentration: ', num2str(info.AnesLevel)])
% 
%     saveas(currentFig, [dirPic, allData(experiment).name, 'imagescOfFullTrace.png'])
%     close all
    waitbar(experiment/totalExp)
end

close(loadingWindow);
