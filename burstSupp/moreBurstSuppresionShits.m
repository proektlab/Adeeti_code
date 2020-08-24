%% Probablity of evoking a burst after VEP in BS

win = 10; % size of window (secs) for spectrum
win_step = 1; % size of window step (secs) for spectrum (in this case we are taking 10sec windows, stepping by 1sec)
ktapers = 10;  % number of tapers for mutlitaper analysis
NW = 19;  % constant for multitaper analysis

%%

[MFE] = findMyExpMulti(dataMatrixFlashes, [], [],[],[0 inf]);
channel3 = [];

for i = 1:length(MFE)
load(dataMatrixFlashes(MFE(i)).expName, 'meanSubFullTrace', 'info', 'finalSampR', 'finalTimeFullTrace')
fullTrace{i} = meanSubFullTrace(:,info.startOffSet:info.endOffSet);
channel3{i} = fullTrace{i}(3,:);
end
vis3d; box on 
for i = 1:length(MFE)
channel3{i} = fullTrace{i}(3,:);
end

sf = finalSampR;

    %data = meanSubData;
    %concatData = reshape(permute(data, [1 3 2]), 64, (size(data,2)*3001));

%% Compute spectrum for each experiment and concatonate together 
    mySpectrum = [];
    indexLength = [];
for i = 1:length(MFE)
	
% high pass filter the data -- Neuralynx data is already high pass
% 	filtered at 0.1Hz
% 	high_cutoff = 0.1;
% 	[b,a] = butter(4,high_cutoff/sf,'high');
% 	for i = 1:size(data,1)
% 		data(i,:) = filtfilt(b,a,double(data(i,:)));
% 	end

    data = fullTrace{i};

	addpath('/home/alex/MatlabCode/Spectra');
    
    %perform spectral analysis on one of the frontal channels 
    
    noiseChannels = info.noiseChannels;
    
    myChannel = 3;
        [out, taper, concentration]=swTFspecAnalog(data(myChannel,:), sf, ktapers, [], win*sf, win_step*sf, NW,[],[],[],[]); %multitaper spectral analysis on the entire length of data 
        disp('Spectral analysis of channel 5')
        myChannel = 3;
    
%     if isempty(find(noiseChannels ==5))
%         [out, taper, concentration]=swTFspecAnalog(data(5,:), sf, ktapers, [], win*sf, win_step*sf, NW,[],[],[],[]); %multitaper spectral analysis on the entire length of data 
%         disp('Spectral analysis of channel 5')
%         myChannel = 5;
%     elseif isempty(find(noiseChannels == 17))
%         [out, taper, concentration]=swTFspecAnalog(data(17,:), sf, ktapers, [], win*sf, win_step*sf, NW,[],[],[],[]); %multitaper spectral analysis on the entire length of data 
%         disp('Spectral analysis of channel 17')
%         myChannel = 17;
%     elseif isempty(find(noiseChannels == 33))
%         [out, taper, concentration]=swTFspecAnalog(data(33,:), sf, ktapers, [], win*sf, win_step*sf, NW,[],[],[],[]); %multitaper spectral analysis on the entire length of data 
%         disp('Spectral analysis of channel 33')
%         myChannel = 33;
%     elseif isempty(find(noiseChannels == 53))
%         [out, taper, concentration]=swTFspecAnalog(data(53,:), sf, ktapers, [], win*sf, win_step*sf, NW,[],[],[],[]); %multitaper spectral analysis on the entire length of data 
%         disp('Spectral analysis of channel 53')
%         myChannel = 53;
%     else
%         randCh = datasample(1:size(data,1), 1);
%         if exist(find(noiseChannels == randCh))
%             continue
%         end
%         [out, taper, concentration]=swTFspecAnalog(data(randCh,:), sf, ktapers, [], win*sf, win_step*sf, NW,[],[],[],[]); %multitaper spectral analysis on the entire length of data - arbitrary middle channel in the grid
%         disp(['Spectral analysis of channel ', num2str(randCh)])
%     end
    
    freq=out.freq_grid; %extract freq evaluated
    T=out.time_grid; %extract time windows evaluated
    spectrum=squeeze(out.tfse); % size = 1 x windows x freq; tfse = power at each freq and time point

%Normalize the spectra

% load('freq.mat')
% load('allSpectrum.mat')

    totalPower = sum(spectrum,2);  %add up the power at each freq for every time window ==> time windows x 1
    totalSpectrum = spectrum./repmat(totalPower,1, length(freq));   % normalizing power at each freq by the total power: replicate the total power at all freq and then divide each power at each time window by the total  
    mySpectrum = vertcat(mySpectrum, totalSpectrum); 
    indexLength = [indexLength, ones(1, size(spectrum,1))*i];
end

%%

    meanSpectrum=mean(10*log10(mySpectrum),1); %take the mean power for each freq ==> 1 x freq 
    
    normSpectrum=10*log10(mySpectrum)-repmat(meanSpectrum, size(mySpectrum, 1), 1); % deviations from mean spectrum (already normalized to the total power)
    
    addpath('/home/rachel/scripts/pca/');
    
    %lowFreq = find(freq>0.1, 1, 'first');
    %highFreq = find(freq>150, 1, 'first');
    lowFreq = 1;
    highFreq = size(freq, 2);
    freqScale = lowFreq:highFreq;
    
% %% Find V1 for the exp
% 
% V1 = info.lowLat;
% 
% % [allV1] = V1forEachMouse(pwd);
% % 
% % V1 = allV1(2,(find(allV1(1,:)== info.exp)));
% % 
% % ySF = max(data(V1,:));
% 
% %% To add timestamps for ttl pulsez
% 
% timeTTL = zeros(1, size(data,2));
% TTLs = 1000:3000:size(data, 2);
% timeTTL(TTLs) = max(data(:));

%% Plotting the data and the multi-taper spectra together

% figure
% h1 = subplot(4, 1, 1)
% plot(data(V1,:))
% hold on 
% plot(timeTTL, 'r')
% title('ECoG over V1')
% colorbar
% h2=subplot(4,1,2)
% plot(data(myChannel,:));
% title('ECoG over frontal channel')
% colorbar
% h3=subplot(4,1,[3 4])
% pcolor((1:size(normSpectrum, 1))*(win_step*sf), freq(freqScale), normSpectrum(:,freqScale)'); shading 'flat'
% set(gca, 'Yscale', 'log')
% colorbar
% set(gca, 'Clim', [-12 12])
% title('Spectrum of frontal channel')
% linkaxes([h1 h2 h3], 'x')
figure
h1= subplot(2,1,1)
pcolor((1:size(normSpectrum, 1))*(win_step*sf),freq(freqScale), normSpectrum(:,freqScale)'); shading 'flat'
set(gca, 'Yscale', 'log')
colorbar
set(gca, 'Clim', [-10 10])
title('Spectrum of frontal channel')
h2= subplot(2,1,2)
plot((1:size(normSpectrum, 1))*(win_step*sf),indexLength)
title('Anesthesia')
linkaxes([h1 h2], 'x')

%%

[~, scores, ~] = pca(normSpectrum(:,freqScale),'NumComponents',8);
figure
scatter3(scores(:,1), scores(:,2), scores(:,3),32,indexLength)
axis vis3d
box on

% %% Find my bursts
% 
% tenHzFreqs = find(freq > 9, 5, 'first'); % finding the 5 freq around ten
% tenHzPower = sum(spectrum(:,tenHzFreqs) - min(spectrum(:)) + 0.000000001,2); %total power around ten, making sure its :)
% 
% figure
% hist(log10(tenHzPower))
% 
% [categories, centroids] = kmeans(log10(tenHzPower), 2); %clustering supression vs bursts in data sets with only bursts and suppressions; kmeans will tell you to find as many catagories you want, but with 2 gaus mixture
% 
% [~, maxCategory] = max(centroids);  %finds larger of position along log10 power spec --> this is the burst
% threshold = min(tenHzPower(categories == maxCategory));  %find the power at the start of the burst
% 
% bursts = tenHzPower >= threshold; % 1 = burst, 0 = suppression 
% bursts = imclose(bursts, ones(10,1)) %makes sure that bursts are continuous
% bursts = imopen(bursts, ones(5,1)) %gets rid of single spikes
% 
% figure;
% clf;
% plot(data(myChannel,:), 'lineWidth', 1.5)
% 
% hold on;
% scatter(find(bursts)*(win_step*sf) + win*sf/2, zeros(length(find(bursts)),1), 'LineWidth',2);
% 
% %% 
% 
% testData = smallTenHzPower;
% 
% [categories, centroids, sumd] = kmeans(log10(testData), 2); %clustering supression vs bursts in data sets with only bursts and suppressions; kmeans will tell you to find as many catagories you want, but with 2 gaus mixture
% [~, maxCategory] = max(centroids);
% 
% inClusterVar = 0;
% for i = 1:length(centroids)
%     inClusterVar = inClusterVar + mean((log10(testData(categories == i)) - centroids(i)).^2);
% end
% 
% inClusterVar/var(log10(testData))
% 
% figure;
% clf
% histogram(log10(testData))
% hold on
% scatter(centroids,[1, 1])
% histogram(log10(testData(categories == maxCategory)))
% histogram(log10(testData(categories ~= maxCategory)))
% 
% %%
% %burst Suppression
% smallData = data(:, 128000:138000);
% figure; clf; 
% plot(squeeze(smallData(V1,:)))
% 
% smallTenHzPower= tenHzPower(1289:1380);
% figure
% hist(smallTenHzPower)
% 
% %not burst suppression
% 
% otherData = data(:, 67000:77000);
% figure; clf; 
% plot(squeeze(otherData(V1,:)))
% 
% smallTenHzPower= tenHzPower(670:770);
% figure
% hist(smallTenHzPower)
% 
% 
% %% 
