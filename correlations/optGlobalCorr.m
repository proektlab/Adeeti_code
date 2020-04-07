%% Global correlations
before = 0;%time in seconds (neg for time before flash and positive for time after flash)
after = 1; %time in seconds

maxLag = 400;

finalSampR = 1000;

before = floor(1001 + (finalSampR*before));
after = floor(1001 + (finalSampR*after));

window = before:after;

allData = dir('2017*.mat');

loadingWindow = waitbar(0, 'Correlating channels...');
totalExp = length(allData);

for exp = 16:length(allData)
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
    
    corrMatrix = nan(size(meanSubData,2), size(meanSubData,1), size(meanSubData,1), 2*maxLag+1);
    lagMatrix = nan(size(meanSubData,2), size(meanSubData,1), size(meanSubData,1), 2*maxLag+1);
    
    maxCorrMatrix = nan(size(meanSubData,2), size(meanSubData,1), size(meanSubData,1));
    maxLagMatrix = nan(size(meanSubData,2), size(meanSubData,1), size(meanSubData,1));
    
    meanCorrMatrix = nan(size(meanSubData,1), size(meanSubData,1), 2*maxLag+1);
    stdCorrMatrix = nan(size(meanSubData,1), size(meanSubData,1), 2*maxLag+1);
    
    meanLagMatrix = nan(size(meanSubData,1), size(meanSubData,1), 2*maxLag+1);
    stdLagMatrix = nan(size(meanSubData,1), size(meanSubData,1), 2*maxLag+1);
    
    if size(meanSubData,2) >= 274
        for tr = 1:size(meanSubData,2)
            tempCorrs = [];
            tempLags = [];
            maxTempCorrMatrix = [];
            maxTempLagMatrix = [];

            for ch1 = 1:size(meanSubData,1)
                for ch2 = 1:size(meanSubData,1)
                    [r, lags] = xcorr(squeeze(meanSubData(ch1, tr, window)), squeeze(meanSubData(ch2, tr, window)), maxLag, 'coeff');
                    tempCorrs(ch1, ch2, :) = r;
                    tempLags(ch1, ch2, :) = lags;

                    [~, maxIndex] = max(r);
                    trialMaxLag = lags(maxIndex);

                    maxTempCorrMatrix(ch1, ch2) = max(r);
                    maxTempLagMatrix(ch1, ch2) = trialMaxLag;
                end
            end

            corrMatrix(tr, :, :, :) = tempCorrs;
            lagMatrix(tr, :, :, :) = tempLags;
            maxCorrMatrix(tr, :,:) = maxTempCorrMatrix;
            maxLagMatrix(tr, :,:) = maxTempLagMatrix;

            disp(['Trial ', num2str(tr), ' out of ', num2str(size(meanSubData, 2))]);
        end
    else
        parfor tr = 1:size(meanSubData,2)
            tempCorrs = [];
            tempLags = [];
            maxTempCorrMatrix = [];
            maxTempLagMatrix = [];

            for ch1 = 1:size(meanSubData,1)
                for ch2 = 1:size(meanSubData,1)
                    [r, lags] = xcorr(squeeze(meanSubData(ch1, tr, window)), squeeze(meanSubData(ch2, tr, window)), maxLag, 'coeff');
                    tempCorrs(ch1, ch2, :) = r;
                    tempLags(ch1, ch2, :) = lags;

                    [~, maxIndex] = max(r);
                    trialMaxLag = lags(maxIndex);

                    maxTempCorrMatrix(ch1, ch2) = max(r);
                    maxTempLagMatrix(ch1, ch2) = trialMaxLag;
                end
            end

            corrMatrix(tr, :, :, :) = tempCorrs;
            lagMatrix(tr, :, :, :) = tempLags;
            maxCorrMatrix(tr, :,:) = maxTempCorrMatrix;
            maxLagMatrix(tr, :,:) = maxTempLagMatrix;

            disp(['Trial ', num2str(tr), ' out of ', num2str(size(meanSubData, 2))]);
        end
    end
    
    meanCorrMatrix = squeeze(nanmean(corrMatrix, 1));
    save(allData(exp).name, 'meanCorrMatrix', '-append')
    clear 'meanCorrMatrix';
    
    for i = 1:size(corrMatrix,2)
        for j = 1:size(corrMatrix,3)
            stdCorrMatrix(i,j,:) = nanstd(corrMatrix(:, i,j,:), [], 1);
        end
    end
    
    save(allData(exp).name, 'stdCorrMatrix', '-append')
    clear 'stdCorrMatrix';
    
    meanLagMatrix = squeeze(nanmean(lagMatrix, 1));
    
    for i = 1:size(lagMatrix,2)
        for j = 1:size(lagMatrix,3)
            stdLagMatrix(i,j,:) = nanstd(lagMatrix(:, i,j,:), [], 1);
        end
    end
    
    save(allData(exp).name, 'maxCorrMatrix', 'maxLagMatrix', 'meanLagMatrix', 'stdLagMatrix', '-append')
    
    clearvars -except exp totalExp allData window maxLag loadingWindow
    
    waitbar(exp/totalExp)
end
close(loadingWindow)

