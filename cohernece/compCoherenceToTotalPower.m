function [currentFig] =compCoherenceToTotalPower(experiment, fr, infopath, filtpath, range, ch)
%  [currentFig] =compCoherenceToTotalPower(experiment, fr, infopath, filtpath)
% experiment = experiment name (not abs path)
% fr = frequency in Hz (defualt is 35 Hz)
% infopath = path for info file before experiment name (defualt is in
% JanMar Wavelets)
% filtpath = path for hilbert filtered data (defualt is in
% JanMar Wavelets Hilbert)

%% Phase Coherence vs Power analysis 

%% Just the things you gotta do

if ~exist('ch')|| isempty(ch)
    ch = 0;
end

if ~exist('range')|| isempty(range)
    range = 0;
end

if ~exist('infopath') || isempty(infopath)
    infopath = '/data/adeeti/ecog/matFlashesJanMar2017/';
end

if ~exist('filtpath') || isempty(filtpath)
    filtpath = '/data/adeeti/ecog/matFlashesJanMar2017/Wavelets/FiltData/';
end

if ~exist('fr') || isempty(fr)
    fr = 35;
end


%% Loading info to get V1, finalTime, and hilbert transform 

load([infopath, experiment, '.mat'], 'info', 'finalTime')

if ch ==0
    ch = info.V1;
end

load([filtpath, experiment, 'wave.mat'],['H', num2str(fr)], 'Freq')

%% Finding closest frequency to specified frequency

[~,closestIndex] = min(abs(Freq-fr));

fr = floor(Freq(closestIndex));
%%
eval(['sig = H', num2str(fr), ';'])

if range ==0
    range = [1:size(sig,1)];
end

%%

[filtSig] = hilbert2filtsig(sig);

sigM = squeeze(mean(filtSig(:,:,:),3));

H = hilbert(sigM);
chEnvH = abs(H);
phaseH = angle(H);

chEnvH = chEnvH(:,ch);
        

%% to get the average of the hilbert envelopes at a part freq

envAllH = abs(sig);
phaseAllH = angle(sig);

meanEnvAllH = squeeze(mean(envAllH, 3));

chMeanEnvAllH = meanEnvAllH(:,ch);

%% figure comparing coherent sig at 35 vs total power at 35

screensize=get(groot, 'Screensize');
currentFig = figure(1);
set(currentFig, 'Position', screensize)

clf

subplot(2, 2, 1)
plot(squeeze(chEnvH), 'Linewidth', 2)
hold on 
plot(squeeze(chMeanEnvAllH), 'Linewidth', 2)
yAxis = get(gca, 'YLim');
line([1000, 1000], yAxis, 'Color', 'g', 'Linewidth', 2)
xlim([range(1) range(end)]);

legend('Coherent signal', 'Average total power')
title(['Coherent power vs total power at ', num2str(fr), 'Hz'])


%% comparing the ratio of coherent power to total power 

subplot(2, 2, 2)
plot(chEnvH./chMeanEnvAllH, 'Linewidth', 2)
xlim([range(1) range(end)]);
ylim([0 1]);
yAxis = get(gca, 'YLim');
line([1000, 1000], yAxis, 'Color', 'g', 'Linewidth', 2)
title(['Ratio of coherent power to total power at ', num2str(fr), 'Hz'])

subplot(2, 2, [3 4])
plot(squeeze(filtSig(:,ch,:)))
hold on 
plot(squeeze(sigM(:,ch)), 'k', 'Linewidth', 3)
yAxis = get(gca, 'YLim');
line([1000, 1000], yAxis, 'Color', 'g', 'Linewidth', 2)
xlim([range(1) range(end)]);
title(['Signal filtered at ', num2str(fr), 'Hz'])

suptitle(['Mouse ID: ', num2str(info.exp), ', Iso: ', num2str(info.AnesLevel), ', Int: ', num2str(info.IntensityPulse), ', Dur: ', num2str(info.LengthPulse), ', Freq: ', num2str(fr)])

end
