function [indices] = getStimIndices(stimIndex, indexSeries, uniqueSeries)
% stimSeries =
% indexSeries = vector with the same length as allStartTimes - indexes row
% in uniqueSeries that each allStartsTimes refers to 
% 8/8/18 AA editted for multistim delivery
    [queryIndex] = ismember(stimIndex, uniqueSeries, 'rows');
    indices = find(queryIndex == indexSeries);
end