%% Adeeti playing around with filtering
%% mikexcohen.com

%% band-pass filtering

load('VEP_ECoGonly2.pl2.mat', 'gridData')
%% Creating an FIR filter - better for ripple effects
% specify Nyquist freuqency
nyquist = finalSampR/2;

% filter frequency band
filtbound = [325 375]; % Hz

% transition width
%trans_width = 0.2; % fraction of 1, thus 20%

% filter order
%filt_order = round(1*(finalSampR/filtbound(1)));
filt_order = 50;

% frequency vector (as fraction of Nyquist
%ffrequencies  = [ 0 (1-trans_width)*filtbound(1) filtbound (1+trans_width)*filtbound(2) nyquist ]/nyquist;
ffrequencies = [0 filtbound(1)/nyquist filtbound(2)/nyquist 1];

% shape of filter (must be the same number of elements as frequency vector
%idealresponse = [ 0 0 1 1 0 0 ];
idealresponse = [1 1 0 0];

% get filter weights
%filterweights = firls(filt_order,ffrequencies,idealresponse);
filterweights= firls(filt_order,ffrequencies,idealresponse,[100 1]);

fir_filtered_data = zeros(size(gridData));
for chani=1:size(gridData,1)
    fir_filtered_data(chani,:) = filtfilt(filterweights,1,double(gridData(chani,:)));
end


% plot for visual inspection
figure(1), clf
subplot(211)
plot(ffrequencies*nyquist,idealresponse,'k--o','markerface','m')
set(gca,'ylim',[-.1 1.1],'xlim',[-2 nyquist+2])
xlabel('Frequencies (Hz)'), ylabel('Response amplitude')

subplot(212)
plot((0:filt_order)*(1000/finalSampR),filterweights)
xlabel('Time (ms)'), ylabel('Amplitude')

figure(2)
hfvt = fvtool(filterweights,'MagnitudeDisplay','Zero-phase');

%% Creating a butterworth filter(IIR)
fcut=325; % in Hz cutoff frequency

[b,a]=butter(8,fcut/(nyquist),'low'); % change low to high for high pass filter
% ^^ transfer function coefficients --> use in filtfilt
butter_filtered_data = zeros(size(gridData));
for chani=1:size(gridData,1)
    butter_filtered_data(chani,:) = filtfilt(b,a,double(gridData(chani,:)));
end
% where x is your data, band a are gotten form the butterworth filter function
% y= zero phase disorteted filtered data

figure(3)
hfvt = fvtool([b,a],'MagnitudeDisplay','Zero-phase');
%% plotting fiters
% apply filter to data

figure(4), clf
channel = 60;
plot(squeeze(gridData(channel,:)))
hold on
plot(squeeze(fir_filtered_data(channel,:)),'r','linew',2)
xlabel('Time (ms)'), ylabel('Voltage (\muV)')
legend({'raw data';'filtered'})
hold on
plot(squeeze(butter_filtered_data(channel,:)),'g')

% %% compute and plot power
% 
% chan4filt = strcmpi('o1',{EEG.chanlocs.labels});
% baseidx   = dsearchn(EEG.times',[-400 -100]');
% 
% pow = zeros(3,EEG.pnts);
% 
% for i=1:3
%     filtered_data = reshape(filtfilt(filterweights(i,:),1,double(reshape(EEG.data(chan4filt,:,:),1,[]))),EEG.pnts,EEG.trials);
%     
%     temppow  = mean(abs(hilbert(filtered_data)).^2,2);
%     pow(i,:) = 10*log10( temppow./mean(temppow(baseidx(1):baseidx(2))) );
% end
% 
% figure(5), clf
% plot(EEG.times,pow)
% xlabel('Time (ms)'), ylabel('power (dB)')
% legend({'filter 10%','filter 15%','filter 20%'})
% set(gca,'xlim',[-300 1200])
