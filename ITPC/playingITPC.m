%% Wavelet Decompostion, Inter-trial Phase Coherence 

%% Torrence and Compos Wavelet code

 % WAVE=zeros(100, 2001, size(smallSnippets,1), size(smallSnippets,2));
     WAVE=zeros(40, 2001, size(smallSnippets,1), size(smallSnippets,2));
    for i=1:size(WAVE,3)
        disp(i);
        for j = 1:size(smallSnippets,2)
            sig=detrend(squeeze(smallSnippets(i, j,:)));
           % [temp,PERIOD,SCALE,COI,DJ, PARAMOUT, K] = contwt(sig,1/1000,1, 0.1);
           [temp,PERIOD,SCALE,COI,DJ, PARAMOUT, K] = contwt(sig,1/1000,1, 0.25);
            WAVE(:,:,i, j)=temp; %WAVE is in freq by time by channels by trials
            Freq=1./PERIOD;
        end
    end
    
   % avgWAVE = abs(nanmean(WAVE,4));
    
 %% For intertrial phase coherence 
 
 clear exp 
 
 tf = zeros(size(Freq,2), size(smallSnippets,3));
 ch = 14;

 for fr = 1:length(Freq)
     waveDecop = squeeze(WAVE(fr, :, ch, :));
     tf(fr,:) = abs(mean(exp(1i*angle(waveDecop)),2)); %absolute value of the mean of the euler's formula of the
%     phase angles from the wavlet transform 
 end
 
 
% plot results
figure, clf
h1= subplot(2,1,1)
plot(squeeze(mean(smallSnippets(ch,:,:),2)));
colorbar

h2= subplot(2, 1, 2)
pcolor(1:size(smallSnippets,3), Freq, tf); shading 'flat';
set(gca, 'yscale', 'log')
colorbar
set(gca,'clim',[0 .8])
suptitle(['ITPC for channel ', num2str(ch)])

linkaxes([h1 h2], 'x')
set(gca, 'xlim', [0, 2001])

%% Wavelet decomp of avarage trace

avgWAVE=zeros(40, 2001, size(smallSnippets,1));

avgSmallTrace = squeeze(mean(smallSnippets(:,:,:), 2));

ch = 14;

for i=1:size(avgWAVE,3)
    disp(i);
    sig=detrend(avgSmallTrace(i,:));
    % [temp,PERIOD,SCALE,COI,DJ, PARAMOUT, K] = contwt(sig,1/1000,1, 0.1);
    [temp,PERIOD,SCALE,COI,DJ, PARAMOUT, K] = contwt(sig,1/1000,1, 0.25);
    avgWAVE(:,:,i)=temp; %WAVE is in freq by time by channels by trials
    Freq=1./PERIOD;
end
figure;
pcolor(1:size(smallSnippets,3), Freq, squeeze(abs(avgWAVE(:, :, ch)))); shading 'flat'
set(gca, 'yscale', 'log')
colorbar
title(['Raw power of average trace channel ', num2str(ch)];

%% 
 
allData = dir('2017*.mat')
for experiment = 1:length(allData)
    load(allData(experiment).name)
     % WAVE=zeros(100, 2001, size(smallSnippets,1), size(smallSnippets,2));
     WAVE=zeros(40, 2001, size(smallSnippets,1), size(smallSnippets,2));
    for i=1:size(WAVE,3)
        disp(i);
        for j = 1:size(smallSnippets,2)
            sig=detrend(squeeze(smallSnippets(i, j,:)));
           % [temp,PERIOD,SCALE,COI,DJ, PARAMOUT, K] = contwt(sig,1/1000,1, 0.1);
           [temp,PERIOD,SCALE,COI,DJ, PARAMOUT, K] = contwt(sig,1/1000,1, 0.25);
            WAVE(:,:,i, j)=temp; %WAVE is in freq by time by channels by trials
            Freq=1./PERIOD;
        end
    end
    
    avgWAVE = abs(nanmean(WAVE,4));
    
 %% For intertrial phase coherence 
 
 clear exp 
 
 tf = zeros(size(Freq,2), size(smallSnippets,3));
 ch = 14;

 for fr = 1:length(Freq)
     waveDecop = squeeze(WAVE(fr, :, ch, :));
     tf(fr,:) = abs(mean(exp(1i*angle(waveDecop)),2)); %absolute value of the mean of the euler's formula of the
%     phase angles from the wavlet transform 
 end
 
 
% plot results
figure, clf
h1= subplot(2,1,1)
plot(squeeze(mean(smallSnippets(ch,:,:),2)));
colorbar

h2= subplot(2, 1, 2)
pcolor(1:size(smallSnippets,3), Freq, tf); shading 'flat';
set(gca, 'yscale', 'log')
colorbar
set(gca,'clim',[0 .8])
suptitle(['ITPC for channel ', num2str(ch)])

linkaxes([h1 h2], 'x')
set(gca, 'xlim', [0, 2001])
    
exp1V1;
exp3V1;
exp4V1;
exp7V1;
exp8V1;
exp9V1;
end


%% Plotting polar plane all angle seen 

ch = 15;
fr= find(Freq> 17 & Freq < 18);
time = 1386;

figure
waveDecop = squeeze(WAVE(fr, time, ch, :));
allAngles = angle(waveDecop);
itpc= abs(mean(exp(1i*allAngles)));
prefAngle = angle(mean(exp(1i*allAngles)));

polarplot([zeros(size(allAngles)), allAngles]', [zeros(size(allAngles)), ones(size(allAngles))]', 'k');
hold on
polarplot([0 prefAngle],[0 itpc], 'LineWidth', 2, 'Color', 'm');
title([ 'Observed ITPC: ' num2str(itpc) ' of ', num2str(round(Freq(fr))), 'Hz at ', num2str(time), ' msec in channel ', num2str(ch)])



%% for ITPC


