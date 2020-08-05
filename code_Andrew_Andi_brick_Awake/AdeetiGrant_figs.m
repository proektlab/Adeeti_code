%% Make a figure for Adeeti's grant resubmission with Andi's data
% She needs a section of clean EEG from wake and anesthetized
% Spectrograms to match.

% Looking at M13 EMERGENCE which has fs = 250 hz
%   30 minutes baseline
%   60 minutes at 0.6% iso
%   30 minutes at 1.2% iso
%   6 hours at 0.6% iso

dirIn = '/data/adeeti/ecog/Andrew_Andi_Brick_Awake/';
load('cleanData_forAdeeti.mat')


%% filter data becuase its super noisy with butterworth filter

fs = 250; % in Hz for channel decimation
fcut=50; % in Hz cutoff frequency
 
[b,a]=butter(8,fcut/(fs/2),'low'); % change high to low for low pass filter
 
% ^^ transfer function coefficients --> use in filtfilt
 
y=filtfilt(b,a,cleanData);  % where x is your data, band a are gotten form the butterworth filter function
 
% y= zero phase disorteted filtered data


%% filter data becuase its super noisy with fir filter

filtbound = [1, 50];
trans_width = 0.3; % fraction of 1, thus 20%
filt_order = 25; %filt_order = round(3*(EEG.srate/filtbound(1)));

[filterweights] = buildBandPassFiltFunc_AA(fs, filtbound, trans_width, filt_order);

% apply filter to data
filtered_data = zeros(size(cleanData));

filtered_data = filtfilt(filterweights,1,double(cleanData));


figure
plot(cleanData)
hold on 
%plot(y)
plot(filtered_data)

%%

% Wake EEG
%timeWake = [160, 180];
timeWake = [163, 173];
wake(1,:) = cleanData(timeWake(1)*fs:timeWake(2)*fs); % 20 seconds of data
wake(2,:) = filtered_data(timeWake(1)*fs:timeWake(2)*fs); % 20 seconds of data
%wake(2,:) = y(160*fs:180*fs); % 20 seconds of data

% Anes EEG (1.2% iso)
%timeAnes = [7440, 7460];
timeAnes = [7453, 7463];
anes(1,:) = cleanData(timeAnes(1)*fs:timeAnes(2)*fs);
anes(2,:) = filtered_data(timeAnes(1)*fs:timeAnes(2)*fs);
%anes(2,:) = y(7440*fs:7460*fs);

figure
h(1) = subplot(2,2,1)
plot(squeeze(wake(1,:)))
title('Awake, no filtering')
h(2) = subplot(2,2,2)
plot(squeeze(wake(2,:)))
title('Awake, with filtering')
h(3) = subplot(2,2,3)
plot(squeeze(anes(1,:)))
title('Anes, no filtering')
h(4) = subplot(2,2,4)
plot(squeeze(anes(2,:)))
title('Anes, with filtering')

set(h, 'ylim', [-500, 500]);

%%
N = length(cleanData);
xdft = fft(cleanData);
xdft = xdft(1:N/2+1);

psdx = (1/(fs*N)) * abs(xdft).^2;
psdx(2:end-1) = 2*psdx(2:end-1);
freq = 0:fs/length(cleanData):fs/2;

plot(freq,10*log10(psdx))
grid on
title('Periodogram Using FFT')
xlabel('Frequency (Hz)')
ylabel('Power/Frequency (dB/Hz)')


eegplot(filtered_data, 'srate', fs)





