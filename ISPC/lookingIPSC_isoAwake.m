

%% lets look at the coherence of two signals in gamma over time 

awake = '2020-01-24_13-14-00wave.mat';

iso = '2020-01-24_12-21-00wave.mat';

load(iso, 'ISPC21','ISPC25', 'ISPC30', 'ISPC35', 'ISPC42', 'ISPC50', 'Freq', 'info')


%%

ch1 = 1;
ch2 = 40;

counter = 0;
for fr = fliplr([21, 25, 30, 35, 42, 50])
    counter = counter +1;
    sig = eval(['ISPC', num2str(fr), '(ch1, ch2,:)']);
    CohMag(counter,:) = squeeze(abs(sig));
cohAng(counter,:) = squeeze(angle(sig));
end

size(cohMag)
size(cohAng)

%%

figure
subplot(2,1,1)
imagesc(cohMag)
colorbar
title('Mag of coherence')
h = subplot(2,1,2);
imagesc(cohAng)
colormap(h, hsv)
colorbar
title('Phase of coherence')
sgtitle(['Coherence between ', num2str(ch1), ' and ', num2str(ch2)])

%%
dirIn = '/synology/adeeti/ecog/iso_awake_VEPs/GL13/';
dirWAVE = [dirIn, 'Wavelets/'];

experiment = '2020-01-25_11-44-00.mat'; %iso

load([dirWAVE, experiment(1:end-4), 'wave.mat'], 'info', 'WAVE16')

waveDecop = WAVE16;

[ISPC, allAngDiff] = ISPC_AA(waveDecop, info);

rho = squeeze(abs(allAngDiff(info.lowLat, ch2,timeFrame,:)));
theta = squeeze(angle(allAngDiff(info.lowLat, ch2,timeFrame,:)));

figure
polar(theta(120,:), rho(120,:))





