function [ff] = fractTrEachElectOnFig(allConsistElec, pEct, thr_Multiply, colorsPlot, useTitleString, mouseID, maxCutPVal)
% [ff] = fractTrEachElectOnFig(allSpread, pSpread, thr_Multiply, allExpNum, useTitleString, mouseID, numGoodChan, edges, maxCutPVal)

if nargin<6
    mouseID = [];
end

if nargin<7
    maxCutPVal = 0.0001;
end

%%
screensize = get(groot, 'screensize');
numThr = length(thr_Multiply);
ff= figure('Color', 'w', 'Position', screensize); clf

for t= 1:numThr
    if pEct(t) <maxCutPVal
        pEct(t) = maxCutPVal;
    end
    b(t)= subplot(1,numThr,t);
    for a = 1:length(colorsPlot)
        if sum(isnan(allConsistElec(t,a,:))) == size(allConsistElec,3)
            continue
        end
        plot(squeeze(allConsistElec(t,a,:))', colorsPlot{a}) ;
        hold on
    end
    
    legend(useTitleString)
    set(gca, 'ylim', [min(allConsistElec(:)), max(allConsistElec(:))])
    title([' Thr: ', num2str(thr_Multiply(t)), ' p=', num2str(pEct(t))])
end
sgtitle([mouseID, ' activity pattern of electrodes'])