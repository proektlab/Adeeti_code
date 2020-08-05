%% Make figure of baseline EEG for VI paper with associated spectra
clear 
clc
close all 

onAlexsWorkStation = 2; %1 if on workstation with complete multistim data set, 0 if on lab mac, 2 if on laptop

if onAlexsWorkStation ==1
    % Alex's computer
    dirIn = '/data/adeeti/ecog/matIsoPropMultiStimVIS_ONLY_/baseline/';
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
    dirIn = '/Users/adeetiaggarwal/Google Drive/data/matIsoPropMultiStimVIS_ONLY_/baseline/';
    dirOut1 = '/Users/adeetiaggarwal/Google Drive/TNI/IsoPropCompV1Paper/';
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
fs = 1000;

%% looking at data
% showData = meanSubData;
% eegplot(showData, 'srate', fs);

%%
totalTimeSement = 10; %in seconds
LFPtimeSegment = totalTimeSement*fs;
timeAxis = linspace(0,totalTimeSement,totalTimeSement*fs+1);
powerSpectraLFP = 54*fs+1;

baselineStringCI = {['Isoflurane 1.2'], ['CI Isoflurane 1.2'], ['Isoflurane 0.6'], ['CI Isoflurane 0.6'], ['Propofol 20'], ['CI Propofol 20'], ['Propofol 35'], ['CI Propofol 35'], ['Isoflurane 1.2'], ['CI Isoflurane 1.2'], ['Isoflurane 0.6'], ['CI Isoflurane 0.6']};

count = 1;
LFPforSpectra = nan(numSubjects, maxExposuresPerSubject, powerSpectraLFP);
baselineSegment = nan(numSubjects, maxExposuresPerSubject, LFPtimeSegment+1);
baselineString = [];
allLFPBaseline = [];
for ID = 1:numSubjects
    
    for experiment = 1: maxExposuresPerSubject
        if experiment> numel(allExp{ID})
            continue
        end
        load(dataMatrixFlashes(allExp{ID}(experiment)).expName, 'info', 'meanSubData')
        V1 = info.lowLat;
        useMeanSubData = meanSubData;
        startTimeLFP = randi(size(useMeanSubData,2)-LFPtimeSegment);
        endTimeLFP = startTimeLFP+LFPtimeSegment;
        LFPforSpectra(ID, experiment,:) = squeeze(useMeanSubData(V1, 1:powerSpectraLFP));
        baselineSegment(ID, experiment,:) = squeeze(useMeanSubData(V1, startTimeLFP:endTimeLFP));
        baselineString{experiment} = [info.AnesType, ' ', num2str(info.AnesLevel)];
        allLFPBaseline(count,:) = squeeze(useMeanSubData(V1, 1:powerSpectraLFP));
        count = count +1;
    end
end

%% Ploting single trials
 % eegplot(allLFPBaseline(allLowPropChan,:), 'srate', 1000)
% size of allLFPBaseline is 32x55001

colorsForPlot= {[0.6350, 0.0780, 0.1840], [0, 0.4470, 0.7410]}; %marroon and blue, respectively

totalTimeSement = 10; %in seconds
timeAxis = linspace(0,totalTimeSement,totalTimeSement*fs+1);

% 1.2% Isoflurane
allhighIsoChan1 = [1, 7, 13, 19, 23, 29, 33];
highIso1Index = 3;
timeHighIso1 = [6, 16];
highIso1 = allLFPBaseline(allhighIsoChan1(highIso1Index), timeHighIso1(1)*fs:timeHighIso1(2)*fs); %10 sec of high iso data

% 0.6% Isoflurane
allLowIsoChan1 = [2, 8, 14, 20, 24, 30, 34];
lowIso1Index = 3;
timelowIso1 = [1, 11];
lowIso1 = allLFPBaseline(allLowIsoChan1(lowIso1Index), timelowIso1(1)*fs:timelowIso1(2)*fs); %10 sec of low iso data

% 20 ug propofol
allLowPropChan = [3, 9, 15, 21, 25, 31, 35];
lowPropIndex = 4;
timelowProp = [10, 20];
% lowPropIndex = 4;
% timelowProp = [25, 35];
lowProp = allLFPBaseline(allLowPropChan(lowPropIndex), timelowProp(1)*fs:timelowProp(2)*fs); %10 sec of low prop data

% 35 ug propofol
allHighPropChan = [4, 10, 16, 22, 26, 32, 36];
highPropIndex = 5;
timehighProp = [26, 36];
highProp = allLFPBaseline(allHighPropChan(highPropIndex), timehighProp(1)*fs:timehighProp(2)*fs); %10 sec of high prop data

data(1,:) = squeeze(highIso1);
data(2,:) = squeeze(lowIso1);
data(3,:) = squeeze(highProp);
data(4,:) = squeeze(lowProp);
titleString = {['High Dose Isoflurane'], ['Low Dose Isoflurane'], ['High Dose Propofol'], ['Low Dose Propofol']};

screensize=get(groot, 'Screensize');
ff = figure('Position', screensize, 'color', 'w'); clf;
ff.Renderer='Painters';

for i = 1:size(data, 1)
    h(i) = subplot(2,2,i);
    plot(timeAxis, data(i,:))
    set(gca, 'ylim', [min(data(:)), max(data(:))])
    hold on
    title(titleString{i})
    if i == 4
         line([0.5 0.5], [-350 -150], 'LineWidth', 2, 'Color', 'k'); % vertical line
         line([0.5 1.5], [-350 -350], 'LineWidth', 2, 'Color', 'k'); % horizontal line
         tt=text(0.5, -250, '200 uV', 'FontName', 'Arial', 'FontSize', 12); % vertical line
         tt2=text(.75, -400, '1 s', 'FontName', 'Arial', 'FontSize', 12); % horizontal line
    end
    axis off
end



% for ID =6%1:size(LFPforSpectra,1)
%     screensize=get(groot, 'Screensize');
%     ff = figure('Position', screensize, 'color', 'w'); clf;
%     ff.Renderer='Painters';
%     clf
%     for i = 1:maxExposuresPerSubject
%         subplot(2,3,i)
%         plot(timeAxis,squeeze(baselineSegment(ID, i,:)))
%         title( baselineString{i})
%         set(gca, 'yLim', [min(baselineSegment(:)), max(baselineSegment(:))])
%     end
%     suptitle(['Mouse ID: ', num2str(ID)])
%     saveas(ff, [dirOut1, 'baseline', num2str(ID), '.png'])
% end


%% using multitaper power spectral density to compare anesthetics

Ktapers = 20;
freqWin = [0.05 100];

matlabColorsForFuns = {[0, 0.4470, 0.7410], [0.8500, 0.3250, 0.0980], [0.9290, 0.6940, 0.1250], [0.4940, 0.1840, 0.5560], [0.4660, 0.6740, 0.1880], [0.3010, 0.7450, 0.9330]};

spectrum = [];
freq = [];
out = [];
specCIUPPER = [];
specCILOWER = [];

for ID = 1:size(LFPforSpectra,1)
    for experiment = 1:size(LFPforSpectra,2)
        [out,taper,concentration]= mtpsd(squeeze(LFPforSpectra(ID, experiment,:))',fs,Ktapers,freqWin,[],[],[],[],1);
        spectrum(ID, experiment, :)=squeeze(out.psd);% size = 1 x windows x freq; tfse = power at each freq and time point
        specCIUPPER(ID, experiment, :) = out.jackknifeCI(1,:);
        specCILOWER(ID, experiment, :) = out.jackknifeCI(2,:);
    end
end
freq=out.freq_grid;

%% normalizing and conditions

totPower=sum(spectrum,3);
temp=repmat(totPower, 1,1, 500);

normSpectrum=spectrum./temp;

useSpectrum = spectrum;

%highIso=squeeze(normSpectrum(:,1,:));
meanCondition = [];
for i = 1:size(useSpectrum,2)
meanCondition(i,:) = nanmean(useSpectrum(:,i,:),1);
stdCondition(i,:) = nanstd(useSpectrum(:,i,:),1)/sqrt(size(useSpectrum,2));
upperCondition(i,:) = meanCondition(i,:) + stdCondition(i,:);
lowerCondition(i,:) = meanCondition(i,:) - stdCondition(i,:);
end

%% quantifying 0.3 to 1.05 htz activity

lowFreqIndex = find(freq>0.3 & freq<1.07);

lowFreqSpec = sum(useSpectrum(:,:,lowFreqIndex),3);

pLowFreq = kruskalwallis(lowFreqSpec(:,1:4));

combLowFreqSpec(:,1) = [lowFreqSpec(:,1); lowFreqSpec(:,2)];
combLowFreqSpec(:,2) = [lowFreqSpec(:,3); lowFreqSpec(:,4)];
[pLowFreqComb, hLowFreqComb, stats] = ranksum(combLowFreqSpec(:,1), combLowFreqSpec(:,2));


x = [1:4];
y = ones(7,1);
ind = meshgrid(x,y);
boxplot(lowFreqSpec(:,1:4), 'notch', 'on')
hold on 
scatter(ind,lowFreqSpec(:,1:4))

%% plot by condition
%colorsForPlot = { ['b'], ['c'], ['m'], ['r'], [0 0.498 0], ['g']};
colorsForPlot= {[0.6350, 0.0780, 0.1840], [0, 0.4470, 0.7410]};

ff= figure
for i = 1:4%size(normSpectrum,2)
    % plot(freq, squeeze(meanCondition(i,:)), 'Color', matlabColorsForFuns{i})
    if i ==1 || i ==5
        plot(freq, squeeze(meanCondition(i,:)), '-', 'Color', colorsForPlot{1}, 'LineWidth', 1)
        hold on
        %ciplot(squeeze(lowerCondition(i, :)), squeeze(upperCondition(i, :)), freq, matlabColorsForFuns{i})
        ciplot(squeeze(lowerCondition(i, :)), squeeze(upperCondition(i, :)), freq, colorsForPlot{1})
    elseif i ==2 || i ==6
        plot(freq, squeeze(meanCondition(i,:)), '--', 'Color', colorsForPlot{1}, 'LineWidth', 1)
        hold on
        %ciplot(squeeze(lowerCondition(i, :)), squeeze(upperCondition(i, :)), freq, matlabColorsForFuns{i})
        ciplot(squeeze(lowerCondition(i, :)), squeeze(upperCondition(i, :)), freq, colorsForPlot{1})
    elseif i ==3
        plot(freq, squeeze(meanCondition(i,:)), '-', 'Color', colorsForPlot{2}, 'LineWidth', 1)
        hold on
        %ciplot(squeeze(lowerCondition(i, :)), squeeze(upperCondition(i, :)), freq, matlabColorsForFuns{i})
        ciplot(squeeze(lowerCondition(i, :)), squeeze(upperCondition(i, :)), freq, colorsForPlot{2})
    elseif i ==4
        plot(freq, squeeze(meanCondition(i,:)), '--','Color', colorsForPlot{2}, 'LineWidth', 1)
        hold on
        %ciplot(squeeze(lowerCondition(i, :)), squeeze(upperCondition(i, :)), freq, matlabColorsForFuns{i})
        ciplot(squeeze(lowerCondition(i, :)), squeeze(upperCondition(i, :)), freq, colorsForPlot{2})
        
    end
end
legend(baselineStringCI, 'Location', 'northeast')
xlabel('Frequency (Hz)')
if useSpectrum == normSpectrum;
    ylabel('Power')
elseif useSpectrum == spectrum;
    ylabel('Normalized Power')
end

title('Average Baseline Spectra') 
set(gca, 'xscale', 'log', 'yscale', 'log')
   % saveas(ff, [dirOut1, 'averageSpectra_log_log', '.png'])
   % saveas(ff, [dirOut1, 'averageSpectra_log_log', '.pdf'])
% set(gca, 'xscale', 'lin','yscale', 'log')
%     saveas(ff, [dirOut1, 'averageSpectra_lin_log', '.png'])
%     saveas(ff, [dirOut1, 'averageSpectra_lin_log', '.pdf'])
% set(gca, 'xscale', 'lin','yscale', 'lin')
%     saveas(ff, [dirOut1, 'averageSpectra_lin_lin_smallFreq', '.png'])
%     saveas(ff, [dirOut1, 'averageSpectra_lin_linsmallFreq', '.pdf'])

%% plot mice and experiments individually 
figure
for ID = 1:size(LFPforSpectra,1)
    h(ID)= subplot(2,3, ID)
    for i = 1:size(LFPforSpectra,2)
        plot(freq,squeeze(spectrum(ID, i,:)), 'Color', matlabColorsForFuns{i})
        %grid on
        hold on
        ciplot(squeeze(specCILOWER(ID, i, :)), squeeze(specCIUPPER(ID, i, :)), freq, matlabColorsForFuns{i})
    end
    title(['Mouse ID: ', num2str(ID), 'Periodogram'])
    xlabel('Frequency (Hz)')
    ylabel('Power/Frequency (dB/Hz)')     
    set(gca, 'xscale', 'log', 'yscale', 'log')
    legend(baselineStringCI, 'Location', 'southwest')
end

suptitle('All spectra for all mice with CIs')


figure
for ID = 1:size(LFPforSpectra,1)
    for i = 1:size(LFPforSpectra,2)
        if i ==1
            plot(freq, squeeze(spectrum(ID, i,:)), 'Color', matlabColorsForFuns{i})
            hold on
            ciplot(squeeze(specCILOWER(ID, i, :)), squeeze(specCIUPPER(ID, i, :)), freq, matlabColorsForFuns{i})
        elseif i ==2
            plot(freq, squeeze(spectrum(ID, i,:)), 'Color', matlabColorsForFuns{i})
            hold on
            ciplot(squeeze(specCILOWER(ID, i, :)), squeeze(specCIUPPER(ID, i, :)), freq, matlabColorsForFuns{i})
        elseif i ==3
            plot(freq, squeeze(spectrum(ID, i,:)), 'Color', matlabColorsForFuns{i})
            hold on
            ciplot(squeeze(specCILOWER(ID, i, :)), squeeze(specCIUPPER(ID, i, :)), freq, matlabColorsForFuns{i})
        elseif i ==4
            plot(freq, squeeze(spectrum(ID, i,:)), 'Color', matlabColorsForFuns{i})
            hold on
            ciplot(squeeze(specCILOWER(ID, i, :)), squeeze(specCIUPPER(ID, i, :)), freq, matlabColorsForFuns{i})
        elseif i ==5
            plot(freq, squeeze(spectrum(ID, i,:)), 'Color', matlabColorsForFuns{i})
            hold on
            ciplot(squeeze(specCILOWER(ID, i, :)), squeeze(specCIUPPER(ID, i, :)), freq, matlabColorsForFuns{i})
        elseif i ==6
            plot(freq, squeeze(spectrum(ID, i,:)), 'Color', matlabColorsForFuns{i})
            hold on
            ciplot(squeeze(specCILOWER(ID, i, :)), squeeze(specCIUPPER(ID, i, :)), freq, matlabColorsForFuns{i})
        end
    end
end
title(['All mice ', 'Periodogram'])
    xlabel('Frequency (Hz)')
    ylabel('Power/Frequency (dB/Hz)')
    set(gca, 'xscale', 'log', 'yscale', 'log')
    legend(baselineStringCI, 'Location', 'southwest')

%% can also try using multitaper with short windows - but seems a little funky 

% win = 5; % size of window (secs) for spectrum
% win_step = 1; % size of window step (secs) for spectrum (in this case we are taking 10sec windows, stepping by 1sec)
% ktapers = 15;  % number of tapers for mutlitaper analysis
% NW = 29;  %
% 
% spectrum = [];
% freq = [];
% T = [];
% out = [];
% totalPowerPerFreq =[];
% 
% for ID = 1:size(LFPforSpectra,1)
%     for experiment = 1:size(LFPforSpectra,2)
%         [out, taper, concentration]=swTFspecAnalog(squeeze(LFPforSpectra(ID, experiment,:)), fs, ktapers, [], win*fs, win_step*fs, NW,[],[],[],[]); %multitaper spectral analysis
%         spectrum(ID, experiment,:, :)=squeeze(out.tfse);% size = 1 x windows x freq; tfse = power at each freq and time point
%     end
% end
% 
% freq=out.freq_grid; %extract freq evaluated
% T=out.time_grid; %extract time windows evaluated
% 
% totalPowerPerFreq = squeeze(sum(spectrum,3));
% 
% figure
% for ID = 1:size(LFPforSpectra,1)
%     h(ID)= subplot(2,3, ID)
%     for i = 1:size(LFPforSpectra,2)
%         plot(freq,10*log10(squeeze(totalPowerPerFreq(ID, i,:))))
%         grid on
%         hold on
%     end
%     title(['Mouse ID: ', num2str(ID), 'Periodogram'])
%     xlabel('Frequency (Hz)')
%     ylabel('Power/Frequency (dB/Hz)')
%     legend(baselineString)
% end
% suptitle('All spectra for all mice')
% 
% 
% figure
% for ID = 1:size(LFPforSpectra,1)
%     for i = 1:size(LFPforSpectra,2)
%         if i ==1
%             plot(freq,10*log10(squeeze(totalPowerPerFreq(ID, i,:))), 'Color', [0, 0.4470, 0.7410])
%             hold on
%         elseif i ==2
%             plot(freq,10*log10(squeeze(totalPowerPerFreq(ID, i,:))), 'Color', [0.8500, 0.3250, 0.0980])
%             hold on
%         elseif i ==3
%             plot(freq,10*log10(squeeze(totalPowerPerFreq(ID, i,:))), 'Color', [0.9290, 0.6940, 0.1250])
%             hold on
%         elseif i ==4
%             plot(freq,10*log10(squeeze(totalPowerPerFreq(ID, i,:))), 'Color', [0.4940, 0.1840, 0.5560])
%             hold on
%         elseif i ==5
%             plot(freq,10*log10(squeeze(totalPowerPerFreq(ID, i,:))), 'Color', [0.4660, 0.6740, 0.1880])
%             hold on
%         elseif i ==6
%             plot(freq,10*log10(squeeze(totalPowerPerFreq(ID, i,:))), 'Color', [0.3010, 0.7450, 0.9330])
%             hold on
%         end
%     end
% end
% title(['All mice ', 'Periodogram'])
%     xlabel('Frequency (Hz)')
%     ylabel('Power/Frequency (dB/Hz)')
%     legend(baselineString)

%% if using FFT
% figure(2)
% for i = 1:size(LFPforSpectra,1)
%     cleanData = squeeze(LFPforSpectra(i,:));
%     N = length(cleanData);
%     xdft = fft(cleanData);
%     xdft = xdft(1:N/2+1);
%     
%     psdx = (1/(fs*N)) * abs(xdft).^2;
%     psdx(2:end-1) = 2*psdx(2:end-1);
%     freq = 0:fs/length(cleanData):fs/2;
%     
%     plot(freq,10*log10(psdx))
%     grid on
%     hold on
% end
% title('Periodogram Using FFT')
% xlabel('Frequency (Hz)')
% ylabel('Power/Frequency (dB/Hz)')

%%

%
% % Ketamine EEG
% timeKet = [10, 15];
% ket = ketDataFilt(timeKet(1)*fs:timeKet(2)*fs); %10 sec of ketamine data
%
% % Wake EEG
% timeWake = [504, 509];
% chWake = 17;
% wake = filtBaseline(chWake, timeWake(1)*fs:timeWake(2)*fs); % 10 seconds of basline wake data
%
% % Drowsy EEG
% timeDrowsy = [3354, 3359];
% chDrowsy = 1;
% drowsy = filtIso(chDrowsy, timeDrowsy(1)*fs:timeDrowsy(2)*fs); % 10 seconds of basline wake data
%
% % Anes EEG (0.6% iso)
% timeIso = [3990, 3995];
% chIso = 1;
% iso = filtIso(chIso, timeIso(1)*fs:timeIso(2)*fs);
%
% clear data
% data(1,:) = wake;
% data(2,:) = drowsy;
% data(3,:) = iso;
% data(4,:) = ket*0.25;
%
% LFPshift = -200;
%
% figure
% for i = 1:size(data, 1)
%     if i == 1
%         plot(timeAxis, data(i,:))
%     elseif i == 2||i == 3
%         plot(timeAxis, data(i,:)+LFPshift*(i-1))
%     elseif i == 4
%         plot(timeAxis, data(i,:)+LFPshift*(i-1))
%         line([0.5 0.5], [-650 -550], 'LineWidth', 2, 'Color', 'k'); % vertical line
%         line([0.5 1], [-650 -650], 'LineWidth', 2, 'Color', 'k'); % horizontal line
%
%         tt=text(0.5, -600, '0.1 mV', 'FontName', 'Arial', 'FontSize', 12); % vertical line
%         tt2=text(.75, -700, '0.5 s', 'FontName', 'Arial', 'FontSize', 12); % horizontal line
%     end
%     hold on
% end
%
% %set(h, 'ylim', [-200, 200]);
% axis off
% fig=gcf;
% set(gcf,'color','w')
% fig.PaperUnits='Inches';
% fig.PaperPosition=[0 0 4 1.5];
% %print('traces','-dpdf')



% linkaxes
% axis off
% title('
% set(gcf,'color','w')
% fig=gcf;
% fig.PaperUnits='Inches';
% fig.PaperPosition=[0 0 2 1.5];
