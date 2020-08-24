%% playing around with spectal analysis 

clear
win = 10; % size of window (secs) for spectrum
win_step = 1; % size of window step (secs) for spectrum (in this case we are taking 10sec windows, stepping by 1sec)
ktapers = 15;  % number of tapers for mutlitaper analysis
NW = 29;  %

load(['/data/adeeti/ecog/matFlashesJanMar2017/', '2017-03-02_19-39-36.mat'])

data = meanSubData;
concatData = reshape(permute(data, [1 3 2]), 64, (size(data,2)*3001));
data = concatData;

sf = finalSampR;

[out, taper, concentration]=swTFspecAnalog(data(45,:), sf, ktapers, [], win*sf, win_step*sf, NW,[],[],[],[]); %multitaper spectral analysis on the entire length of data - arbitrary middle channel in the grid

spectrum=out.tfse; % size = 1 x windows x freq; tfse = power at each freq and time point
spectrum=squeeze(out.tfse);

freq=out.freq_grid; %extract freq evaluated
T=out.time_grid; %extract time windows evaluated

figure
pcolor(T, freq, 10*log10(spectrum')); shading flat; %picture of total spectrum
set(gca, 'Yscale', 'Log') %making frequency into log scale
colorbar

totalPower = sum(spectrum,2);
totalSpectrum = spectrum./repmat(totalPower,1, length(freq));
meanSpectrum=mean(10*log10(totalSpectrum),1);

figure
plot(freq, meanSpectrum)
set(gca, 'Xscale', 'log')

normSpectrum=10*log10(totalSpectrum)-repmat(meanSpectrum, length(T), 1); % normalizing spectrum - deviations from mean spectrum 
pcolor(T, freq, normSpectrum'); shading flat;
set(gca, 'Yscale', 'Log')
colorbar
set(gca, 'Clim', [-8 8])

addpath('/home/rachel/scripts/pca/');


lowFreq = find(freq>0.1, 1, 'first');
highFreq = find(freq>100, 1, 'first')

[T,pvar,W,L] = pca_alex(normSpectrum(:,lowFreq:highFreq)'); % T 

figure;
plot(cumsum(pvar), 'o') %shows how much of variance is explained by each PC 

figure;
plot(T(1,:), T(2,:), 'ok'); %plots scatter of each spectral power in PC1 and PC2 space 

figure  % plots the PC vectors - can compare these 
plot(T(1,:))
hold on;
plot(T(2,:))

figure
hist(T(2,:), 100) % shows bimodal histogram 

%% to smooth a spectral signal 

size(normSpectrum)
NS=zeros(size(normSpectrum));

for i=1:freq, NS(:,i)=filtfilt(ones(10,1)./10, 1, normSpectrum); end
i
for i=1:229, NS(:,i)=filtfilt(ones(10,1)./10, 1, normSpectrum(:,i)); end
pcolor(1:size(normSpectrum, 1), freq, NS'); shading 'flat'

%% To create a 3D histogram for PCA plots

[n,c]=hist3(T(1:2,:)',[25, 25]);
figure
pcolor(n)
shading flat

% to try smoothing
addpath(genpath('/home/alex/MatlabCode/alex'));
ns=HistSmooth(n,5);
pcolor(n)
shading flat


%% looking for probability density 
[f,xi] = ksdensity(T(1,:));
figure
plot(xi, f)

%% 3D plot of PCs

plot3(T(1,:), T(2,:), T(3,:), 'ok')
axis vis3d;
box on;

%% plot power spectra as deviations from mean for different windows
figure 
plot(freq, normSpectrum(1,:))
set(gca, 'Xscale', 'log')
line([0.1,500], zeros(2,1), 'linewidth', 2, 'color', 'k')
plot(freq, normSpectrum(5928,:), 'r')
