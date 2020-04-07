%% Make figure of baseline EEG for VI paper with associated spectra
clear
clc
close all

onAlexsWorkStation = 1; %1 if on workstation with complete multistim data set, 0 if on lab mac, 2 if on laptop

if onAlexsWorkStation ==1
    % Alex's computer
    dirIn = '/synology/adeeti/ecog/matIsoPropMultiStimVIS_ONLY_/baseline/';
    dirOut1 = '/home/adeeti/GoogleDrive/TNI/IsoPropCompV1Paper/';
    cd(dirIn)
    load('dataMatrixFlashesVIS_ONLY.mat')
    dataMatrixFlashes = dataMatrixFlashesVIS_ONLY;
elseif onAlexsWorkStation ==0
    % Adeeti's Desktop
    dirIn = '/Users/adeeti/Google Drive/data/matIsoPropMultiStimVIS_ONLY_/baseline/';
    dirOut1 = '/Users/adeeti/Google Drive/TNI/IsoPropCompV1Paper/';
    cd(dirIn)
    load('dataMatrixFlashesVIS_ONLY.mat')
    dataMatrixFlashes = dataMatrixFlashesVIS_ONLY;
elseif onAlexsWorkStation ==2
    % Adeeti's laptop
    dirIn = '/Users/adeetiaggarwal/Dropbox/KelzLab/Playing_data/IP2/';
    dirOut1 = '/Users/adeetiaggarwal/Dropbox/KelzLab/misc_figures/';
    cd(dirIn)
    load('dataMatrixFlashes.mat')
    %dataMatrixFlashes = dataMatrixFlashes;
end



%% looking at data

isoExp = '2019-07-26_14-16-00.mat';
awakeExp = '2019-07-26_14-42-00.mat';


load(awakeExp, 'meanSubFullTrace', 'info', 'finalSampR')
showData = meanSubFullTrace ;
% eegplot(showData, 'srate', fs);

chan2plot = 1:5;%35:39;
time2plot = 6;
timeAxis = 0.001:1/finalSampR:time2plot;
shift = 0.2;

ff = figure('color', 'w'); clf;
%ff.Renderer='Painters';

for i = 1:length(chan2plot)
    plot(timeAxis, showData(chan2plot(i),1:time2plot*finalSampR)+(i-1)*shift)
    %set(gca, 'ylim', [min(data(:)), max(data(:))])
    hold on
    %title(titleString{i})
    if i == 4
        line([0.5 0.5], [0.05 0.15], 'LineWidth', 2, 'Color', 'k'); % vertical line
        line([0.5 1.5], [0.05 0.05], 'LineWidth', 2, 'Color', 'k'); % horizontal line
        tt=text(0.5, 0.15, '100 uV', 'FontName', 'Arial', 'FontSize', 12); % vertical line
        tt2=text(.75, 0.05, '1 s', 'FontName', 'Arial', 'FontSize', 12); % horizontal line
    end
    axis off
end


%% Ploting single trials

freqBound = [1, 120];
useTime = [500:2000];
use_p_value = 1;

load(awakeExp, 'meanSubData', 'info', 'finalSampR', 'uniqueSeries', 'indexSeries', 'meanSubFullTrace')

[indices] = getStimIndices([0 inf], indexSeries, uniqueSeries);
useMeanSubData = meanSubData(:, indices,:);
awakeData = useMeanSubData;
awakeFullTrace = meanSubFullTrace;

channels = info.lowLat;


load(isoExp, 'meanSubData', 'info', 'finalSampR')

[indices] = getStimIndices([0 inf], indexSeries, uniqueSeries);
useMeanSubData = meanSubData(:, indices,:);
isoData = useMeanSubData;
isoFullTrace = meanSubFullTrace;



%% Run wavelet on awake, ITPC
awakeWAVE=zeros(43, size(awakeData,3), 1, size(awakeData,2));
for i= info.lowLat %i=1:size(WAVE,3)
    disp(i);
    for j = 1:size(awakeData,2)
        sig=detrend(squeeze(awakeData(i, j,:)));
        % [temp,PERIOD,SCALE,COI,DJ, PARAMOUT, K] = contwt(sig,1/1000,1, 0.1);
        [temp,PERIOD,SCALE,COI,DJ, PARAMOUT, K] = contwt(sig,1/1000,1, 0.25);
        awakeWAVE(:,:,1, j)=temp; %WAVE is in freq by time by channels by trials
        Freq=1./PERIOD;
    end
end
awakeITPC = ITPC_AA(awakeWAVE);

%% Run wavelet on iso, ITPC
isoWAVE=zeros(43, size(isoData,3), 1, size(isoData,2));
for i= info.lowLat %i=1:size(WAVE,3)
    disp(i);
    for j = 1:size(isoData,2)
        sig=detrend(squeeze(isoData(i, j,:)));
        % [temp,PERIOD,SCALE,COI,DJ, PARAMOUT, K] = contwt(sig,1/1000,1, 0.1);
        [temp,PERIOD,SCALE,COI,DJ, PARAMOUT, K] = contwt(sig,1/1000,1, 0.25);
        isoWAVE(:,:,1, j)=temp; %WAVE is in freq by time by channels by trials
        Freq=1./PERIOD;
    end
end
isoITPC = ITPC_AA(isoWAVE);

%%
freqInd = find(Freq>freqBound(1) & Freq<freqBound(2));
useFreq = Freq(freqInd);

%% plotting and shit
% plot results
ff = figure('color', 'w'); clf;
% ff.Renderer='Painters';
timeAxis = (useTime-1000)*1/finalSampR;

h1= subplot(3,2,1);
pcolor(timeAxis, [1:size(isoData,2)], squeeze(isoData(channels,:,useTime)));  shading 'flat';
colorbar
set(gca, 'clim', [-0.6, 0.3])
set(gca, 'fontsize', 16)
title('0.4% Isoflurane Single Trials')

h2= subplot(3,2,2);
pcolor(timeAxis, [1:size(awakeData,2)], squeeze(awakeData(channels,:,useTime)));  shading 'flat';
colorbar
set(gca, 'clim', [-0.6, 0.3])
set(gca, 'fontsize', 16)
title('Awake Single Trials')

h3= subplot(3,2,3);
plot(timeAxis,squeeze(mean(isoData(channels,:,useTime),2)));
colorbar
set(gca, 'fontsize', 16)
title('Average trace')

h4= subplot(3,2,4);
plot(timeAxis,squeeze(mean(awakeData(channels,:,useTime),2)));
colorbar
set(gca, 'fontsize', 16)
title('Average trace')

h5 = subplot(3, 2, 5);
pcolor(timeAxis, useFreq, squeeze(isoITPC(1,freqInd,useTime))); shading 'flat';
%set(gca, 'yscale', 'log')
set(gca, 'YTick', [1, 10, 30, 50, 70, 90])
set(gca, 'fontsize', 16)
colorbar
set(gca, 'clim', [0, 0.8])
title('ITPC')

h6 = subplot(3, 2, 6);
pcolor(timeAxis, useFreq, squeeze(awakeITPC(1,freqInd,useTime))); shading 'flat';
%set(gca, 'yscale', 'log')
set(gca, 'YTick', [1, 10, 30, 50, 70, 90])
set(gca, 'fontsize', 16)
colorbar
set(gca, 'clim', [0, 0.8])
title('ITPC')

%suptitle(['ITPC for V1 of ', strrep(info.expName(1:end-4), '_', '\_'), ' drug: ', info.AnesType, ' conc: ' num2str(info.AnesLevel)])
%suptitle(['ITPC for channel ', num2str(channels)])

linkaxes([h1 h2 h3 h4 h5 h6], 'x')



