function [burstIndex, weirdos] = findBurstIndex(prb)
%% Find Burst Indices
%detect, remove outliers
stds = std(prb,[],2);
weirdos = find(isoutlier(stds))';
goods = setdiff(1:length(stds),weirdos);
prb_g = prb(goods,:); %probabilities with only non outlier channels

mprb = mean(prb); %mean the channels
mprb_g = mean(prb_g); 

fullB = find(mprb>.99); %find areas that are full burst or suppression
fullS = find(mprb<.01);

rmprb_g = round(mprb_g); %round the remaning values
shiftForward = [0 rmprb_g(1:(end-1))]; %shift forward by one

pts = find((shiftForward - rmprb_g) == -1 ); %finds where it goes from 0 (sup) to 1 (burst)

s = [];
b = [];

i = 1;
while 1 %do while for each point
    
    temp = pts(i);
    
    stemp = max(fullS(fullS<temp)); %find last  "full suppresion" before given point
    btemp = min(fullB(fullB>temp)); %find first "full burst" before given point
        
    if (btemp - stemp) < 2000 %limit for transition time
    s = [s stemp];
    b = [b btemp];
    end
        
i = i + 1;
if i > length(pts)
    break
end
end

burstIndex = [s' b'];

%{
indexStruct = struct(...
    's',s,...
    'b',b,...
    'weirdos',weirdos...
    );
%}
end
