function [ff] = frTrElecOnHist_allMice(allConsistElec, goodMiceInd, thr_Multiply, thrInd, useTitleString, colorsPlot, allMiceIDs, edges)
% [ff] = fractTrElecOnHist(allConsistElec, thr_Multiply, allExpNum, useTitleString, colorsPlot, mouseID, edges)

if nargin<8
    edges = 0:0.05:1;
end

%%
screensize = get(groot, 'screensize');
ff= figure('Color', 'w', 'Position', screensize); clf

for g = 1:length(goodMiceInd)
    mouseInd = goodMiceInd(g);
    b(g)= subplot(2,ceil(length(goodMiceInd)/2),g);
    
    useAnesTitles= useTitleString{mouseInd};
    useConsist = squeeze(allConsistElec(mouseInd,:,:,:));
    allExpNum = numel(useAnesTitles);
    mouseID = cell2mat(allMiceIDs(mouseInd));
    
    
    for a = 1:allExpNum
        %useData = squeeze(useConsist(thrInd,a,:));
        %histogram(useData(~isnan(useData)), edges, 'FaceColor', colorsPlot{a})
        histogram(squeeze(useConsist(thrInd,a,:)), edges, 'FaceColor', colorsPlot{a})
        hold on
        legend(useAnesTitles)
    end
    title([mouseID])

end

sgtitle(['Threshold = ', num2str(thr_Multiply(thrInd)), ' Fraction of trials each electrode is active'])








