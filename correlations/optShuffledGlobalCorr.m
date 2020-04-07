%% Global correlations
before = -1;%time in seconds (neg for time before flash and positive for time after flash)
after = 0; %time in seconds
finalSampR = 1000;

before = floor(1001 + (finalSampR*before));
after = floor(1001 + (finalSampR*after));

window = before:after;

allData = dir('2017*.mat')

loadingWindow = waitbar(0, 'Correlating channels...');
totalExp = length(allData);

for exp = 114%:length(allData)
    load(allData(exp).name)
    
    if ~exist('meanSubData')
        continue
    end
    disp(['Exp ', num2str(exp), ' out of ', num2str(totalExp)])
    
    %%create corr and lag matrices
    
%     corrMatrix = [];
%     lagMatrix = [];
%     maxCorrMatrix = [];
%     maxLagMatrix = [];
%     meanCorrMatrix = [];
%     stdCorrMatrix = [];
%     meanLagMatrix = [];
%     stdLagMatrix = [];
    
    shufCorrMatrix = nan(size(meanSubData,2), size(meanSubData,1), size(meanSubData,1), 2*length(window)-1);
    shufLagMatrix = nan(size(meanSubData,2), size(meanSubData,1), size(meanSubData,1), 2*length(window)-1);
    
    shufMaxCorrMatrix = nan(size(meanSubData,2), size(meanSubData,1), size(meanSubData,1));
    shufMaxLagMatrix = nan(size(meanSubData,2), size(meanSubData,1), size(meanSubData,1));
    
    shufMeanCorrMatrix = nan(size(meanSubData,1), size(meanSubData,1), 2*length(window)-1);
    shufStdCorrMatrix = nan(size(meanSubData,1), size(meanSubData,1), 2*length(window)-1);
    
    shufMeanLagMatrix = nan(size(meanSubData,1), size(meanSubData,1), 2*length(window)-1);
    shufStdLagMatrix = nan(size(meanSubData,1), size(meanSubData,1), 2*length(window)-1);
    
    if size(meanSubData,2) >= 274
        for tr = 1:size(meanSubData,2)
            tempCorrs = [];
            tempLags = [];
            maxTempCorrMatrix = [];
            maxTempLagMatrix = [];

            for ch1 = 1:size(meanSubData,1)
                for ch2 = ch1:size(meanSubData,1)
                    [r, lags] = xcorr(squeeze(meanSubData(ch1, tr, window)), squeeze(meanSubData(ch2, tr, window)), 'coeff');
                    tempCorrs(ch1, ch2, :) = r;
                    tempLags(ch1, ch2, :) = lags;

                    [~, maxIndex] = max(r);
                    trialMaxLag = lags(maxIndex);

                    maxTempCorrMatrix(ch1, ch2) = max(r);
                    maxTempLagMatrix(ch1, ch2) = trialMaxLag;
                end
            end

            shufCorrMatrix(tr, :, :, :) = tempCorrs;
            shufLagMatrix(tr, :, :, :) = tempLags;
            shufMaxCorrMatrix(tr, :,:) = maxTempCorrMatrix;
            shufMaxLagMatrix(tr, :,:) = maxTempLagMatrix;

            disp(['Trial ', num2str(tr), ' out of ', num2str(size(meanSubData, 2))]);
        end
    else
        parfor tr = 1:size(meanSubData,2)
            tempCorrs = [];
            tempLags = [];
            maxTempCorrMatrix = [];
            maxTempLagMatrix = [];

            for ch1 = 1:size(meanSubData,1)
                for ch2 = ch1:size(meanSubData,1)
                    [r, lags] = xcorr(squeeze(meanSubData(ch1, tr, window)), squeeze(meanSubData(ch2, tr, window)), 'coeff');
                    tempCorrs(ch1, ch2, :) = r;
                    tempLags(ch1, ch2, :) = lags;

                    [~, maxIndex] = max(r);
                    trialMaxLag = lags(maxIndex);

                    maxTempCorrMatrix(ch1, ch2) = max(r);
                    maxTempLagMatrix(ch1, ch2) = trialMaxLag;
                end
            end

            shufCorrMatrix(tr, :, :, :) = tempCorrs;
            shufLagMatrix(tr, :, :, :) = tempLags;
            shufMaxCorrMatrix(tr, :,:) = maxTempCorrMatrix;
            shufMaxLagMatrix(tr, :,:) = maxTempLagMatrix;

            disp(['Trial ', num2str(tr), ' out of ', num2str(size(meanSubData, 2))]);
        end
    end
    
    shufMeanCorrMatrix = squeeze(nanmean(shufCorrMatrix, 1));
    save(allData(exp).name, 'shufMeanCorrMatrix', '-append')
    clear 'shufMeanCorrMatrix';
    
    for i = 1:size(shufCorrMatrix,2)
        for j = 1:size(shufCorrMatrix,3)
            shufStdCorrMatrix(i,j,:) = nanstd(shufCorrMatrix(:, i,j,:), [], 1);
        end
    end
    
    save(allData(exp).name, 'shufStdCorrMatrix', '-append')
    clear 'shufStdCorrMatrix';
    
    shufMeanLagMatrix = squeeze(nanmean(shufLagMatrix, 1));
    
    for i = 1:size(shufLagMatrix,2)
        for j = 1:size(shufLagMatrix,3)
            shufStdLagMatrix(i,j,:) = nanstd(shufLagMatrix(:, i,j,:), [], 1);
        end
    end
    
    save(allData(exp).name, 'shufMaxCorrMatrix', 'shufMaxLagMatrix', 'shufMeanLagMatrix', 'shufStdLagMatrix', '-append')
    
    waitbar(exp/totalExp)
end
close(loadingWindow)

