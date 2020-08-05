
channelID = 16;

phases = unwrap(angle(squeeze(H(:,channelID,:))));

meanPhases = diff(mean(phases,2))';
filteredPhase = filterData(meanPhases,10);
plot(filteredPhase);

plot(mod(mean(phases(900:1300,:),2),2*pi))
plot(detrend(mean(phases,2)))
plot(diff(mean(phases,2)))

%% making phase moving

useData = [900:1300];
amp=abs(H(useData,:,:));
phase=unwrap(angle(H(useData,:,:)));
phase = permute(phase, [2, 3, 1]); 

[currentFig] = plotAverages(diff(squeeze(mean(phase,2)),1, 2), [-0.1:.001:0.3-.001], [], [], [], .1, .4, [0,0])


%% Looking at ind freq bands

channelID = 25;
F = 1; % 15, 16, 17 --> 42.7805   35.9740   30.2504
FreqID = Freq(15:17);

phases = unwrap(angle(squeeze(HInd(F,:,channelID,:))));

meanPhases = diff(mean(phases,2))';
filteredPhase = filterData(meanPhases,10);

figure
h1= subplot(3,1,1)
plot(meanPhases)
title(['Mean angle of channel ', num2str(channelID), ' Freq ', num2str(FreqID(F))])
h2= subplot(3, 1,2)
plot(filteredPhase);
title(['Gaussian filtered dirivative of mean phase data of channel ', num2str(channelID), ' Freq ', num2str(FreqID(F))])
h3 = subplot(3,1,3)
plot(mod(mean(phases(1:2000,:),2),2*pi))
title(['Mean angle of channel ', num2str(channelID), ' Freq ', num2str(FreqID(F))])
linkaxes([h1 h2 h3], 'x')
linkaxes([h1 h2], 'y')

%% Working with Alex 12/13/17

ch = 16; 
fr = 2;
timePoints = [960:20:1100]; 

load('2017-03-02_19-39-36wave.mat', 'filtSingalInd', 'HInd')
F=squeeze(filtSingalInd(fr,:,ch,:))
H=squeeze(HInd(fr,:,ch,:));
phases=angle(H);

figure;
plot(F) %plots filtered data at freq 35 Hz at a particular channel - can see coherent stretch of signal after the flash that lasts ~100msec
hold on
plot(mean(F,2), 'lineWidth', 3,'k')


bins=-pi:pi/10:pi
[n, ~]=histcounts(phases(timePoints(1),:), bins); %histogram of the phases at the first point in time 

phaseHist=zeros(size(phases,1), length(bins));

for i=1:size(phaseHist,1)
    [n, ~]=histcounts(phases(i,:), bins)
    phaseHist(i,:)=n
end


figure
imagesc(0:2000, bins(1:end-1)+diff(bins)./2, phaseHist')

figure
for t =1:length(timePoints)
    plot(phaseHist(timePoints(t),:))
    hold on;
end
hold off
legend

figure;
surf(phaseHist(900:1200,:));

%% Trying to show phase resetting 

unwrapPhase=unwrap(phases, [], 1);
velocity=diff(unwrapPhase, 1, 1);
detrendedVel=detrend(unwrapPhase);

figure
subplot(3,1,1)
plot(unwrapPhase)
subplot(3,1,2)
plot(velocity)
subplot(3,1,3)
plot(detrendedVel)

phaseAdvance=sum(detrendedVel(970:1030,:), 1);
startPhase=phases(970,:);

figure;
plot(phaseAdvance)

plot(startPhase, phaseAdvance, 'o');
plot(startPhase, phases(1030,:), 'o');
plot([startPhase; phases(1030,:)]);
plot([startPhase;phaseAdvance./30]);

figure
plot([startPhase;phaseAdvance./30]);
plot(startPhase, phaseAdvance./30, 'o');

figure
plot(phases(970,:), (phases(1030,:)-phases(970,:))/60, 'o');

hold on
figure
plot(mean(F,2))
