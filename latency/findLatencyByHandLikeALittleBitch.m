dirIn ='/data/adeeti/ecog/matFlashesJanMar2017';

cd(dirIn)
identifier = '2017*.mat';

allData = dir(identifier);

V1latency = nan(size(allData, 1),3);

if ~exist('savePoint')
    savePoint = 1;
end

for exp = savePoint:length(allData)
    load(dataMatrixFlashes(exp).name, 'info', 'latency', 'aveTrace')
    figure(1);
    clf;
    hold on;
    plot(zscore(squeeze(aveTrace(info.V1, :))));
    plot([0 3000], [1 1]*2, 'r');
    plot([1000 1000], [-1 2], 'k--');
    xlim([800 1300]);
    
    V1latency(exp,1) = input('Where is latency?');
    V1latency(exp,2) = info.AnesLevel;
    V1latency(exp,3) = info.exp;
    
    savePoint = exp;
end

V1LatByHand = V1latency;

%%

edges = 0:2:100;
figure
histogram(V1LatByHand(:,1), edges)

boxplot(V1LatByHand(:,1),V1LatByHand(:,2))

boxplot(V1LatByHand(:,1),V1LatByHand(:,3))

%% Mean Differences 

sortedLatencies = {};
means = [];
stds = [];

allExp = unique(V1LatByHand(:,3));
allIso = unique(V1LatByHand(:,2));

for i =1:length(allExp)
    for j = 1:length(allIso)
        thisIndices = find(ismember(V1LatByHand(:,2:3), [allIso(j) allExp(i)], 'rows'));
        sortedExp(i,j) = length(thisIndices);
        sortedLatencies{i,j} = V1LatByHand(thisIndices,1);
        means(i,j) = nanmean(sortedLatencies{i,j});
        stds(i,j) = nanstd(sortedLatencies{i,j});
    end
end


%% 
% % allNoise = [];
% % for e= 1:length(allExp)
% %     x = find([dataMatrixFlashes.exp] == allExp(e), 1, 'first')
% %     allNoise = [allNoise, dataMatrixFlashes(x).noiseChannels];
% % end
% % 
% % neverNoise = find(~ismember(1:64, unique(allNoise)));
% % 

%%

