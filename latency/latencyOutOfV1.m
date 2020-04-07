%% Looking for latency difference outside of V1

dirIn = '/data/adeeti/ecog/matFlashesJanMar2017';
cd(dirIn)
identifier = '2017*.mat';

allData = dir(identifier);
load(allData(1).name, 'info')

[allV1] = V1forEachMouse(pwd);
adjChan = findAdjacentChan(info);
above2V1 = nan(size(allV1, 2),1);
above3V1 = nan(size(allV1,2), 1);

for i = 1:length(allV1)
    x = adjChan(allV1(2,i), 2);
    if isnan(x) 
        continue
    end
    x = adjChan(x, 2);
    above2V1(i) = x;
    if isnan(x) 
        continue
    end
    x = adjChan(x, 2);
    above3V1(i) = x;
end

latAboveV1 = nan(length(allData), 4);

for exp = 1:length(allData)
    load(allData(exp).name, 'latency', 'info')
    if info.exp ==1
        continue
    end
    
    expID = info.exp;
    expIndex = find(allV1(1,:) == expID);

    latAboveV1(exp, 1) = latency(above2V1(expIndex));
    latAboveV1(exp, 2) = latency(above3V1(expIndex));
    latAboveV1(exp, 3) = info.AnesLevel;
    latAboveV1(exp, 4) = info.exp;
end

edges = 0:2:150;
figure
histogram(latAboveV1(:,2), edges)

boxplot(latAboveV1(:,2),latAboveV1(:,3))

boxplot(latAboveV1(:,1),latAboveV1(:,4))

useData = 2;

V1LatPt8 = latAboveV1(find(latAboveV1(:,3) == 0.8),useData)';
V1Lat1 = latAboveV1(find(latAboveV1(:,3) == 1),useData)';
V1Lat1pt2 = latAboveV1(find(latAboveV1(:,3) == 1.2),useData)';

figure
histogram(V1LatPt8, 10)
hold on 
histogram(V1Lat1,10)
histogram(V1Lat1pt2, 10)


%% All three iso
useData = 1;

V1LatPt8 = latAboveV1(find(latAboveV1(:,3) == 0.8),useData)';
V1Lat1 = latAboveV1(find(latAboveV1(:,3) == 1),useData)';
V1Lat1pt2 = latAboveV1(find(latAboveV1(:,3) == 1.2),useData)';

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

%% 0.8 -> 1

useData = 1;

V1LatPt8 = latAboveV1(find(latAboveV1(:,3) == 0.8),useData)';
V1Lat1 = latAboveV1(find(latAboveV1(:,3) == 1),useData)';
[~,maxIndex] = max(V1LatPt8);
V1LatPt8(maxIndex) = [];

sizePt8 = length(V1LatPt8);
size1 = length(V1Lat1);
sizeTot = sizePt8 + size1;
totalStuff = [V1LatPt8, V1Lat1];
meanTotal = nanmean(totalStuff);

sigma = sqrt(...
    ((sizePt8-1)*nanstd(V1LatPt8)^2 + (size1-1)*nanstd(V1Lat1)^2 )...
    /(sizePt8+size1))


part1 = (sizePt8/sizeTot)*(nanmean(V1LatPt8)- meanTotal)^2;
part2 = (size1/sizeTot)*(nanmean(V1Lat1)- meanTotal)^2;

f = sqrt((part1+part2)/sigma^2)


%% 1.0 -> 1.2

useData = 1;

V1Lat1 = latAboveV1(find(latAboveV1(:,3) == 1),useData)';
V1Lat1pt2 = latAboveV1(find(latAboveV1(:,3) == 1.2),useData)';

size1 = length(V1Lat1);
size1pt2 = length(V1Lat1pt2);
sizeTot =  size1 + size1pt2;
totalStuff = [V1Lat1, V1Lat1pt2];
meanTotal = nanmean(totalStuff);

sigma = sqrt(...
    ((size1-1)*nanstd(V1Lat1)^2 +  (size1pt2-1)*nanstd(V1Lat1pt2)^2 )...
    /(size1+size1pt2))


part2 = (size1/sizeTot)*(nanmean(V1Lat1)- meanTotal)^2;
part3 = (size1pt2/sizeTot)*(nanmean(V1Lat1pt2)- meanTotal)^2;

f = sqrt((part2+part3)/sigma^2)

%% 0.8 -> 1.2

useData = 1;

V1LatPt8 = latAboveV1(find(latAboveV1(:,3) == 0.8),useData)';
V1Lat1 = latAboveV1(find(latAboveV1(:,3) == 1),useData)';
V1Lat1pt2 = latAboveV1(find(latAboveV1(:,3) == 1.2),useData)';

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