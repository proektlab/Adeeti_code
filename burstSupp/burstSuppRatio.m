%% Calculating Burst Suppresion ratio

onAlexsWorkStation = 1; %1 if on workstation with complete multistim data set, 0 if on lab mac, 2 if on laptop

if onAlexsWorkStation ==1
    % Alex's computer
    dirIn = '/data/adeeti/ecog/matIsoPropMultiStimVIS_ONLY_/flashTrials/';
    dirOut1 = '/home/adeeti/GoogleDrive/TNI/IsoPropCompV1Paper/';
    cd(dirIn)
    load('dataMatrixFlashesVIS_ONLY.mat')
    dataMatrixFlashes = dataMatrixFlashesVIS_ONLY;
elseif onAlexsWorkStation ==0
    % Adeeti's Desktop
    dirIn = '/Users/adeeti/Desktop/data/VIS_Only_Iso_prop_2018/flashTrials/';
    dirOut1 = '/Users/adeeti/Google Drive/TNI/IsoPropCompV1Paper/';
    cd(dirIn)
    load('dataMatrixFlashesVIS_ONLY.mat')
    dataMatrixFlashes = dataMatrixFlashesVIS_ONLY;
elseif onAlexsWorkStation ==2
    % Adeeti's Laptop
    dirIn = '/Users/adeetiaggarwal/Google Drive/data/VIS_Only_Iso_prop_2018/flashTrials/';
    dirOut1 = '/Users/adeeti/Google Drive/TNI/IsoPropCompV1Paper/';
    cd(dirIn)
    load('dataMatrixFlashesVIS_ONLY.mat')
    dataMatrixFlashes = dataMatrixFlashesVIS_ONLY;
end

lowestLatVariable = 'lowLat';
stimIndex = [0, Inf]; %if want all, stimIndex = matStimIndex; % if want
%all uniStimIndexes/multiStimIndexes, use [uniStimIndex, multiStimIndex] =
%findUniMutliStimIndex(matStimIndex), [stimIndex, ~] = findUniMutliStimIndex(matStimIndex)

% Setting up new data set for just visual only stim
expLabel =unique(vertcat(dataMatrixFlashes(:).exp));
allExp = {};
if exist('stimIndex')  && ~isempty(stimIndex)
    for i = 1:length(expLabel)
        for j = 1:size(stimIndex,1)
            [MFE] = findMyExpMulti(dataMatrixFlashes, expLabel(i), [], [], []);
            allExp{i}(:) = MFE;
        end
    end
else
    [MFE] = 1:length(dataMatrixFlashes);
end

numSubjects = size(allExp,2);
maxExposuresPerSubject = max(cellfun(@length, allExp));
fs = 1000;

%% setting up for spectal estimation 
win = 0.5; % size of window (secs) for spectrum
win_step = .1; % size of window step (secs) for spectrum (in this case we are taking 10sec windows, stepping by 1sec)
ktapers = 5;  % number of tapers for mutlitaper analysis
NW = 11;  % constant for multitaper analysis

sf = 1000; 
freq = [];
T= [];
rawSpectrum = [];
normMeanSpectrum= [];

winLow = 4; % size of window (secs) for spectrum
win_stepLow = .5; % size of window step (secs) for spectrum (in this case we are taking 10sec windows, stepping by 1sec)
ktapersLow = 10;  % number of tapers for mutlitaper analysis
NWLow = 19;  % constant for multitaper analysis

freqLow = [];
TLow = [];
normMeanSpectrumLow= [];
rawSpectrumLow= [];

fullTraces = [];
V1Traces = [];
V1s = [];

for ID = 1:numSubjects
    for experiment = 1: maxExposuresPerSubject
        if experiment> numel(allExp{ID})
            continue
        end
        load(dataMatrixFlashes(allExp{ID}(experiment)).expName, 'meanSubFullTrace', 'info', 'finalSampR', 'finalTimeFullTrace')
        if experiment ==1
            V1 = info.lowLat;
            V1s{ID} = V1;
        end
        %fullTraces{i,:,:} = meanSubFullTrace;
        V1Traces{ID}{experiment} = squeeze(meanSubFullTrace(V1,:));
    end
end


for ID = 1:numSubjects
    for experiment = 1: maxExposuresPerSubject
        if experiment> numel(allExp{ID})
            continue
        end
        data = V1Traces{ID}{experiment};
        [out, taper, concentration]=swTFspecAnalog(data, sf, ktapers, [], win*sf, win_step*sf, NW,[],[],[],[]); %multitaper spectral analysis on the entire length of data
        disp('Spectral analysis of V1')
        
        if ID ==1 && experiment ==1
        freq=out.freq_grid; %extract freq evaluated
        end
        
        T{ID}{experiment}=out.time_grid; %extract time windows evaluated
        spectrum=squeeze(out.tfse); % size = 1 x windows x freq; tfse = power at each freq and time point
        
        %totalPower = sum(spectrum,2);  %add up the power at each freq for every time window ==> time windows x 1
        meanSpectrum=mean(10*log10(spectrum),1); %take the mean power for each freq ==> 1 x freq
        rawSpectrum{ID}{experiment}=spectrum;
        normMeanSpectrum{ID}{experiment}=10*log10(spectrum)-repmat(meanSpectrum, size(spectrum, 1), 1);
        %totalSpectrum{ID}{experiment} = spectrum./repmat(totalPower,1, length(out.freq_grid));   % normalizing power at each freq by the total power: replicate the total power at all freq and then divide each power at each time window by the tota
                
        
        [out, taper, concentration]=swTFspecAnalog(data, sf, ktapersLow, [], winLow*sf, win_stepLow*sf, NWLow,[],[],[],[]); %multitaper spectral analysis on the entire length of data
        disp('Spectral analysis of V1')
        
        if ID ==1 && experiment ==1
        freqLow=out.freq_grid; %extract freq evaluated
        end
        
        TLow{ID}{experiment}=out.time_grid; %extract time windows evaluated
        spectrum=squeeze(out.tfse); % size = 1 x windows x freq; tfse = power at each freq and time point
        
        meanSpectrum=mean(10*log10(spectrum),1); %take the mean power for each freq ==> 1 x freq
        rawSpectrumLow{ID}{experiment}=spectrum;
        normMeanSpectrumLow{ID}{experiment}=10*log10(spectrum)-repmat(meanSpectrum, size(spectrum, 1), 1);
    end
end


%% Looking at spectrum
ID =1;
experiment =1;

useTrace = V1Traces{ID}{experiment};
useTime = T{ID}{experiment}*sf;
useTimeLow = TLow{ID}{experiment}*sf;

useSpectrum = normMeanSpectrum;
useSpectrumLow = normMeanSpectrumLow;

trueLowFreq = 1;
trueHighFreq  = 100;

lowFreq = find(freq>trueLowFreq, 1, 'first');
highFreq = find(freq<trueHighFreq, 1, 'last');
freqScale = lowFreq:highFreq;

trueLowFreq = .25;
trueHighFreq  = 10;

lowFreqLow = find(freqLow>trueLowFreq, 1, 'first');
highFreqLow = find(freqLow<trueHighFreq, 1, 'last');
freqScaleLow = lowFreqLow:highFreqLow;

figure
h1= subplot(3,1,1)
pcolor(useTime,freq(freqScale), useSpectrum{ID}{experiment}(:,freqScale)'); shading 'flat'
%pcolor(T{1}{1}*sf,freq(freqScale), 10*log10(rawSpectrum{1}{1}(:,freqScale)')); shading 'flat'
%pcolor(T{1}{1}*sf,freq(freqScale),freq(freqScale), normMeanSpectrum{1}{1}(:,freqScale)'); shading 'flat'
set(gca, 'Yscale', 'log')
colorbar
%set(gca, 'Clim', [-10 10])
title('High freq Spectrum of V1 channel')
h2= subplot(3,1,2)
pcolor(useTimeLow,freqLow(freqScaleLow), useSpectrumLow{ID}{experiment}(:,freqScaleLow)'); shading 'flat'
%pcolor(T{1}{1}*sf,freq(freqScale), 10*log10(rawSpectrum{1}{1}(:,freqScale)')); shading 'flat'
%pcolor(T{1}{1}*sf,freq(freqScale),freq(freqScale), normMeanSpectrum{1}{1}(:,freqScale)'); shading 'flat'
set(gca, 'Yscale', 'log')
colorbar
%set(gca, 'Clim', [-10 10])
title('Low freq Spectrum of V1 channel')
h3= subplot(3,1,3)
plot(useTrace); colorbar
title('Raw Trace')
linkaxes([h1 h2 h3], 'x')

%% Find calculating total power metrics
totPower = [];
totPowerLow = [];

useSpectrum = normMeanSpectrum;
useSpectrumLow = normMeanSpectrumLow;

for ID = 1:numSubjects
    figure
    for experiment = 1:maxExposuresPerSubject
        if experiment> numel(allExp{ID})
            continue
        end
        %totPower{ID}{experiment} = sum(10*log10(useSpectrum{ID}{experiment}(:,freqScale)),2); %total power around ten, making sure its :)
        totPower{ID}{experiment} = sum(useSpectrum{ID}{experiment}(:,freqScale),2); %total power around ten, making sure its :)
        totPowerLow{ID}{experiment} = sum(useSpectrumLow{ID}{experiment}(:,freqScaleLow),2); %total power around ten, making sure its :)
        
        subplot(2,3,experiment)
        histogram(totPower{ID}{experiment}, 100)
        title(['Experiment = ', num2str(experiment)])
    end
end

%% cluster spectrum into suppression periods- cluster each mouse and experiment differenetly 
ID =1;
experiment =1;

useTrace = V1Traces{ID}{experiment};
useTime = T{ID}{experiment}*sf;

useTotPower = totPower{ID}{experiment};

useTotPowerLow = totPowerLow{ID}{experiment};
useTimeLow = TLow{ID}{experiment}*sf;

[categories, centroids] = kmeans(useTotPower, 2); %clustering supression vs bursts in data sets with only bursts and suppressions; kmeans will tell you to find as many catagories you want, but with 2 gaus mixture
[~, minCategory] = min(centroids);  %finds larger of position along log10 power spec --> this is the burst
threshold = max(useTotPower(categories == minCategory));  %find the power at the start of the burst
suppression = useTotPower <= threshold; % 1 = suppression, 0 = burst 
%suppression = imclose(suppression, ones(5,1)); %makes sure that bursts are continuous
suppression = imopen(suppression, ones(5,1)); %gets rid of single spikes



[categoriesLow, centroidsLow] = kmeans(useTotPowerLow, 2); %clustering supression vs bursts in data sets with only bursts and suppressions; kmeans will tell you to find as many catagories you want, but with 2 gaus mixture
[~, minCategoryLow] = min(centroidsLow);  %finds larger of position along log10 power spec --> this is the burst
thresholdLow = max(useTotPowerLow(categoriesLow == minCategoryLow));  %find the power at the start of the burst
suppressionLow = useTotPowerLow <= thresholdLow; % 1 = suppression, 0 = burst 



%% concatonate all exposure in the same mouse together

whichTotPower = totPower;

mouseTotPower = [];
allTotPower = [];
for ID = 1:numSubjects
    for experiment = 1:maxExposuresPerSubject
        if experiment> numel(allExp{ID})
            continue
        end
        allTotPower = [allTotPower; whichTotPower{ID}{experiment}];
    end
    mouseTotPower{ID} = allTotPower;
end


%% clustering concatonated total power for each mouse
figure
histogram(mouseTotPower{1}, 100)

for ID = 2%:numSubjects
    figure
    useData = mouseTotPower{ID};
    
    [categories, centroids] = kmeans(useData, 2); %clustering supression vs bursts in data sets with only bursts and suppressions; kmeans will tell you to find as many catagories you want, but with 2 gaus mixture
    [~, minCategory] = min(centroids);  %finds larger of position along log10 power spec --> this is the burst
    threshold = max(useData(categories == minCategory));  %find the power at the start of the burst
    
    for experiment = 1:maxExposuresPerSubject
        if experiment> numel(allExp{ID})
            continue
        end
        useTotPower = totPower{ID}{experiment};
        useTime = T{ID}{experiment}*sf;
        useTrace = V1Traces{ID}{experiment};
        
        suppression = useTotPower <= threshold; % 1 = suppression, 0 = burst
        %suppression = imclose(suppression, ones(5,1)); %makes sure that bursts are continuous
        suppression = imopen(suppression, ones(5,1)); %gets rid of single spikes
        
        subplot(numel(allExp{ID}),1,experiment)
        plot(useTrace, 'lineWidth', 1.5)
        
        hold on;
        scatter(useTime(find(suppression)), zeros(length(find(suppression)),1), 'LineWidth',2);
    end
end



%% Concatonate spectrograms together for each mouse and for entire data set 

% concatonating spectra together for each mouse 
useSpectrum = normMeanSpectrum;

mouseNormSpectrum= [];
allSpec = [];
for ID = 1:numSubjects
    for experiment = 1:maxExposuresPerSubject
        if experiment> numel(allExp{ID})
            continue
        end
        allSpec = [allSpec; useSpectrum{ID}{experiment}];
    end
    mouseNormSpectrum{ID} = allSpec;
end

allMiceAllPower = [];
for ID = 1:numSubjects
   allMiceAllPower = [allMiceAllPower; mouseNormSpectrum{ID}];
end


%% Try looking at how PCA of all concatonated data looks - in theory, suppresion should be very differnt from all other spectral signitures

% concatonate spectra for all mice
useSpectrum = allMiceAllPower;
[Tvalue,pvar,W,L] = pca_alex(useSpectrum(:,freqScale)'); % original
useData = Tvalue(1,:);
[categories, centroids] = kmeans(useData', 2); %clustering supression vs bursts in data sets with only bursts and suppressions; kmeans will tell you to find as many catagories you want, but with 2 gaus mixture
[~, minCategory] = min(centroids);  %finds larger of position along log10 power spec --> this is the burst
threshold = max(useData(categories == minCategory));  %find the power at the start of the burst
PC1 = L(1,:);

for ID = 2%:numSubjects
    figure
    for experiment = 1:maxExposuresPerSubject
        if experiment> numel(allExp{ID})
            continue
        end
        useSpectrum = normMeanSpectrum{ID}{experiment}(:,freqScale)';

        projectionPC = PC1*useSpectrum;
        useTime = T{ID}{experiment}*sf;
        useTrace = V1Traces{ID}{experiment};
        
        suppression = projectionPC >= threshold; % 1 = suppression, 0 = burst
        %suppression = imclose(suppression, ones(5,1)); %makes sure that bursts are continuous
        suppression = imopen(suppression', ones(5,1)); %gets rid of single spikes
        
        subplot(numel(allExp{ID}),1,experiment)
        plot(useTrace, 'lineWidth', 1.5)
        
        hold on;
        scatter(useTime(find(suppression)), zeros(length(find(suppression)),1), 'LineWidth',2);
    end
    linkaxes
end

% overall, this method did not work as well for data sets that were not the
% first one- would be catching a lot of areas that are not suppression 


%% finding suppressions based on PCA of one exposure per mouse data

threshold = [];
PC1 = [];

for ID = 2%:numSubjects
    for experiment = 1%:maxExposuresPerSubject
        if experiment> numel(allExp{ID})
            continue
        end
    useSpectrum = normMeanSpectrum{ID}{experiment};
    
    [Tvalue,pvar,W,L] = pca_alex(useSpectrum(:,freqScale)'); % original
    %[T,pvar,W,L] = pca_alex(Snorm(:,1:freq_lim));
    
    % Plot pvar
    figure;
    subplot(2,1,1)
    plot(cumsum(pvar), '-o');
    set(gca, 'Ylim', [0 100])
    xlabel('Number of PCs');
    ylabel('Percent of Variance');
    
    subplot(2,1,2)
    histogram(Tvalue(1,:), 100)
    useData = Tvalue(1,:);
    [categories, centroids] = kmeans(useData', 2); %clustering supression vs bursts in data sets with only bursts and suppressions; kmeans will tell you to find as many catagories you want, but with 2 gaus mixture
    [~, minCategory] = min(centroids);  %finds larger of position along log10 power spec --> this is the burst
    threshold{ID} = max(useData(categories == minCategory));  %find the power at the start of the burst
    PC1{ID} = L(1,:);
    end
end


for ID = 2%:numSubjects
    figure
    for experiment = 1:maxExposuresPerSubject
        if experiment> numel(allExp{ID})
            continue
        end
        useSpectrum = normMeanSpectrum{ID}{experiment}(:,freqScale)';

        projectionPC = PC1{ID}*useSpectrum;
        useTime = T{ID}{experiment}*sf;
        useTrace = V1Traces{ID}{experiment};
        
        suppression = projectionPC >= threshold{ID}; % 1 = suppression, 0 = burst
        %suppression = imclose(suppression, ones(5,1)); %makes sure that bursts are continuous
        suppression = imopen(suppression', ones(5,1)); %gets rid of single spikes
        
        subplot(numel(allExp{ID}),1,experiment)
        plot(useTrace, 'lineWidth', 1.5)
        
        hold on;
        scatter(useTime(find(suppression)), zeros(length(find(suppression)),1), 'LineWidth',2);
    end
    linkaxes
end
%% Looking at multiple PCs 

useData = Tvalue(1,:);
 suppression = useData <= threshold; % 1 = suppression, 0 = burst
 %suppression = imclose(suppression, ones(5,1)); %makes sure that bursts are continuous
 suppression = imopen(suppression, ones(5,1)); %gets rid of single spikes
 
 useTrace =V1Traces{ID}{experiment};
 useTime = T{ID}{experiment}*sf;
 
 figure
 plot(useTrace, 'lineWidth', 1.5)
 hold on;
 scatter(useTime(find(suppression)), zeros(length(find(suppression)),1), 'LineWidth',2);
 

% scatter plot of 1st two components
figure;
scatter3(Tvalue(1,:), Tvalue(2,:), Tvalue(3,:));
axis vis3d
box on


%% Trying RMS 

RMS_win = .2; %sec
RMS_win_step = .05; %sec
sf = 1000; %samples per sec

RMS_win = RMS_win*sf;
RMS_win_step = RMS_win_step *sf;
RMS = [];

for ID = 1%:numSubjects
    for experiment = 1%:maxExposuresPerSubject
        if experiment> numel(allExp{ID})
            continue
        end
        trace = V1Traces{ID}{experiment};
        t= 1;
        while t*RMS_win_step+ RMS_win< length(trace)
            RMS{ID}{experiment}(t) = rms(trace(1+(t-1)*RMS_win_step:RMS_win+(t-1)*RMS_win_step));
            t = t+1;
        end
    end
end

figure
h1= subplot(2,1,1)
plot((0:1:length(RMS{ID}{experiment})-1)*RMS_win_step+RMS_win/2, RMS{ID}{experiment})
h2=  subplot(2,1,2)
plot(trace)
linkaxes([h1, h2],'x')








useData = RMS{ID}{experiment};
[categories, centroids] = kmeans(useData', 2); %clustering supression vs bursts in data sets with only bursts and suppressions; kmeans will tell you to find as many catagories you want, but with 2 gaus mixture
[~, minCategory] = min(centroids);  %finds larger of position along log10 power spec --> this is the burst
threshold = max(useData(categories == minCategory));  %find the power at the start of the burst
 
 suppression = useData <= threshold; % 1 = suppression, 0 = burst
 %suppression = imclose(suppression, ones(5,1)); %makes sure that bursts are continuous
 suppression = imopen(suppression, ones(5,1)); %gets rid of single spikes
 
 useTrace =V1Traces{ID}{experiment};
 useTime = RMS_win/2:RMS_win_step:(length(RMS{ID}{experiment})*RMS_win_step+RMS_win_step);
 
figure
h1= subplot(2,1,1)
plot(RMS_win/2:RMS_win_step:(length(RMS{ID}{experiment})*RMS_win_step+RMS_win_step), RMS{ID}{experiment})
h2=  subplot(2,1,2)
 plot(useTrace, 'lineWidth', 1.5)
 hold on;
 scatter(useTime(find(suppression)), zeros(length(find(suppression)),1), 'LineWidth',2);
 linkaxes([h1, h2],'x')


% scatter plot of 1st two components









%%


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
% plot(V1Traces{1}{1}, 'lineWidth', 1.5)
% 
% hold on;
% scatter(find(bursts)*(win_step*sf) + win*sf/2, zeros(length(find(bursts)),1), 'LineWidth',2);
% 
% %% Finding individual bursts - dwell times and interburst intervals 
% 
% stats = regionprops(bursts,'Area');  %stats.Area = dwell times 
% burstDwellTimes = [stats.Area];
% 
% stats = regionprops(~bursts,'Area');  %stats.Area = dwell times 
% supressionDwellTimes = [stats.Area];
% 
% bursts(1)
% 
% %%
% 
% timeLockedBursts = ones(length(timeTTL), 1) * bursts(end);
% burstData = [bursts(1) * ones(floor(win*sf/2),1); kron(bursts, ones(win_step*sf,1))];
% timeLockedBursts(1:length(burstData)) = burstData;
% 
% % burstEnds = find(diff(bursts) == -1)*(win_step*sf) + win*sf/2;
% burstEnds = find(diff(timeLockedBursts) == -1);
% 
% ttlOnset = find(timeTTL);
% 
% pulses = find(timeTTL==1);
% suppressionPulsesIndicies = find(timeLockedBursts(find(timeTTL==1)) == 0);
% suppressionPulses = pulses(suppressionPulsesIndicies);
% burstPulsesIndices = 1:length(pulses);
% burstPulsesIndices(suppressionPulsesIndicies) = [];
% burstPulses = pulses(burstPulsesIndices);
% 
% 
% timesSinceLastBurst = nan(length(suppressionPulses), 1);
% for i = 1:length(suppressionPulses)
%     latestBurst = burstEnds(find(burstEnds <= suppressionPulses(i), 1, 'last'));
%     if ~isempty(latestBurst)
%         timesSinceLastBurst(i) = suppressionPulses(i) - burstEnds(find(burstEnds <= suppressionPulses(i), 1, 'last'));
%     end
% end
% 
% %% 
% 
% [~, order] = sort(timesSinceLastBurst);
% lagSortedVEPz = squeeze(meanSubData(V1, suppressionPulsesIndicies(order), :));
% VEPsupp = squeeze(meanSubData(V1, suppressionPulsesIndicies, :));
% VEPburst = squeeze(meanSubData(V1, burstPulsesIndices, :));
% 
% %%
% UniqueTimes=unique(timesSinceLastBurst);
% UniqueTimes=UniqueTimes(~isnan(UniqueTimes));
% 
% EP=zeros(length(UniqueTimes),size(VEPsupp,2));
% 
% for i=1:length(UniqueTimes)
%     EP(i,:)=VEPsupp( find(timesSinceLastBurst==UniqueTimes(i),1, 'first'),:);
% end
% 
% %%
% tl=linspace(0, max(timesSinceLastBurst)+1, 5);
% figure;
% for i=1:length(tl)-1
%     plot(mean(VEPsupp(find(timesSinceLastBurst>tl(i) & timesSinceLastBurst<tl(i+1)),:),1), 'linewidth', 2);
%     disp(length(find(timesSinceLastBurst>tl(i) & timesSinceLastBurst<tl(i+1))));
%     hold on;
% end
% %%
% 
% category = [];
% dwellTimes = [];
% for i = 1:length(stats)
% %     category(i) = bursts(stats(i).PixelIdxList(1));
%     dwellTimes(i) = stats(i).Area;
% end
% 
% transitions=[1; find(diff(bursts))];
% if transitions(end)<length(bursts)
%    transitions=[transitions; length(bursts)];
% end
% durations=diff(transitions);
% 
% 
% 
% 
% 
% 
% 
