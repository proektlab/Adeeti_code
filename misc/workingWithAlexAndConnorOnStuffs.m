%% figure making

ff=figure('color', 'w');

s=zeros(2,10);
s(1)=subplot(2,1,1);
pcolor(1:3001, f, squeeze(meanMag)); shading flat;
colorbar;
s(2)=subplot(2,1,2);
pcolor(1:3001, f, phase); shading flat;
colorbar;

set(s(1), 'Yscale', 'log','Ylim', [1 100]);
set(s(2), 'Yscale', 'log','Ylim', [1 100]);
set(s(2), 'Clim',  [- pi/4 pi/4]);
set(s(1), 'Clim',  [0 1]);
linkaxes(s);
%%

sig1=squeeze(meanSubData(25,1,:));
sig2=squeeze(meanSubData(15,10,:));
[WAVE1,PERIOD,SCALE,COI,DJ, PARAMOUT, K] = contwt(sig1,0.001,1,.25);
[WAVE2,PERIOD,SCALE,COI,DJ, PARAMOUT, K] = contwt(sig2,0.001,1,.25);

temp=zeros(size(WAVE1));
temp(16:18,:)=WAVE1(16:18,:);
F1 = invcwt(temp, 'MORLET', SCALE, PARAMOUT,K);
temp=zeros(size(WAVE1));
temp(16:18,:)=WAVE2(16:18,:);
F2 = invcwt(temp, 'MORLET', SCALE, PARAMOUT,K);

%%

A1=hilbert(F1);
A2=hilbert(F2);

%A1=A1./abs(A1);
%A2=A2./abs(A2);
%Adiff=(A1-A2)./abs(A1-A2);

Ang=angle(A1)-angle(A2);
unitCircle = exp(1i*Ang);

%%

Filt=gausswin(100);
Filt=Filt./sum(Filt);

%%

figure;
s(1)=subplot(2,1,1);
plot(F1);
hold on;
plot(F2);




