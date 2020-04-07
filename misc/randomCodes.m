%% Random Codes

%% Using EEG lab

% load('2017-03-01_16-11-50.mat')

data = meanSubData;

concatData = reshape(permute(data, [1 3 2]), 64, (size(data,2)*3001));
eegplot(concatData, 'srate', finalSampR)

%% Adding unique series id to info files and big ass matrix

dirIn =  '/data/adeeti/ecog/matIsoPropMultiStim/';
cd(dirIn)
allData = dir('2018*mat');
load('dataMatrixFlashes.mat');

for i = 1:length(allData)
    load(allData(i).name, 'info', 'uniqueSeries', 'indexSeries')
    y =  mode(indexSeries);
    info.stimIndex = uniqueSeries(y,:);
    dataMatrixFlashes(i).stimIndex = info.stimIndex;
    save(allData(i).name, 'info', '-append')
end

save('dataMatrixFlashes.mat', 'dataMatrixFlashes')

%% Making the Info files

    
info = [];
info.TypeOfTrial = 'flashes';
info.AnesType = 'propofol';
info.AnesLevel = 10;
info.LengthPulse = 100;
info.IntensityPulse = 10;
info.NumberPulses = 1;
info.InterTrainPulseInterval = NaN;
info.TimeBtwnPulses = 3000;
info.trials = size(meanSubData, 2);
info.channels = size(meanSubData, 1);
temp = dirName;
info.expName = temp(1:end-4);
info.date = '2017_02_22'
%info.goodChannels = goodChannels; %vector with the number of channels that are noise free

save([dirName '.mat'], 'info', '-append')

%% adding gridIndicies to info file s

clear
clc

dirOut1 = '/data/adeeti/ecog/matIsoPropMultiStim/';

identifier = '2018*';
START_AT= 1; % starting experiment

cd(dirOut1)
allData = dir(identifier);

for i = START_AT:length(allData)
    load(allData(i).name, 'info');
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
    
    save([dirOut1, allData(i).name], 'info', '-append')
    
end

%% adding X and Y offsets from bregma to info files

clear
clc

dirOut1 = '/data/adeeti/ecog/matIsoPropMultiStim/';

identifier = '2018*';
START_AT= 80; % starting experiment

cd(dirOut1)
allData = dir(identifier);

for i = START_AT:85
    load(allData(i).name, 'info');
    if info.exp <3 
    info.bregmaOffsetY = 0.75; % pos is P to bregma and neg is A of bregma
    info.bregmaOffsetX = 1; % pos is L of bregma and neg is R of bregma
%     else
%     info.bregmaOffsetY = 0.5; % pos is P to bregma and neg is A of bregma
%     info.bregmaOffsetX = 1.0; % pos is L of bregma and neg is R of bregma
    end
    
    save([dirOut1, allData(i).name], 'info', '-append')
    disp(num2str(i))
end

dirOut1 = '/data/adeeti/ecog/matIsoPropMultiStim/Wavelets/';

identifier = '2018*';
START_AT= 1; % starting experiment

cd(dirOut1)
allData = dir(identifier);

for i = START_AT:85
    load(allData(i).name, 'info');
    if info.exp <3 
    info.bregmaOffsetY = 0.75; % pos is P to bregma and neg is A of bregma
    info.bregmaOffsetX = 1; % pos is L of bregma and neg is R of bregma
    end
    save([dirOut1, allData(i).name], 'info', '-append')
    disp(num2str(i))
end

dirOut1 = '/data/adeeti/ecog/matIsoPropMultiStim/Wavelets/FiltData/';

identifier = '2018*';
START_AT= 1; % starting experiment

cd(dirOut1)
allData = dir(identifier);

for i = START_AT:85
    load(allData(i).name, 'info');
    if info.exp <3 
    info.bregmaOffsetY = 0.75; % pos is P to bregma and neg is A of bregma
    info.bregmaOffsetX = 1; % pos is L of bregma and neg is R of bregma
    end
    save([dirOut1, allData(i).name], 'info', '-append')
    disp(num2str(i))
end

%% checking to see if indexes on index series and datasnippets match up 

clear
close all

dirIn =  '/data/adeeti/ecog/matIsoPropMultiStim/';
cd(dirIn)
identifier = '2018*';
allData = dir(identifier);

catchTrials = [];
for i = 2:length(allData)
    load(allData(i).name, 'allStartTimes', 'dataSnippits')
    if  length(allStartTimes) - size(dataSnippits,2) ==0
        continue
    end
    if length(allStartTimes) - size(dataSnippits,2) ==1
        load(allData(i).name)
        allStartTimes = allStartTimes(1:end-1);
        indexSeries = indexSeries(1:end-1);
        stimOffSet = stimOffSet(1:end-1,:);
    elseif length(allStartTimes) - size(dataSnippits,2) ~=1
        disp('You got a big problem');
        catchTrials = [catchTrials; info.expName];
    end
    save(allData(i).name, 'stimOffSet', 'indexSeries', 'allStartTimes', '-append')
end

%% removing feilds from structures - like info files 

clear
close all

dirIn =  '/data/adeeti/ecog/matIsoPropMultiStim/';
cd(dirIn)
identifier = '2018*';
allData = dir(identifier);
load('dataMatrixFlashes.mat')

for i = 4:length(allData)
    load(allData(i).name, 'info')
    info = rmfield(info, 'lowLat');
    save(allData(i).name, 'info', '-append')
end


%% Adding experiment IDs for all IspPropExps 

dirIn =  '/data/adeeti/ecog/matIsoPropMultiStim/';
cd(dirIn)
identifier = '2018*';
allData = dir(identifier);

for i = 1:length(allData)
    temp = [];
    load(allData(i).name, 'info')
    s = info.date;
    
    if contains(s, '07-07')
        dataMatrixFlashes(i).exp = 1;
        info.exp = 1;
    elseif contains(s, '07-09')
        dataMatrixFlashes(i).exp = 2;
        info.exp = 2;
    elseif contains(s, '07-10')
        dataMatrixFlashes(i).exp = 3;
        info.exp = 3;
    elseif contains(s, '07-12')
        dataMatrixFlashes(i).exp = 4;
        info.exp = 4;
    elseif contains(s, '07-18')
        dataMatrixFlashes(i).exp = 5;
        info.exp = 5;
    elseif contains(s, '07-19')
        dataMatrixFlashes(i).exp = 6;
        info.exp = 6;
    end
    save(allData(i).name, 'info', '-append')
end

save([dirIn, 'dataMatrixFlashes.mat'], 'dataMatrixFlashes')
  
%% Making info files from dataMatrixFlashes you know, if you are stupid and write over all of them 

close all
clear

load('dataMatrixFlashes.mat')
allData= dir('2018*.mat');

for experiment = 1:length(allData)
    temp1 = allData(experiment).name;
    temp2 = ['/data/adeeti/ecog/matIsoPropMultiStim/', temp1];
    load(allData(experiment).name, 'dataSnippits')
    for i = 1:size(dataMatrixFlashes, 2)
        if strcmpi(temp2, dataMatrixFlashes(i).expName)==1
            info = [];
            info.expName = [allData(experiment).name];
            info.exp = dataMatrixFlashes(i).exp;
            info.AnesType = dataMatrixFlashes(i).AnesType;
            info.AnesLevel= dataMatrixFlashes(i).AnesLevel;
            info.TypeOfTrial = dataMatrixFlashes(i).TypeOfTrial;
            info.date= dataMatrixFlashes(i).date;
            info.channels= dataMatrixFlashes(i).channels;
            info.notes= dataMatrixFlashes(i).notes;
            info.noiseChannels = dataMatrixFlashes(i).noiseChannels;
            info.interPulseInterval= dataMatrixFlashes(i).interPulseInterval;
            info.interStimInterval= dataMatrixFlashes(i).interStimInterval;
            info.numberStim= dataMatrixFlashes(i).numberStim;
            info.gridIndicies= dataMatrixFlashes(i).gridIndicies;
            info.Stim1= dataMatrixFlashes(i).Stim1;
            info.Stim1ID = dataMatrixFlashes(i).Stim1ID;
            info.LengthStim1= dataMatrixFlashes(i).LengthStim1;
            info.IntensityStim1= dataMatrixFlashes(i).IntensityStim1;
            info.bregmaOffsetX = dataMatrixFlashes(i).bregmaOffsetX;
            info.bregmaOffsetY = dataMatrixFlashes(i).bregmaOffsetY;
            
            if dataMatrixFlashes(i).numberStim >= 2
                info.Stim2= dataMatrixFlashes(i).Stim2;
                info.Stim2ID= dataMatrixFlashes(i).Stim2ID;
                info.LengthStim2= dataMatrixFlashes(i).LengthStim2;
                info.IntensityStim2= dataMatrixFlashes(i).IntensityStim2;
            end
            
            if dataMatrixFlashes(i).numberStim >= 3
                info.Stim3= dataMatrixFlashes(i).Stim3;
                info.Stim3ID= dataMatrixFlashes(i).Stim3ID;
                info.LengthStim3= dataMatrixFlashes(i).LengthStim3;
                info.IntensityStim3= dataMatrixFlashes(i).IntensityStim3;
            end
            
            if dataMatrixFlashes(i).numberStim >= 4
                info.Stim4= dataMatrixFlashes(i).Stim4;
                info.Stim4ID= dataMatrixFlashes(i).Stim4ID;
                info.LengthStim4= dataMatrixFlashes(i).LengthStim4;
                info.IntensityStim4= dataMatrixFlashes(i).IntensityStim4;
            end
            
            if isfield(dataMatrixFlashes, 'polarity')
                info.polarity = dataMatrixFlashes(i).polarity;
            end
            
            if isfield(dataMatrixFlashes, 'V1')
                info.V1 = dataMatrixFlashes(i).V1;
            end
            
            if isfield(dataMatrixFlashes, 'noiseChannels')
                info.noiseChannels = dataMatrixFlashes(i).noiseChannels;
            else
                info.noiseChannels = [];
            end
            
            save(temp2, 'info', '-append')
        end
    end
end



%% Adding names to experiments in info section

allData = dir('2017*.mat')

load('gridIndicies.mat')


for i = 1:length(allData)
    load(allData(i).name, 'info','meanSubData')
    temp = allData(i).name;
    info.expName = temp(1:end-4);
    temp1 = size(meanSubData, 2);
    info.trials = temp1;
    temp2 = size(meanSubData, 1);
    info.channels = temp2;
    info.gridIndicies = gridIndicies;
    save(allData(i).name, 'info', '-append')
end

%% Adding number of trials in info section

cd('/data/adeeti/ecog/matFlashesJanMar2017/')
allData = dir('2017*.mat')

for i = 1:length(allData)
    load(allData(i).name, 'meanSubData')
    temp1 = size(meanSubData, 2);
    info.trials = temp1;
    temp2 = size(meanSubData, 1);
    info.channels = temp2;
    save(allData(i).name, 'info', '-append')
    disp(['Saving experiment ', num2str(i), ' out of ', num2str(length(allData))])
end

%% Finding the number of trials

allData = dir('2018*.mat')

trials = []

for exp = 1:length(allData)
    load(allData(exp).name, 'dataSnippits')
    trials = [trials, size(dataSnippits,2)];
end

%% Putting info for each experiment in wavelets folder
clear
clc

dirIn = '/data/adeeti/ecog/matIsoPropMultiStim/';
dirOut1 = '/data/adeeti/ecog/matIsoPropMultiStim/Wavelets/';
dirOut2 = '/data/adeeti/ecog/matIsoPropMultiStim/Wavelets/FiltData/';

identifier = '2018*';
START_AT= 3; % starting experiment

cd(dirOut1)
allData = dir(identifier);

for i = START_AT:length(allData)
    temp = allData(i).name;
    temp = temp(1:end-8);
    temp = [temp, '.mat'];
    load([dirIn, temp], 'info', 'uniqueSeries', 'indexSeries')
    save([dirOut1, allData(i).name], 'info', 'uniqueSeries', 'indexSeries', '-append')
    save([dirOut2, allData(i).name], 'info', 'uniqueSeries', 'indexSeries', '-append')
    disp(['Saving experiment ', num2str(i), ' out of ', num2str(length(allData))])
end

%% getting rid of fake waves in wavelet folder 
% 
% loadFreq = {};
% 
% for f= 1:40
%     temp = ['WAVE', num2str(f)];
%     loadFreq{f} = {temp};
% end

cd('/data/adeeti/ecog/matFlashesJanMar2017/Wavelets')
allData = dir('2017*.mat')

for i = 29:length(allData)
    clearvars -except allData i %loadFreq
%     for f = 1:40
%         load(allData(i).name, char(loadFreq{f}))
%     end
    load(allData(i).name, 'COI', 'DJ', 'Freq', 'H', 'HInd', 'K', 'PARAMOUT', 'SCALE', 'WAVE1', 'WAVE10', 'WAVE11', 'WAVE12', 'WAVE13', 'WAVE14', 'WAVE15', 'WAVE16', 'WAVE17', 'WAVE18', 'WAVE19', 'WAVE2', 'WAVE20', 'WAVE21', 'WAVE22', 'WAVE23', 'WAVE24', 'WAVE25', 'WAVE26', 'WAVE27', 'WAVE28', 'WAVE29', 'WAVE3', 'WAVE30', 'WAVE31', 'WAVE32', 'WAVE33', 'WAVE34', 'WAVE35', 'WAVE36', 'WAVE37', 'WAVE38', 'WAVE39', 'WAVE4', 'WAVE40', 'WAVE5', 'WAVE6', 'WAVE7', 'WAVE8', 'WAVE9', 'filtSingal', 'filtSingalInd')
    save(allData(i).name, 'COI', 'DJ', 'Freq', 'H', 'HInd', 'K', 'PARAMOUT', 'SCALE', 'WAVE1', 'WAVE10', 'WAVE11', 'WAVE12', 'WAVE13', 'WAVE14', 'WAVE15', 'WAVE16', 'WAVE17', 'WAVE18', 'WAVE19', 'WAVE2', 'WAVE20', 'WAVE21', 'WAVE22', 'WAVE23', 'WAVE24', 'WAVE25', 'WAVE26', 'WAVE27', 'WAVE28', 'WAVE29', 'WAVE3', 'WAVE30', 'WAVE31', 'WAVE32', 'WAVE33', 'WAVE34', 'WAVE35', 'WAVE36', 'WAVE37', 'WAVE38', 'WAVE39', 'WAVE4', 'WAVE40', 'WAVE5', 'WAVE6', 'WAVE7', 'WAVE8', 'WAVE9', 'filtSingal', 'filtSingalInd')
    disp(['Saving experiment ', num2str(i), ' out of ', num2str(length(allData))])
end



%% Finding latency of onset for all channels

allData = dir('2017*.mat')

allLatency = nan(size(allData, 1), 64);

for exp = 1:length(allData)
    load(allData(exp).name, 'latency')
    allLatency(exp, :) = latency;
end

edges = 0:10:250;
figure
histogram(allLatency(:), edges);

%% Creating random signal

randSig = randperm(length(VisSig));
randSig = VisSig(randSig);


%% Changing the final time
cd('/data/adeeti/ecog/matFlashesJanMar2017Again/')

allData = dir('*.mat')

for exp = 1:length(allData)
    finalTime = linspace(-before, l-before, l*finalSampR+1);
    save(['/data/adeeti/ecog/matFlashesJanMar2017Again/', allData(exp).name], 'finalTime', '-append')
end


%% finding which files do not have info.noiseChannels
cd('/data/adeeti/ecog/matFlashesJanMar2017Again/')

noNoiseChannelsVect = [];

allData = dir('*.mat')

for exp = 1:length(allData)
    load(allData(exp).name, 'info')
    if ~isfield(info, 'noiseChannels')
        noNoiseChannelsVect = [noNoiseChannelsVect, allData(exp).name];
    end
end

noNoiseChannelsVect = strsplit(noNoiseChannelsVect, '.mat');

%% Assigning mouse numbers based on date

for i = 1:length(dataMatrixFlashes)
    s = dataMatrixFlashes(i).date;
    
    if contains(s, '01_31')
        dataMatrixFlashes(i).exp = 1;
    elseif contains(s, '02_10')
        dataMatrixFlashes(i).exp = 3;
    elseif contains(s, '02_14')
        dataMatrixFlashes(i).exp = 4;
    elseif contains(s, '02_16')
        dataMatrixFlashes(i).exp = 5;
    elseif contains(s, '02_23')
        dataMatrixFlashes(i).exp = 7;
    elseif contains(s, '02_28')
        dataMatrixFlashes(i).exp = 8;
    elseif contains(s, '03_02')
        dataMatrixFlashes(i).exp = 9;
    end
end


%% extracting aspects of big ass matrix
ID=vertcat(dataMatrixFlashes(:).exp);
uniqueID=unique(ID);
DrugConc=vertcat(dataMatrixFlashes(:).AnesLevel);
uniqueDrug=unique(DrugConc);
Intense=vertcat(dataMatrixFlashes(:).IntensityPulse);
uniqueIntense=unique(Intense);
Duration=vertcat(dataMatrixFlashes(:).LengthPulse);
uniqueDuration=unique(Duration);

%% adding exp ids
allData = dir('2017*.mat')

for i = 1:length(allData)
    load(allData(i).name, 'info')
    info.exp = dataMatrixFlashes(i).exp
    save(allData(i).name, 'info', '-append')
end


%% Changing names to get rid of hyphens in dataMatrixFlashes

for i = 1:length(dataMatrixFlashes)
    temp = dataMatrixFlashes(i).date;
    temp(5) = '-';
    temp(8) = '-';
    dataMatrixFlashes(i).date = temp;
end

%% Average evoked potentials: Connor's Code
WINDOW_SIZE = 1000;

lightOnIndicies = find(diff(traceTTL) == 1);

averageTrace = zeros(size(rawTraceData,1), WINDOW_SIZE);
for i = 1:length(lightOnIndicies)
    averageTrace = averageTrace + rawTraceData(:,lightOnIndicies+1:lightOnIndicies+WINDOW_SIZE);
end
averageTrace = averageTrace / length(lightOnIndicies);

% eegplot(averageTrace, 'srate', 1000);

gridIndicies = [[5 17 0 0 48 60]; ...
    [6 18 28 37 47 59]; ...
    [7 19 29 36 46 58]; ...
    [8 20 30 35 45 57]; ...
    [9 21 31 34 44 56]; ...
    [10 22 32 33 43 55]; ...
    [11 16 27 38 49 54]; ...
    [4 15 26 39 50 61]; ...
    [3 14 25 40 51 62]; ...
    [2 13 24 41 52 63]; ...
    [1 12 23 42 53 64]];

for i = 1:64
    [electrodeX(i), electrodeY(i)] = ind2sub(size(gridIndicies), find(gridIndicies == i));
end

electrodePositionsX = (electrodeX-1) * 0.5 + 0.25;
electrodePositionsY = (electrodeY-1) * 0.5 + 0.25;

x = 0:0.1:3;
y = 0:0.1:6;

[X, Y] = meshgrid(x, y);
for i = 1:WINDOW_SIZE
    interpolationFunction = scatteredInterpolant(electrodePositionsX', electrodePositionsY', averageTrace(:,i));
    data(:,:,i) = interpolationFunction(X,Y);
end

minColor = min(averageTrace(:));
maxColor = max(averageTrace(:));
for i = 1:WINDOW_SIZE
    clf;
    
    subplot(3,1,1);
    cla;
    hold on;
    plot(averageTrace');
    plot([i i], [min(averageTrace(:)), max(averageTrace(:))], 'r');
    
    subplot(3,1,2:3);
    cla;
    %     hold on;
    %     imagesc(data(:,:,i));
    scatter(electrodePositionsX, electrodePositionsY, 72, averageTrace(:,i), 'filled', 'MarkerEdgeColor',[0 0 0]);
    title(num2str(i));
    caxis([minColor maxColor]);
    colorbar;
    
    pause(0.001);
end

%% Re-ordering trials and making small averages
randTrial = randperm(size(meanSubData,2));
randOrder = meanSubData(:,randTrial,:);

smallAveTraces = zeros(size(randOrder,1), floor(size(randOrder, 2)/5), size(randOrder,3));

for ch = 1:size(randOrder,1)
    j = 1;
    for i = 1:5:size(randOrder, 2)
        if i+5 > size(randOrder,2)
            continue
        end
        smallAveTraces(ch, j, :) = mean(randOrder(ch, i:i+5, :),2);
        j = j +1;
    end
end

%% Latency on small averages Trials

before=1;
l = 3;
flashOn = [0,0];
thresh=3;
maxThresh = 5;
consistent = 4;
endMeasure = 0.35;

latency = zeros(size(smallAveTraces, 1), size(smallAveTraces,2));

for i = 1:size(smallAveTraces,2)
    
    [ zData, onset ] = normalizedThreshold(squeeze(smallAveTraces(:,i,:)), thresh, maxThresh, consistent, endMeasure, before, finalSampR);
    latency(:, i) = onset;
    
end

%% Latency on single trial basis

before=1;
l = 3;
flashOn = [0,0];
thresh=3;
maxThresh = 5;
consistent = 4;
endMeasure = 0.35;

latency = zeros(size(meanSubData, 1), size(meanSubData,2));

for i = 1:size(meanSubData,2)
    
    [ zData, onset ] = normalizedThreshold(squeeze(meanSubData(:,i,:)), thresh, maxThresh, consistent, endMeasure, before, finalSampR);
    latency(:, i) = onset;
    
end


%% Histograms of latency on grid

screensize=get(groot, 'Screensize');

gridIndicies = [[5 17 0 0 33 53]; ...
    [6 18 28 44 34 54]; ...
    [7 19 29 45 35 55]; ...
    [8 20 30 46 36 56]; ...
    [9 21 31 47 37 57]; ...
    [10 22 32 48 38 58]; ...
    [11 16 27 43 64 59]; ...
    [4 15 26 42 63 52]; ...
    [3 14 25 41 62 51]; ...
    [2 13 24 40 61 50]; ...
    [1 12 23 39 60 49]];

for i = 1:64
    [electrodeX(i), electrodeY(i)] = ind2sub(size(gridIndicies), find(gridIndicies == i));
end

% timeLabels = [-beforePeriod:duration];

currentFig = figure('Position', screensize)

clf

for ch = 1:size(latency, 1)
    trueChannel = ch;%info.goodChannels(ch);
    channelIndex = sub2ind([6 11], electrodeY(trueChannel), electrodeX(trueChannel));
    
    subplot(11,6,channelIndex);
    hist(latency(ch,:))
end

suptitle(['Latency Histogram', ' Drug Concentration ', num2str(info.AnesLevel), ' maxThresh: ', num2str(maxThresh), ' thresh: ', num2str(thresh), ' consistancy', num2str(consistent)])



%% Finding max trials for all iso experiments

allData = dir('2017*.mat')

maxTrials = zeros(1, length(allData));

for i = 1:length(allData)
    load([allData(i).name], 'meanSubData')
    maxTrials(i) = size(meanSubData, 2);
end

