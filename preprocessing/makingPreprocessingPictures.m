function [stFig, avFig] = makingPreprocessingPictures(dirIn, identifier, dirPic, ...
    PicByTrialType, PicByAnesType, PicByAnesAndTrial, before, after, flashOn)
%[stFig, avFig] = makingPreprocessingPictures(dirIn, identifier, dirPic, ...
%    finalSampR, PicByTrialType, PicByAnesType, PicByAnesAndTrial, before, after, flashOn)

if nargin< 7
    flashOn = [0,0];
    before = 1;
    after = 2;
end

%%
cd(dirIn)
allData = dir(identifier);

for expID = 1:length(allData)
    load(allData(expID).name, 'uniqueSeries', 'indexSeries', 'meanSubData', 'aveTrace', ...
        'info', 'finalSampR', 'finalTime')
    
    for stimIndexLoop= 1:size(uniqueSeries, 1)
        strStimInd = uniqueSeries(stimIndexLoop,:);
        [stimIndexSeriesString] = stimIndex2string4saving(strStimInd, finalSampR);
        
        %Single trial images
        [indices] = getStimIndices(uniqueSeries(stimIndexLoop,:), indexSeries, uniqueSeries);
        useMeanSubData = meanSubData(:,indices,:);
        
        [stFig] = plotSingleTrials(useMeanSubData, finalTime, info);
        suptitle(['Single trials, Experiment ', num2str(info.exp), ', ', info.TypeOfTrial, ', Drug: ',  info.AnesType, ', Conc: ', num2str(info.AnesLevel), ', Series ', strrep(stimIndexSeriesString, '_', '\_')]);
        if PicByTrialType ==1
            saveas(stFig, [dirPic, info.expName(1:end-4), '_', info.TypeOfTrial, stimIndexSeriesString, '_singletrials.png'])
        elseif PicByAnesType ==1
            saveas(stFig, [dirPic, info.expName(1:end-4), '_', info.AnesType, stimIndexSeriesString, '_singletrials.png'])
        elseif PicByAnesAndTrial ==1
            saveas(stFig, [dirPic, info.expName(1:end-4), '_', info.TypeOfTrial, info.AnesType, StimIndexSeriesString, '_singletrials.png'])
        end
        close all
        
        % Plot on onset of latency on averages
        [avFig] = plotAverages(squeeze(aveTrace(stimIndexLoop,:,:)), finalTime, info, [], [], [],[], before, after, flashOn, finalSampR);
        suptitle(['Average, Experiment ', num2str(info.exp), ',  Drug: ', info.AnesType, ', Conc: ', num2str(info.AnesLevel), ', Series ', strrep(stimIndexSeriesString, '_', '\_')])
        if PicByTrialType ==1
            saveas(avFig, [dirPic, info.expName(1:end-4), '_', info.TypeOfTrial, stimIndexSeriesString, '_ave.png'])
        elseif PicByAnesType ==1
            saveas(avFig, [dirPic, info.expName(1:end-4), '_', info.AnesType, stimIndexSeriesString, '_ave.png'])
        elseif PicByAnesAndTrial ==1
            saveas(avFig, [dirPic, info.expName(1:end-4), '_', info.TypeOfTrial, info.AnesType, StimIndexSeriesString, '_ave.png'])
        end
        close all
    end
end
