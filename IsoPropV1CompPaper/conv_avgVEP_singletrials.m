%% Reliability analysis - convolving with average and corrlations among single trials

clear
clc
close all

onAlexsWorkStation = 0; %1 if on workstation with complete multistim data set, 0 if on lab mac, 2 if on laptop

if onAlexsWorkStation ==1
    % Alex's computer
    dirIn = '/data/adeeti/ecog/matIsoPropMultiStimVIS_ONLY_/flashTrials/';
    dirOut1 = '/home/adeeti/GoogleDrive/TNI/IsoPropCompV1Paper/';
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
    % Adeeti's Laptop
    dirIn = '/Users/adeetiaggarwal/Google Drive/data/matIsoPropMultiStimVIS_ONLY_/flashTrials/';
    dirOut1 = '/Users/adeeti/Google Drive/TNI/IsoPropCompV1Paper/';
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
            [MFE] = findMyExpMulti(dataMatrixFlashes, expLabel(i), [], [], []);
            allExp{i}(:) = MFE;
        end
    end
else
    [MFE] = 1:length(dataMatrixFlashes);
end

numSubjects = size(allExp,2);
maxExposuresPerSubject = max(cellfun(@length, allExp));

%%  Extracting single trials and setting up kernal

og_sf = 1000; 
VEP_kernal_time = 1000:1350;

allAvgVEPs = [];
V1Traces = [];
V1s = [];
V1Trials = [];

for ID = 1:numSubjects
    for experiment = 1: maxExposuresPerSubject
        if experiment> numel(allExp{ID})
            continue
        end
        load(dataMatrixFlashes(allExp{ID}(experiment)).expName, 'meanSubFullTrace', 'meanSubData', 'info', 'finalSampR', 'finalTimeFullTrace', 'aveTrace')
        V1 = info.lowLat;
        %fullTraces{i,:,:} = meanSubFullTrace;
        V1Traces{ID}{experiment} = squeeze(meanSubFullTrace(V1,:));
        allAvgVEPs{ID}{experiment} = squeeze(aveTrace(1,V1,VEP_kernal_time));
        
        V1Trials{ID}{experiment} = squeeze(meanSubData(V1,:,:));
    end
end

%% Convloving with the VEP kernal

%checking average kernals
figure 
for ID = 1:numSubjects
    for experiment = 1: maxExposuresPerSubject
        if experiment> numel(allExp{ID})
            continue
        end
        subplot(numSubjects, maxExposuresPerSubject, (ID-1)*6+experiment)
        plot(allAvgVEPs{ID}{experiment})
        title(['mouse ', num2str(ID), ', exp ', num2str(experiment)])
    end
end


% convolving with average
conv_With_VEP =[];
conv_With_singTrials =[];

for ID = 1:numSubjects
    for experiment = 1: maxExposuresPerSubject
        if experiment> numel(allExp{ID})
            continue
        end
        useTrace = V1Traces{ID}{experiment};
        useV1Trials = V1Trials{ID}{experiment};
        
        VEP_kernal = allAvgVEPs{ID}{experiment};
        conv_With_VEP{ID}{experiment}= convn(useTrace,fliplr(VEP_kernal), 'same');
        
        for t = 1:size(useV1Trials,1)
        conv_With_singTrials{ID}{experiment}(t,:) = convn(squeeze(useV1Trials(t,:)),fliplr(VEP_kernal), 'same');
        end
    end
end



%% mouse by mouse - interavearge variance vs cross concentration
% cross correlation  between avverage traces

timeRange = 1000:1250;
corrReliability = [];

V1 = info.lowLat;
corrReliability = nan(numSubjects, maxExposuresPerSubject);

for ID = 1:numSubjects
    for experiment =1:maxExposuresPerSubject
         if experiment> numel(allExp{ID})
            continue
         end
        
        useV1Trials = V1Trials{ID}{experiment};
        numTrials = size(useV1Trials,1);
        tempCorrReliability = [];

        for t = 1:numTrials
            for j = t+1:numTrials
                trial1 = squeeze(useV1Trials(t,timeRange));
                trial2 = squeeze(useV1Trials(j,timeRange));
                corrSingleTrials = corr(trial1', trial2');
                tempCorrReliability = [tempCorrReliability, corrSingleTrials];
                %corrSingleTrials = (trial1-nanmean(trial1))*(trial2'-nanmean(trial2))/(std(trial1)*std(trial2))/length(timeRange);
            end
        end
        corrReliability(ID,experiment)= sum(tempCorrReliability)/((numTrials^2-numTrials)/2);
    end
end

figure 
for experiment = 1:maxExposuresPerSubject
subplot(2,3,experiment)
histogram(squeeze(corrReliability(:,experiment)),7)
end

corrReliability
meanCorrReliability = nanmean(corrReliability, 1)
stdCorrReliability = nanstd(corrReliability, 1)
medianCorrReliability = median(corrReliability, 1)
iqrCorrReliability = iqr(corrReliability, 1)

%% Making figure 
% figure for reliabilty 
ff = figure;
ff.Renderer = 'Painters';
ff.Color = 'w';
bar(meanCorrReliability(1:4)) 
hold on
e = errorbar(1:4, meanCorrReliability(1:4), stdCorrReliability(1:4)/numSubjects, '.');
ylabel('Reliability of VEP', 'FontSize', 20)
xlabel('Anesthetic Exposure', 'FontSize', 20)
title('Reliablity of VEPs in time domain', 'FontSize', 22)

% Stats for reliability
pCorrReliability = kruskalwallis(corrReliability(:,1:4));
[pIsoCorrReliability, hIsoCorrReliability, stats]=ranksum(corrReliability(:,1), corrReliability(:,2));
[pPropCorrReliability, hPropCorrReliability, stats]=ranksum(corrReliability(:,3), corrReliability(:,4));

combCorrReliability(:,1) = [corrReliability(:,1); corrReliability(:,2)];
combCorrReliability(:,2) = [corrReliability(:,3); corrReliability(:,4)];
[pCombCorrReliability, hCombCorrReliability, stats] = ranksum(combCorrReliability(:,1), combCorrReliability(:,2));

