%% Looking at two channels with reversals in phase lags

timeFrame = [950:1350];

dirIn = '/data/adeeti/ecog/matIsoPropMultiStim/';
cd(dirIn)
load('dataMatrixFlashes.mat');
dirFilt = '/data/adeeti/ecog/matIsoPropMultiStim/Wavelets/FiltData/';

%% experiment 1 iso 1.2 first - all in V1
epIndex = findMyExpMulti(dataMatrixFlashes, 1, 'isoflurane', 1.2, [0 Inf]);

epIndex = min(epIndex)

load(dataMatrixFlashes(epIndex).expName);
experiment = info.expName(1:end-4);
load([dirFilt, experiment, 'wave.mat'], 'filtSig35', 'info', 'indexSeries', 'uniqueSeries')

filtData = filtSig35;
avgFiltData = mean(filtData,3);
avgFiltDataTruc = avgFiltData(timeFrame,:)';
timeAxis = [-(1000-timeFrame(1)):1:(timeFrame(end)-1000)];


anSig = hilbert(avgFiltDataTruc');
phases = angle(anSig);
phases = phases';

amp = abs(anSig);
amp = amp';


figure
plot(squeeze(phases(46,:)))
hold on 
plot(squeeze(phases(48,:)))

unwrappedAngles1 = unwrap(squeeze(phases(46,:)));
unwrappedAngles2 = unwrap(squeeze(phases(48,:)));

OFFSET = -0.2;
unwrappedDiff = unwrappedAngles1 - unwrappedAngles2 + pi - OFFSET;
angleDiffs = mod(unwrappedDiff, 2*pi) - pi + OFFSET;

figure
clf;
plot(angleDiffs);




%% figure with phase angles

ch1 = 46;
ch2 = 48;


figure
clf
subplot(2,1,1)
plot(timeAxis, squeeze(avgFiltDataTruc(ch1,:)),'linewidth', 2)
hold on
plot(timeAxis, squeeze(avgFiltDataTruc(ch2,:)), 'linewidth', 2)
line([-40 10],[-3.5, -3.5], 'linewidth', 2, 'Color', 'k')
text(-45, -3.7, '50 ms')
line([-40 -40],[-3.5, -2.5], 'linewidth', 2, 'Color', 'k')
text(-30, -3.0, '1 uV')
line([0 0],[-3.5, 3.5], 'linewidth', 2, 'Color', 'g')
xlabel('Time in ms')
ylabel('Voltage in \muV')
title(['Two electrodes 1 mm apart, Exp ', num2str(info.exp), ' Iso ', num2str(info.AnesLevel)])

subplot(2,1,2)
plot(timeAxis, abs(angle(anSig(:,ch2)./anSig(:,ch1))))
yticks([0, 0.25*pi, 0.5*pi, 0.75*pi, pi])
yticklabels({'0','0.25\pi','0.5\pi', '0.75\pi','\pi'})
line([0 0],[0, 3.5], 'linewidth', 2, 'Color', 'g')
xlabel('Time in ms')
ylabel('Phase angle difference')
title('Phase Angle difference between two electrodes')

figure
rose(abs(angle(anSig(:,ch2)./anSig(:,ch1))), 25)


%% making movie from the phase angle example with cirlces around electrodes 

start = 950;
endTime = 1350;

darknessOutline = 80;
dropboxLocation = '/home/adeeti/Dropbox/KelzLab/';
bregmaOffsetX = info.bregmaOffsetX;
bregmaOffsetY = info.bregmaOffsetY;
gridIndicies = info.gridIndicies;
plotIndex = 1;

sig = avgFiltData;
m = mean(sig(1:1000,:),1);
s = std(sig(1:1000,:),1);
ztransform=(m-sig)./s;

filtSig = permute(ztransform, [3, 1, 2]);

%create labels
plotTitles{1} = []; %[info.AnesType, ', dose: ', num2str(info.AnesLevel)];
superTitle = [info.AnesType, ', dose: ', num2str(info.AnesLevel), '%'];
colorTitle = ['z threshold voltages from baseline'];

[movieOutput] = makeMoviesWithOutlinesFunc(filtSig, start, endTime, bregmaOffsetX, bregmaOffsetY, gridIndicies, plotTitles, superTitle, colorTitle, [], darknessOutline, dropboxLocation, ch1, ch2);

v = VideoWriter([dropboxLocation, 'singleExperimentExample.avi']);
open(v)
writeVideo(v,movieOutput)
close(v)
close all
               
































%% experiment 1 iso 1.2 second -- extends outside of V1
epIndex = findMyExpMulti(dataMatrixFlashes, 1, 'isoflurane', 1.2, [0 Inf]);

epIndex = max(epIndex)

load(dataMatrixFlashes(epIndex).expName);

experiment = info.expName(1:end-4);

load([dirFilt, experiment, 'wave.mat'], 'filtSig35', 'info', 'indexSeries', 'uniqueSeries')

filtData = filtSig35;

avgFiltDataTruc = mean(filtData,3);

avgFiltDataTruc = avgFiltDataTruc(timeFrame,:)';

figure
clf
plot(squeeze(avgFiltDataTruc(46,:)),'linewidth', 2)
hold on
plot(squeeze(avgFiltDataTruc(48,:)), 'linewidth', 2)
line([10 60],[-3.5, -3.5], 'linewidth', 2, 'Color', 'k')
text(20, -3.7, '50 ms')
line([10 10],[-3.5, -2.5], 'linewidth', 2, 'Color', 'k')
text(0, -3.0, '1 uV')
line([50 50],[-3.5, 3.5], 'linewidth', 2, 'Color', 'g')
title(['Two electrodes 1 mm apart, Exp ', num2str(info.exp), ' Iso ', num2str(info.AnesLevel)])
axis off

%% experiment 4 iso 0.6

epIndex = findMyExpMulti(dataMatrixFlashes, 4, 'isoflurane', 0.6, [0 Inf]);

load(dataMatrixFlashes(epIndex).expName);

experiment = info.expName(1:end-4);

load([dirFilt, experiment, 'wave.mat'], 'filtSig35', 'info', 'indexSeries', 'uniqueSeries')

filtData = filtSig35;

avgFiltDataTruc = mean(filtData,3);

avgFiltDataTruc = avgFiltDataTruc(timeFrame,:)';


figure
clf
plot(squeeze(avgFiltDataTruc(44,:)),'linewidth', 2)
hold on
plot(squeeze(avgFiltDataTruc(22,:)), 'linewidth', 2)
line([10 60],[-3.5, -3.5], 'linewidth', 2, 'Color', 'k')
text(20, -3.7, '50 ms')
line([10 10],[-3.5, -2.5], 'linewidth', 2, 'Color', 'k')
text(0, -3.0, '1 uV')
line([50 50],[-3.5, 3.5], 'linewidth', 2, 'Color', 'g')
title(['Two electrodes 1 mm apart, Exp ', num2str(info.exp), ' Iso ', num2str(info.AnesLevel)])
axis off

