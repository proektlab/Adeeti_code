close all
clear

%%%%% Code for loading in Prop States first
if isunix
    dirData = '/synology/adeeti/';
    dirCode = '/synology/code/Adeeti_code/';
elseif ispc
    dirData = 'Z:/adeeti/';
    dirCode = 'Z:\code\Adeeti_code\';
end

geDirIn = [dirData, 'JenniferHelen/'];
mice = {['2019-01-18b\']}; %{'2018-12-14\', '2019-01-18b\'};
%%
for m = 1:length(mice)
    dirIn = [dirData, geDirIn, mice{m}];
    identifier = '2019-01-18_17*.mat';
    finalSampR = 1000; %in Hz
    mkdir(dirIn);
    cd(dirIn)
    allData = dir(identifier);
    
    START_AT = 1;
    
    %% Finding noise Channels
    numbOfSamp = 8;
    date = 'start';
    
    for i = START_AT:length(allData)
        dirName = allData(i).name;
        load(dirName, 'info', 'LFPData', 'dataSnippits', 'fullTraceTime');
        
        if ~exist('dataSnippits', 'var')||isempty(dataSnippits)
            dataSnippits = LFPData;
        end
        
        if strcmpi(info.date, date)
            info.noiseChannels = noiseChannels;
            save(dirName, 'info', '-append')
        else
            
            clearvars noiseChannels
            data = dataSnippits;
            
            upperBound = max(data(:));
            lowerBound = min(data(:));
            if ndims(dataSnippits,2)==2
                [ noiseChannelsManual ] = examChannelBaseline(dataSnippits, fullTraceTime);
            elseif ndims(dataSnippits) == 3
                noiseChannelsManual = examChannelSnippits(data, finalTime, numbOfSamp, upperBound, lowerBound);
                
            end
            
            noiseChannels = unique([info.noiseChannels, noiseChannelsManual']);
            prompt = ['NoiseChannels =', mat2str(noiseChannels), ' Enter other bad channels, if there are none, put []'];
            exNoise = input(prompt);
            noiseChannels = sort([noiseChannels, exNoise]);
            
            info.noiseChannels = noiseChannels;
            
            save(dirName, 'info', 'dataSnippits', '-append')
            
            date = info.date;
            clearvars LFPData dataSnippits fullTraceTime
        end
        %
    end
    
    %% Clean data, mean subtract make average pictures
    close all
    
    loadingWindow = waitbar(0, 'Converting data...');
    totalExp = length(allData);
    
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
            cleanedFullTrace(noiseChannels(n), :) = NaN(1, size(LFPData, 2));
            
            if ndims(dataSnippits) ==3
                 cleanedData(noiseChannels(n), :, :) = NaN(size(dataSnippits,2), size(dataSnippits, 3));
            end
        end

    % to mean subtract ecog data only
    if ~isnan(info.ecogChannels)
        if ndims(dataSnippits) ==3
            eCoGMean = nanmean(cleanedData(info.ecogChannels,:, :),1);
            meanSubData(info.ecogChannels,:,:) = cleanedData(info.ecogChannels,:,:) - repmat(eCoGMean, [size(info.ecogChannels,2), 1, 1]);
        end
        
        LFPeCoGMean = nanmean(cleanedFullTrace(info.ecogChannels, :),1);
        meanSubFullTrace(info.ecogChannels,:) = cleanedFullTrace(info.ecogChannels,:) - repmat(LFPeCoGMean, [size(info.ecogChannels,2), 1]);
    end
    
    % to mean subtract shanks data only
    if ~isnan(info.forkChannels)
        for f = 1:size(info.forkChannels,1)
            if ndims(dataSnippits) ==3
                forkMean = nanmean(cleanedData(info.forkChannels(f,:),:, :),1);
                meanSubData(info.forkChannels(f,:),:,:) = cleanedData(info.forkChannels(f,:),:,:) - repmat(forkMean, [size(info.forkChannels(f,:),2), 1, 1]);
            end
            
            LFPforkMean = nanmean(cleanedFullTrace(info.forkChannels(f,:), :),1);
            meanSubFullTrace(info.forkChannels(f,:),:) = cleanedFullTrace(info.forkChannels(f,:),:) - repmat(LFPforkMean, [size(info.forkChannels(f,:),2), 1]);
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
        
        if exist('allStartTimes') && ~empty(allStartTimes)
            if iscell(allStartTimes) && length(allStartTimes) ==1
                allStartTimes = allStartTimes{1};
            end
            info.startOffSet = round(finalSampR*(allStartTimes(1)-before));
            info.endOffSet = round(finalSampR*(allStartTimes(end)+after));
        end
    end 
    
    if ndims(dataSnippits) ==3
        save([dirIn, dirName],'meanSubFullTrace', 'meanSubData', 'aveTrace', 'standError', 'info', '-append')
    else
        save([dirIn, dirName],'meanSubFullTrace', 'info', '-append')
    end
        waitbar(experiment/totalExp)
    end
    
    close(loadingWindow);
    
end
