%this is a function that finds the starting and ending indices of bursts
%7/2/2020 JL, some chunks copied from Jared's code

function [burstIndex, burstLen, supLen, weirdos] = findBurstIndex(prb)
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

threshold = 0.9;
isBurst = ceil(mprb_g - threshold);

shiftForward = [0 isBurst(1:(end-1))]; %shift forward by one
%finds where it goes from 0 (sup) to 1 (burst)
burstStartPts = find((shiftForward - isBurst) == -1 );  

shiftBackwards = [isBurst(2:end), 1]; %shift backwards by one
%finds where it goes from 1 (burst) to 0 (sup)
burstEndPts = find((shiftBackwards - isBurst) == -1 ); 

%adjust for whether it starts with a burst

if isBurst(end) == 1
    burstIndex = [burstStartPts; burstEndPts, numel(isBurst)];
else
    burstIndex = [burstStartPts; burstEndPts];
end


burstLen = zeros(1, size(burstIndex,2)); %length of bursts
supLen = []; %length of supresses

for i = 1:size(burstIndex,2) %convert indices to lengths
    burstLen(i) = burstIndex(2, i) - burstIndex(1, i) + 1;
    if i > 1
        supLen(i-1) = burstIndex(1, i) - burstIndex(2, i - 1) - 1;
    end
end

if isBurst(1) == 0
    supLen = [burstIndex(1, 1) - 1, supLen];
end

if isBurst(end) == 0
    supLen = [supLen, (numel(isBurst) - burstIndex(2, end))];
end

