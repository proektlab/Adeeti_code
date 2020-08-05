%% Plotting Correlations in  a direction specific manner

%% finding adjacent channels in the left, right, top, and bottom directions
% of V1

V1 = 15; % channel number at which latency of onset of the average is the shortest

addChan = 8; % number of channels want to show drop of for

[adjRight, adjLeft, adjTop, adjBottom] = findChanFromV1(V1, addChan);


%% Cleaning matrixes based on maxLag calculations

allData = dir('2017*.mat');

for exp = 2:length(allData)
    % making all channels with no correlations into nan lags
    load(allData(exp).name)
    disp(['Cleaning experiments ', num2str(exp), ' out of ', num2str(length(allData))])
    
    maxLagMatrix(find(isnan(maxCorrMatrix))) = nan;
    
    %% Setting all Corrs and Lags to nans depending on if maxLag is positive or negative
    negOnlyMaxCorr = maxCorrMatrix;
    negOnlyLag = maxLagMatrix;
    posOnlyMaxCorr = maxCorrMatrix;
    posOnlyLag = maxLagMatrix;
    
    posInd = find(maxLagMatrix>0);
    negOnlyMaxCorr(posInd) = nan;
    negOnlyLag(posInd) = nan;
    
    negInd = find(maxLagMatrix<0);
    posOnlyMaxCorr(negInd) = nan;
    posOnlyLag(negInd) = nan;
    
    save(allData(exp).name, 'maxLagMatrix', 'negOnlyMaxCorr', 'negOnlyLag', 'posOnlyMaxCorr', 'posOnlyLag', '-append')
end


%% Comparing anes for corr decay for one experiment

load('dataMatrixFlashes.mat')

% to use particular corr and lags (pos or neg only)
USE_NEG_ONLY = 1; %one for only neg lags from V1, 0 for positve lags from V1 

% to get first experiment
exp = 4;
int = 10;
anes = [];
dur = 10;

[myFavoriteExp] = findMyExp(dataMatrixFlashes, exp, anes, int, dur);

figure

legendTitles = {};
legendIndex = 1;

if exp == 9  %9 for iso - first set did not see VEPs
    start = 2;
else
    start = 1;
end
    
for i = start:length(myFavoriteExp)
    load(dataMatrixFlashes(myFavoriteExp(i)).name)
    NUM_TR = size(maxCorrMatrix,1);
    CI_Val = 1.96;
    
    if USE_NEG_ONLY == 1
        useCorrMatrix = negOnlyMaxCorr;
        useLagMatrix = negOnlyLag;
    else
        useCorrMatrix = posOnlyMaxCorr;
        useLagMatrix = posOnlyLag;
    end
    
    meanMaxCorr = squeeze(nanmean(useCorrMatrix,1));
    seMaxCorr = CI_Val*(squeeze(nanstd(useCorrMatrix,[],1))/sqrt(NUM_TR));
    meanMaxLag = squeeze(nanmean(useLagMatrix,1));
    seMaxLag = CI_Val*(squeeze(nanstd(useLagMatrix,[],1))/sqrt(NUM_TR));
    
    meanMaxCorrV1 = nan(4,addChan); %in first dim: 1 - Left, 2 - right, 3 - top, 4- bottom
    seMaxCorrV1 = nan(4,addChan);
    
    meanMaxLagV1 = nan(4,addChan); %in first dim: 1 - Left, 2 - right, 3 - top, 4- bottom
    seMaxLagV1 = nan(4,addChan);
    
    indexDirection = [adjLeft; adjRight; adjTop; adjBottom];
    
    % find mean and se corr and lag for all channels in all directions
    for ID = 1:size(indexDirection, 1)
        
        for direction = 1:size(indexDirection, 2)
            if isnan(indexDirection(ID, direction))
                continue
            end
            if ismember(indexDirection(ID, direction), info.noiseChannels)
                continue
            end
            
            meanMaxCorrV1(ID, direction) = meanMaxCorr(V1, indexDirection(ID, direction));
            meanMaxLagV1(ID, direction) = meanMaxLag(V1, indexDirection(ID, direction));
            seMaxCorrV1(ID, direction) = seMaxCorr(V1, indexDirection(ID, direction));
            seMaxLagV1(ID, direction) = seMaxLag(V1, indexDirection(ID, direction));
        end
    end
    
    legendTitles{legendIndex} = ['Anes level: ' num2str(dataMatrixFlashes(myFavoriteExp(i)).AnesLevel)];
    
    %plot corr
    subplot(2,2,1)
    errorbar(meanMaxCorrV1(1,:), seMaxCorrV1(1, :), '-o')
    hold on
    title('Correlations of Channels to the left of V1')
    ylabel('Correlation Coefficient')
    xlabel('Channel')
    
    subplot(2,2,2)
    errorbar(meanMaxCorrV1(2,:), seMaxCorrV1(2, :), '-o')
    hold on
    title('Correlations of Channels to the right of V1')
    ylabel('Correlation Coefficient')
    xlabel('Channel')
    
    subplot(2,2,3)
    errorbar(meanMaxCorrV1(3,:), seMaxCorrV1(3, :), '-o')
    hold on
    title('Correlations of Channels to the top of V1')
    ylabel('Correlation Coefficient')
    xlabel('Channel')
    
    subplot(2,2,4)
    errorbar(meanMaxCorrV1(4,:), seMaxCorrV1(4, :), '-o')
    hold on
    title('Correlations of Channels to the bottom of V1')
    ylabel('Correlation Coefficient')
    xlabel('Channel')
    
    legendIndex = legendIndex + 1;
    
    meanMaxCorrV1
end

legend(legendTitles);

hold off