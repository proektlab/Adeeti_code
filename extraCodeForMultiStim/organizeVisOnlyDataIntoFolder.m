% extracting all the Vis only files and putting them in a folder 
%10/25/18 AA

clc
clear
close all

dirInFlashes = '/data/adeeti/ecog/matIsoPropMultiStim/';
dirInBaseline = '/data/adeeti/ecog/matBaselineIsoPropMultiStim/';
dirOut1 = '/data/adeeti/ecog/matIsoPropMultiStimVIS_ONLY_/flashTrials/';
dirOut2 = '/data/adeeti/ecog/matIsoPropMultiStimVIS_ONLY_/baseline/';

cd(dirInFlashes)
load('dataMatrixFlashes.mat')
load('matStimIndex.mat')

stimIndex = [0, Inf]; %if want all, stimIndex = matStimIndex; % if want
%all uniStimIndexes/multiStimIndexes, use [uniStimIndex, multiStimIndex] =
%findUniMutliStimIndex(matStimIndex), [stimIndex, ~] = findUniMutliStimIndex(matStimIndex)

% Setting up parameters
allExp = [];
if exist('stimIndex')  && ~isempty(stimIndex)
    for i = 1:size(stimIndex,1)
        [MFE] = findMyExpMulti(dataMatrixFlashes, [], [], [], stimIndex(i,:));
        allExp = [allExp, MFE];
    end
else
    [MFE] = 1:length(dataMatrixFlashes);
end
mkdir(dirOut1);
mkdir(dirOut2);
mkdir([dirOut1, 'Wavelets/FiltData/']);
mkdir([dirOut2, 'Wavelets/']);

%% moving the trial data 

cd(dirInFlashes)
for i = 1:length(allExp)
    temp = dataMatrixFlashes(allExp(i)).expName;
    temp = temp(39:end);
    copyfile(temp, dirOut1)
end

for i = 1:length(dataMatrixFlashes)
    temp = dataMatrixFlashes(i).expName;
    temp = temp(39:end);
    dataMatrixFlashes(i).expName = temp;
end

dataMatrixFlashesVIS_ONLY = dataMatrixFlashes(allExp);
save([dirOut1, 'dataMatrixFlashesVIS_ONLY.mat'], 'dataMatrixFlashesVIS_ONLY')

%% moving wavelets and filtered data into visual only folder 

cd([dirInFlashes, 'Wavelets/'])
for i = 1:length(allExp)
    temp = dataMatrixFlashesVIS_ONLY(i).expName;
    temp = [temp(1:end-4), 'wave.mat'];
    copyfile(temp, [dirOut1, 'Wavelets/'])
end

cd([dirInFlashes, 'Wavelets/FiltData/'])
for i = 1:length(allExp)
    temp = dataMatrixFlashesVIS_ONLY(i).expName;
    temp = [temp(1:end-4), 'wave.mat'];
    copyfile(temp, [dirOut1, 'Wavelets/FiltData/'])
end

%% moving the baseline data 

cd(dirInFlashes)
load('dataMatrixFlashes.mat')
load('matStimIndex.mat')

cd(dirInBaseline)
for i = 1:length(allExp)
    load(dataMatrixFlashes(allExp(i)).expName)
    temp = dataMatrixFlashes(allExp(i)).expName;
    temp = temp(39:end);
    copyfile(temp, dirOut2)
end

for i = 1:length(dataMatrixFlashes)
    temp = dataMatrixFlashes(i).expName;
    temp = temp(39:end);
    dataMatrixFlashes(i).expName = temp;
end

save([dirInBaseline, 'dataMatrixFlashes.mat'], 'dataMatrixFlashes')
save([dirInBaseline, 'matStimIndex.mat'], 'matStimIndex')

dataMatrixFlashesVIS_ONLY = dataMatrixFlashes(allExp);
save([dirOut2, 'dataMatrixFlashesVIS_ONLY.mat'], 'dataMatrixFlashesVIS_ONLY')

%% moving wavelets for baseline data into visual only folder 

cd([dirInBaseline, 'Wavelets/'])
for i = 1:length(allExp)
    temp = dataMatrixFlashesVIS_ONLY(i).expName;
    temp = [temp(1:end-4), 'wave.mat'];
    copyfile(temp, [dirOut2, 'Wavelets/'])
end
