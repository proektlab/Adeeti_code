% Looking for images for Brenna's paper

ch = 17;

load('/data/adeeti/ecog/matBaselinePropJanMar2017/lulls/2017-03-01_16-11-50.mat')
lull1 = 1;
data1 = meanSubData{lull1}(17,:);
time1 = finalTime{lull1};

%% wavelet transform of data 

[temp,PERIOD,SCALE,COI,DJ, PARAMOUT, K] = contwt(data1,1/1000,1, 0.25);
freq = 1./PERIOD; 

% figure; 
% pcolor(time1, freq, abs(temp)); shading flat;
% set(gca, 'Yscale', 'Log')
% colorbar

alphaBand = find(freq>8 & freq<12);
alphaPower = nanmean(abs(temp(alphaBand,:)),1);

figure;
plot(time1, alphaPower)