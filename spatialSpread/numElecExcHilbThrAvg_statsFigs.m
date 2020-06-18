%% stats
%numTrials_mouse(mouseCounter, a);
%numChannels_mouse(mouseCounter, a);
      
numCond = size(allSpread,2);
clearvars P_RS_Spread fracGridSpread

for mouseCounter= 1:totMice
    for t = 1:numThr
        %to look at spread
        testSpread = squeeze(nanmean(allSpread(mouseCounter,:,t,:),4));  %allSpread(mouseCounter,cond,thr,chan)
        fracGridSpread(mouseCounter,t,:) = testSpread;
    end
end

% for t= 1:numThr
%             useSpread = squeeze(fracGridSpread(:,t,:));
%         pSpd_frElctAct(t) = kruskalwallis(useSpread, titleString ,'on');
%         
%         for i = 1:length(MFE)
%             for j = i+1:length(MFE)
%                 [pTemp, hTemp, ~]=ranksum(useSpread(:,i), useSpread(:,j));
%                 
%                 P_RS_Spread(t,i,j) = pTemp;
%                % H_RS_Spread(t,i,j) = hTemp;
%             end
%         end
% end


%%
%allSpread(mouseCounter,cond,thr,trials,chan)
%fracGridSpread(mouseCounter,thr,cond,trial)
%allConsistElec(mouseCounter,thr,cond,chan)

useThr = 1;
goodMInd = 1:5;
maybeMInd = 6:11;
allMInd = [goodMInd, maybeMInd];

useFrac = squeeze(fracGridSpread(goodMInd,useThr,:));


%% concatonate all single trials of all mice together per condition and look at spread

pSpd_frElctAct = kruskalwallis(useFrac, titleString ,'on');

for i = 1:length(MFE)
    for j = i+1:length(MFE)
        [pTemp, hTemp, ~]=ranksum(useFrac(:,i), useFrac(:,j));
        
        P_RS_Spread(i,j) = pTemp;
        % H_RS_Spread(t,i,j) = hTemp;
    end
end

pSpd_frElctAct
P_RS_Spread
%%
edges = 0:0.05:1;
ff= figure('Color', 'w')
for i = 1:numCond
    useData = useFrac(:,i);
        histogram(useData(~isnan(useData)), edges, 'Normalization','probability','FaceColor', colorsPlot{i})
        hold on
        legend(titleString, 'Location','NorthWest')
end
xlabel('Fraction of electrodes active during VEP','fontsize', 16)
ylabel('Prercent of Trials','fontsize', 16)

figure;  violinplot(useFrac, titleString)

%% looking at amplitude

useAmp = allAmpOnly(goodMInd,:);

pAmp_concat= kruskalwallis(allAmpOnly, titleString, 'on'); %,[],'off');

P_RS_Amp_concat = nan(numCond,numCond);
for i = 1:length(MFE)
    for j = i+1:length(MFE)
            [pTemp, hTemp, ~]=ranksum(useAmp(:,i), useAmp(:,j));
            
            P_RS_Amp_concat(i,j) = pTemp;
    end
end

pAmp_concat
P_RS_Amp_concat

bins = 5;
ff= figure('Color', 'w')
for i = 1:numCond
    useData = useAmp(:,i);
        histogram(useData(~isnan(useData)), bins, 'Normalization','probability','FaceColor', colorsPlot{i})
        hold on
        legend(titleString, 'Location','NorthWest')
end
xlabel('Gamma power during VEP','fontsize', 16)
ylabel('Prercent of Trials','fontsize', 16)
