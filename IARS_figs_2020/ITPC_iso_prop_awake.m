%% Stats on ITPC measures and making graphs for each experiment

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
expos = [2,3];
lowestLatVariable = 'lowLat';

useMeanSubData = nan(3, 85, 3001);
for experiment = 1:length(expos)
    mouseID = expos(experiment);
    disp(num2str(experiment))
    load(dataMatrixFlashes(MFE(mouseID)).expName, 'info', 'uniqueSeries', 'indexSeries', 'meanSubData')
    isoProp_V1 = info.lowLat;
    [indices] = getStimIndices(stimIndex, indexSeries, uniqueSeries);
    useMeanSubData(experiment,:,:) =squeeze(meanSubData(info.lowLat, indices(1:85),:));
end


%% load and organize get awake data
dirIn_Awake = '/Users/adeetiaggarwal/Dropbox/KelzLab/Playing_data/IP2/';
cd(dirIn_Awake)
load('dataMatrixFlashes.mat')
awakeID = 3;
load(dataMatrixFlashes(4).expName(end-22:end), 'meanSubData', 'aveTrace', 'info')
useMeanSubData(3,:,:) = squeeze(meanSubData(info.lowLat,1:85,:))*1100;

trueITPC = nan(3,40,2001);

%% parameters for bootstrapping

for experiment = 1:size(useMeanSubData,1)
    
    useMeanSubDataEXP = useMeanSubData(experiment,:,:);
    useSmallSnippits = useMeanSubDataEXP(:,:,1:2001);
    
    %% Run wavelet on real data
    WAVE=zeros(40, 2001, 1, size(useSmallSnippits,2));
    disp('Calc real wavelet')
    for j = 1:size(useSmallSnippits,2)
        sig=detrend(squeeze(useSmallSnippits(1, j,:)));
        % [temp,PERIOD,SCALE,COI,DJ, PARAMOUT, K] = contwt(sig,1/1000,1, 0.1);
        [temp,PERIOD,SCALE,COI,DJ, PARAMOUT, K] = contwt(sig,1/1000,1, 0.25);
        WAVE(:,:,:,j)=temp; %WAVE is in freq by time by channels by trials
        Freq=1./PERIOD;
    end
    
    
    trueITPC(experiment,:,:) = ITPC_AA(WAVE);
end

%% plotting and shit
% plot results

ff = figure('color', 'w'); clf;
% ff.Renderer='Painters';
clf
useFreq = find(Freq>20 & Freq<150);
timeAxis = linspace(-0.5,0.5,1001);
useTime = 500:1500;

for experiment = 1:size(useMeanSubData,1)
    h(experiment)= subplot(2,3,experiment)
    plot(timeAxis,squeeze(mean(useMeanSubData(experiment,:,useTime),2)));
    hold on
    line([0 0], [min(useMeanSubData(:)), max(useMeanSubData(:))], 'LineWidth', 2, 'Color', 'g');
    colorbar
    set(gca, 'ylim', [-120, 100])
    axis off
    if experiment ==1
        title('Isoflurane')
        line([-.05 -.05], [-100 -50], 'LineWidth', 2, 'Color', 'k');
        line([-.05 .05], [-100 -100], 'LineWidth', 2, 'Color', 'k');
        
        tt=text(-.05, -70, '50 \muV', 'FontName', 'Arial', 'FontSize', 12);
        tt2=text(-.05, -100, '100 ms', 'FontName', 'Arial', 'FontSize', 12);
    elseif experiment ==2
        title('Propofol')
    elseif experiment ==3
        title('Awake')
    end
    
    
    h(experiment+3) = subplot(2, 3, experiment+3)
    pcolor(timeAxis, Freq(useFreq), squeeze(trueITPC(experiment,useFreq,useTime))); shading 'flat';
    xlabel('Time (s)')
    ylabel('Frequency (Hz)')
    set(gca, 'yscale', 'log')
    set(gca, 'YTick', [1, 10, 20, 40, 60, 80, 100])
    colorbar
    set(gca, 'clim', [0, 0.8])
    title('True ITPC')
    
    
    %suptitle(['ITPC'])
    
    linkaxes(h, 'x')
    set(gca, 'xlim', [min(timeAxis), max(timeAxis)])
    
    %saveas(ff, [dirOut1, 'ITPCsingleTrialOnlyGamma', info.expName, '.png'])
    
    %saveas(ff, [dirOut1, 'ITPCforF30', '.pdf'])
    
end