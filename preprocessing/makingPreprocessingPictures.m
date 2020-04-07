%% Making preprocessing pictures

close all
clear

dirIn = '/synology/adeeti/ecog/iso_awake_VEPs/GL8/';
dirPic =  '/synology/adeeti/ecog/images/Iso_Awake_VEPs/GL8/preprocessing/';

identifier = '2019*.mat';
START_AT = 1;

flashOn = [0,0];
before = 1;
after = 2;
markTime = -before:.1:after;
screensize=get(groot, 'Screensize');

mkdir(dirPic)

cd(dirIn)
allData = dir(identifier);

loadingWindow = waitbar(0, 'Converting data...');
totalExp = length(allData);

for i = START_AT:length(allData)
    load(allData(i).name, 'info', 'meanSubData', 'aveTrace', 'finalTime', 'finalSampR', 'latency', 'indexSeries', 'uniqueSeries')
    
%     if size(uniqueSeries,1) ==1
%         continue
%     end 
    
    for a = 1:size(aveTrace, 1)
        
        stimIndex = uniqueSeries(a,:);
        indices = find(a == indexSeries);
        useMeanSubData = meanSubData(:, indices,:);
       [stimIndexSeriesString] = stimIndex2string4saving(stimIndex, finalSampR);
        
        %Single trial images
        [currentFig] = plotSingleTrials(useMeanSubData, finalTime, info);
        suptitle(['Single trials, Experiment ', num2str(info.exp), ', ', info.TypeOfTrial, ', Drug: ',  info.AnesType, ', Conc: ', num2str(info.AnesLevel), ', Series ', strrep(stimIndexSeriesString, '_', '\_')]);
        saveas(currentFig, [dirPic, info.expName(1:end-4), '_', stimIndexSeriesString, '_singletrials.png'])
        close all;
        
        [stimIndexSeriesString] = stimIndex2string4saving(stimIndex, finalSampR);
        
        % Plot on onset of latency on averages
        if exist('latency', 'var')
            [currentFig] = plotAverages(squeeze(aveTrace(a,:,:)), finalTime, info, [], [], [], squeeze(latency(a,:)), before, after, flashOn, finalSampR);
            suptitle(['Average with Latency, Experiment ', num2str(info.exp), ',  Drug: ', info.AnesType, ', Conc: ', num2str(info.AnesLevel), ', Series ', strrep(stimIndexSeriesString, '_', '\_')])
            saveas(currentFig, [dirPic, info.expName(1:end-4), '_', info.AnesType, '_', stimIndexSeriesString '_aveLat.png'])
        else
            [currentFig] = plotAverages(squeeze(aveTrace(a,:,:)), finalTime, info, [], [], [],[], before, after, flashOn, finalSampR);
        suptitle(['Average, Experiment ', num2str(info.exp), ',  Drug: ', info.AnesType, ', Conc: ', num2str(info.AnesLevel), ', Series ', strrep(stimIndexSeriesString, '_', '\_')])
        saveas(currentFig, [dirPic, info.expName(1:end-4), '_', info.AnesType, '_', stimIndexSeriesString '_ave.png'])
        end
        
        close all
        
        % Plot latency heat map on grid
        if exist('latency', 'var')
        [currentFig, colorMatrix, gridData]=PlotOnECoG(squeeze(latency(a,:)), info, 1);
        title({['Latency: Experiment ',  num2str(info.exp), ', Series ', strrep(stimIndexSeriesString, '_', '\_')],
            ['Drug: ', info.AnesType, ', Conc: ', num2str(info.AnesLevel)]})
        saveas(currentFig, [dirPic, info.expName(1:end-4), '_', info.AnesType, '_', stimIndexSeriesString 'heatLat.png'])
        close all
        end
        
    end
    
    waitbar(i/totalExp)
end

close(loadingWindow);