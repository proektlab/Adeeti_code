%% Creating Butterfly plots... again

%% general loading
clc
clear
close all

% Adeeti's Laptop

%% load and organize iso prop data
dirIn_IsoProp = '/Users/adeetiaggarwal/Google Drive/data/matIsoPropMultiStimVIS_ONLY_/flashTrials/';
cd(dirIn_IsoProp)
load('dataMatrixFlashesVIS_ONLY.mat')
dataMatrixFlashes = dataMatrixFlashesVIS_ONLY;

isoPropMouseID = 5;
stimIndex= [0, Inf];
[MFE] = findMyExpMulti(dataMatrixFlashes, isoPropMouseID, [], [], stimIndex);
maxExposuresPerSubject = 6;
lowestLatVariable = 'lowLat';

useMeanSubData = nan(7, 85, 3001);
for experiment = 1:maxExposuresPerSubject
    load(dataMatrixFlashes(experiment).expName, 'info', 'uniqueSeries', 'indexSeries', 'meanSubData')
    isoProp_V1 = info.lowLat;
    [indices] = getStimIndices(stimIndex, indexSeries, uniqueSeries);
    useMeanSubData(experiment,:,:,:) =squeeze(meanSubData(info.lowLat, indices(1:85),:));
end


%% load and organize get awake data
dirIn_Awake = '/Users/adeetiaggarwal/Dropbox/KelzLab/Playing_data/IP2/';
cd(dirIn_Awake)
load('dataMatrixFlashes.mat')
awakeID = 3;
load(dataMatrixFlashes(4).expName(end-22:end), 'meanSubData', 'aveTrace', 'info')
useMeanSubData(7,:,:,:) = squeeze(meanSubData(info.lowLat,1:85,:))*1100;



%% for plotting butterfly plots

plotTime = [950:1200];
timeAxis = linspace(-1+plotTime(1)*.001, -1+plotTime(end)*.001, numel(plotTime));

screensize=get(groot, 'Screensize');

ff = figure('Position', screensize, 'color', 'w'); clf;
ff.Renderer='Painters';
clf

for expID = 1:7
    h(expID) = subplot(2,4,expID);
    plot(timeAxis, squeeze(useMeanSubData(expID,:, plotTime)))
    hold on
    plot(timeAxis, squeeze(nanmean(useMeanSubData(expID,:, plotTime), 2)), 'k', 'LineWidth', 2)
    axis off
    line([0 0], [min(useMeanSubData(:)), max(useMeanSubData(:))], 'LineWidth', 2, 'Color', 'g');
    
    if expID == 1
        title('High Dose Isoflurane')
    elseif expID == 2
        title('Low Dose Isoflurane')
    elseif expID == 3
        title('Low Dose Propofol')
    elseif expID == 4
        title('High Dose Propofol')
    elseif expID == 5
        title('Re-exposure High Dose Isoflurane')
    elseif expID == 6
        title('Re-exposure Low Dose Isoflurane')
    elseif expID == 7
        title('Awake')
    end
    
    if expID ==1
        line([-.05 -.05], [-500 -250], 'LineWidth', 2, 'Color', 'k');
        line([-.05 .05], [-500 -500], 'LineWidth', 2, 'Color', 'k');
        
        tt=text(-.05, -370, '250 \muV', 'FontName', 'Arial', 'FontSize', 12);
        tt2=text(-.05, -550, '250 ms', 'FontName', 'Arial', 'FontSize', 12);
    end
    
end
%suptitle(['Mouse ID: ', num2str(ID)])


