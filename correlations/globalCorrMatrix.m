%% Global correlations
before = 0;%time in seconds (neg for time before flash and positive for time after flash)
after = 1; %time in seconds
finalSampR = 1000;

if before <0
    before = finalSampR*abs(before);
elseif before == 0
    before = 1000;
else
    before = 1000 + (finalSampR*before);
end

after = 1000 + (finalSampR*after);
window = before:after;

allData = dir('*.mat')

loadingWindow = waitbar(0, 'Correlating channels...');
totalExp = length(allData);

for exp = 2:length(allData)
    load(allData(exp).name)
    
    if ~exist('meanSubData')
        continue
    end
    
    %%create corr and lag matrices
    corrMatrix = nan(size(meanSubData,2), size(meanSubData,1), size(meanSubData,1), 2*length(window)-1);
    lagMatrix = nan(size(meanSubData,2), size(meanSubData,1), size(meanSubData,1), 2*length(window)-1);
    
    maxCorrMatrix = nan(size(meanSubData,2), size(meanSubData,1), size(meanSubData,1));
    maxLagMatrix = nan(size(meanSubData,2), size(meanSubData,1), size(meanSubData,1));
    
    meanCorrMatrix = nan(size(meanSubData,1), size(meanSubData,1), 2*length(window)-1);
    stdCorrMatrix = nan(size(meanSubData,1), size(meanSubData,1), 2*length(window)-1);
    
    meanLagMatrix = nan(size(meanSubData,1), size(meanSubData,1), 2*length(window)-1);
    stdLagMatrix = nan(size(meanSubData,1), size(meanSubData,1), 2*length(window)-1);
    
    parfor tr = 1:size(meanSubData,2)
        for ch1 = 1:size(meanSubData,1)
            for ch2 = ch1:size(meanSubData,1)
                [r, lags] = xcorr(squeeze(meanSubData(ch1, tr, window)), squeeze(meanSubData(ch2, tr, window)), 'coeff');
                corrMatrix(tr, ch1, ch2, :) = r;
                lagMatrix(tr, ch1, ch2, :) = lags;
                
                [~, maxIndex] = max(r);
                trialMaxLag = lags(maxIndex);
                
                maxCorrMatrix(tr, ch1, ch2) = max(r);
                maxLagMatrix(tr, ch1, ch2) = trialMaxLag;
            end
        end
        disp(['Trial ', num2str(tr), ' out of ', num2str(size(meanSubData, 2))]);
    end
    
    meanCorrMatrix = squeeze(nanmean(corrMatrix, 1));
    stdCorrMatrix = squeeze(nanstd(corrMatrix, [], 1));
    
    meanLagMatrix = squeeze(nanmean(lagMatrix, 1));
    stdLagMatrix = squeeze(nanstd(lagMatrix, [], 1));
    
    save(allData(exp).name, 'maxCorrMatrix', 'maxLagMatrix', 'meanCorrMatrix', 'stdCorrMatrix', 'meanLagMatrix', 'stdLagMatrix', '-append')
    
    waitbar(exp/totalExp)
end
close(loadingWindow)

