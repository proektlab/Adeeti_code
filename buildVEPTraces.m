
gendir = '\\192.168.1.206\LabData';

USE_FITLERED_DATA = 1;

dirIn = [ gendir, '\adeeti\ecog\matIsoPropMultiStim\'];
dirOut = 'C:\Users\adeeti\Dropbox\ProektLab_code\machinelearning\';
dirOut = 'F:\Dropbox\ProektLab_code\MachineLearning\';
identifer = '2018*mat';

if USE_FITLERED_DATA
    allData = dir([dirIn 'Wavelets\FiltData\' identifer]);
else
    allData = dir([dirIn identifer]);
end
load([dirIn 'dataMatrixFlashes.mat'])

spontAct = [1:1001];
VEP = [1030:1300];

inputs = [];
outputs = [];
IDs = [];

inputsOneExp = [];
outputsOneExp = [];
IDsOneExp = [];

% counter = 1;
% for i = 1:length(allData)-4
%     load(allData(i).name, 'meanSubData', 'info', 'uniqueSeries', 'indexSeries')
%     disp(num2str(i));
%     [indices] = getStimIndices([0 inf], indexSeries, uniqueSeries);
%     useData = squeeze(meanSubData(info.lowLat,indices,:));
%     for j = 1:size(useData,1)
%         inputs(counter,:) = useData(j,spontAct);
%         outputs(counter,:) = useData(j,VEP);
%         IDs(counter) = i; 
%         counter = counter +1;
%     end
% end

useEXP = 5;
drugType = [];
conc = [];
stimIndex = [0, Inf];

[MFE]=findMyExpMulti(dataMatrixFlashes, useEXP, drugType, conc, stimIndex);


times = 1:2000;

VEPs = {};
infos = {};
counter = 1;
for i = MFE
%for i = 1:size(dataMatrixFlashesVIS_ONLY,2)-4
    if USE_FITLERED_DATA
        load([allData(i).folder '\' allData(i).name], 'filtSig35', 'info', 'indexSeries', 'uniqueSeries')
    else
        load([allData(i).folder '\' allData(i).name], 'smallSnippits', 'info', 'indexSeries', 'uniqueSeries')
    end
    disp([num2str(counter) ' -> ' info.AnesType ' ' num2str(info.AnesLevel)]);
    [indices] = getStimIndices([0 inf], indexSeries, uniqueSeries);
    
    if USE_FITLERED_DATA
        VEPs{counter} = squeeze(filtSig35(times,:,indices));
    else
        VEPs{counter} = squeeze(smallSnippits(:,indices,times));
        VEPs{counter} = permute(VEPs{counter}, [3,1,2]);
    end
    
    infos{counter} = info;
        
    counter = counter +1;
end



% save([dirOut,'VEPs_IsoProp.mat'], 'inputs', 'outputs', 'IDs')
%save([dirOut,'SingleEXP_VEPs_IsoProp.mat'], 'inputs', 'outputs', 'IDs')

%%

trialID = 75;

playData = VEPs{4};

avgCovMatrix = {};
covMatrix = {};

for j = 1
    if j == 1
        time = 1:500;
    else
    	time = 1000:1500;
    end
    
    average = squeeze(mean(playData, 3));
    
    covMatrix{j} = corr(playData(time, :, trialID));
    avgCovMatrix{j} = corr(average(time, :));
end

%%

aboveOrBelow = [];
corrValues = [];
for i = 1:2
    for j = 1:size(playData,3)
        if i == 1
            time = 1:500;
        else
            time = 1000:1500;
        end

        corrValues(i,j) = nansum(nansum(abs(corr(playData(time, :, j)))));
    end
    
    [~, midPoint] = kmeans(corrValues(i,:)', 2);
    midPoint = mean(midPoint);

    aboveOrBelow(i,:) = corrValues(i,:) > midPoint;
end

figure(1);
straws = 20;
clf;
hold on
histogram(corrValues(1,:), straws)
histogram(corrValues(2,:), straws)

figure(2);
clf;
hold on;
% plot(aboveOrBelow', '-o');
scatter(corrValues(1,:), corrValues(2,:))

corr(corrValues(1,:)', corrValues(2,:)')

%%

figure(3)
clf
% subplot(1,2,1)
% covMatrix = corr(playData(time, :, trialID));
% imagesc(covMatrix);
imagesc(covMatrix{2} - covMatrix{1})
% subplot(1,2,2)
% covMatrix = corr(average(time, :));
% imagesc(covMatrix);
% imagesc(avgCovMatrix{2} - avgCovMatrix{1})

%%

USE_SVD = 0;
Z_SCORE = 0;
SPLIT_SINGLE_TRIAL = 0;
NUM_BOOTS = 1;

times = 950:1350;

colors = {'k', 'r', 'g', 'b'};

electrodes = [47, 31, 21, 46, 30, 20, 45, 29, 19];

figure(1);
clf
hold on;

allData = {};
allAverages = [];
counter = 1;
for expID = [1,2]    
    allData{counter} = VEPs{expID};%(:,electrodes,:);
    
    for i = 1:size(allData{counter},2)
        allData{counter}(:,i,:) = hilbert(squeeze(allData{counter}(:,i,:)));
        
        allData{counter}(:,i,:) = (angle(allData{counter}(:,i,:)));
    end

    allData{counter} = permute(allData{counter}, [1, 3, 2]);
    
    p = plot(allData{counter}(:,:,infos{counter}.lowLat), colors{counter});
    for i = 1:length(p)
        p(i).Color(4) = 0.3;
    end
    xlim([950 1150]);
%     
    if Z_SCORE
        for i = 1:size(allData{counter},2)
            allData{counter}(:,i,:) = zscore(squeeze(allData{counter}(:,i,:)), [], 1);
        end
%     else
%         for i = 1:size(allData{counter},2)
%             allData{counter}(:,i,:) = (squeeze(allData{counter}(:,i,:))) .* std(squeeze(allData{counter}(:,i,:)));
%         end
    end
    
    indexList = 1:size(allData{counter},2);
    
    if SPLIT_SINGLE_TRIAL
        trialEnds = 50;
        if counter == 1
    %         indexList = 1:floor(length(indexList)/2);
            indexList = 1:trialEnds;
        else
    %         indexList = floor(length(indexList)/2)+1:length(indexList);
            indexList = length(indexList)-trialEnds+1:length(indexList);
        end

    %     indexList = randsample(1:length(indexList), length(indexList), true);
    end
    
    allData{counter} = allData{counter}(:,indexList,:);
    
    average = squeeze(mean(allData{counter}, 2));
    
    allAverages = [allAverages; average];
    
    counter = counter + 1;
end

badIndices = [];
for i = 1:size(allAverages,2)
    if sum(isnan(allAverages(:,i))) > 0
        badIndices = [badIndices i];
    end
end
goodIndices = setdiff(1:size(allAverages,2), badIndices);
allAverages = allAverages(:,goodIndices);

if USE_SVD
    [U,S,V] = svd(allAverages');
    
    spatialModes = U;
    invSpatialModes = inv(spatialModes);
else
    [pcaBasis, pcaOutputs, ~, ~, explained] = pca(allAverages, 'NumComponents', 3);
end

figure(2);
clf
hold on;
for expID = 1:length(allData)
    plotData = allData{expID}(times,:,goodIndices);

%     plotData = permute(plotData, [1, 3, 2]);
    % plotData = plotData(50:100,:,find(~isnan(plotData(1,1,:))));
    %plotData = plotData(:,:,find(~isnan(plotData(1,1,:))));

%     for i = 1:size(plotData,2)
%         plotData(:,i,:) = zscore(squeeze(plotData(:,i,:)), [], 1);
%     end

    average = squeeze(mean(plotData, 2));

%     pcaTrace = reshape(plotData, [size(plotData,1) * size(plotData,2), size(plotData,3)]);
%     pcaTrace(isnan(pcaTrace)) = 0;
% 
%     

    for i = 1:50
        thisIndicies = randsample(size(plotData, 2), NUM_BOOTS, 1);

        thisData = squeeze(mean(plotData(:,thisIndicies,:), 2));

        if USE_SVD
            plotTrace = (invSpatialModes * thisData')';
        else
            plotTrace = thisData*pcaBasis;
        end
        
        if USE_SVD
            p = plot3(plotTrace(:,1), plotTrace(:,3), plotTrace(:,5), colors{expID}, 'linewidth', 0.5);
        else
            p = plot3(plotTrace(:,1), plotTrace(:,2), plotTrace(:,3), colors{expID}, 'linewidth', 0.5);
        end
        p.Color(4) = 0.2;
    end


    if USE_SVD
        plotTrace = (invSpatialModes * average')';
    else
        plotTrace = average*pcaBasis;
    end

    if USE_SVD
        plot3(plotTrace(:,1), plotTrace(:,3), plotTrace(:,5), colors{expID}, 'linewidth', 3);
    else
        plot3(plotTrace(:,1), plotTrace(:,2), plotTrace(:,3), colors{expID}, 'linewidth', 3);
    end
end

%%

[U,S,V] = svd(average');

spatialModes = U;
invSpatialModes = inv(spatialModes);

times = 1:150;

clf
hold on
% for i = 1:10:size(plotData, 2)
for i = 1:10
    thisIndicies = randsample(1:size(plotData, 2), ceil(size(plotData, 2)), 1);
%     thisIndicies = 1:size(plotData, 2);
    
    thisData = squeeze(mean(plotData(:,thisIndicies,:), 2));
    
    temporalModes = invSpatialModes * thisData';
    
    plot3(temporalModes(1,times), temporalModes(3,times), temporalModes(5,times));
%     plot(temporalModes(1,times), temporalModes(2,times));
end

temporalModes = invSpatialModes * average';
plot3(temporalModes(1,times), temporalModes(3,times), temporalModes(5,times), 'k', 'linewidth', 3);
% plot(temporalModes(1,times), temporalModes(2,times), 'k', 'linewidth', 3);



