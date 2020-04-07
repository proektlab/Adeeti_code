%% finding mean of the max correlations and lags over trials

%% finding adjacent channels in the left, right, top, and bottom directions
% of V1

V1 = 25; % channel number at which latency of onset of the average is the shortest

addChan = 8; % number of channels want to show drop of for

[adjRight, adjLeft, adjTop, adjBottom] = findChanFromV1(V1, addChan);

%%

NUM_TR = size(shufMaxCorrMatrix,1);
CI_Val = 1.98;

meanMaxCorr = squeeze(mean(shufMaxCorrMatrix,1));
seMaxCorr = CI_Val*(squeeze(std(shufMaxCorrMatrix,[],1))/sqrt(NUM_TR));
meanMaxLag = squeeze(mean(shufMaxLagMatrix,1));
seMaxLag = CI_Val*(squeeze(std(shufMaxLagMatrix,[],1))/sqrt(NUM_TR));

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

% %plot lags
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