%% Reliability analysis for average and single trial EPs 
% 
%% just what you gotta do
clc
clear

onAlexsWorkStation = 0; %1 if on workstation with complete multistim data set, 0 if on lab mac, 2 if on laptop

if onAlexsWorkStation ==1
    % Alex's computer
    dirIn = '/data/adeeti/ecog/matIsoPropMultiStimVIS_ONLY_/flashTrials/';
    dirOut1 = '/home/adeeti/GoogleDrive/TNI/IsoPropCompV1Paper/';
    dirFiltData = '/data/adeeti/ecog/matIsoPropMultiStim/Wavelets/FiltData/';
    cd(dirIn)
     load('dataMatrixFlashesVIS_ONLY.mat')
    dataMatrixFlashes = dataMatrixFlashesVIS_ONLY;
elseif onAlexsWorkStation ==0
    % Adeeti's Desktop
    dirIn = '/Users/adeeti/Desktop/data/VIS_Only_Iso_prop_2018/flashTrials/';
    dirOut1 = '/Users/adeeti/Google Drive/TNI/IsoPropCompV1Paper/';
    cd(dirIn)
    load('dataMatrixFlashesVIS_ONLY.mat')
    dataMatrixFlashes = dataMatrixFlashesVIS_ONLY;
elseif onAlexsWorkStation ==2
    % Adeeti's Desktop
    dirIn = '/Users/adeetiaggarwal/Google Drive/data/flashTrials/';
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

%% parameter

%% Calculate normalized for magnitude, latency, duration

for ID = 1:numSubjects
    for experiment = 1: maxExposuresPerSubject
        if experiment> numel(allExp{ID})
            continue
        end
        load(dataMatrixFlashes(allExp{ID}(experiment)).expName, 'info', 'aveTrace', 'indexSeries', 'uniqueSeries', 'latency')
        V1 = info.lowLat;
        queryIndex = ismember(stimIndex, uniqueSeries, 'rows');
        useAveTrace = squeeze(aveTrace(queryIndex,V1,:));
        useLatency = squeeze(latency(queryIndex,:));
        
        z=nanstd(useAveTrace(preStimTime));                 % compute the mean and the standard deviation of the signal before the stimulus
        m=nanmean(useAveTrace(preStimTime));
        
        zData=(useAveTrace-repmat(m, length(useAveTrace), 1))./repmat(z, length(useAveTrace), 1);
        
        %finding latency for each channel
        EPData = zData(timeframeEP);
        latnecyEP = abs(EPData)>threshEP;
        conLatEp=convn(latnecyEP', ones(1,consistentEP)/consistentEP, 'same');
        onsetEP = find(conLatEp==1, 1, 'first')-round(consistentEP./2);
        onsetEP = onsetEP + timeframeEP(1)-before;
        
        %finding duration for each channel
        returnData = zData(onsetEP+before:onsetEP+before+timeframeReturn);
        latnecyReturn = abs(returnData)<threshReturn;
        conLatReturn=convn(latnecyReturn', ones(1,consistentReturn)/consistentReturn, 'same');
        duration = find(conLatReturn>0.9 & conLatReturn<1.1, 1, 'first')-round(consistentReturn./2);
        if isempty(duration)
            duration = 1000;
        end
        onsetReturn = duration + onsetEP;
        
        allAverageTrace(ID,experiment,:) = useAveTrace;
        allOGLatEP(ID,experiment,:) = useLatency(V1);
        allZData(ID,experiment, :) = zData;
        allNewLatEP(ID,experiment,:) = onsetEP;
        allNewLatReturn(ID,experiment,:) = onsetReturn;
        allDuration(ID,experiment,:) = duration;
        
        clearvars zData latency useAceTrace aveTrace z m V1 duration onsetEP onsetReturn
    end
end

% Stats for latency and duration 
meanDur = nanmean(allDuration,1);
stdDur = nanstd(allDuration, 1, 1)/numSubjects;

pDur = kruskalwallis(allDuration(:,1:4));
[pIsoDur, hIsoDur, stats]=ranksum(allDuration(:,1), allDuration(:,2));
[pPropDur, hPropDur, stats]=ranksum(allDuration(:,3), allDuration(:,4));

combDur(:,1) = [allDuration(:,1); allDuration(:,2)];
combDur(:,2) = [allDuration(:,3); allDuration(:,4)];
[p, h, stats] = ranksum(combDur(:,1), combDur(:,2));


meanLat = nanmean(allNewLatEP,1);
stdLat = nanstd(allNewLatEP, 1, 1)/numSubjects;

pLat = kruskalwallis(allNewLatEP(:,1:4));
[pIsoLat, hIsoLat, stats]=ranksum(allNewLatEP(:,1), allNewLatEP(:,2));
[pPropLat, hPropLat, stats]=ranksum(allNewLatEP(:,3), allNewLatEP(:,4));

combLat(:,1) = [allNewLatEP(:,1); allNewLatEP(:,2)];
combLat(:,2) = [allNewLatEP(:,3); allNewLatEP(:,4)];
[p, h, stats] = ranksum(allNewLatEP(:,1), allNewLatEP(:,2))


%% RMS calculations
%squartVolt = allAverageTrace(:,:, before:before+endRMS).^2;

RMSVolt = nan(numSubjects,maxExposuresPerSubject);
for i = 1: size(allAverageTrace, 1)
    for j = 1:size(allAverageTrace, 2)
        tempData =squeeze(allAverageTrace(i, j,before:before+endRMS));
        sqVolt = tempData.^2;
        sumSqVolt = nansum(sqVolt);
        RMSVolt(i,j) = sqrt(sumSqVolt*1/(endRMS+1));
    end
end

% Stats for RMS
meanRMS = nanmean(RMSVolt, 1);
stdRMS = nanstd(RMSVolt, 1, 1)/numSubjects;

pRMS = kruskalwallis(RMSVolt(:,1:4));
[pIsoRMS, hIsoRMS, stats]=ranksum(RMSVolt(:,1), RMSVolt(:,2));
[pPropRMS, hPropRMS, stats]=ranksum(RMSVolt(:,3), RMSVolt(:,4));

combRMS(:,1) = [RMSVolt(:,1); RMSVolt(:,2)];
combRMS(:,2) = [RMSVolt(:,3); RMSVolt(:,4)];
[pPropRMS, hPropRMS, stats] = ranksum(combRMS(:,1), combRMS(:,2));

%% pictures

% figure for RMS 
ff = figure;
ff.Renderer = 'Painters';
ff.Color = 'w';
subplot(1, 3, 1)
bar(meanRMS(1:4)) 
hold on
e = errorbar(1:4, meanRMS(1:4), stdRMS(1:4), '.');
ylabel('RMS Average VEP \muV', 'FontSize', 20)
xlabel('Anesthetic Exposure', 'FontSize', 20)
title('VEP Amplitude', 'FontSize', 22)

% figure for duration 
subplot(1, 3, 2)
bar(meanDur(1:4)) 
hold on
e = errorbar(1:4, meanDur(1:4), stdDur(1:4), '.');
ylabel('Duration of VEP in msec', 'FontSize', 20)
xlabel('Anesthetic Exposure', 'FontSize', 20)
title('VEP Duration', 'FontSize', 22)

% figure for latency 
subplot(1, 3, 3)
bar(meanLat(1:4)) 
hold on
e = errorbar(1:4, meanLat(1:4), stdLat(1:4), '.');
ylabel('Latency of onset in msec', 'FontSize', 20)
xlabel('Anesthetic Exposure', 'FontSize', 20)
title('VEP Latency of Onset', 'FontSize', 22)

%% Looking at all averages 

plotAverageTime = [800:1850];
figure 
for i = 1:size(allAverageTrace, 2)
    subplot(2, 3, i);
    for j = 1:size(allAverageTrace, 1)
        plot(squeeze(allAverageTrace(j, i,plotAverageTime)))
        hold on
    end 
    legend 
    title(['Exposure ', num2str(i)])
end

%% looking at distributions 

figure
for i = 1:6
    subplot(2,3,i)
    hist(RMSVolt(:,i))
end
suptitle('RMS')

figure
for i = 1:6
    subplot(2,3,i)
    hist(allDuration(:,i))
end
suptitle('Duration')

figure
for i = 1:6
    subplot(2,3,i)
    hist(allNewLatEP(:,i))
end
suptitle('Latency')




