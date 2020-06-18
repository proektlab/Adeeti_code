function [ff] = fractActiveElectFig(allSpread, pSpread, thr_Multiply, allExpNum, useTitleString, mouseID, info, edges, maxCutPVal)
% [ff] = fractActiveElectFig(allSpread, pSpread, thr_Multiply, allExpNum, useTitleString, mouseID, numGoodChan, edges, maxCutPVal)

if nargin<8
    edges = 0:0.05:1;
end

if nargin<9
    maxCutPVal = 0.0001;
end

%%

goodChan = info.ecogChannels;
goodChan(info.noiseChannels)= [];
numGoodChan= numel(goodChan);

numThr = length(thr_Multiply);
ff= figure('Color', 'w', 'Position', [1 -138 827 954]); clf

useChanNum = min(20,numGoodChan);
counter = 0;
for t= 1:numThr
    if pSpread(t) <maxCutPVal
        pSpread(t) = maxCutPVal;
    end
    for a = 1:allExpNum
        counter = counter +1;
        b(counter)= subplot(numThr,allExpNum,a+(t-1)*allExpNum);
        h(counter) = histogram(squeeze(allSpread(t,a,:)),edges);
        
        if t ==1
            title([useTitleString{a}, ' Thr: ', num2str(thr_Multiply(t)), ' p=', num2str(pSpread(t))])
        elseif a ==2 && t~=1
            title([' Thr: ', num2str(thr_Multiply(t)), ' p=', num2str(pSpread(t))])
        end
    end
end

sgtitle([mouseID, ' Fraction of Active Electrodes'])