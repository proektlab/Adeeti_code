%% Finding latency of onset for all channels and of V1 for all experiments 

dirIn = '/data/adeeti/ecog/matFlashesJanMar2017';
cd(dirIn)
identifier = '2017*.mat';

allData = dir(identifier);

[allV1] = V1forEachMouse(pwd);

V1latency = nan(size(allData, 1), 1);
allLatency = nan(size(allData, 1), 64);

for exp = 1:length(allData)
    load(allData(exp).name, 'latency', 'info')
    allLatency(exp, :) = latency;
    V1 = allV1(2,(find(allV1(1,:)== info.exp)));
    V1latency(exp) = latency(V1);
end

edges = 0:10:250;
figure
histogram(allLatency(:), edges);

V1Edges = 0:2:152;
figure
histogram(V1latency(:), V1Edges);

figure
boxplot(V1latency)

%% 

V1LatPt8 = [];
V1Lat1 = [];
V1Lat1pt2 = [];

for exp = 1:length(allData)
    load(allData(exp).name, 'latency', 'info')
    V1 = allV1(2,(find(allV1(1,:)== info.exp)));
    if info.AnesLevel ==0.8
        temp = latency(V1);
        V1LatPt8 = [V1LatPt8, temp];
    elseif info.AnesLevel == 1
        temp = latency(V1);
        V1Lat1 = [V1Lat1, temp];
    elseif info.AnesLevel == 1.2
        temp = latency(V1);
        V1Lat1pt2 = [V1Lat1pt2, temp];
    else 
        continue
    end
end

figure 
V1Edges = 0:2:150;
figure
histogram(V1LatPt8(:), V1Edges)
hold on 
histogram(V1Lat1(:), V1Edges)
histogram(V1Lat1pt2(:), V1Edges)


%%

% V1LatPt8(V1LatPt8 > 48) = []
% V1Lat1(V1Lat1 > 48) = []
% V1Lat1pt2(V1Lat1pt2 > 48) = []

sizePt8 = length(V1LatPt8);
size1 = length(V1Lat1);
size1pt2 = length(V1Lat1pt2);
sizeTot = sizePt8 + size1 + size1pt2;
totalStuff = [V1LatPt8, V1Lat1, V1Lat1pt2];
meanTotal = nanmean(totalStuff);

sigma = sqrt(...
    ((sizePt8-1)*nanstd(V1LatPt8)^2 + (size1-1)*nanstd(V1Lat1)^2 +  (size1pt2-1)*nanstd(V1Lat1pt2)^2 )...
    /(sizePt8+size1+size1pt2))


part1 = (sizePt8/sizeTot)*(nanmean(V1LatPt8)- meanTotal)^2;
part2 = (size1/sizeTot)*(nanmean(V1Lat1)- meanTotal)^2;
part3 = (size1pt2/sizeTot)*(nanmean(V1Lat1pt2)- meanTotal)^2;

f = sqrt((part1+part2+part3)/sigma^2)

%% 0.8 -> 1.0

sizePt8 = length(V1LatPt8);
size1 = length(V1Lat1);
sizeTot = sizePt8 + size1;
totalStuff = [V1LatPt8, V1Lat1];
meanTotal = nanmean(totalStuff);

sigma = sqrt(...
    ((sizePt8-1)*nanstd(V1LatPt8)^2 + (size1-1)*nanstd(V1Lat1)^2)...
    /(sizePt8+size1))


part1 = (sizePt8/sizeTot)*(nanmean(V1LatPt8)- meanTotal)^2;
part2 = (size1/sizeTot)*(nanmean(V1Lat1)- meanTotal)^2;


f = sqrt((part1+part2)/sigma^2)


%% 1.0 -> 1.2

size1 = length(V1Lat1);
size1pt2 = length(V1Lat1pt2);
sizeTot = + size1 + size1pt2;
totalStuff = [V1Lat1, V1Lat1pt2];
meanTotal = nanmean(totalStuff);

sigma = sqrt(...
    ((size1-1)*nanstd(V1Lat1)^2 +  (size1pt2-1)*nanstd(V1Lat1pt2)^2 )...
    /(sizePt8+size1+size1pt2))


part2 = (size1/sizeTot)*(nanmean(V1Lat1)- meanTotal)^2;
part3 = (size1pt2/sizeTot)*(nanmean(V1Lat1pt2)- meanTotal)^2;

f = sqrt((part2+part3)/sigma^2)

%% 0.8 -> 1.2
sizePt8 = length(V1LatPt8);
size1pt2 = length(V1Lat1pt2);
sizeTot = sizePt8 + size1pt2;
totalStuff = [V1LatPt8, V1Lat1pt2];
meanTotal = nanmean(totalStuff);

sigma = sqrt(...
    ((sizePt8-1)*nanstd(V1LatPt8)^2 +(size1pt2-1)*nanstd(V1Lat1pt2)^2 )...
    /(sizePt8+size1pt2))


part1 = (sizePt8/sizeTot)*(nanmean(V1LatPt8)- meanTotal)^2;
part3 = (size1pt2/sizeTot)*(nanmean(V1Lat1pt2)- meanTotal)^2;

f = sqrt((part1+part3)/sigma^2)

%% look for change in latency from V1

timeFromV1 = nan(size(latency));

timeFromV1 = latency - latency(V1);

[ currentFig, colorMatrix, gridData] = PlotOnECoG(timeFromV1, info, 1)


%% looking for velocity of spread of the average signal by looking at adj channels 

load(allData(1).name, 'aveTrace')
[adjVector] = findAdjacentChan(aveTrace);

load('2017-03-02_19-29-09.mat', 'info', 'latency')
V1 = allV1(2,(find(allV1(1,:)== info.exp)));
timeDiff = nan(size(adjVector));


for i = 1:size(adjVector, 1)
    for j = 1:size(adjVector, 2)
        if isnan(adjVector(i, j))
            continue
        end
        
        if isnan(latency(adjVector(i, 5)))
            continue
        end
        
        if isnan(latency(adjVector(i, j)))
            continue
        end
        
        timeDiff(i,j) = latency(adjVector(i, j))- latency(adjVector(i, 5));
    end
end
