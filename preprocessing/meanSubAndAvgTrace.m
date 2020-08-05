function [meanSubData, meanSubFullTrace] = meanSubAndAvgTrace(dirName, before, after)

if nargin<2
    before = 1;
    after = 2;
end
%%
    load(dirName)
    disp(['Converting data ', dirName])
    
    % Cleaning data and subtracting the mean
    noiseChannels = info.noiseChannels;
    cleanedData = dataSnippits;
    cleanedFullTrace = LFPData;
    meanSubData = nan(size(dataSnippits));
    meanSubFullTrace = nan(size(LFPData));
    
    for n = 1:length(noiseChannels)
        if isempty(noiseChannels)
            continue
        end
        cleanedFullTrace(noiseChannels(n), :) = NaN(1, size(LFPData, 2));
        if ndims(dataSnippits) ==3
            cleanedData(noiseChannels(n), :, :) = NaN(size(dataSnippits,2), size(dataSnippits, 3));
        end
    end
    
    if ~isfield(info, 'ecogChannels') 
        info.ecogChannels = 1:size(LFPData,1);
        info.forkChannels = nan;
    end
    
    % to mean subtract ecog data only
    if ~isnan(info.ecogChannels)
        LFPeCoGMean = nanmean(cleanedFullTrace(info.ecogChannels, :),1);
        meanSubFullTrace(info.ecogChannels,:) = cleanedFullTrace(info.ecogChannels,:) - repmat(LFPeCoGMean, [size(info.ecogChannels,2), 1]);
        
        if ndims(dataSnippits) ==3
            eCoGMean = nanmean(cleanedData(info.ecogChannels,:, :),1);
            meanSubData(info.ecogChannels,:,:) = cleanedData(info.ecogChannels,:,:) - repmat(eCoGMean, [size(info.ecogChannels,2), 1, 1]);
        end
    end
    % to mean subtract shanks data only
    if ~isnan(info.forkChannels)
        for f = 1:size(info.forkChannels,1)
            LFPforkMean = nanmean(cleanedFullTrace(info.forkChannels(f,:), :),1);
            meanSubFullTrace(info.forkChannels(f,:),:) = cleanedFullTrace(info.forkChannels(f,:),:) - repmat(LFPforkMean, [size(info.forkChannels(f,:),2), 1]);
            
            if ndims(dataSnippits) ==3
                forkMean = nanmean(cleanedData(info.forkChannels(f,:),:, :),1);
                meanSubData(info.forkChannels(f,:),:,:) = cleanedData(info.forkChannels(f,:),:,:) - repmat(forkMean, [size(info.forkChannels(f,:),2), 1, 1]);
            end
        end
    end
    
    if ndims(dataSnippits) ==3
        aveTrace = nan(size(uniqueSeries, 1), size(meanSubData,1), size(meanSubData,3));
        standError = nan(size(uniqueSeries, 1), size(meanSubData,1), size(meanSubData,3));
        
        for i = 1:size(uniqueSeries, 1)
            [indices] = getStimIndices(uniqueSeries(i,:), indexSeries, uniqueSeries);
            useMeanSubData = meanSubData(:,indices,:);
            parfor ch = 1:size(useMeanSubData,1)
                aveTrace(i, ch, :) = squeeze(nanmean(useMeanSubData(ch,:,:), 2));
                standError(i, ch,:) = squeeze(nanstd(useMeanSubData(ch,:,:), 1, 2)/sqrt(size(useMeanSubData(ch,:,:), 2)));
                
            end
        end
    end
    
    if exist('allStartTimes') && ndims(dataSnippits) ==3
        if iscell(allStartTimes) && length(allStartTimes) ==1
            allStartTimes = allStartTimes{1};
        end
        
        info.startOffSet = round(finalSampR*(allStartTimes(1)-before));
        info.endOffSet = round(finalSampR*(allStartTimes(end)+after));
    end
    
    if ndims(dataSnippits) ==3
    save([dirName], 'cleanedData', 'meanSubFullTrace', 'meanSubData', 'aveTrace', 'standError', 'info',  '-append')
    else 
    save([dirName], 'meanSubFullTrace', 'info', '-append')
end
