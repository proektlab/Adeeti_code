%% Committee meeting pictures

dirOut1 = '/data/adeeti/Dropbox/KelzLab/misc_figures/';

%% electrical stimulation
dirIn = '/data/adeeti/ecog/mat2018Stim/';
dirOut2 = '/data/adeeti/ecog/images/2018Stim/';
plotTimeFull = [800:1300];
ch = 1;

cd(dirIn)
load('2018-02-08_14-46-54.mat')
data1 = squeeze(meanSubData(ch,:,:));

load('2018-02-08_14-51-13.mat')
data2 = squeeze(meanSubData(ch,:,:));

allData = [data1; data2];

% making picuture
ff=figure('color', 'w');
h=zeros(3,1);

h(1)=subplot(3,1,1);
plot(finalTime([plotTimeFull]), data1(:, plotTimeFull));
hold on
plot(finalTime(plotTimeFull), mean(data1(:, plotTimeFull), 1), 'k', 'Linewidth', 2)
title('Electrical stimulation at electrode 1 at 0.3mA at postive polarity')
xlabel('Time in seconds')
ylabel('Voltage in \muV')
set(gca, 'xlim', [finalTime(plotTime(1)),finalTime(plotTime(end))], 'ylim', [-500, 1000])

h(2)=subplot(3,1,2);
plot(finalTime(plotTimeFull), allData(:, plotTimeFull));
hold on
plot(finalTime(plotTimeFull), mean(allData(:, plotTimeFull), 1), 'k', 'Linewidth', 2)
title('Electrical stimulation at electrode 1 at 0.3mA at both polarities')
set(gca, 'xlim', [finalTime(plotTime(1)),finalTime(plotTime(end))], 'ylim', [-500, 1000])
xlabel('Time in seconds')
ylabel('Voltage in \muV')

h(3)=subplot(3,1,3);
plot(finalTime(plotTimeFull), allData(:, plotTimeFull));
hold on
plot(finalTime(plotTimeFull), mean(allData(:, plotTimeFull), 1), 'k', 'Linewidth', 2)
title('Zoomed in electrical stimulation does not show gamma')
xlabel('Time in seconds')
ylabel('Voltage in \muV')
set(gca, 'xlim', [finalTime(plotTime(1)),finalTime(plotTime(end))], 'ylim', [-200, 300])

%set(h, 'Xcolor', 'none', 'Ycolor', 'none');
% Saving picture

saveas(ff, [dirOut1, 'stimFigCM', '.png'])
saveas(ff, [dirOut2, 'stimFigCM', '.png'])

%% for evoked potentials

dirIn = '/data/adeeti/ecog/matFlashesJanMar2017/';
experiment = '2017-02-23_19-00-25';
cd(dirIn)

load([experiment, '.mat'], 'info', 'aveTrace', 'finalTime', 'meanSubData')

plotTime = [800:2000];

V1 = info.V1;

meanData = squeeze(aveTrace(V1, :));
singData = squeeze(meanSubData(V1,10:14,:));

% plotTime = [800:2000];
% flashOn = [0,0];
% interval = 0.1;
% markTime = finalTime(plotTime(1)):interval:finalTime(plotTime(end));
%
% ff=figure('color', 'w');
%
% plot(finalTime(plotTime), meanData(plotTime), 'b', 'Linewidth', 2)
%
% set(gca, 'xlim', [finalTime(plotTime(1)),finalTime(plotTime(end))], 'ylim', [min(meanData(:)), max(meanData(:))])
%
% yAxis = get(gca, 'YLim');
% for t = 1:length(markTime)
%     line([markTime(t), markTime(t)], yAxis, 'Color', [.9 .9 .9])
%     hold on
% end
% plot(flashOn, yAxis, 'r')

% single trials

ff=figure('color', 'w');
h=zeros(5,1);

for index = 1:4
    h(index) = subplot(5,1,index);
    plot(finalTime(plotTime), squeeze(singData(index, plotTime))')
    hold on
    line([-0.01, 0], [100, 100], 'linewidth', 4, 'color','g');
    set(gca, 'ylim', [min(singData(:)), max(singData(:))])
    if index == 1
        text(-.005, 150, '10ms LED', 'FontName', 'Arial','FontSize', 14, 'Color', 'g', 'HorizontalAlignment', 'center');
    end
    if index == 4
        line([-0.01, 0], [200, 200], 'linewidth', 4, 'color','g');
        line([-0.1, 0], [-100, -100], 'linewidth', 2, 'color','k');
        text(-.05, -130, '100ms', 'FontName', 'Arial','FontSize', 14, 'HorizontalAlignment', 'center');
        line([-.10, -.10], [-100, 0], 'linewidth', 2, 'color','k');
        text(-.15, -50, '100\muV', 'FontName', 'Arial','FontSize', 14, 'HorizontalAlignment', 'center');
    end
    
end

h(5) = subplot(5,1,5);
plot(finalTime(plotTime), meanData(plotTime), 'b', 'Linewidth', 2)
hold on
line([-0.01, 0], [50, 50], 'linewidth', 4, 'color','g');
line([-0.1, 0], [-35, -35], 'linewidth', 2, 'color','k');
text(-.05, -65, '100ms', 'FontName', 'Arial','FontSize', 14, 'HorizontalAlignment', 'center');
line([-.10, -.10], [-35, -10], 'linewidth', 2, 'color','k');
text(-.15, -25, '25\muV', 'FontName', 'Arial','FontSize', 14, 'HorizontalAlignment', 'center');
set(gca, 'ylim', [-50, 100])

set(h, 'Xcolor', 'none', 'Ycolor', 'none');
set(h, 'xlim', [finalTime(plotTime(1)),finalTime(plotTime(end))])

saveas(ff, [dirOut1, 'singleTracesAndAverageEP', '.pdf'])

%% for filtering data
dirInTime = '/data/adeeti/ecog/matFlashesJanMar2017/';
dirInFilt = '/data/adeeti/ecog/matFlashesJanMar2017/Wavelets/FiltData/';

experiment = '2017-03-02_16-23-53';
ch = 0;
fr = 35;
trials = [35:55];
plotTime = [600:1600];

load([dirInTime, experiment, '.mat'], 'finalTime', 'info')
load([dirInFilt, experiment, 'wave.mat'],['filtSig', num2str(fr)])

if ch == 0
    ch = info.V1;
end

eval(['filtSig = filtSig', num2str(fr), ';'])

if plotTime ==0
    plotTime = [1:size(sig,1)];
end


ff=figure('color', 'w');
plot(finalTime(plotTime), squeeze(filtSig(plotTime,ch,trials)))
hold on
xlabel('Time in seconds')
ylabel('Voltage in \muV')
yAxis = get(gca, 'YLim');
line([0,0], yAxis, 'Color', 'g')
set(gca, 'xlim', [finalTime(plotTime(1)),finalTime(plotTime(end))])
title('20 Trials of Filtered data at 35Hz')

saveas(ff, [dirOut1, '20filtTrials', '.png'])

%% comparing total power to coherent power

experiment = '2017-03-02_16-23-53';
fr = 35;
ch = [];
[currentFig] =compCoherenceToTotalPower(experiment, 35, [], [], [600:1600], [])

if isempty(ch)
saveas(currentFig, [dirOut1, 'compTotalGammaCohGamV1', '.png'])
else
    saveas(currentFig, [dirOut1, 'compTotalGammaCohGamV1', '.png'])


