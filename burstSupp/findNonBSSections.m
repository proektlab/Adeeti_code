%this is a function that finds the starting and ending indices of bursts
%7/2/2020 JL, some chunks copied from Jared's code

function [confuseIndex, weirdos] = findNonBSSections(prb)
%% Find Burst Indices

%finds outliers
stds = std(prb,[],2);
weirdos = find(isoutlier(stds))';
goods = setdiff(1:length(stds),weirdos);
prb_g = prb(goods,:); %probabilities with only non outlier channels

mprb = mean(prb); %mean the channels
mprb_g = mean(prb_g);

%for testing
%mprb_g = prb;

thresholdLow = 0.3;
thresholdHigh = 0.7;
isConfusing = (mprb_g > thresholdLow) &  (mprb_g < thresholdHigh);

shiftForward = [0 isConfusing(1:(end-1))]; %shift forward by one
%finds where it goes from 0 (ok) to 1 (confusing)
confuseStartPts = find((shiftForward - isConfusing) == -1 );  

shiftBackwards = [isConfusing(2:end), 1]; %shift backwards by one
%finds where it goes from 1 (confusing) to 0 (ok)
confuseEndPts = find((shiftBackwards - isConfusing) == -1 ); 

%adjust for whether it starts with a burst

if isConfusing(end) == 1
    confuseIndex = [confuseStartPts; confuseEndPts, numel(isConfusing)];
else
    confuseIndex = [confuseStartPts; confuseEndPts];
end

%remove short periods of confusion

shortThresh = 1000;
okLen = zeros(1, size(confuseIndex, 2));

for i = size(confuseIndex, 2)
    okLen(i) = (confuseIndex(2, i) - confuseIndex(1, i) > shortThresh);
end

confuseIndex = confuseIndex(find(okLen));

end

