%% Make a figure for Adeeti's grant resubmission with Andi's data
% She needs a section of clean EEG from wake and anesthetized
% Spectrograms to match.

% Looking at M13 EMERGENCE which has fs = 250 hz
%   30 minutes baseline
%   60 minutes at 0.6% iso
%   30 minutes at 1.2% iso
%   6 hours at 0.6% iso

dirIn = '/Users/adeetiaggarwal/Google Drive/NEURA_codeShare/';
load('ketamine_only_single_channel.mat')
load('baseline.mat')
load('sampdat.mat')

fs = 250; % in Hz for channel decimation - for Andrew's data 

%% turn ketamine data into same formate as other data

ketSR = 1000;
timeForIP = 15; % time in min 
timeToExclude = timeForIP*60*ketSR;

ketDataRaw = x(timeToExclude: end);
ketDataFilt = y(timeToExclude: end);

ketDataRaw = decimate(ketDataRaw, ketSR/fs);
ketDataFilt = decimate(ketDataFilt, ketSR/fs);

ketDataRaw = ketDataRaw';
ketDataFilt = ketDataFilt';

filtIso = filtdata;
filtBaseline = filtdat2;

%% filter data becuase its super noisy with butterworth filter

% % fs = 250; % in Hz for channel decimation
% % fcutHigh=50; % in Hz cutoff frequency
% % fcutLow =1;
% % filtOrder = 5;
% %  
% % [b,a]=butter(filtOrder,fcutHigh/(fs/2),'low'); % change high to low for low pass filter
% % [b,a] = butter(filtOrder,[fcutLow fcutHigh]/fs);
% %  
% % ^^ transfer function coefficients --> use in filtfilt
% % 
% % y=filtfilt(b,a,data);  % where x is your data, band a are gotten form the butterworth filter function
% %  
% % y= zero phase disorteted filtered data


% % % filter data becuase its super noisy with fir filter
% % 
% % filtbound = [1, 50];
% % trans_width = 0.3; % fraction of 1, thus 20%
% % filt_order = 25; %filt_order = round(3*(EEG.srate/filtbound(1)));
% % 
% % [filterweights] = buildBandPassFiltFunc_AA(fs, filtbound, trans_width, filt_order);
% % 
% % apply filter to data
% % filtered_data = zeros(size(cleanData));
% % 
% % filtered_data = filtfilt(filterweights,1,double(cleanData));
% % 
% % 
% % figure
% % plot(cleanData)
% % hold on 
% % plot(y)
% % plot(filtered_data)

%% Looking at the data 

%Data can be ketDataRaw ketDataFilt filtIso filtBaseline 

showData = filtBaseline;

eegplot(showData, 'srate', fs);


%%

totalTimeSement = 5; %in seconds 

timeAxis = linspace(0,totalTimeSement,totalTimeSement*fs+1);

% Ketamine EEG 
timeKet = [10, 15];
ket = ketDataFilt(timeKet(1)*fs:timeKet(2)*fs); %10 sec of ketamine data 

% Wake EEG
timeWake = [504, 509];
chWake = 17;
wake = filtBaseline(chWake, timeWake(1)*fs:timeWake(2)*fs); % 10 seconds of basline wake data

% Drowsy EEG
timeDrowsy = [3354, 3359];
chDrowsy = 1;
drowsy = filtIso(chDrowsy, timeDrowsy(1)*fs:timeDrowsy(2)*fs); % 10 seconds of basline wake data

% Anes EEG (0.6% iso)
timeIso = [3990, 3995];
chIso = 1;
iso = filtIso(chIso, timeIso(1)*fs:timeIso(2)*fs);

clear data
data(1,:) = wake;
data(2,:) = drowsy;
data(3,:) = iso;
data(4,:) = ket*0.25;

LFPshift = -200;

figure
for i = 1:size(data, 1)
    if i == 1
        plot(timeAxis, data(i,:))
    elseif i == 2||i == 3
        plot(timeAxis, data(i,:)+LFPshift*(i-1))
    elseif i == 4
        plot(timeAxis, data(i,:)+LFPshift*(i-1))
        line([0.5 0.5], [-650 -550], 'LineWidth', 2, 'Color', 'k'); % vertical line
        line([0.5 1], [-650 -650], 'LineWidth', 2, 'Color', 'k'); % horizontal line
                    
        tt=text(0.5, -600, '0.1 mV', 'FontName', 'Arial', 'FontSize', 12); % vertical line
        tt2=text(.75, -700, '0.5 s', 'FontName', 'Arial', 'FontSize', 12); % horizontal line
    end
    hold on
end

%set(h, 'ylim', [-200, 200]);
axis off
fig=gcf;
set(gcf,'color','w')
fig.PaperUnits='Inches';
fig.PaperPosition=[0 0 4 1.5];
%print('traces','-dpdf')





%%

figure(2)

for i = 1:size(data,1)
    cleanData = squeeze(data(i,:));
    N = length(cleanData);
    xdft = fft(cleanData);
    xdft = xdft(1:N/2+1);
    
    psdx = (1/(fs*N)) * abs(xdft).^2;
    psdx(2:end-1) = 2*psdx(2:end-1);
    freq = 0:fs/length(cleanData):fs/2;
    
    plot(freq,10*log10(psdx))
    %grid on
    hold on
end
title('Periodogram Using FFT')
xlabel('Frequency (Hz)')
ylabel('Power/Frequency (dB/Hz)')

%%
% linkaxes
% axis off
% title('
% set(gcf,'color','w')
% fig=gcf;
% fig.PaperUnits='Inches';
% fig.PaperPosition=[0 0 2 1.5];
