function [forStatsLatency] = statsLatency(data)
 aveData = mean(data, 1);

before=1;
l = 3;
flashOn = [0,0];
thresh=4;
maxThresh = 8;
consistent = 4;
endMeasure = 0.35;
 
[~, forStatsLatency ] = normalizedThreshold(aveData, thresh, maxThresh, consistent, endMeasure, before, finalSampR)
end
