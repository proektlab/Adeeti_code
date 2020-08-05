%% building a band pass filter for freq of interest 

% setting up for low pass FIR filtering
nyquist = finalSampR/2;
filtbound = [30 40]; % Hz
trans_width = 0.2; % fraction of 1, thus 20%
filt_order = 50; %filt_order = round(3*(EEG.srate/filtbound(1)));
ffrequencies = [ 0 (1-trans_width)*filtbound(1) filtbound (1+trans_width)*filtbound(2) nyquist ]/nyquist;
idealresponse = [0 0 1 1 0 0];
filterweights= firls(filt_order,ffrequencies,idealresponse);

% plot for visual inspection
figure(1), clf
subplot(211)
plot(ffrequencies*nyquist,idealresponse,'k--o','markerface','m')
set(gca,'ylim',[-.1 1.1],'xlim',[-2 nyquist+2])
xlabel('Frequencies (Hz)'), ylabel('Response amplitude')

subplot(212)
plot((0:filt_order)*(1000/finalSampR),filterweights)
xlabel('Time (ms)'), ylabel('Amplitude')

% apply filter to data
filtered_data = zeros(size(meanSubData));
for ch=1:size(meanSubData, 1)
    for tr = 1:size(meanSubData,2)
    filtered_data(ch,tr,:) = filtfilt(filterweights,1,double(meanSubData(ch,tr,:)));
    end
end

figure(2), clf
plot(finalTime,squeeze(meanSubData(49,3,:)))
hold on
plot(finalTime,squeeze(filtered_data(49,3,:)),'r','linew',2)
xlabel('Time (ms)'), ylabel('Voltage (\muV)')
legend({'raw data';'filtered'})
