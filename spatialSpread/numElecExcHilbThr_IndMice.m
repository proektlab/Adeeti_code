%% stats
%numTrials_mouse(mouseCounter, a);
%numChannels_mouse(mouseCounter, a);
             
for mouseCounter= 1:totMice
    for t = 1:numThr
        testSpread = squeeze(nanmean(allSpread(mouseCounter,:,t,:,:),5));  %allSpread(mouseCounter,cond,thr,trials,chan)
        
        fracGridSpread(mouseCounter,t,:,:) = testSpread;
        testSpread = testSpread';
        pSpd_frElctAct(mouseCounter,t) = kruskalwallis(testSpread,[],'off');
        
        consitSpread = squeeze(nanmean(allSpread(mouseCounter,:,t,:,:),4));
        allConsistElec(mouseCounter,t,:,:) = consitSpread;
        consitSpread = consitSpread';
        pEct(mouseCounter,t) = kruskalwallis(consitSpread,[],'off');
        
        
        for i = 1:length(MFE)
            for j = i+1:length(MFE)
                if sum(isnan(testSpread(:,i))) == size(testSpread,1) || sum(isnan(testSpread(:,j))) == size(testSpread,1)
                    continue
                else 
                [pTemp, hTemp, ~]=ranksum(testSpread(:,i), testSpread(:,j));
                
                P_RS_Spread(mouseCounter,t,i,j) = pTemp;
                H_RS_Spread(mouseCounter,t,i,j) = hTemp;
                end
               
                
                if sum(isnan(consitSpread(:,i))) == size(consitSpread,1) || sum(isnan(consitSpread(:,j))) == size(consitSpread,1)
                    continue
                else 
                [pTemp, hTemp, ~]=ranksum(consitSpread(:,i), consitSpread(:,j));
                
                P_RS_ConsitEl(mouseCounter,t,i,j) = pTemp;
                H_RS_ConsitEl(mouseCounter,t,i,j) = hTemp;
                end
            end
        end
    end
end
%

%% Making individual figures per aniamal 
for mouseCounter = 1:totMice
    useAnesTitles= useTitleString{mouseCounter};
    allExpNum = numel(useAnesTitles);
    mouseID = cell2mat(allMiceIDs(mouseCounter));
    
    useSpread = squeeze(fracGridSpread(mouseCounter,:,:,:));
    useConsist = squeeze(allConsistElec(mouseCounter,:,:,:));

    usePSpread = pSpd_frElctAct(mouseCounter,:);
    usePEct = pEct(mouseCounter,:);
    
    maxCutPVal = 0.0001;
    
    
    % Looking at number of electrodes activated per each trial - spread
    close all
    [ff] = fractActiveElectFig(useSpread, usePSpread, thr_Multiply, allExpNum, useAnesTitles, mouseID, info);
  %  saveas(ff, [dirPicLoc, mouseID, '_ST_numElec_multThr.png'])
    
    
    % Looking at how many trials each electrodes was active on  - for ind electrodes
    close all
    [ff] = fractTrEachElectOnFig(useConsist, usePEct, thr_Multiply, colorsPlot, useAnesTitles, mouseID, maxCutPVal);
   % saveas(ff, [dirPicLoc, mouseID, '_ST_whichElec_multThr.png'])
    
    % Looking at fraction of trials electrodes were active on
    close all
    [ff] = fractTrElecOnHist(useConsist, thr_Multiply, allExpNum, useAnesTitles, colorsPlot, mouseID);
    %saveas(ff, [dirPicLoc, mouseID, '_ST_fracTrEleActive_multThr.png'])

end

%% Quickly looking all all stats 
close all

thrInd = 2;
useThr = thr_Multiply(thrInd);

titleThresh = [];
for i = 1:length(thr_Multiply)
    titleThresh{i} = ['Thresh = ', num2str(thr_Multiply(i))];
end
[ff, pTableSpread, compTitle] = deconstPspreadTable(P_RS_Spread, [], [thrInd], titleString, titleThresh,allMiceIDs);
sgtitle('Rank Sum P values for number of electrodes active each trial')

[ff, pTableConsit, compTitle] = deconstPspreadTable(P_RS_ConsitEl, [], [thrInd], titleString, titleThresh,allMiceIDs);
sgtitle('Rank Sum P values for trials each electrode is active for')


%% Averaging stats per mouse group 

useMice = [1:5];
pValueLim = 0.05/(numel(useMice)*numel(compTitle));

testSpread = pTableSpread(:,useMice);
testConist = pTableConsit(:,useMice);

propSpread = nan(size(testSpread));
propConsist = nan(size(testConist));

propSpread(find(pTableSpread(:,useMice)<pValueLim)) = 1;
propConsist(find(pTableConsit(:,useMice)<pValueLim)) = 1;

propSpread(find(pTableSpread(:,useMice)>pValueLim)) = 0
propConsist(find(pTableConsit(:,useMice)>pValueLim)) = 0

gM_Spread_mean= nanmean(propSpread,2)
gM_Consist_mean= nanmean(propConsist,2)


%% Make a figure of spread and consistancy of the good mice seperately 

thrInd = 2;

[ff] = frTrElecOnHist_allMice(allConsistElec, useMice, thr_Multiply, thrInd, useTitleString, colorsPlot, allMiceIDs)

[ff] = frTrPerElec_allMice(allConsistElec, useMice, thr_Multiply, thrInd, useTitleString, colorsPlot, allMiceIDs)
