function [allStimStarts, allStartTimes, stimOffSet, uniqueSeries, indexSeries] = findAllStartsAndSeries(eveID, eveTime, stimIDs, interPulseInterval, cutoff)
% [allStarts, allStimTimes, uniStimOnlyStarts, multiStimStarts] = findUpto4MultiAndUniStimStarts(eveID, eveTime, stimIDs, interPulseInterval)
% load and include eveID and eventTime
% stimIDs are in the order of stim1, stim2, stim3, stim4, write the bit
% position of the stim ID, if there are only 2 stim, this is a two 
% interPulseIntervals needs to be min time between stimuli in seconds
%

% 8/9/18 AA editted for mutlistim and added cutoff
%% Parameters 
if nargin < 3
    stimIDs = [1,2]; % usually two stimuli are put in ports 1 and 2
end
if nargin < 4
    interPulseInterval = 3; % min time between trials is 3 seconds
end
if nargin < 5
    cutoff = interPulseInterval; 
end


timeThresh = interPulseInterval/3; %Threshold was set conservatively to three

%% Finding trial starts based on bit mapping (barf)

diffEveID = diff(eveID);
diffEveTime = diff(eveTime);
stopRecording = eveTime(end);

for i = 1:length(stimIDs)
    allStimChanges{i} = find(bitget(abs(diffEveID), stimIDs(i))); %checks each bit postion of the difference in eveID to see if there was a change in the TTL high or low position 
end

for i = 1:size(allStimChanges,2) %all changes from above happen from on to off or off to on
    onsAndOffs{i} = ones(size(allStimChanges{i})); 
    onsAndOffs{i}(2:2:end) = 0; %very first pulse is off 
end

for i = 1:length(stimIDs)
    allStimStarts{i} = eveTime(allStimChanges{i}(find(onsAndOffs{i}==1))+1); 
end

startTrials = find(diffEveTime> timeThresh)+1;

allStartTimes = eveTime(startTrials);
allStartTimes = allStartTimes(1:end-1);

if stopRecording - allStartTimes(end) < cutoff
    allStartTimes = allStartTimes(1:end-1);
end


for i = 1:length(allStartTimes)
    for j = 1:size(allStimStarts,2)
        indStimOnTime = allStimStarts{j}(find(allStimStarts{j}>= allStartTimes(i) & allStimStarts{j}< allStartTimes(i)+timeThresh));
        if isempty(indStimOnTime)
            stimOffSet(i,j) = inf;
        else
            stimOffSet(i,j) = max(indStimOnTime - allStartTimes(i));
        end
        
    end
end

stimOffSet = round(stimOffSet, 3);

%%

[uniqueSeries, ~, indexSeries] = unique(stimOffSet, 'rows');
end


