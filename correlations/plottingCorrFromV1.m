%% Plotting Corralation drop off from V1

% finding adjacent channels in the left, right, top, and bottom directions
% of V1

V1 = 15; % channel number at which latency of onset of the average is the shortest

addChan = 8; % number of channels want to show drop of for

[adjRight, adjLeft, adjTop, adjBottom] = findChanFromV1(V1, addChan);


%% finding mean of the max correlations and lags over trials

NUM_TR = size(maxCorrMatrix,1);
CI_Val = 1.98;

meanMaxCorr = squeeze(mean(maxCorrMatrix,1));
seMaxCorr = CI_Val*(squeeze(std(maxCorrMatrix,[],1))/sqrt(NUM_TR));
meanMaxLag = squeeze(mean(maxLagMatrix,1));
seMaxLag = CI_Val*(squeeze(std(maxLagMatrix,[],1))/sqrt(NUM_TR));

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
        if V1 > indexDirection(ID, direction)
            meanMaxCorrV1(ID, direction) = meanMaxCorr(indexDirection(ID, direction), V1);
            meanMaxLagV1(ID, direction) = meanMaxLag(indexDirection(ID, direction), V1);
            seMaxCorrV1(ID, direction) = seMaxCorr(indexDirection(ID, direction), V1);
            seMaxLagV1(ID, direction) = seMaxLag(indexDirection(ID, direction), V1);
           
        else
            meanMaxCorrV1(ID, direction) = meanMaxCorr(V1, indexDirection(ID, direction));
            meanMaxLagV1(ID, direction) = meanMaxLag(V1, indexDirection(ID, direction));
            seMaxCorrV1(ID, direction) = seMaxCorr(V1, indexDirection(ID, direction));
            seMaxLagV1(ID, direction) = seMaxLag(V1, indexDirection(ID, direction));

        end
    end
end


%plot corr
figure
subplot(2,2,1)
errorbar(meanMaxCorrV1(1,:), seMaxCorrV1(1, :), '-o')
title('Correlations of Channels to the left of V1')
ylabel('Correlation Coefficient')
xlabel('Channel')

subplot(2,2,2)
errorbar(meanMaxCorrV1(2,:), seMaxCorrV1(2, :), '-o')
title('Correlations of Channels to the right of V1')
ylabel('Correlation Coefficient')
xlabel('Channel')

subplot(2,2,3)
errorbar(meanMaxCorrV1(3,:), seMaxCorrV1(3, :), '-o')
title('Correlations of Channels to the top of V1')
ylabel('Correlation Coefficient')
xlabel('Channel')

subplot(2,2,4)
errorbar(meanMaxCorrV1(4,:), seMaxCorrV1(4, :), '-o')
title('Correlations of Channels to the bottom of V1')
ylabel('Correlation Coefficient')
xlabel('Channel')

% plot lags
% figure
% subplot(2,2,1)
% errorbar(meanMaxLagV1(1,:), seMaxLagV1(1,:), '-o')
% title('Lags of Channels to the left of V1')
% ylabel('Lag in milliseconds')
% xlabel('Channel')
% 
% subplot(2,2,2)
% errorbar(meanMaxLagV1(2,:), seMaxLagV1(2,:), '-o')
% title('Lags of Channels to the right of V1')
% ylabel('Lag in milliseconds')
% xlabel('Channel')
% 
% subplot(2,2,3)
% errorbar(meanMaxLagV1(3,:), seMaxLagV1(3,:), '-o')
% title('Lags of Channels to the top of V1')
% ylabel('Lag in milliseconds')
% xlabel('Channel')
% 
% subplot(2,2,4)
% errorbar(meanMaxLagV1(4,:), seMaxLagV1(4,:), '-o')
% title('Lags of Channels to the bottom of V1')
% ylabel('Lag in milliseconds')
% xlabel('Channel')

%% Comparing anes for corr decay for one experiment

load('dataMatrixFlashes.mat')

% to get first experiment
exp = 2;
int = [];
anes = [];
dur = [];

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
    
    meanMaxCorr = squeeze(mean(maxCorrMatrix,1));
    seMaxCorr = CI_Val*(squeeze(std(maxCorrMatrix,[],1))/sqrt(NUM_TR));
    meanMaxLag = squeeze(mean(maxLagMatrix,1));
    seMaxLag = CI_Val*(squeeze(std(maxLagMatrix,[],1))/sqrt(NUM_TR));
    
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
            if V1 > indexDirection(ID, direction)
                meanMaxCorrV1(ID, direction) = meanMaxCorr(indexDirection(ID, direction), V1);
                meanMaxLagV1(ID, direction) = meanMaxLag(indexDirection(ID, direction), V1);
                seMaxCorrV1(ID, direction) = seMaxCorr(indexDirection(ID, direction), V1);
                seMaxLagV1(ID, direction) = seMaxLag(indexDirection(ID, direction), V1);
            else
                meanMaxCorrV1(ID, direction) = meanMaxCorr(V1, indexDirection(ID, direction));
                meanMaxLagV1(ID, direction) = meanMaxLag(V1, indexDirection(ID, direction));
                seMaxCorrV1(ID, direction) = seMaxCorr(V1, indexDirection(ID, direction));
                seMaxLagV1(ID, direction) = seMaxLag(V1, indexDirection(ID, direction));
            end
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



%% Comparing corrlation decay with change in anesthetic concentration for all experiments

load('dataMatrixFlashes.mat')

expLabel =unique(vertcat(dataMatrixFlashes(:).exp));
intPulse = unique(vertcat(dataMatrixFlashes(:).IntensityPulse));
durationPulse = unique(vertcat(dataMatrixFlashes(:).LengthPulse));
isoLevel = unique(vertcat(dataMatrixFlashes(:).AnesLevel));

for exp = 1:length(expLabel)
    for int = 1:length(intPulse)
        for dur = 1:length(durationPulse)
            compExp = find([dataMatrixFlashes.exp] == expLabel(exp) & [dataMatrixFlashes.IntensityPulse] == intPulse(int) & [dataMatrixFlashes.LengthPulse] == durationPulse(dur));
            
            %disp(['exp: ' num2str(expLabel(exp)) 'int: ' num2str(intPulse(int)) 'dur: ' num2str(durationPulse(dur)) ]);
            
            for t = 1:length(compExp)
                temp = dataMatrixFlashes(compExp(t)).name;
                compIso{exp, int, dur, t} = temp(length(temp)-22:end);
            end
            
        end
    end
end


