%autocorrlations 

sig = squeeze(meanSubData(info.V1,4,:));

autoCorr = xcorr(sig, sig, 'coeff');

figure
subplot(2,1,1)
plot(sig)
subplot(2,1,2)
plot(autoCorr)
hold on 
plot(xlim, [1 1].*1/exp(1), 'r')