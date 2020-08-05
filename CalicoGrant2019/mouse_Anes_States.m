%% Figure for Max's grant 
clear 
clc
close all 

onAlexsWorkStation = 0; %1 if on workstation with complete multistim data set, 0 if on lab mac, 2 if on laptop

if onAlexsWorkStation ==1
    % Alex's computer
    dirIn = '/data/adeeti/ecog/matIsoPropMultiStimVIS_ONLY_/baseline/';
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
fs = 1000;

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
  %eegplot(allLFPBaseline(allhighIsoChan1,:), 'srate', 1000)
% size of allLFPBaseline is 32x55001

colorsForPlot= {[0.6350, 0.0780, 0.1840], [0, 0.4470, 0.7410]}; %marroon and blue, respectively

totalTimeSement = 10; %in seconds
timeAxis = linspace(0,totalTimeSement,totalTimeSement*fs+1);

% Supp only Isoflurane
allhighIsoChan1 = [1, 7, 13, 19, 23, 29, 33];
supIso1Index = 3;
timeSupIso1 = [6, 16];
supIso1 = allLFPBaseline(allhighIsoChan1(supIso1Index), timeSupIso1(1)*fs:timeSupIso1(2)*fs); %10 sec of high iso data

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

% supp propofol
allHighPropChan = [4, 10, 16, 22, 26, 32, 36];
supPropIndex = 4;
timeSupProp = [1, 11];
supProp = allLFPBaseline(allHighPropChan(supPropIndex), timeSupProp(1)*fs:timeSupProp(2)*fs); %10 sec of high prop data

%%

titleStringBS = {['Suppression Isoflurane'], ['High Dose Isoflurane'], ['Low Dose Isoflurane'], ['Supression Propofol'], ['High Dose Propofol'], ['Low Dose Propofol'], ['Ketamine'], ['Awake'], ['Drowsy']};
titleStringNoBS = {['Suppression Isoflurane'], ['Low Dose Isoflurane'], ['Supression Propofol'], ['Low Dose Propofol'], ['Ketamine'], ['Awake'], ['Drowsy']};

dataBS(1,:) = nan(size(squeeze(supProp))); %iso suppresion
dataBS(2,:) = squeeze(highIso1); %high iso
dataBS(3,:) = squeeze(lowIso1); %low iso
dataBS(4,:) = squeeze(supProp);  %supp prop
dataBS(5,:) = squeeze(highProp); %high Prop
dataBS(6,:) = squeeze(lowProp); %low prop


%% get iso suppression, ketamine, and awake data 
if onAlexsWorkStation ==1
    dirIn = '/data/adeeti/ecog/googleDrive/Data/';
elseif onAlexsWorkStation ==0
    % Adeeti's Desktop
    dirIn = '/Users/adeeti/Google Drive/data/';
elseif onAlexsWorkStation ==2
    % Adeeti's laptop
    dirIn = '/Users/adeetiaggarwal/Google Drive/';
end

%for iso suppression
cd(dirIn)
load('suppression_Iso.mat', 'meanSubData')
ch = 51;
timeSupIso1 = [6, 16];
dataBS(1,:) = meanSubData(ch, timeSupIso1(1)*fs:timeSupIso1(2)*fs)*(1/70); %iso suppresion

% for ketamine 
load('ketamine_only_single_channel.mat', 't', 'y')
ketSR = 1000;
timeForIP = 15; % time in min 
timeToExclude = timeForIP*60*ketSR;
ketDataFilt = y(timeToExclude: end);

timeKet = [10, 20];
dataBS(7,:) = ketDataFilt(timeKet(1)*fs:timeKet(2)*fs)*0.6; %ketamine


% for no anesethesia 
load('awake.mat')
ch = 6;
timeAwake = [273, 283];
timeDrowsy = [329,339];
dataBS(8,:) = x(ch, timeAwake(1)*fs:timeAwake(2)*fs); %Awake
dataBS(9,:) = x(ch, timeDrowsy(1)*fs:timeDrowsy(2)*fs); %Drowsy

%%
dataNoBS = dataBS;
dataNoBS(2,:) = [];
dataNoBS(5,:) = [];

%%

screensize=get(groot, 'Screensize');
ff = figure('Position', screensize, 'color', 'w'); clf;
ff.Renderer='Painters';

for i = 1:size(dataBS, 1)
    h(i) = subplot(9,1,i);
    plot(timeAxis, dataBS(i,:))
    set(gca, 'ylim', [min(dataBS(:)), max(dataBS(:))])
    hold on
    title(titleStringBS{i})
    if i == 1
         line([0.5 0.5], [-350 -150], 'LineWidth', 2, 'Color', 'k'); % vertical line
         line([0.5 1.5], [-350 -350], 'LineWidth', 2, 'Color', 'k'); % horizontal line
         tt=text(0.5, -250, '200 mV', 'FontName', 'Arial', 'FontSize', 12); % vertical line
         tt2=text(.75, -400, '1 s', 'FontName', 'Arial', 'FontSize', 12); % horizontal line
    end
    axis off
end



%% calculating spectrum
Ktapers = 20;
freqWin = [0.2 50];

useData = dataNoBS;
useTitles = titleStringNoBS;

spectrum = [];

for i =1:size(useData,1)
    [out,taper,concentration]= mtpsd(squeeze(useData(i,:)),fs,Ktapers,freqWin,[],[],[],[],1);
    spectrum(i,:) = out.psd;
end
freq = out.freq_grid;

%% power spectrum
totPower=sum(spectrum,2);
temp=repmat(totPower, 1, size(freq,2));
normSpectrum=spectrum./temp;

%%
useSpectrum = spectrum;

figure
plot(freq, useSpectrum)
legend(useTitles, 'Location', 'northeast')
xlabel('Frequency (Hz)')
ylabel('Normalized Power')
title('Average Baseline Spectra') 
set(gca, 'yscale', 'log')
%set(gca, 'xscale', 'log', 'yscale', 'log')

%%

% screensize=get(groot, 'Screensize');
% ff = figure('Position', screensize, 'color', 'w'); clf;
% ff.Renderer='Painters';
% 
% for i = 1:size(data, 1)
%     h(i) = subplot(2,2,i);
%     plot(timeAxis, data(i,:))
%     set(gca, 'ylim', [min(data(:)), max(data(:))])
%     hold on
%     title(titleString{i})
%     if i == 4
%          line([0.5 0.5], [-350 -150], 'LineWidth', 2, 'Color', 'k'); % vertical line
%          line([0.5 1.5], [-350 -350], 'LineWidth', 2, 'Color', 'k'); % horizontal line
%          tt=text(0.5, -250, '200 mV', 'FontName', 'Arial', 'FontSize', 12); % vertical line
%          tt2=text(.75, -400, '1 s', 'FontName', 'Arial', 'FontSize', 12); % horizontal line
%     end
%     axis off
% end


% Wakefulness

% Drowsiness 

% Low Iso

% BS Iso 

% Supp Iso 

% Low Prop

% BS Prop

% Supp Prop

% Ketamine 
