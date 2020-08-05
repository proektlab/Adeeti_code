%% Shits for State Determination
% 08/23/18 AA
directory = '/data/adeeti/ecog/matIsoPropMultiStim/';

cd(directory);
close all 

%% Parameters for multitaper spectral analysis and shits

win = 5; % size of window (secs) for spectrum
win_step = 0.5; % size of window step (secs) for spectrum (in this case we are taking 10sec windows, stepping by 1sec)
ktapers = 10;  % number of tapers for mutlitaper analysis
NW = 19;  % constant for multitaper analysis

USE_CHANNEL = 3; % channel for analysis

%% Loading data and doing the shits

load('dataMatrixFlashes.mat')

[MFE] = findMyExpMulti(dataMatrixFlashes, [], [],[],[0 inf]);
oneChanFullTrace = [];

for i = 1:length(MFE)
    load(dataMatrixFlashes(MFE(i)).expName, 'meanSubFullTrace', 'info', 'finalSampR', 'finalTimeFullTrace')
    fullTrace{i} = meanSubFullTrace(:,info.startOffSet:info.endOffSet);
    expID{i} = info.exp;
    anesType{i}= info.AnesType;
    anesLevel{i}= info.AnesLevel;
    oneChanFullTrace{i} = fullTrace{i}(USE_CHANNEL,:);
end

USE_DATA = fullTrace;
sf = finalSampR;

%% Compute spectrum for each experiment and concatonate together and shits
mySpectrum = [];
myTotalSpectrum = [];
indexLength = [];
startTimes = [];
endTimes =[];
expLabel = [];
drugLabel = [];
doseLabel = [];

for i = 1:length(MFE)
    
    % high pass filter the data -- Neuralynx data is already high pass
    % 	filtered at 0.1Hz
    % 	high_cutoff = 0.1;
    % 	[b,a] = butter(4,high_cutoff/sf,'high');
    % 	for i = 1:size(data,1)
    % 		data(i,:) = filtfilt(b,a,double(data(i,:)));
    % 	end
    
    addpath('/home/alex/MatlabCode/Spectra');
    
    %perform spectral analysis on one of the frontal channels
    data = USE_DATA{i};
    noiseChannels = info.noiseChannels;
    
    [out, taper, concentration]=swTFspecAnalog(data(USE_CHANNEL,:), sf, ktapers, [], win*sf, win_step*sf, NW,[],[],[],[]); %multitaper spectral analysis on the entire length of data
    disp(['Spectral analysis of channel ', num2str(USE_CHANNEL)])
    
    freq=out.freq_grid; %extract freq evaluated
    T=out.time_grid; %extract time windows evaluated
    spectrum=squeeze(out.tfse); % size = 1 x windows x freq; tfse = power at each freq and time point
    
    %Normalize the spectra
    
    % load('freq.mat')
    % load('allSpectrum.mat')
    
    totalPower = sum(spectrum,2);  %add up the power at each freq for every time window ==> time windows x 1
    totalSpectrum = spectrum./repmat(totalPower,1, length(freq));   % normalizing power at each freq by the total power: replicate the total power at all freq and then divide each power at each time window by the total
    mySpectrum = vertcat(mySpectrum, spectrum);
    myTotalSpectrum= vertcat(myTotalSpectrum, totalSpectrum);
    indexLength = [indexLength, ones(1, size(spectrum,1))*i];
    expLabel = [expLabel, ones(1, size(spectrum,1))*expID{i}];
    %drugLabel = [drugLabel, ones(1, size(spectrum,1))anesType{i}];
    doseLabel = [doseLabel, ones(1, size(spectrum,1))*anesLevel{i}];
    startTimes = [startTimes, win_step*(0:(size(spectrum,1)-1))];
end

endTimes = startTimes+win;

%% normalizing spectra and shits

USE_SPECTRUM = myTotalSpectrum; % myTotalSpectrum

meanSpectrum=mean(10*log10(USE_SPECTRUM),1); %take the mean power for each freq ==> 1 x freq

normSpectrum=10*log10(USE_SPECTRUM)-repmat(meanSpectrum, size(USE_SPECTRUM, 1), 1); % deviations from mean spectrum (already normalized to the total power)

addpath('/home/rachel/scripts/pca/');

%lowFreq = find(freq>0.1, 1, 'first');
%highFreq = find(freq>150, 1, 'first');
lowFreq = 1;
highFreq = size(freq, 2);
freqScale = lowFreq:highFreq;


%% Plotting the data and the multi-taper spectra together and shits

figure
h1= subplot(2,1,1);
pcolor((1:size(normSpectrum, 1))*(win_step*sf),freq(freqScale), normSpectrum(:,freqScale)'); shading 'flat'
set(gca, 'Yscale', 'log')
colorbar
set(gca, 'Clim', [-10 10])
title('Spectrum of frontal channel')
h2= subplot(2,1,2);
plot((1:size(normSpectrum, 1))*(win_step*sf),indexLength)
title('Anesthesia')
colorbar
linkaxes([h1 h2], 'x')

%% PCA of spectrum and shits

[~, scores, ~, ~, explained] = pca(normSpectrum(:,freqScale),'NumComponents',8);
figure
scatter3(scores(:,1), scores(:,2), scores(:,3),32,log(doseLabel))
title('Scatter with Colors for Anes Level')
axis vis3d
box on

figure
scatter3(scores(:,1), scores(:,2), scores(:,3),32,expLabel)
title('Scatter with Colors for Mouse')
axis vis3d
box on

%% looking at how data is distributed over the PCs and shits
figure
for i = 1:size(scores, 2)
    h(i) = subplot(2, 4, i);
    histogram(scores(:,i),100)
    title(['PC ', num2str(i)])
end
suptitle('Distribution of data in PC space')

figure
plot(explained(1:10))
title({'Variance explained by each PC'; ['Variance explained the first 3 PCs is ', num2str(sum(explained(1:3))), '%']})

%% Clustering data based on PCs and shits

eva = evalclusters(scores(:,1:3),'kmeans','CalinskiHarabasz','KList',[1:8]);
clusterIndex=kmeans(scores(:,1:3), eva.OptimalK, 'Replicates', 1000, 'Display', 'iter');
T = clusterdata(scores(:,1:3),8);

figure
subplot(1,2,1)
scatter3(scores(:,1), scores(:,2), scores(:,3),32,clusterIndex)
title('Scatter with Colors for Cluster using kmeans')
axis vis3d
box on
subplot(1,2,2)
scatter3(scores(:,1), scores(:,2), scores(:,3),32,T)
title('Scatter with Colors for Cluster using heirarchical tree clustering')
axis vis3d
box on

%% Removing clusters that seem like the Seems like there might be an outlier cluster and shits

prompt = 'Enter in numeric value of outlier cluster:';
OUTLIER_CLUSTER = input(prompt);

%OUTLIER_CLUSTER = 2;
OG_CLUSTER = clusterIndex; % cluster_Index or T

outlierClusterIndex = find(OG_CLUSTER == OUTLIER_CLUSTER);
newScores = scores;
newScores(outlierClusterIndex,:) = NaN;
newClusterIndex=kmeans(newScores(:,1:3), eva.OptimalK, 'Replicates', 1000, 'Display', 'iter');
newT = clusterdata(newScores(:,1:3),8);

figure
subplot(1,2,1)
scatter3(newScores(:,1), newScores(:,2), newScores(:,3),32,newClusterIndex)
title('Scatter with Colors for Cluster using kmeans, outlier removed')
axis vis3d
box on
subplot(1,2,2)
scatter3(newScores(:,1), newScores(:,2), newScores(:,3),32,newT)
title('Scatter with Colors for Cluster using heirarchical tree clustering, outlier removed')
axis vis3d
box on

%% Making more plots for clustering validations and shits

USE_CLUSTERS = newClusterIndex;

figure
subplot(2,1,1)
plot(USE_CLUSTERS)
title('States in Data')
subplot(2,1,2)
plot(indexLength, USE_CLUSTERS, 'ok')
title('States for each condition')

figure
hist(USE_CLUSTERS)
title('Freq of windows in each state')

figure
for i = 1:max(USE_CLUSTERS)
    subplot(2,3,i)
    hist(find(USE_CLUSTERS ==i), 50)
    title(['Cluster: ', num2str(i)])
end
suptitle('Times in each cluster')

figure
for i = 1:max(indexLength)
    subplot(4,8,i)
    hist(USE_CLUSTERS(find(indexLength ==i)))
    title(['Condition: ', num2str(i)])
end
suptitle('Clusters in each condition')

%% Looking at time epochs in each cluster and shits

SHOW_CLUSTER = 2;
NUM_SAMP = 18;
USE_CLUSTERS = newClusterIndex; %newT, T, clusterIndex, newClusterIndex

myCluster = [];
mySamples = [];

myCluster= find(USE_CLUSTERS == SHOW_CLUSTER);


mySamples = randsample(myCluster, NUM_SAMP, false);
for s = 1:NUM_SAMP
    myCluster(find(myCluster==mySamples(s))) = [];
end

plotTime = (0:win*finalSampR)/finalSampR;

figure
allPlot = [];
for i= 1:NUM_SAMP
    h(i) = subplot(3,ceil(NUM_SAMP/3),i);
    samp = mySamples(i);
    plotTrace = squeeze(fullTrace{indexLength(samp)}(USE_CHANNEL,startTimes(samp)*finalSampR:endTimes(samp)*finalSampR));
    allPlot = [allPlot, plotTrace];
    plot(plotTime,plotTrace)
    xlim = [min(plotTime), max(plotTime)];
    title(['M', num2str(expLabel(samp)), ' ', anesType{indexLength(samp)}, ' ', num2str(doseLabel(samp))])
end
suptitle(['Randomly picked traces in cluster ', num2str(SHOW_CLUSTER)])
set(h, 'ylim', [min(allPlot), max(allPlot)]);

%% 
drugInd = doseLabel;
drugInd(find(doseLabel <2))= 1;
drugInd(find(doseLabel >2))= 2;

W = LDA(normSpectrum, drugInd);
MdlLinear = fitcdiscr(normSpectrum, drugInd);
MdlLinearDoses= fitcdiscr(normSpectrum, doseLabel);


%%
CLUSTER1 = 3;
CLUSTER2 = 5;

values = MdlLinearDoses.Coeffs(CLUSTER1,CLUSTER2).Const + normSpectrum*MdlLinearDoses.Coeffs(CLUSTER1,CLUSTER2).Linear;

clusterValues = [];
clusterValues{1} = values(doseLabel==MdlLinearDoses.ClassNames(CLUSTER1));
clusterValues{2} = values(doseLabel==MdlLinearDoses.ClassNames(CLUSTER2));

figure(6);
clf;
[~,bins] = histcounts(values,20);
histogram([clusterValues{1}; clusterValues{2}],bins);
hold on;
histogram(clusterValues{1},bins);
histogram(clusterValues{2},bins);

legend({num2str(MdlLinearDoses.ClassNames(CLUSTER1)),num2str(MdlLinearDoses.ClassNames(CLUSTER2))});

% [h,p,kstat] = kstest2(clusterValues{1},clusterValues{2})


% Fisher's linear disriminant
clusterMeans = [];
clusterMeans(1) = mean(clusterValues{1});
clusterMeans(2) = mean(clusterValues{2});
allValues = [clusterValues{1}; clusterValues{2}];

inClusterVar = 0;
for i = 1:2
    inClusterVar = inClusterVar + mean((clusterValues{i} - clusterMeans(i)).^2);
end

fisherDiscrim = inClusterVar/mean((allValues - mean(allValues)).^2);

title(['Fishers linear discriminant: ' num2str(fisherDiscrim)]);

[dip, p, xlow, xup] = HartigansDipSignifTest(allValues,100)
