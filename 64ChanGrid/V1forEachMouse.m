function [allV1, onsetMat] = V1forEachMouse(useStimIndex, useNumStim, stimIndex, numStim, variableName, thresh, saveV1)
%[allV1, onsetMat] = V1forEachMouse(useStimIndex, useNumStim, stimIndex, numStim, variableName, thresh, saveV1)
%dirIn = directory to evaluate
%identifer = '2018*.mat'
%saveV1 = 1 of want to save V1 to the info files, 0 if not, defualt is set
%to one
%variableName = string of variable to save in info e.g., V1, S1, lowestLat,
%default is set to V1 for VEPs
%thresh is number at which latency has to be greater than to be counted as
%a hit - default is set to 30 for VEPs
% 8/8/18 AA editted for multistim delivery
% 11/19/19 AA edited for numStim - fixed ismember change in syntax

%%


if nargin <7
    saveV1 = 1;
end
if nargin <6
    thresh = 3;
end
if nargin <5
    variableName = 'lowLat';
end
if nargin <4
    numStim = [];
end
if nargin <3
    stimIndex = [];
end
if nargin <2
    useNumStim = [];
end
if nargin <1
    useStimIndex = [];
end

if isempty(useStimIndex)
    useStimIndex = 0;
end

if isempty(useNumStim)
    useNumStim = 0;
end

if useStimIndex ==0 && numStim ==0
    error('You did not specify how to determine which stimulus to get latency information for')
end

%% Finding overall V1 for experiment
load('dataMatrixFlashes.mat')
allExp =unique(vertcat(dataMatrixFlashes(:).exp));
relaventExperiments = {};

%% if using stim index
if useStimIndex == 1
    for i =1:length(allExp)
        genvarname(['exp',  num2str(allExp(i)), 'V1']);
        eval(['exp',  num2str(allExp(i)), 'V1 = [];'])
        [MFE] = findMyExpMulti(dataMatrixFlashes, allExp(i), [], [], stimIndex);
        relaventExperiments{i} = MFE;
    end
    for i = 1:size(relaventExperiments,2)
        for j = 1:size(relaventExperiments{i},2)
            dataIndex = relaventExperiments{i}(j);
            load(dataMatrixFlashes(dataIndex).expName(end-22:end), 'latency', 'info', 'uniqueSeries')
            
            [~,latIndex] = find(ismember(stimIndex, uniqueSeries, 'rows'));
            latency = squeeze(latency(latIndex,:));
            sortLatency = sort(latency);
            onset = find(sortLatency>=thresh, 1, 'first');
            if isempty(onset)
                onset = nan;
                onsetMat{i}(j) = nan;
            else
                onsetMat{i}(j) = [sortLatency(onset)];
            end
            if isnan(onset)
                V1 = nan;
            else
                V1 = find(latency == sortLatency(onset), 1, 'first');  % channel with latency shortest but greater than zero
                eval(['exp',  num2str(allExp(i)), 'V1 = [exp',  num2str(allExp(i)), 'V1, V1];'])
            end
        end
    end
end

%% If sorting by num of stim
if useNumStim == 1
    for i =1:length(allExp)
        genvarname(['exp',  num2str(allExp(i)), 'V1']);
        eval(['exp',  num2str(allExp(i)), 'V1 = [];'])
        [MFE] = findMyExpMulti(dataMatrixFlashes, allExp(i), [], [], [], numStim);
        relaventExperiments{i} = MFE;
    end
    for i = 1:size(relaventExperiments,2)
        for j = 1:size(relaventExperiments{i},2)
            dataIndex = relaventExperiments{i}(j);
            load(dataMatrixFlashes(dataIndex).expName(end-22:end), 'latency', 'info', 'uniqueSeries')
            
            [~,latIndex] = find(ismember(stimIndex, uniqueSeries, 'rows'));
            latency = squeeze(latency(latIndex,:));
            sortLatency = sort(latency);
            onset = find(sortLatency>=thresh, 1, 'first');
            if isempty(onset)
                onset = nan;
                onsetMat{i}(j) = nan;
            else
                onsetMat{i}(j) = [sortLatency(onset)];
            end
            if isnan(onset)
                V1 = nan;
            else
                V1 = find(latency == sortLatency(onset), 1, 'first');  % channel with latency shortest but greater than zero
                eval(['exp',  num2str(allExp(i)), 'V1 = [exp',  num2str(allExp(i)), 'V1, V1];'])
            end
        end
    end
end

for i = 1:length(allExp)
    eval(['exp',  num2str(allExp(i)), 'V1 = mode(exp',  num2str(allExp(i)), 'V1);'])
end

for i = 1:length(allExp)
    allV1(1,i) = [allExp(i)];
    eval(['allV1(2,', num2str(i), ') = [exp',  num2str(allExp(i)), 'V1];'])
end
%%
if saveV1 ==1
    for i = 1:size(relaventExperiments,2)
        for j = 1:size(relaventExperiments{i},2)
            dataIndex = relaventExperiments{i}(j);
            load(dataMatrixFlashes(dataIndex).expName(end-22:end), 'info')
            expIndex = find(allV1(1,:) == info.exp);
            eval(['info.', variableName, ' = allV1(2, expIndex)'])
            save(dataMatrixFlashes(dataIndex).expName(end-22:end), 'info', '-append')
            eval(['dataMatrixFlashes(dataIndex).', variableName, ' = allV1(2, expIndex)'])
        end
    end
    save('dataMatrixFlashes.mat', 'dataMatrixFlashes', '-append')
end


