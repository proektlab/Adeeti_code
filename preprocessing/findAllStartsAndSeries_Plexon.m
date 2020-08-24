function [allStimStarts, allStartTimes, stimOffSet, uniqueSeries, indexSeries] = findAllStartsAndSeries_Plexon(eveID, eveTime, LFPData, finalSampR, interPulseInterval, cutoff)
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

%% Organizing the events and start times into a single vector 

%diffEveID = diff(eveID);
allEveTimes =[];
count = 1;
for i = 1:length(eveID)
    chan = eveID{i};
    eveChan= str2num(chan(regexp(chan, '\d')));
    numEvents = length(eveTime{i});
    allEveTimes(count:count+numEvents-1,1) = eveTime{i};
    allEveTimes(count:count+numEvents-1,2) = eveChan;
    count = count+numEvents;
end

%sorting events by time
[~, I]= sort(allEveTimes(:,1));
allEveTimes = allEveTimes(I,1);

%% Find Trials

diffEveTime = diff(allEveTimes(:,1));
stopRecording = size(LFPData,2)/finalSampR;

allStimStarts = eveTime;

allStartTimes = [allEveTimes(1); allEveTimes(find(diffEveTime> timeThresh)+1)];


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

[uniqueSeries, ~, indexSeries] = unique(stimOffSet, 'rows');

