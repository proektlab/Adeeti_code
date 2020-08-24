%% RMS on single trial data

clear
clc
close all

onAlexsWorkStation = 2; %1 if on workstation with complete multistim data set, 0 if on lab mac, 2 if on laptop

if onAlexsWorkStation ==1
    % Alex's computer
    dirIn = '/data/adeeti/ecog/matVIS_Only_Iso_prop_2018/flashTrials/';
    dirOut1 = '/home/adeeti/GoogleDrive/';
    cd(dirIn)
    load('dataMatrixFlashes.mat')
elseif onAlexsWorkStation ==0
    % Adeeti's Desktop
    dirIn = '/Users/adeeti/Desktop/data/VIS_Only_Iso_prop_2018/baseline/';
    dirOut1 = '/Users/adeeti/Dropbox/';
    cd(dirIn)
    load('dataMatrixFlashesVIS_ONLY.mat')
    dataMatrixFlashes = dataMatrixFlashesVIS_ONLY;
elseif onAlexsWorkStation ==2
    % Adeeti's laptop
    dirIn = '/Users/adeetiaggarwal/Google Drive/data/matIsoPropMultiStimVIS_ONLY_/flashTrials/';
    dirOut1 = '/Users/adeetiaggarwal/Dropbox/';
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
preStimTime = [500:1000];
endRMS = 350;
before = 1000;



%% RMS calculations
%squartVolt = allAverageTrace(:,:, before:before+endRMS).^2;

RMSVolt = nan(numSubjects,maxExposuresPerSubject);

for ID = 1: numSubjects
    for experiment = 1:maxExposuresPerSubject
        if experiment> numel(allExp{ID})
            continue
        end
        load(dataMatrixFlashes(allExp{ID}(experiment)).expName, 'info', 'meanSubData', 'indexSeries', 'uniqueSeries', 'latency')
        V1 = info.lowLat;
        [indices] = getStimIndices(stimIndex, indexSeries, uniqueSeries);
        useMeanSubData = meanSubData(:, indices,:);
        
        RMSexp = nan(1, size(useMeanSubData, 2));
        for i = 1:size(useMeanSubData,2)
            tempData =squeeze(useMeanSubData(V1, i,before:before+endRMS));
            sqVolt = tempData.^2;
            sumSqVolt = nansum(sqVolt);
            RMSexp(i) = sqrt(sumSqVolt*1/(endRMS+1));
        end
        RMSVolt(ID, experiment) = nanmean(RMSexp);
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
pRMS = kruskalwallis(combRMS);
[p, h, stats]=ranksum(combRMS(:,1), combRMS(:,2))