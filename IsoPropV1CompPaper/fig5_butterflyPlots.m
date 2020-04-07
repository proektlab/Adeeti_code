%% Creating Butterfly plots... again

%% general loading
clc
clear
close all

onAlexsWorkStation = 2; %1 if on workstation with complete multistim data set, 0 if on lab mac, 2 if on laptop

if onAlexsWorkStation ==1
    % Alex's computer
    dirIn = '/data/adeeti/ecog/matIsoPropMultiStim/';
    dirFiltData = '/data/adeeti/ecog/matIsoPropMultiStim/Wavelets/FiltData/';
    dirOut1 = '/data/adeeti/ecog/images/IsoPropCompV1Paper/';
    dirDropbox = '/data/adeeti/Dropbox/';
    cd(dirIn)
    load('dataMatrixFlashes.mat')
elseif onAlexsWorkStation ==0
    % Adeeti's Desktop
    dirIn = '/Users/adeeti/Desktop/data/VIS_Only_Iso_prop_2018/flashTrials/';
    dirOut1 = '/Users/adeeti/Google Drive/TNI/IsoPropCompV1Paper/';
    cd(dirIn)
    load('dataMatrixFlashesVIS_ONLY.mat')
    dataMatrixFlashes = dataMatrixFlashesVIS_ONLY;
elseif onAlexsWorkStation ==2
    % Adeeti's Laptop
    dirIn = '/Users/adeetiaggarwal/Google Drive/data/VIS_Only_Iso_prop_2018/flashTrials/';
    dirOut1 = '/Users/adeeti/Google Drive/TNI/IsoPropCompV1Paper/';
    cd(dirIn)
    load('dataMatrixFlashesVIS_ONLY.mat')
    dataMatrixFlashes = dataMatrixFlashesVIS_ONLY;
end

lowestLatVariable = 'lowLat';

stimIndex = [0, Inf]; %if want all, stimIndex = matStimIndex; % if want
%all uniStimIndexes/multiStimIndexes, use [uniStimIndex, multiStimIndex] =
%findUniMutliStimIndex(matStimIndex), [stimIndex, ~] = findUniMutliStimIndex(matStimIndex)

% Setting up new data set for just visual only stim
expLabel =unique(vertcat(dataMatrixFlashes(:).exp));
allExp = {};
if exist('stimIndex')  && ~isempty(stimIndex)
    for i = 1:length(expLabel)
        for experiment = 1:size(stimIndex,1)
            [MFE] = findMyExpMulti(dataMatrixFlashes, expLabel(i), [], [], stimIndex(experiment,:));
            allExp{i}(:) = MFE;
        end
    end
else
    [MFE] = 1:length(dataMatrixFlashes);
end

numSubjects = size(allExp,2);
maxExposuresPerSubject = max(cellfun(@length, allExp));

%% for plotting butterfly plots

plotTime = [500:1500];
timeAxis = linspace(-1+plotTime(1)*.001, -1+plotTime(end)*.001, numel(plotTime));

screensize=get(groot, 'Screensize');


for ID = 5%1:numSubjects
    ff = figure('Position', screensize, 'color', 'w'); clf;
    ff.Renderer='Painters';
    clf
    useMeanSubData = nan(maxExposuresPerSubject, 64, 85, 3001);
    for experiment = 1:maxExposuresPerSubject
        if experiment> numel(allExp{ID})
            continue
        end
        load(dataMatrixFlashes(allExp{ID}(experiment)).expName, 'info', 'uniqueSeries', 'indexSeries', 'meanSubData')
        V1 = info.lowLat;
        [indices] = getStimIndices(stimIndex, indexSeries, uniqueSeries);
        useMeanSubData(experiment,:,:,:) = meanSubData(:, indices(1:85),:);
    end
    
    for experiment = 1:maxExposuresPerSubject
        h(experiment) = subplot(2,3,experiment);
        plot(timeAxis, squeeze(useMeanSubData(experiment, V1,:, plotTime)))
        hold on
        plot(timeAxis, squeeze(nanmean(useMeanSubData(experiment, V1,:, plotTime), 3)), 'k', 'LineWidth', 2)
        axis off 
        line([0 0], [min(useMeanSubData(:)), max(useMeanSubData(:))], 'LineWidth', 2, 'Color', 'g');
        
        if experiment == 1
            title('High Dose Isoflurane')
        elseif experiment == 2
            title('Low Dose Isoflurane')
        elseif experiment == 3
            title('Low Dose Propofol')
        elseif experiment == 4
            title('High Dose Propofol')
        elseif experiment == 5
            title('Re-exposure High Dose Isoflurane')
        elseif experiment == 6
            title('Re-exposure Low Dose Isoflurane')
        end
        
        if experiment ==1
            line([-.3 -.3], [-500 -250], 'LineWidth', 2, 'Color', 'k');
            line([-.3 -.05], [-500 -500], 'LineWidth', 2, 'Color', 'k');
            
            tt=text(-.4, -370, '250 \muV', 'FontName', 'Arial', 'FontSize', 12);
            tt2=text(-.2, -550, '250 ms', 'FontName', 'Arial', 'FontSize', 12);
        end
        
    end
    suptitle(['Mouse ID: ', num2str(ID)])
end

