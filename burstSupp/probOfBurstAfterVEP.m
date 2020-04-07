%% Probablity of evoking a burst after VEP in BS

win = 1; % size of window (secs) for spectrum
win_step = .1; % size of window step (secs) for spectrum (in this case we are taking 10sec windows, stepping by 1sec)
ktapers = 10;  % number of tapers for mutlitaper analysis
NW = 19;  %

%% Compute spectrum for each experiment and concatonate together 

    data = meanSubData;
    concatData = reshape(permute(data, [1 3 2]), 64, (size(data,2)*3001));
    data = concatData;
    
    sf = finalSampR;
	
% 	% high pass filter the data -- Neuralynx data is already high pass
% 	filtered at 0.1Hz
% 	high_cutoff = 0.1;
% 	[b,a] = butter(4,high_cutoff/sf,'high');
% 	for i = 1:size(data,1)
% 		data(i,:) = filtfilt(b,a,double(data(i,:)));
% 	end
	
	addpath('/home/alex/MatlabCode/Spectra');
    
    %perform spectral analysis on one of the frontal channels 
    
    noiseChannels = info.noiseChannels;
    
    
    
    if isempty(find(noiseChannels ==5))
        [out, taper, concentration]=swTFspecAnalog(data(5,:), sf, ktapers, [], win*sf, win_step*sf, NW,[],[],[],[]); %multitaper spectral analysis on the entire length of data 
        disp('Spectral analysis of channel 5')
        myChannel = 5;
    elseif isempty(find(noiseChannels == 17))
        [out, taper, concentration]=swTFspecAnalog(data(17,:), sf, ktapers, [], win*sf, win_step*sf, NW,[],[],[],[]); %multitaper spectral analysis on the entire length of data 
        disp('Spectral analysis of channel 17')
        myChannel = 17;
    elseif isempty(find(noiseChannels == 33))
        [out, taper, concentration]=swTFspecAnalog(data(33,:), sf, ktapers, [], win*sf, win_step*sf, NW,[],[],[],[]); %multitaper spectral analysis on the entire length of data 
        disp('Spectral analysis of channel 33')
        myChannel = 33;
    elseif isempty(find(noiseChannels == 53))
        [out, taper, concentration]=swTFspecAnalog(data(53,:), sf, ktapers, [], win*sf, win_step*sf, NW,[],[],[],[]); %multitaper spectral analysis on the entire length of data 
        disp('Spectral analysis of channel 53')
        myChannel = 53;
%     else
%         randCh = datasample(1:size(data,1), 1);
%         if exist(find(noiseChannels == randCh))
%             continue
%         end
%         [out, taper, concentration]=swTFspecAnalog(data(randCh,:), sf, ktapers, [], win*sf, win_step*sf, NW,[],[],[],[]); %multitaper spectral analysis on the entire length of data - arbitrary middle channel in the grid
%         disp(['Spectral analysis of channel ', num2str(randCh)])
    end
    
    freq=out.freq_grid; %extract freq evaluated
    T=out.time_grid; %extract time windows evaluated
    spectrum=squeeze(out.tfse); % size = 1 x windows x freq; tfse = power at each freq and time point


%% Normalize the spectra

% load('freq.mat')
% load('allSpectrum.mat')

    totalPower = sum(spectrum,2);  %add up the power at each freq for every time window ==> time windows x 1
    totalSpectrum = spectrum./repmat(totalPower,1, length(freq));   % normalizing power at each freq by the total power: replicate the total power at all freq and then divide each power at each time window by the total  
    meanSpectrum=mean(10*log10(spectrum),1); %take the mean power for each freq ==> 1 x freq 
    normSpectrum=10*log10(spectrum)-repmat(meanSpectrum, size(spectrum, 1), 1); % deviations from mean spectrum (already normalized to the total power)
    
    addpath('/home/rachel/scripts/pca/');
    
    %lowFreq = find(freq>0.1, 1, 'first');
    %highFreq = find(freq>150, 1, 'first');
    lowFreq = 1;
    highFreq = size(freq, 2);
    freqScale = lowFreq:highFreq;
    
%% Find V1 for the exp

% [allV1] = V1forEachMouse(pwd);
% 
% V1 = allV1(2,(find(allV1(1,:)== info.exp)));
% 
% ySF = max(data(V1,:));

V1 = info.V1;

%% To add timestamps for ttl pulsez

timeTTL = zeros(1, size(data,2));
TTLs = 1000:3000:size(data, 2);
timeTTL(TTLs) = 1;

%% Plotting the data and the multi-taper spectra together
dirDropbox = '/data/adeeti/Dropbox/';

conToMin = 60000;
trueTime = linspace(0, size(data,2)/60000, size(data,2));

ff = figure;
h1 = subplot(4, 1, 1);
plot(trueTime, data(V1,:)')
hold on 
% plot(timeTTL, 'r')
ylabel('Voltage \muV', 'FontSize', 14)
xlabel('Time (min)', 'FontSize', 14)
title('ECoG over V1', 'FontSize', 16)
colorbar
h2=subplot(4,1,2);
plot(trueTime, data(myChannel,:)');
ylabel('Voltage \muV', 'FontSize', 14)
xlabel('Time (min)', 'FontSize', 14)
title('ECoG over frontal channel', 'FontSize', 16)
colorbar
h3=subplot(4,1,[3 4]);
pcolor((1:size(normSpectrum, 1))*(win_step*sf/conToMin), freq(freqScale), normSpectrum(:,freqScale)'); shading 'flat'
set(gca, 'Yscale', 'log')
ylabel('Freq (Hz)', 'FontSize', 14)
xlabel('Time (min)', 'FontSize', 14)
c = colorbar;
c.Label.String = 'Power (dB)';
c.Label.FontSize = 14;
colormap('jet')
set(gca, 'Clim', [-12 12])
title('Spectrum of frontal channel', 'FontSize', 16)
linkaxes([h1 h2 h3], 'x')
set(gca, 'xlim', [0,10])

saveas(ff, [dirDropbox, 'burstSuppStatesComMeeting', '.png'])

%% Find my bursts

tenHzFreqs = find(freq > 9, 5, 'first'); % finding the 5 freq around ten
tenHzPower = sum(spectrum(:,tenHzFreqs) - min(spectrum(:)) + 0.000000001,2); %total power around ten, making sure its :)

figure
hist(log10(tenHzPower))

[categories, centroids] = kmeans(log10(tenHzPower), 2); %clustering supression vs bursts in data sets with only bursts and suppressions; kmeans will tell you to find as many catagories you want, but with 2 gaus mixture

[~, maxCategory] = max(centroids);  %finds larger of position along log10 power spec --> this is the burst
threshold = min(tenHzPower(categories == maxCategory));  %find the power at the start of the burst

bursts = tenHzPower >= threshold; % 1 = burst, 0 = suppression 
bursts = imclose(bursts, ones(10,1)) %makes sure that bursts are continuous
bursts = imopen(bursts, ones(5,1)) %gets rid of single spikes

figure;
clf;
plot(data(myChannel,:), 'lineWidth', 1.5)

hold on;
scatter(find(bursts)*(win_step*sf) + win*sf/2, zeros(length(find(bursts)),1), 'LineWidth',2);

%% Finding individual bursts - dwell times and interburst intervals 

stats = regionprops(bursts,'Area');  %stats.Area = dwell times 
burstDwellTimes = [stats.Area];

stats = regionprops(~bursts,'Area');  %stats.Area = dwell times 
supressionDwellTimes = [stats.Area];

bursts(1)

%%

timeLockedBursts = ones(length(timeTTL), 1) * bursts(end);
burstData = [bursts(1) * ones(floor(win*sf/2),1); kron(bursts, ones(win_step*sf,1))];
timeLockedBursts(1:length(burstData)) = burstData;

% burstEnds = find(diff(bursts) == -1)*(win_step*sf) + win*sf/2;
burstEnds = find(diff(timeLockedBursts) == -1);

ttlOnset = find(timeTTL);

pulses = find(timeTTL==1);
suppressionPulsesIndicies = find(timeLockedBursts(find(timeTTL==1)) == 0);
suppressionPulses = pulses(suppressionPulsesIndicies);
burstPulsesIndices = 1:length(pulses);
burstPulsesIndices(suppressionPulsesIndicies) = [];
burstPulses = pulses(burstPulsesIndices);


timesSinceLastBurst = nan(length(suppressionPulses), 1);
for i = 1:length(suppressionPulses)
    latestBurst = burstEnds(find(burstEnds <= suppressionPulses(i), 1, 'last'));
    if ~isempty(latestBurst)
        timesSinceLastBurst(i) = suppressionPulses(i) - burstEnds(find(burstEnds <= suppressionPulses(i), 1, 'last'));
    end
end

%% 

[~, order] = sort(timesSinceLastBurst);
lagSortedVEPz = squeeze(meanSubData(V1, suppressionPulsesIndicies(order), :));
VEPsupp = squeeze(meanSubData(V1, suppressionPulsesIndicies, :));
VEPburst = squeeze(meanSubData(V1, burstPulsesIndices, :));

%%
UniqueTimes=unique(timesSinceLastBurst);
UniqueTimes=UniqueTimes(~isnan(UniqueTimes));

EP=zeros(length(UniqueTimes),size(VEPsupp,2));

for i=1:length(UniqueTimes)
    EP(i,:)=VEPsupp( find(timesSinceLastBurst==UniqueTimes(i),1, 'first'),:);
end

%%
tl=linspace(0, max(timesSinceLastBurst)+1, 5);
figure;
for i=1:length(tl)-1
    plot(mean(VEPsupp(find(timesSinceLastBurst>tl(i) & timesSinceLastBurst<tl(i+1)),:),1), 'linewidth', 2);
    disp(length(find(timesSinceLastBurst>tl(i) & timesSinceLastBurst<tl(i+1))));
    hold on;
end
%%

category = [];
dwellTimes = [];
for i = 1:length(stats)
%     category(i) = bursts(stats(i).PixelIdxList(1));
    dwellTimes(i) = stats(i).Area;
end

transitions=[1; find(diff(bursts))];
if transitions(end)<length(bursts)
   transitions=[transitions; length(bursts)];
end
durations=diff(transitions);

%% comparing aveTrace from in a burst vs not 
legInd = {};

figure
plot(squeeze(mean(VEPburst, 1)), 'r', 'linewidth', 2);
legInd{end+1} = ['Average Burst EP, n = ', num2str(size(VEPburst, 1))];
CIBurst = 2*std(VEPburst, [], 1)/sqrt(size(VEPburst, 1));
hold on 
ciplot(squeeze(mean(VEPburst, 1))-CIBurst, squeeze(mean(VEPburst, 1))+CIBurst, 1:size(VEPburst,2), 'r')
legInd{end+1} = '95% CI Burst';

plot(squeeze(mean(VEPsupp, 1)), 'b', 'linewidth', 2);
legInd{end+1} = ['Average Supp EP, n = ', num2str(size(VEPsupp, 1))];
CISupp = 2*std(VEPsupp, [], 1)/sqrt(size(VEPsupp, 1));
ciplot(squeeze(mean(VEPsupp, 1))-CISupp, squeeze(mean(VEPsupp, 1))+CISupp, 1:size(VEPburst,2), 'b')
legInd{end+1} = '95% CI Supp';
hold off

legend(legInd)



