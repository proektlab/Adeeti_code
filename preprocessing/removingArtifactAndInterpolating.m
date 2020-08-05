%% Removing artifact region in LFP singal and interpolating over signal 

if REMOVE_STIM_ARTIFACT == 1
    for experiment = 1:length(allData)
        load(allData(experiment).name, 'dataSnippits')
        disp(['Artifact removal for eperiment ', num2str(experiment)])
        data = dataSnippits;
        
        artifactRegion = 1000:1015;
        bufferPoints = [artifactRegion(1)-10:artifactRegion(1), artifactRegion(end):artifactRegion(end)+10];
        data(:,:,artifactRegion) = [];
        
        time1 = [1:999, 1016:3001];
        time2 = 1:size(dataSnippits,3);
        
        for i = 1:size(data, 1)
            for j = 1:size(data,2)
                dataSnippits(i,j,:) = interp1(time1, squeeze(data(i, j, :)), time2, 'spline');
            end
        end
        save(allData(experiment).name, 'dataSnippits', '-append')
    end
end

%% Clean data, mean subtract make average pictures 

close all

START_AT = 1;

flashOn = [0,0];
before = 1;
after = 2;
markTime = -before:.1:after;
screensize=get(groot, 'Screensize');

if ~exist('dirPic')
    mkdir(dirPic)
end

cd(dirIn)
allData = dir(identifier);

for experiment = START_AT:length(allData)
    dirName = allData(experiment).name;
    load(dirName)
    disp(['Converting data ', allData(experiment).name])
    
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
        cleanedData(noiseChannels(n), :, :) = NaN(size(dataSnippits,2), size(dataSnippits, 3));
        cleanedFullTrace(noiseChannels(n), :) = NaN(1, size(LFPData, 2));
    end
    
    % to mean subtract ecog data only
    if ~isnan(info.ecogChannels)
        eCoGMean = nanmean(cleanedData(info.ecogChannels,:, :),1);
        LFPeCoGMean = nanmean(cleanedFullTrace(info.ecogChannels, :),1);
        
        meanSubData(info.ecogChannels,:,:) = cleanedData(info.ecogChannels,:,:) - repmat(eCoGMean, [size(info.ecogChannels,2), 1, 1]);
        meanSubFullTrace(info.ecogChannels,:) = cleanedFullTrace(info.ecogChannels,:) - repmat(LFPeCoGMean, [size(info.ecogChannels,2), 1]);
    end
    % to mean subtract shanks data only
    if ~isnan(info.forkChannels)
        for f = 1:size(info.forkChannels,1)
            forkMean = nanmean(cleanedData(info.forkChannels(f,:),:, :),1);
            LFPforkMean = nanmean(cleanedFullTrace(info.forkChannels(f,:), :),1);
            
            meanSubData(info.forkChannels(f,:),:,:) = cleanedData(info.forkChannels(f,:),:,:) - repmat(forkMean, [size(info.forkChannels(f,:),2), 1, 1]);
            meanSubFullTrace(info.forkChannels(f,:),:) = cleanedFullTrace(info.forkChannels(f,:),:) - repmat(LFPforkMean, [size(info.forkChannels(f,:),2), 1]);
        end
    end
    
    aveTrace = nan(size(uniqueSeries, 1), size(meanSubData,1), size(meanSubData,3));
    standError = nan(size(uniqueSeries, 1), size(meanSubData,1), size(meanSubData,3));
    
    for i = 1:size(uniqueSeries, 1)
        [indices] = getStimIndices(uniqueSeries(i,:), indexSeries, uniqueSeries);
        useMeanSubData = meanSubData(:,indices,:);
        parfor ch = 1:size(useMeanSubData,1)
            aveTrace(i, ch, :) = squeeze(nanmean(useMeanSubData(ch,:,:), 2));
            standError(i, ch,:) = squeeze(nanstd(useMeanSubData(ch,:,:), 1, 2)/sqrt(size(useMeanSubData(ch,:,:), 2)));
            
            %lowerCIBound(i, ch,:) = squeeze(quantile(meanSubData(ch,:,:), 0.05, 2));
            %upperCIBound(i, ch,:) =  squeeze(quantile(meanSubData(ch,:,:), 0.95, 2));
        end
    end
    
    if exist('allStartTimes')
        if iscell(allStartTimes) && length(allStartTimes) ==1
            allStartTimes = allStartTimes{1};
        end
            
        info.startOffSet = round(finalSampR*(allStartTimes(1)-before));
        info.endOffSet = round(finalSampR*(allStartTimes(end)+after));
    end
    
    save([dirIn, dirName], 'cleanedData', 'meanSubFullTrace', 'meanSubData', 'aveTrace', 'standError', 'info',  '-append')
    %save([dirIn, dirName], 'cleanedData', 'meanSubFullTrace' 'meanSubData', 'aveTrace', 'standError', 'info', 'dataSnippits','finalTime', 'finalSampR', 'LFPData', 'eventTimes', 'fullTraceTime','plexInfoStuffs','uniqueSeries', 'indexSeries')
    
    % making images
    for stimIndexLoop= 1:size(uniqueSeries, 1)
        strStimInd = uniqueSeries(stimIndexLoop,:);
        [stimIndexSeriesString] = stimIndex2string4saving(strStimInd, finalSampR);
        
        %Single trial images
        [indices] = getStimIndices(uniqueSeries(stimIndexLoop,:), indexSeries, uniqueSeries);
        useMeanSubData = meanSubData(:,indices,:); 
        
        [currentFig] = plotSingleTrials(useMeanSubData, finalTime, info);
        suptitle(['Single trials, Experiment ', num2str(info.exp), ', ', info.TypeOfTrial, ', Drug: ',  info.AnesType, ', Conc: ', num2str(info.AnesLevel), ', Series ', strrep(stimIndexSeriesString, '_', '\_')]);
        if PicByTrialType ==1
            saveas(currentFig, [dirPic, info.expName(1:end-4), '_', info.TypeOfTrial, stimIndexSeriesString, '_singletrials.png'])
        elseif PicByAnesType ==1
            saveas(currentFig, [dirPic, info.expName(1:end-4), '_', info.AnesType, stimIndexSeriesString, '_singletrials.png'])
        elseif PicByAnesAndTrial ==1
            saveas(currentFig, [dirPic, info.expName(1:end-4), '_', info.TypeOfTrial, info.AnesType, StimIndexSeriesString, '_singletrials.png'])
        end
       
        close all;
        
        % Plot on onset of latency on averages        
        [currentFig] = plotAverages(squeeze(aveTrace(stimIndexLoop,:,:)), finalTime, info, [], [], [],[], before, after, flashOn, finalSampR);
        suptitle(['Average, Experiment ', num2str(info.exp), ',  Drug: ', info.AnesType, ', Conc: ', num2str(info.AnesLevel), ', Series ', strrep(stimIndexSeriesString, '_', '\_')])
        if PicByTrialType ==1
            saveas(currentFig, [dirPic, info.expName(1:end-4), '_', info.TypeOfTrial, stimIndexSeriesString, '_ave.png'])
        elseif PicByAnesType ==1
            saveas(currentFig, [dirPic, info.expName(1:end-4), '_', info.AnesType, stimIndexSeriesString, '_ave.png'])
        elseif PicByAnesAndTrial ==1
            saveas(currentFig, [dirPic, info.expName(1:end-4), '_', info.TypeOfTrial, info.AnesType, StimIndexSeriesString, '_ave.png'])
        end

        close all
    end
end


