clear
clc
close all

onAlexsWorkStation = 2; %1 if on workstation with complete multistim data set, 0 if on lab mac, 2 if on laptop

if onAlexsWorkStation ==1
    % Alex's computer
    dirIn = '/data/adeeti/ecog/matIsoPropMultiStimVIS_ONLY_/flashTrials/';
    dirOut1 = '/home/adeeti/GoogleDrive/';
    cd(dirIn)
    load('dataMatrixFlashesVIS_ONLY.mat')
    dataMatrixFlashes = dataMatrixFlashesVIS_ONLY;
elseif onAlexsWorkStation ==0
    % Adeeti's Desktop
    dirIn = '/Users/adeeti/Desktop/data/VIS_Only_Iso_prop_2018/flashTrials/';
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

consistentEP = 3;
threshEP = 2.91;
timeframeEP = 1025:1200;

consistentReturn = 30;
threshReturn = 2;
timeframeReturn = 1000;

allAverageTrace = nan(numSubjects, maxExposuresPerSubject, 3001);
allZData = nan(size(allAverageTrace));

allOGLatEP = nan(numSubjects, maxExposuresPerSubject, 1);
allNewLatEP = nan(size(allOGLatEP));
allNewLatReturn = nan(size(allOGLatEP));
allDuration = nan(size(allOGLatEP));
allLatency = nan(numSubjects, maxExposuresPerSubject, 64);

%% Calculate normalized for magnitude, latency, duration

for ID = 1:numSubjects
    for experiment = 1: maxExposuresPerSubject
        if experiment> numel(allExp{ID})
            continue
        end
        load(dataMatrixFlashes(allExp{ID}(experiment)).expName, 'info', 'aveTrace', 'indexSeries', 'uniqueSeries', 'latency')
        V1 = info.lowLat;
        queryIndex = ismember(stimIndex, uniqueSeries, 'rows');
        useAveTrace = squeeze(aveTrace(queryIndex,:,:));
        
        z=nanstd(useAveTrace(:,preStimTime),0,2);                 % compute the mean and the standard deviation of the signal before the stimulus
        m=nanmean(useAveTrace(:,preStimTime),2);
        
        zData=(useAveTrace-repmat(m, 1, length(useAveTrace)))./repmat(z, 1, length(useAveTrace));
        
        %finding latency for each channel
        EPData = zData(:,timeframeEP);
        for ch = 1:64
            
            latnecyEP = abs(EPData(ch,:))>threshEP;
            conLatEp=convn(latnecyEP', ones(1,consistentEP)/consistentEP, 'same');
            onsetEP = find(conLatEp==1, 1, 'first')-round(consistentEP./2);
            onsetEP = onsetEP + timeframeEP(1)-before;
            
            if isempty(onsetEP)
                onsetEP = nan;
            end
            
            allLatency(ID, experiment,ch) = onsetEP;
        end
        
    end
end

        
%% finding all the channels that have the lowest latency of onset 



sameOnset= nan(numSubjects, maxExposuresPerSubject);
withinOne= nan(numSubjects, maxExposuresPerSubject);
withinTwo= nan(numSubjects, maxExposuresPerSubject);

for ID = 1:numSubjects
    for experiment = 1: maxExposuresPerSubject
        if experiment> numel(allExp{ID})
            continue
        end
        useLat = allLatency(ID,experiment,:);
        lowLat = min(useLat);
        sOnset = numel(find(useLat== lowLat));
        
        if sOnset ==0
            sOnset = 1;
        end
        
        
        
        sameOnset(ID, experiment) = sOnset;
        withinOne(ID, experiment) = sOnset+ numel(find(useLat== lowLat+1));
        withinTwo(ID, experiment) = sOnset+ numel(find(useLat== lowLat+1))+ numel(find(useLat== lowLat+2));
    end
end

        
        
        