
dirIn = '/synology/adeeti/ecog/iso_awake_VEPs/GL13/';

%experiment = '2020-01-25_12-47-00.mat'; ket
%experiment = '2020-01-25_12-25-00.mat'; awake
experiment = '2020-01-25_11-44-00.mat'; %iso

load([dirIn, experiment], 'info', 'meanSubData')

timeFrame = 250:2000;

tr = 10;
ch2 = 10;
finalSampR = 1000;
allCohMag = [];
allCohAng = [];
tic;
for tr = 1:size(meanSubData,2)
sig1 = squeeze(meanSubData(info.lowLat, tr,timeFrame));
sig2 = squeeze(meanSubData(ch2, tr, timeFrame));

 [cohMag, cohComplex, freq] = wcoherence(sig1,sig2, finalSampR, 'NumOctaves', 8, 'VoicesPerOctave', 10);
 size(cohMag)
 freq
% [cohMag, cohComplex, freq] = wcoherence(sig1,sig2, finalSampR);
 allCohMag(tr,:,:) = cohMag;
 allCohAng(tr,:,:) = cohComplex;

end
toc;

gammaWCoh = find(freq>20 & freq<55);

%%
figure(2)
subplot(1,2,1)
 pcolor(timeFrame, freq(gammaWCoh), squeeze(nanmean(allCohMag(:,gammaWCoh,:),1))); shading 'flat';
 set(gca, 'clim', [0 0.8]);
 title(['Wavelet Coh', info.AnesType])
 colorbar
 %set(gca, 'yscale', 'log')
 
 %%
 
dirIPSC = [dirIn, 'IPSC/'];

gammaBand = [21, 25, 30, 35, 42, 50];

load([dirIPSC, experiment(1:end-4), 'wave.mat'], 'ISPC21','ISPC25', 'ISPC30', 'ISPC35', 'ISPC42', 'ISPC50', 'Freq', 'info')

allIPSC = [];
counter = 0;
for fr = gammaBand
    counter = counter +1;
    sig = eval(['ISPC', num2str(fr)]);
    allIPSC(counter,:,:,:) = squeeze(abs(sig(info.lowLat, ch2, timeFrame)));
end

%%
figure(2)
subplot(1,2,2)
 pcolor(timeFrame, gammaBand, allIPSC); shading 'flat';
  set(gca, 'clim', [0 0.8]);
  title(['ISPC', info.AnesType])
  colorbar
 %set(gca, 'yscale', 'log')