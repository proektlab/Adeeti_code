%% single trials for isoflurane and propofol

%% general loading
clc
clear
close all

dirIn = '/data/adeeti/ecog/matIsoPropMultiStim/';
dirFiltData = '/data/adeeti/ecog/matIsoPropMultiStim/Wavelets/FiltData/';
dirOut1 = '/data/adeeti/ecog/images/IsoPropCompV1Paper/';
dirDropbox = '/data/adeeti/Dropbox/';

cd(dirIn)
load('dataMatrixFlashes.mat')
load('matStimIndex.mat')

lowestLatVariable = 'lowLat';

stimIndex = [0, Inf]; %if want all, stimIndex = matStimIndex; % if want
%all uniStimIndexes/multiStimIndexes, use [uniStimIndex, multiStimIndex] =
%findUniMutliStimIndex(matStimIndex), [stimIndex, ~] = findUniMutliStimIndex(matStimIndex)

% Setting up new data set for just visual only stim
expLabel =unique(vertcat(dataMatrixFlashes(:).exp));
allExp = {};
if exist('stimIndex')  && ~isempty(stimIndex)
    for i = 1:length(expLabel)
        for j = 1:size(stimIndex,1)
            [MFE] = findMyExpMulti(dataMatrixFlashes, expLabel(i), [], [], stimIndex(j,:));
            allExp{i}(:) = MFE;
        end
    end
else
    [MFE] = 1:length(dataMatrixFlashes);
end

numSubjects = size(allExp,2);
maxExposuresPerSubject = max(cellfun(@length, allExp));

%ID = 5;
numTrials = 6;

%% single trials 

for ID = 1:numSubjects
    singleTrials = nan(maxExposuresPerSubject, numTrials, 3001);
    averages = nan(maxExposuresPerSubject, 3001);
    
    for experiment = 1: maxExposuresPerSubject
        if experiment> numel(allExp{ID})
            continue
        end
        load(dataMatrixFlashes(allExp{ID}(experiment)).expName, 'info', 'uniqueSeries', 'indexSeries', 'meanSubData')
        V1 = info.lowLat;
        [indices] = getStimIndices(stimIndex, indexSeries, uniqueSeries);
        useMeanSubData = meanSubData(:, indices,:);
        
        chosenTrials = randsample(size(useMeanSubData,2), numTrials);
        singleTrials(experiment,:,:) = squeeze(useMeanSubData(V1,chosenTrials,:));
        averages(experiment,:) = squeeze(nanmean(useMeanSubData(V1,:,:),2));
    end
    
    plotTime = [500:1500];
    timeAxis = linspace(-1+plotTime(1)*.001, -1+plotTime(end)*.001, numel(plotTime));
    
    plotCounter = 0;
    screensize=get(groot, 'Screensize');
    ff = figure('Position', screensize, 'color', 'w'); clf;
    ff.Renderer='Painters';
    clf
    for trial = 1:numTrials+1
        for experiment = 1:maxExposuresPerSubject
            plotCounter = plotCounter +1;
            h(plotCounter) =subplot(numTrials+1, maxExposuresPerSubject, plotCounter);
            
            if trial < numTrials+1
                plot(timeAxis, squeeze(singleTrials(experiment,trial,plotTime)))
                line([0 0], [min(singleTrials(:)), max(singleTrials(:))], 'LineWidth', 2, 'Color', 'g');
                if trial == 1 && (experiment == 1|| experiment == 5)
                    title('High Dose Isoflurane')
                elseif trial == 1 && (experiment == 2|| experiment == 6)
                    title('Low Dose Isoflurane')
                elseif trial == 1 && experiment == 3
                    title('Low Dose Propofol')
                elseif trial == 1 && experiment == 4
                    title('High Dose Propofol')
                end
            end
            
            if trial ==numTrials && experiment ==1
                line([-.3 -.3], [-500 -250], 'LineWidth', 2, 'Color', 'k');
                line([-.3 -.05], [-500 -500], 'LineWidth', 2, 'Color', 'k');
                
                tt=text(-.4, -370, '250 \muV', 'FontName', 'Arial', 'FontSize', 12);
                tt2=text(-.2, -550, '250 ms', 'FontName', 'Arial', 'FontSize', 12);
            end
            
            if trial == numTrials+1
                plot(timeAxis, squeeze(averages(experiment,plotTime)), 'Linewidth', 2)
                line([0 0], [min(singleTrials(:)), max(singleTrials(:))], 'LineWidth', 2, 'Color', 'g');
                title('Average VEP')
                if experiment == 1
                    line([-.3 -.3], [-40 10], 'LineWidth', 2, 'Color', 'k');
                    line([-.3 -.05], [-40 -40], 'LineWidth', 2, 'Color', 'k');
                    
                    tt3=text(-.4, -15, '50 \muV', 'FontName', 'Arial', 'FontSize', 12);
                    tt4=text(-.25, -30, '250 ms', 'FontName', 'Arial', 'FontSize', 12);
                end
                set(gca, 'ylim', [min(averages(:)), max(averages(:))])
            else
                set(gca, 'ylim', [min(singleTrials(:)), max(singleTrials(:))])
            end
            
            set(gca, 'xlim', [timeAxis(1), timeAxis(end)])
            axis off
        end
        
%         if trial ==numTrials+1 && experiment ==1
%             line([-.3 -.3], [-40 10], 'LineWidth', 2, 'Color', 'k');
%             line([-.3 -.05], [-40 -40], 'LineWidth', 2, 'Color', 'k');
%             
%             tt3=text(-.4, -15, '50 \muV', 'FontName', 'Arial', 'FontSize', 12);
%             tt4=text(-.25, -30, '250 ms', 'FontName', 'Arial', 'FontSize', 12);
%         end
    end
    suptitle(['Mouse ID: ', num2str(ID)'])
    saveas(ff, [dirOut1, 'singletrials', num2str(ID), '.png'])
end
%set(h, 'axes', 'off')

%% showing that the coherent power at gamma increases with visual evoked potential 

chooseFr = 35;
numTrials = 6;

for ID = 5%:numSubjects
    singleTrials = nan(maxExposuresPerSubject, numTrials, 3001);
    filtSingleTrials = nan(maxExposuresPerSubject, numTrials, 2001);
    
    allSingleTrials = nan(maxExposuresPerSubject, 80, 3001);
    allFiltSingleTrials = nan(maxExposuresPerSubject, 80, 2001);
    
    averages = nan(maxExposuresPerSubject, 3001);
    filtAverages = nan(maxExposuresPerSubject, 2001);
    
    for experiment = 1:maxExposuresPerSubject
        if experiment> numel(allExp{ID})
            continue
        end
        cd(dirIn)
        load(dataMatrixFlashes(allExp{ID}(experiment)).expName, 'info', 'uniqueSeries', 'indexSeries', 'meanSubData')
        V1 = info.lowLat;
        [indices] = getStimIndices(stimIndex, indexSeries, uniqueSeries);
        useMeanSubData = meanSubData(:, indices,:);
        allSingleTrials(experiment,:,:) = squeeze(useMeanSubData(V1,1:80,:));
        
        temp = dataMatrixFlashes(allExp{ID}(experiment)).expName;
        filtFileName = [temp(numel(temp)-22:end-4), 'wave.mat'];
        cd(dirFiltData)
        load(filtFileName, 'info', 'Freq', ['filtSig', num2str(chooseFr)])
        eval(['filtSig = filtSig', num2str(chooseFr), ';'])
        useFiltSig = permute(filtSig(:,:,indices), [2, 3, 1]);
        
        allFiltSingleTrials(experiment,:,:) = squeeze(useFiltSig(V1,1:80,:));
        
        chosenTrials = randsample(size(useMeanSubData,2), numTrials);
        singleTrials(experiment,:,:) = squeeze(useMeanSubData(V1,chosenTrials,:));
        filtSingleTrials(experiment,:,:) = squeeze(useFiltSig(V1,chosenTrials,:));
        averages(experiment,:) = squeeze(nanmean(useMeanSubData(V1,:,:),2));
        filtAverages(experiment,:) = squeeze(nanmean(useFiltSig(V1,:,:),2));
    end
    
    % plotting all single trials
    figure
    for experiment = 1:size(allFiltSingleTrials,1)
        h = subplot(6,1,experiment);
        plot(squeeze(allFiltSingleTrials(experiment,:,:))')
        hold on
        plot(squeeze(filtAverages(experiment,:)), 'k', 'Linewidth', 2.5)
        if experiment == 1|| experiment == 5
            title('High Dose Isoflurane')
        elseif experiment == 2|| experiment == 6
            title('Low Dose Isoflurane')
        elseif experiment == 3
            title('Low Dose Propofol')
        elseif experiment == 4
            title('High Dose Propofol')
        end
        set(gca,'ylim', [min(allFiltSingleTrials(:)), max(allFiltSingleTrials(:))])
        set(gca,'xlim', [750,1500])
    end
    suptitle(['Mouse ID: ', num2str(ID)])
end

trial = [3 16 39 32 45 58 69];
timeFrame= [850:1350];

for experiment =1:maxExposuresPerSubject
    figure
    for t = 1:length(trial)
        subplot(7,1,t)
        plot(squeeze(allFiltSingleTrials(experiment,trial(t),timeFrame))')
        hold on
        plot(squeeze(allSingleTrials(experiment,trial(t),timeFrame)*.05)')
        title(['Trial ', num2str(trial(t))])
        legend('filtered data', 'VEP')
    end
    if experiment == 1|| experiment == 5
        suptitle('High Dose Isoflurane')
    elseif experiment == 2|| experiment == 6
        suptitle('Low Dose Isoflurane')
    elseif experiment == 3
        suptitle('Low Dose Propofol')
    elseif experiment == 4
        suptitle('High Dose Propofol')
    end
end

figure



%%





