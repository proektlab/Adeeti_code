%% Finding Latencies for each experiment

% 8/9/18 AA editted for multistim delivery
% 9/10/18 AA editted to allow for concurrent analysis of ECOG and Fork 
%%

% clear
% dirIn = '/synology/adeeti/ecog/iso_awake_VEPs/GL7/';
% % dirPics = '/data/adeeti/ecog/images/IsoPropMultiStim/latencyHeatMap/';
% %dirPics1 = '/data/adeeti/ecog/images/IsoPropMultiStim/latencyOnAverages/';
% % mkdir(dirPics)
% 
% stimIndex = [0, Inf];
% 
% identifier = '2019*.mat';
% START_AT = 1;

before=1;
l = 3;
flashOn = [0,0];
thresh=4;
maxThresh = 5;
consistent = 4;
endMeasure = 0.35;
allV1Lat = 22;

cd(dirIn)
allData = dir(identifier);

for experiment = START_AT:length(allData)
    close all
    disp(['Finding latency for experiment ', num2str(experiment), ' out of ', num2str(length(allData))])
    
    dirName = allData(experiment).name;
    load(allData(experiment).name, 'finalSampR', 'aveTrace', 'finalTime', 'info', 'uniqueSeries')
    if isempty(aveTrace)
        continue
    end
    
    useAve = aveTrace(:, info.ecogChannels,:);
    latency = nan(size(useAve,1), size(useAve,2));
    
    % Gettting Latencies
    for i = 1:size(aveTrace,1)
    [ zData, stimTypeLat ] = normalizedThreshold(squeeze(useAve(i,:,:)), thresh, maxThresh, consistent, endMeasure, before, finalSampR);

        %% Plot on onset of latency on averages
    %stimIndex = uniqueSeries(i,:);
    %[stimIndexSeriesString] = stimIndex2string4saving(stimIndex, finalSampR);
    %
    %[currentFig] = plotAverages(zData, finalTime, info, [], [], [], stimTypeLat before, l-before, flashOn, finalSampR)
    %suptitle(['Average with Latency: Experiment ', info.exp, ',  Drug: ', info.AnesType, ' Conc: ', num2str(info.AnesLevel), ', ', strrep(stimIndexSeriesString, '_', '\_')])
    %saveas(currentFig, [dirPics1, info.expName(1:end-4), '_', info.AnesType, '_', stimIndexSeriesString '_aveLat.png'])
    
    %% Plot latency heat map on grid
    
%     [currentFig, colorMatrix, gridData]=PlotOnECoG(stimTypeLat, info, 1);
%     title({['Latency: Experiment ', info.date],
%         ['Drug: ', info.AnesType, 'Conc: ', num2str(info.AnesLevel), strrep(stimIndexSeriesString, '_', '\_')]})
%     saveas(currentFig, [dirPics, info.expName(1:end-4), '_', info.AnesType, '_', stimIndexSeriesString 'heatLat.png'])
    
    
    latency(i,:) = stimTypeLat; 
    save([dirIn, allData(experiment).name], 'latency', '-append')
    end
end

%% Finding the same V1 for every mouse

%[allV1, onsetMat] = V1forEachMouse([0, Inf, Inf, Inf], 'lowLat', 30, 1);
[allV1, onsetMat] = V1forEachMouse(1, 0, stimIndex, 1, 'lowLat', allV1Lat, 1);
%[allV1, onsetMat] = V1forEachMouse(useStimIndex, useNumStim, stimIndex, numStim, variableName, thresh, saveV1)

