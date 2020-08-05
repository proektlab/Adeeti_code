%% stats
%numTrials_mouse(mouseCounter, a);
%numChannels_mouse(mouseCounter, a);
      
numCond = size(allSpread,2);

for mouseCounter= 1:totMice
    for t = 1:numThr
        %to look at spread
        testSpread = squeeze(nanmean(allSpread(mouseCounter,:,t,:,:),5));  %allSpread(mouseCounter,cond,thr,trials,chan)
        fracGridSpread(mouseCounter,t,:,:) = testSpread;
        testSpread = testSpread';
        pSpd_frElctAct(mouseCounter,t) = kruskalwallis(testSpread,[],'off');
        
        %to look at consistancy
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


%figure;  violinplot(fracElc_CondConcat, {'High Iso', 'Low Iso', 'Awake', 'Ketamine'})

%%
%allSpread(mouseCounter,cond,thr,trials,chan)
%fracGridSpread(mouseCounter,thr,cond,trial)
%allConsistElec(mouseCounter,thr,cond,chan)

useThr = 1;
goodMInd = 1:5;
maybeMInd = 6:11;
allMInd = [goodMInd, maybeMInd];

useFrac = squeeze(fracGridSpread(goodMInd,useThr,:,:));
useConst = squeeze(allConsistElec(goodMInd,useThr,:,:));



%% averaging the numbers over mice - collapes the spread vs consistancy
% 
% allMiceAvgFrac = squeeze(nanmean(useFrac,3));
% %allMiceAvgConst = squeeze(nanmean(useConst,3));
% 
% pSpr_avgM= kruskalwallis(allMiceAvgFrac) %,[],'off');
% %pEct_avgM= kruskalwallis(allMiceAvgConst) %,[],'off');
% 
% P_RS_Spread_avgM = nan(numCond,numCond);
% H_RS_Spread_avgM = nan(numCond,numCond);
% for i = 1:length(MFE)
%     for j = i+1:length(MFE)
%             [pTemp, hTemp, ~]=ranksum(allMiceAvgFrac(:,i), allMiceAvgFrac(:,j));
%             
%             P_RS_Spread_avgM(i,j) = pTemp;
%             H_RS_Spread_avgM(i,j) = hTemp;
% 
%     end
% end
% 
% P_RS_Spread_avgM


%% concatonate all single trials of all mice together per condition and look at spread
fracElc_CondConcat = [];
for i = 1:numCond
    fracElc_CondConcat(i,:) = reshape(squeeze(useFrac(:,i,:)), [1,size(useFrac,1)*size(useFrac,3)]);
end

fracElc_CondConcat = fracElc_CondConcat';
pSpr_KW_concat= kruskalwallis(fracElc_CondConcat, titleString); %,[],'off');

P_RS_Spread_concat = nan(numCond,numCond);
H_RS_Spread_concat = nan(numCond,numCond);
for i = 1:length(MFE)
    for j = i+1:length(MFE)
            [pTemp, hTemp, ~]=ranksum(fracElc_CondConcat(:,i), fracElc_CondConcat(:,j));
            
            P_RS_Spread_concat(i,j) = pTemp;
            H_RS_Spread_concat(i,j) = hTemp;

    end
end

pSpr_KW_concat
P_RS_Spread_concat

edges = 0:0.05:1;
ff= figure('Color', 'w')
for i = 1:numCond
    useData = fracElc_CondConcat(:,i);
        histogram(useData(~isnan(useData)), edges, 'Normalization','probability','FaceColor', colorsPlot{i})
        hold on
        legend(titleString, 'Location','NorthWest')
end
xlabel('Fraction of electrodes active during VEP','fontsize', 16)
ylabel('Prercent of Trials','fontsize', 16)

figure;  violinplot(fracElc_CondConcat, titleString)

%% looking at amplitude

useAmp_concat = [];
for i = 1:numCond
    useAmp_concat(i,:) = reshape(squeeze(allAmpOnly(:,i,:)), [1,size(allAmpOnly,1)*size(allAmpOnly,3)]);
end

useAmp_concat = useAmp_concat';
pAmp_concat= kruskalwallis(useAmp_concat); %,[],'off');

P_RS_Amp_concat = nan(numCond,numCond);
for i = 1:length(MFE)
    for j = i+1:length(MFE)
            [pTemp, hTemp, ~]=ranksum(useAmp_concat(:,i), useAmp_concat(:,j));
            
            P_RS_Amp_concat(i,j) = pTemp;

    end
end

pAmp_concat
P_RS_Amp_concat

bins = 50;
ff= figure('Color', 'w')
for i = 1:numCond
    useData = useAmp_concat(:,i);
        histogram(useData(~isnan(useData)), bins, 'Normalization','probability','FaceColor', colorsPlot{i})
        hold on
        legend(titleString, 'Location','NorthWest')
end
xlabel('Gamma power during VEP','fontsize', 16)
ylabel('Prercent of Trials','fontsize', 16)
