function [ff] = frTrPerElec_allMice(allConsistElec, goodMiceInd, thr_Multiply, thrInd, useTitleString, colorsPlot, allMiceIDs)
% [ff] = fractTrElecOnHist(allConsistElec, thr_Multiply, allExpNum, useTitleString, colorsPlot, mouseID, edges)

%%
screensize = get(groot, 'screensize');
ff= figure('Color', 'w', 'Position', screensize); clf

for g = 1:length(goodMiceInd)
    mouseInd = goodMiceInd(g);
    b(g)= subplot(2,ceil(length(goodMiceInd)/2),g);
    
    useAnesTitles= useTitleString{mouseInd};
    useConsist = squeeze(allConsistElec(mouseInd,:,:,:));
    mouseID = cell2mat(allMiceIDs(mouseInd));
    
    
    for a = 1:length(colorsPlot)
        %useData = squeeze(useConsist(thrInd,a,:));
        %histogram(useData(~isnan(useData)), edges, 'FaceColor', colorsPlot{a})
        if sum(isnan(useConsist(thrInd,a,:))) == size(useConsist,3)
            continue
        end
        plot(squeeze(useConsist(thrInd,a,:))', colorsPlot{a}) ;
        hold on
       
    end
    legend(useAnesTitles)
    title([mouseID])

end

sgtitle(['Threshold = ', num2str(thr_Multiply(thrInd)), ' Fraction of trials each electrode is active'])