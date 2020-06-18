function [ff] = fractTrElecOnHist(allConsistElec, thr_Multiply, allExpNum, useTitleString, colorsPlot, mouseID, edges)
% [ff] = fractTrElecOnHist(allConsistElec, thr_Multiply, allExpNum, useTitleString, colorsPlot, mouseID, edges)

if nargin<6
    mouseID = [];
end
if nargin<7
    edges = 0:.05:1;
end

%%
screensize = get(groot, 'screensize');
numThr = length(thr_Multiply);
ff= figure('Color', 'w', 'Position', screensize); clf

for t= 1:numThr
    b(t)= subplot(1,numThr,t);
    for a = 1:allExpNum
        histogram(allConsistElec(t,a,:), edges, 'FaceColor', colorsPlot{a})
        hold on
        legend(useTitleString)
    end
    title(['Threshold = ', num2str(thr_Multiply(t))])
end

sgtitle([mouseID, ' Fraction of trials each electrode is active'])