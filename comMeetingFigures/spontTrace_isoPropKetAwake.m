%% Make figure of baseline EEG for VI paper with associated spectra
clear 
clc
close all 

onAlexsWorkStation = 1; %1 if on workstation with complete multistim data set, 0 if on lab mac, 2 if on laptop

if onAlexsWorkStation ==1
    % Alex's computer
    dirIn = '/synology/adeeti/ecog/matIsoPropMultiStimVIS_ONLY_/baseline/';
    dirOut1 = '/home/adeeti/GoogleDrive/TNI/IsoPropCompV1Paper/';
    cd(dirIn)
    load('dataMatrixFlashesVIS_ONLY.mat')
    dataMatrixFlashes = dataMatrixFlashesVIS_ONLY;
elseif onAlexsWorkStation ==0
    % Adeeti's Desktop
    dirIn = '/Users/adeeti/Google Drive/data/matIsoPropMultiStimVIS_ONLY_/baseline/';
    dirOut1 = '/Users/adeeti/Google Drive/TNI/IsoPropCompV1Paper/';
    cd(dirIn)
    load('dataMatrixFlashesVIS_ONLY.mat')
    dataMatrixFlashes = dataMatrixFlashesVIS_ONLY;
elseif onAlexsWorkStation ==2
    % Adeeti's laptop
    dirIn = '/Users/adeetiaggarwal/Google Drive/data/matIsoPropMultiStimVIS_ONLY_/baseline/';
    dirOut1 = '/Users/adeetiaggarwal/Google Drive/TNI/IsoPropCompV1Paper/';
    cd(dirIn)
    load('dataMatrixFlashesVIS_ONLY.mat')
    dataMatrixFlashes = dataMatrixFlashesVIS_ONLY;
end

lowestLatVariable = 'lowLat';
stimIndex = [0, Inf];

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
fs = 1000;

%% looking at data
% showData = meanSubData;
% eegplot(showData, 'srate', fs);

%%
totalTimeSement = 10; %in seconds
LFPtimeSegment = totalTimeSement*fs;
timeAxis = linspace(0,totalTimeSement,totalTimeSement*fs+1);
powerSpectraLFP = 54*fs+1;

baselineStringCI = {['Isoflurane 1.2'], ['CI Isoflurane 1.2'], ['Isoflurane 0.6'], ['CI Isoflurane 0.6'], ['Propofol 20'], ['CI Propofol 20'], ['Propofol 35'], ['CI Propofol 35'], ['Isoflurane 1.2'], ['CI Isoflurane 1.2'], ['Isoflurane 0.6'], ['CI Isoflurane 0.6']};

count = 1;
LFPforSpectra = nan(numSubjects, maxExposuresPerSubject, powerSpectraLFP);
baselineSegment = nan(numSubjects, maxExposuresPerSubject, LFPtimeSegment+1);
baselineString = [];
allLFPBaseline = [];
for ID = 1:numSubjects
    
    for experiment = 1: maxExposuresPerSubject
        if experiment> numel(allExp{ID})
            continue
        end
        load(dataMatrixFlashes(allExp{ID}(experiment)).expName, 'info', 'meanSubData')
        V1 = info.lowLat;
        useMeanSubData = meanSubData;
        startTimeLFP = randi(size(useMeanSubData,2)-LFPtimeSegment);
        endTimeLFP = startTimeLFP+LFPtimeSegment;
        LFPforSpectra(ID, experiment,:) = squeeze(useMeanSubData(V1, 1:powerSpectraLFP));
        baselineSegment(ID, experiment,:) = squeeze(useMeanSubData(V1, startTimeLFP:endTimeLFP));
        baselineString{experiment} = [info.AnesType, ' ', num2str(info.AnesLevel)];
        allLFPBaseline(count,:) = squeeze(useMeanSubData(V1, 1:powerSpectraLFP));
        count = count +1;
    end
end

%% Ploting single trials
 % eegplot(allLFPBaseline(allLowPropChan,:), 'srate', 1000)
% size of allLFPBaseline is 32x55001

colorsForPlot= {[0.6350, 0.0780, 0.1840], [0, 0.4470, 0.7410]}; %marroon and blue, respectively

totalTimeSement = 10; %in seconds
timeAxis = linspace(0,totalTimeSement,totalTimeSement*fs+1);

% 1.2% Isoflurane
allhighIsoChan1 = [1, 7, 13, 19, 23, 29, 33];
highIso1Index = 3;
timeHighIso1 = [6, 16];
highIso1 = allLFPBaseline(allhighIsoChan1(highIso1Index), timeHighIso1(1)*fs:timeHighIso1(2)*fs); %10 sec of high iso data

% 0.6% Isoflurane
allLowIsoChan1 = [2, 8, 14, 20, 24, 30, 34];
lowIso1Index = 3;
timelowIso1 = [1, 11];
lowIso1 = allLFPBaseline(allLowIsoChan1(lowIso1Index), timelowIso1(1)*fs:timelowIso1(2)*fs); %10 sec of low iso data

% 20 ug propofol
allLowPropChan = [3, 9, 15, 21, 25, 31, 35];
lowPropIndex = 4;
timelowProp = [10, 20];
% lowPropIndex = 4;
% timelowProp = [25, 35];
lowProp = allLFPBaseline(allLowPropChan(lowPropIndex), timelowProp(1)*fs:timelowProp(2)*fs); %10 sec of low prop data

% 35 ug propofol
allHighPropChan = [4, 10, 16, 22, 26, 32, 36];
highPropIndex = 5;
timehighProp = [26, 36];
highProp = allLFPBaseline(allHighPropChan(highPropIndex), timehighProp(1)*fs:timehighProp(2)*fs); %10 sec of high prop data

data(1,:) = squeeze(highIso1);
data(2,:) = squeeze(lowIso1);
data(3,:) = squeeze(highProp);
data(4,:) = squeeze(lowProp);

%% Finding awake and ketamine 

awakeVEPDir = '/synology/adeeti/ecog/iso_awake_VEPs/'
mouseID = 'GL10'

cd([awakeVEPDir, mouseID, '/'])


awakeInd = 5;
ketInd = 6;
timeAwakeKet = [10, 20];

load('dataMatrixFlashes.mat')

load(dataMatrixFlashes(ketInd).expName, 'info', 'meanSubFullTrace')
data(5,:) = squeeze(meanSubFullTrace(49, timeAwakeKet(1)*fs:timeAwakeKet(2)*fs)*1000); %10 sec of ketamine

load(dataMatrixFlashes(awakeInd).expName, 'info', 'meanSubFullTrace')
data(6,:) = squeeze(meanSubFullTrace(49, timeAwakeKet(1)*fs:timeAwakeKet(2)*fs)*1000); %10 sec of awake

%%
titleString = {['High Dose Isoflurane'], ['Low Dose Isoflurane'], ['High Dose Propofol'], ['Low Dose Propofol'], ['Low Dose Ketamine'], ['Awake']};

%%

screensize=get(groot, 'Screensize');
ff = figure('Position', screensize, 'color', 'w'); clf;
ff.Renderer='Painters';

for i = 1:size(data, 1)
    h(i) = subplot(2,3,i);
    plot(timeAxis, data(i,:))
    set(gca, 'ylim', [min(data(:)), max(data(:))])
    hold on
    title(titleString{i})
    if i == 4
         line([0.5 0.5], [-350 -150], 'LineWidth', 2, 'Color', 'k'); % vertical line
         line([0.5 1.5], [-350 -350], 'LineWidth', 2, 'Color', 'k'); % horizontal line
         tt=text(0.5, -250, '200 uV', 'FontName', 'Arial', 'FontSize', 12); % vertical line
         tt2=text(.75, -400, '1 s', 'FontName', 'Arial', 'FontSize', 12); % horizontal line
    end
    axis off
end



