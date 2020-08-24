%% Finding Burst Suppression

clear;

cd('/data/adeeti/ecog/matFlashesJanMar2017')

allData =dir('2017*.mat');

win = 15; % size of window (secs) for spectrum
win_step = 1; % size of window step (secs) for spectrum (in this case we are taking 10sec windows, stepping by 1sec)
ktapers = 10;  % number of tapers for mutlitaper analysis
NW = 19;  %

load('dataMatrixFlashes.mat')
load(allData(1).name, 'finalSampR')
sf = finalSampR;

all1Spectrum = [];
all3Spectrum = [];
all4Spectrum = [];
all7Spectrum = [];
all8Spectrum = [];
all9Spectrum = [];



%% Compute spectrum for each experiment and concatonate together 

for exp = 1%:length(allData)
    experiment = allData(exp).name;
	% load data
	load(experiment); % my data is currently in .mat files
    
    data = meanSubData;
    concatData = reshape(permute(data, [1 3 2]), 64, (size(data,2)*3001));
    data = concatData;
    
    sf = finalSampR;
	
	% load rejection times
	
% 	% high pass filter the data -- Neuralynx data is already high pass
% 	filtered at 0.1Hz
% 	high_cutoff = 0.1;
% 	[b,a] = butter(4,high_cutoff/sf,'high');
% 	for i = 1:size(data,1)
% 		data(i,:) = filtfilt(b,a,double(data(i,:)));
% 	end
	
	%addpath('/home/alex/MatlabCode/Spectra');
    
    %perform spectral analysis on one of the frontal channels 
    
    noiseChannels = info.noiseChannels;
    
    if size(data,2) < win*sf
        continue
    end
    
    if isempty(find(noiseChannels ==5))
        [out, taper, concentration]=swTFspecAnalog(data(5,:), sf, ktapers, [], win*sf, win_step*sf, NW,[],[],[],[]); %multitaper spectral analysis on the entire length of data 
        disp('Spectral analysis of channel 5')
    elseif isempty(find(noiseChannels == 17))
        [out, taper, concentration]=swTFspecAnalog(data(17,:), sf, ktapers, [], win*sf, win_step*sf, NW,[],[],[],[]); %multitaper spectral analysis on the entire length of data 
        disp('Spectral analysis of channel 17')
    elseif isempty(find(noiseChannels == 33))
        [out, taper, concentration]=swTFspecAnalog(data(33,:), sf, ktapers, [], win*sf, win_step*sf, NW,[],[],[],[]); %multitaper spectral analysis on the entire length of data 
        disp('Spectral analysis of channel 33')
    elseif isempty(find(noiseChannels == 53))
        [out, taper, concentration]=swTFspecAnalog(data(53,:), sf, ktapers, [], win*sf, win_step*sf, NW,[],[],[],[]); %multitaper spectral analysis on the entire length of data 
        disp('Spectral analysis of channel 53')
    else
        randCh = datasample(1:size(data,1), 1);
        if exist(find(noiseChannels == randCh))
            continue
        end
        [out, taper, concentration]=swTFspecAnalog(data(randCh,:), sf, ktapers, [], win*sf, win_step*sf, NW,[],[],[],[]); %multitaper spectral analysis on the entire length of data - arbitrary middle channel in the grid
        disp(['Spectral analysis of channel ', num2str(randCh)])
    end
    
    freq=out.freq_grid; %extract freq evaluated
    T=out.time_grid; %extract time windows evaluated
    spectrum=squeeze(out.tfse); % size = 1 x windows x freq; tfse = power at each freq and time point
    
    if info.exp ==1
        all1Spectrum = [all1Spectrum, spectrum']; %note that these are 
    elseif info.exp ==3
        all3Spectrum = [all3Spectrum, spectrum'];
    elseif info.exp ==4
        all4Spectrum = [all4Spectrum, spectrum'];
    elseif info.exp ==7
        all7Spectrum = [all7Spectrum, spectrum'];
    elseif info.exp ==8
        all8Spectrum = [all8Spectrum, spectrum'];
    elseif info.exp ==9
        all9Spectrum = [all9Spectrum, spectrum'];
    else
        disp(['Unable to process experiment ', num2str(exp)]);
    end
    close all 
end

%% 

save('allSpectrum.mat', 'all1Spectrum', 'all3Spectrum', 'all4Spectrum', 'all7Spectrum', 'all8Spectrum','all9Spectrum');

%% Normalize the spectra

load('freq.mat')
load('allSpectrum.mat')
 
spectrum = all7Spectrum';

    totalPower = sum(spectrum,2);  %add up the power at each freq for every time window ==> time windows x 1
    totalSpectrum = spectrum./repmat(totalPower,1, length(freq));   % normalizing power at each freq by the total power: replicate the total power at all freq and then divide each power at each time window by the total  
    meanSpectrum=mean(10*log10(spectrum),1); %take the mean power for each freq ==> 1 x freq 
    normSpectrum=10*log10(spectrum)-repmat(meanSpectrum, size(spectrum, 1), 1); % deviations from mean spectrum (already normalized to the total power)
    
    addpath('/home/rachel/scripts/pca/');
    
    %lowFreq = find(freq>0.1, 1, 'first');
    lowFreq = 1;
    highFreq = find(freq>150, 1, 'first');
    freqScale = lowFreq:highFreq;

% [T, scores, ~, ~, pvar] = pca(normSpectrum(:,lowFreq:highFreq), 'NumComponents', 2);
%     
     [T,pvar,W,L] = pca_alex(normSpectrum(:, freqScale)'); 
    
figure;
plot(cumsum(pvar), 'o') %shows how much of variance is explained by each PC

figure;
plot(T(1,:), T(2,:), 'ok'); %plots scatter of each spectral power in PC1 and PC2 space

figure  % plots the PC vectors - can compare these
plot(T(1,:))
hold on;
plot(T(2,:))

figure
hist(T(:,2), 100) % shows bimodal histogram

figure
pcolor(1:size(normSpectrum, 1), freq(freqScale), normSpectrum(:,freqScale)'); shading 'flat'
set(gca, 'Yscale', 'log')
colorbar
set(gca, 'Clim', [-5 5])

figure; plot3(T(1,:), T(2,:), T(3,:), 'ok')
box on
axis vis3d

scatter3(T(1,:), T(2,:), T(3,:), 10, 1:size(T,2), 'filled')
box on;
axis vis3d

    
    