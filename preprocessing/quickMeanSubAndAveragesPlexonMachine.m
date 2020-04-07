%% mean subtraction and making averages and unique series/index series 

uniqueSeries = [0,inf];
info = [];

CSDWITHGRID =1; %1 if want to analyze both CSD and grid, 0 if want to analyze grid only 
GRID = 0; %if 1, Grid is present, if 0 grid is not 
totalChan = 64;

info.noiseChannels = [74];
info.ecogChannels= [65:128];
info.forkChannels = [1:64];

if min(noiseChanels 

START_AT = 1;
identifier = '2019*.mat';

flashOn = [0,0];
before = 1;
after = 2;
markTime = -before:.1:after;
screensize=get(groot, 'Screensize');

cd(dirOut)
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
    
    indexSeries = ones(size(meanSubData,2), 1);
    info.stimIndex = uniqueSeries;
    
    for n = 1:length(noiseChannels)
        if isempty(noiseChannels)
            continue
        end
        cleanedData(noiseChannels(n), :, :) = NaN(size(dataSnippits,2), size(dataSnippits, 3));
        cleanedFullTrace(noiseChannels(n), :) = NaN(1, size(LFPData, 2));
    end
    
    % to mean subtract ecog data only 
    eCoGMean = nanmean(cleanedData(info.ecogChannels,:, :),1);
    LFPeCoGMean = nanmean(cleanedFullTrace(info.ecogChannels, :),1);
    
    meanSubData(info.ecogChannels,:,:) = cleanedData(info.ecogChannels,:,:) - repmat(eCoGMean, [size(info.ecogChannels,2), 1, 1]);
    meanSubFullTrace(info.ecogChannels,:) = cleanedFullTrace(info.ecogChannels,:) - repmat(LFPeCoGMean, [size(info.ecogChannels,2), 1]);  
    
     % to mean subtract shanks data only
    if CSDWITHGRID ==1
        for f = 1:size(info.forkChannels,1)
            forkMean = nanmean(cleanedData(info.forkChannels(f,:),:, :),1);
            LFPforkMean = nanmean(cleanedFullTrace(info.forkChannels(f,:), :),1);
            
            meanSubData(info.forkChannels(f,:),:,:) = cleanedData(info.forkChannels(f,:),:,:) - repmat(forkMean, [size(info.forkChannels(f,:),2), 1, 1]);
            meanSubFullTrace(info.forkChannels(f,:),:) = cleanedFullTrace(info.forkChannels(f,:),:) - repmat(LFPforkMean, [size(info.forkChannels(f,:),2), 1]);
        end
    end

    %meanSubData = cleanedData - repmat(nanmean(cleanedData,1), [size(cleanedData,1), 1, 1]);
    aveTrace = nan(size(uniqueSeries, 1), size(meanSubData,1), size(meanSubData,3));
    standError = nan(size(uniqueSeries, 1), size(meanSubData,1), size(meanSubData,3));
    
    for i = 1:size(uniqueSeries, 1)
        [indices] = getStimIndices(uniqueSeries(i,:), indexSeries, uniqueSeries);
        useMeanSubData = meanSubData(:,indices,:);
        parfor ch = 1:size(meanSubData,1)
            aveTrace(i, ch, :) = squeeze(nanmean(meanSubData(ch,:,:), 2));
            standError(i, ch,:) = squeeze(nanstd(meanSubData(ch,:,:), 1, 2)/sqrt(size(meanSubData(ch,:,:), 2)));
        end
    end
    
    info.startOffSet = round(finalSampR*(allStartTimes{1}(1)-before));
    info.endOffSet = round(finalSampR*(allStartTimes{1}(end)+after));
    
    save([dirOut, dirName], 'meanSubFullTrace', 'uniqueSeries', 'indexSeries', 'meanSubData', 'aveTrace', 'standError', 'info',  '-append')
    %save([dirOut, dirName], 'cleanedData', 'meanSubFullTrace' 'meanSubData', 'aveTrace', 'standError', 'info', 'dataSnippits','finalTime', 'finalSampR', 'LFPData', 'eventTimes', 'fullTraceTime','plexInfoStuffs','uniqueSeries', 'indexSeries')
      
    % Single trial images
    
    %[currentFig] = plotSingleTrials(meanSubData, finalTime, info);

    %saveas(currentFig, [dirPic, dirName, 'singletrials.png'])
    %close all;
    
    % Flash triggered average images
    
    %[currentFig] = plotAverages(aveTrace, finalTime, info, [], [], [], [], before, after, flashOn);
    
    %[currentFig] = plotAverages(plotData, finalTime, info, yAxis, lowerCIBound, upperCIBound, latency,  before, after, flashOn, finalSampR)
    
    %saveas(currentFig, [dirPic, allData(experiment).name, 'average.png'])
    close all;
end

%% to make some average picture 

experimentName = '2019-003-07_12-50-00'
load(experimentName, 'aveTrace')
subplot(2,1,1)
plot(squeeze(aveTrace(1,info.forkChannels,800:end))')
title('Flashes on Depth')
subplot(2,1,2)
plot(squeeze(aveTrace(1,info.ecogChannels,800:end))')
title('Flashes on ECOG')
suptitle('Aveerage VEP traces')

%%

figure
LFPforkMean = nanmean(dataSnippits,1);
 meanSubData = dataSnippits - repmat(LFPforkMean, [64, 1]);
ave = squeeze(nanmean(meanSubData,2));
plot(ave')
