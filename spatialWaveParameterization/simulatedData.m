

x = 0:100;
t = 1:1000;
tempFreq1 = 2*pi*1/10;
phaseOffset1 = pi;
tempFreq2 = 2*pi*1/20;
phaseOffset2 = pi;


kernal1 = sin(tempFreq1*x);
sig1 = sin(tempFreq1*t + phaseOffset1);

kernal2 = sin(tempFreq2*x);
sig2 = sin(tempFreq2*t + phaseOffset1);

figure(1); clf;
h(1)= subplot(2,1,1);
plot(sig1)
hold on 
h(2) = plot(kernal1);
subplot(2,1,2)
plot(sig2)
hold on 
plot(kernal2)
linkaxes(h, 'x')



% hilKern = hilbert(kernal);
% angKern = angle(hilKern);
% 
% hilSig1 = hilbert(sig1);
% ang1 = angle(hilSig1);
% 
%% 

totKern = [kernal1, kernal2];

sizeSnip = length(kernal1);

corCoeVal = nan(1, length(sig1)-sizeSnip-1);


for i = 1:length(sig1)-sizeSnip-1
    %corVal = xcorr(sig1(i:i+sizeSnip),kernal);
    smallSig1 = sig1(i:i+sizeSnip-1);
    smallSig2 = sig2(i:i+sizeSnip-1);
    totSig = [smallSig1,smallSig2];
    temp = corrcoef(totSig,totKern);
    corCoeVal(i) = temp(2,1);
end

figure(2); clf;
h(1) = subplot(3,1,1);
hold on 
plot(sig1)
plot(kernal1)
legend('signal', 'kernal')
h(2) = subplot(3,1,2);
hold on 
plot(sig2)
plot(kernal2)
legend('signal', 'kernal')
h(3) = subplot(3,1,3);
plot(corCoeVal) 
%legend('correlation', 'signal', 'kernal')
linkaxes(h, 'x')
set(gca, 'xlim', [0,100])
legend('correlation')


