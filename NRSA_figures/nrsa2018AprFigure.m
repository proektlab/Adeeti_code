%% for filtering data
dirInTime = '/data/adeeti/ecog/matFlashesJanMar2017/';
dirInFilt = '/data/adeeti/ecog/matFlashesJanMar2017/Wavelets/FiltData/';

experiment = '2017-03-02_16-23-53';
ch1 = 0;
ch2 = 31;
fr = 35;
plotTime = [600:1600];

load([dirInTime, experiment, '.mat'], 'finalTime', 'info')
load([dirInFilt, experiment, 'wave.mat'],['filtSig', num2str(fr)])

if ch1 == 0
    ch1 = info.V1;
end

eval(['filtSig = filtSig', num2str(fr), ';'])

if plotTime ==0
    plotTime = [1:size(sig,1)];
end

filtSig1 = squeeze(filtSig(plotTime,ch1,:));
filtSig2 = squeeze(filtSig(plotTime,ch2,:));

%%
ff=figure('color', 'w');

ff.Renderer='Painters';

subplot(2,1,1)
plot(finalTime(plotTime), filtSig1)
hold on
plot(finalTime(plotTime), squeeze(mean(filtSig1,2)), 'k', 'lineWidth', 3)
xlabel('Time in seconds')
ylabel('Voltage in \muV')
yAxis = get(gca, 'YLim');
line([0,0], yAxis, 'Color', 'g', 'lineWidth', 2)
set(gca, 'xlim', [finalTime(plotTime(1)),finalTime(plotTime(end))])
set(gca, 'ylim', [-15,15])
title('Filtered data at 35Hz at V1')

subplot(2,1,2)
plot(finalTime(plotTime), filtSig2)
hold on
plot(finalTime(plotTime), squeeze(mean(filtSig2,2)), 'k', 'lineWidth', 3)
xlabel('Time in seconds')
ylabel('Voltage in \muV')
yAxis = get(gca, 'YLim');
line([0,0], yAxis, 'Color', 'g', 'lineWidth', 2)
set(gca, 'xlim', [finalTime(plotTime(1)),finalTime(plotTime(end))])
set(gca, 'ylim', [-15,15])
title('Filtered data at 35Hz at Posterior Parietal Cortex, 2 mm Rostral of V1')

% saveas(ff, [dirOut1, '20filtTrials', '.pdf'])



