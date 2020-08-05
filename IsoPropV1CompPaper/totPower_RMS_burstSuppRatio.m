%% Calculating Burst Suppresion ratio
clear 
clc
close all

onAlexsWorkStation = 2; %1 if on workstation with complete multistim data set, 0 if on lab mac, 2 if on laptop

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
    dirIn = '/Users/adeetiaggarwal/Google Drive/data/matIsoPropMultiStimVIS_ONLY_/flashTrials/';
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
                
    end
end


%% Looking at spectrum
ID =1;
experiment =1;

useTrace = V1Traces{ID}{experiment};
useTime = T{ID}{experiment}*sf;

useSpectrum = rawSpectrum;

trueLowFreq = 1;
trueHighFreq  = 100;

lowFreq = find(freq>trueLowFreq, 1, 'first');
highFreq = find(freq<trueHighFreq, 1, 'last');
freqScale = lowFreq:highFreq;

figure
h1= subplot(2,1,1)
pcolor(useTime,freq(freqScale), useSpectrum{ID}{experiment}(:,freqScale)'); shading 'flat'
%pcolor(T{1}{1}*sf,freq(freqScale), 10*log10(rawSpectrum{1}{1}(:,freqScale)')); shading 'flat'
%pcolor(T{1}{1}*sf,freq(freqScale),freq(freqScale), normMeanSpectrum{1}{1}(:,freqScale)'); shading 'flat'
set(gca, 'Yscale', 'log')
colorbar
%set(gca, 'Clim', [-10 10])
title('High freq Spectrum of V1 channel')
h2= subplot(2,1,2)
plot(useTrace); colorbar
title('Raw Trace')
linkaxes([h1 h2], 'x')

%% Calculating total power metrics for each animal at each exposure
totPower = [];
useSpectrum = rawSpectrum;

for ID = 1:numSubjects
    figure
    for experiment = 1:maxExposuresPerSubject
        if experiment> numel(allExp{ID})
            continue
        end
        totPower{ID}{experiment} = sum(10*log10(useSpectrum{ID}{experiment}(:,freqScale)),2); %total power around ten, making sure its :)
        %totPower{ID}{experiment} = sum(useSpectrum{ID}{experiment}(:,freqScale),2); %total power around ten, making sure its :)
       
        subplot(2,3,experiment)
        histogram(totPower{ID}{experiment}, 100)
        title(['Experiment = ', num2str(experiment)])
    end
end

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

%% cluster spectrum into suppression periods- cluster each mouse and experiment differenetly 

% after looking at all experiments - seems like there is BS in experiments
% 1 and 4 - can use these to make the threshold for BS
bsExperiments = [1, 4];
threshold = [];

for ID = 1:numSubjects
    for experiment = 1:length(bsExperiments)
        if experiment> numel(allExp{ID})
            continue
        end
        expIndex = bsExperiments(experiment);
        useTotPower = totPower{ID}{expIndex};
        
        [categories, centroids] = kmeans(useTotPower, 2); %clustering supression vs bursts in data sets with only bursts and suppressions; kmeans will tell you to find as many catagories you want, but with 2 gaus mixture
        [~, minCategory] = min(centroids);  %finds larger of position along log10 power spec --> this is the burst
        threshold{ID}(experiment) = max(useTotPower(categories == minCategory));  %find the power at the start of the burst
    end
end


%%  Classify suppressions for each mouse based on total power 

allSuppressPower = [];

for ID = 1:numSubjects
%     figure
    for experiment = 1:maxExposuresPerSubject
        if experiment> numel(allExp{ID})
            continue
        end
        useTotPower = totPower{ID}{experiment};
        useTime = T{ID}{experiment}*sf;
        useTrace = V1Traces{ID}{experiment};
        
        suppression = useTotPower <= min(threshold{ID}); % 1 = suppression, 0 = burst
        %suppression = imclose(suppression, ones(5,1)); %makes sure that bursts are continuous
        %suppression = imopen(suppression, ones(5,1)); %gets rid of single spikes
        allSuppressPower{ID}{experiment} = suppression;
        
%         h(experiment) = subplot(numel(allExp{ID}),1,experiment);
%         plot(useTrace, 'lineWidth', 1.5)
%         
%         hold on;
%         scatter(useTime(find(suppression)), zeros(length(find(suppression)),1), 'LineWidth',2);
    end
%     linkaxes(h, 'x')
end

% this looks ok for mouse 1, highlighted a lot of delta activity in mouse
% 2, seems to highlight some delta and some highfreq in mouse 3, seems to
% pick up some delta and not highlight some long periods of suppression in
% mouse 4 esp from long high dose propofol exposure, reasonable job for
% mouse 5 although still picks up some delta, reasonable for mouse 6,
% reasonable for 7 but still picks up some delta 


%% Calculating RMS 

% Made same window size to be easy 
RMS_win = .5; %sec
RMS_win_step = .1; %sec
sf = 1000; %samples per sec

RMS_win = RMS_win*sf;
RMS_win_step = RMS_win_step *sf;
RMS = [];

RMSMouse =[];

for ID = 1:numSubjects
    temp = [];
    for experiment = 1:maxExposuresPerSubject
        if experiment> numel(allExp{ID})
            continue
        end
        trace = V1Traces{ID}{experiment};
        nSteps = round((length(trace)-RMS_win)/RMS_win_step);
        
        for t = 1:nSteps
            startHere = 1+(t-1)*RMS_win_step;
            endHere = startHere + RMS_win;
            RMS{ID}{experiment}(t) = rms(trace(startHere:endHere));
        end
        temp = [temp, RMS{ID}{experiment}];
    end
    RMSMouse{ID} = temp;
end

% looking at RMS throughout entire mouse exposure 
figure
for ID = 1:numSubjects
    h(ID)= subplot(7,1,ID);
    plot(RMSMouse{ID})
end
linkaxes(h, 'x')

%% looking at each mouse individually and finding threshold for RMS
ID = 4;
experiment = 1;

useRMS = RMS{ID}{experiment};
useTime = T{ID}{experiment}*sf;
useTrace = V1Traces{ID}{experiment};

figure
h(1) = subplot(2,1,1);
plot(useTime, useRMS)

h(2) = subplot(2,1,2);
plot(useTrace, 'lineWidth', 1.5)
linkaxes(h,'x')

% enter in manual threshold that corresponds with suppression periods 
RMSthres{1} = [50];
RMSthres{2} = [30];
RMSthres{3} = [45];
RMSthres{4} = [70];
RMSthres{5} = [55];
RMSthres{6} = [55];
RMSthres{7} = [0.02];

%% Aligning time axes for power and for RMS 
close all;
allSuppWindows = [];
bsRatio = nan(numSubjects,maxExposuresPerSubject);

for ID = 1:numSubjects
    figure
    for experiment = 1:maxExposuresPerSubject
        if experiment> numel(allExp{ID})
            continue
        end
        suppPower = allSuppressPower{ID}{experiment};
        useTime = T{ID}{experiment}*sf;
        useTrace = V1Traces{ID}{experiment};
        
        useRMS = RMS{ID}{experiment};
        suppRMS = useRMS <= RMSthres{ID};
        suppression = find([suppPower & suppRMS']);
        allSuppWindows{ID}{experiment} = suppression;
        bsRatio(ID,experiment) = length(allSuppWindows{ID}{experiment})/length(useTime);
        
        h(experiment) = subplot(numel(allExp{ID}),1,experiment);
        plot(useTrace, 'lineWidth', 1.5)
        
        hold on;
        scatter(useTime(suppression), zeros(length(suppression),1), 'LineWidth',2);
    end
    linkaxes(h,'x')
end

%% Stats on Suppression ratio

bsRatio
meanBSRatio = nanmean(bsRatio, 1)
stdBSRatio = nanstd(bsRatio, 1)
medianBSRatio = median(bsRatio, 1)
iqrBSRatio = iqr(bsRatio, 1)

figure 
for ID = 1:maxExposuresPerSubject
subplot(2,3,ID)
histogram(squeeze(bsRatio(:,ID)),6)
end

pbsRatio = kruskalwallis(bsRatio(:,1:4));
[pHIGHbsRatio, hHIGHbsRatio, stats]=ranksum(bsRatio(:,1), bsRatio(:,4));
[pLOWbsRatio, hLOWbsRatio, stats]=ranksum(bsRatio(:,2), bsRatio(:,3));

combHigh(:,2) = [bsRatio(:,1); bsRatio(:,4)];
combLow(:,2) = [bsRatio(:,2); bsRatio(:,3)];
[pConcBSRatio, hConcBSRatio, stats] = ranksum(combHigh(:,1), combLow(:,2))



