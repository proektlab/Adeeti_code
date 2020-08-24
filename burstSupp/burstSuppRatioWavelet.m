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

%% setting up for wavlet
og_sf = 1000;
dec_sf = 250; 
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
        V1Traces{ID}{experiment} = decimate(squeeze(meanSubFullTrace(V1,:)),og_sf/dec_sf);
    end
end


for ID = 1:numSubjects
    for experiment = 1: maxExposuresPerSubject
        if experiment> numel(allExp{ID})
            continue
        end
        data = V1Traces{ID}{experiment};
        disp('Wavelet on Data')
        [temp,PERIOD,SCALE,COI,DJ, PARAMOUT, K] = contwt(data, 1/dec_sf, 1, 0.25);
        rawSpectrum{ID}{experiment}=temp; %WAVE is in freq by time by channels by trials
        freq=1./PERIOD;
    end
end

%%
ID =1;
experiment =1;

useTrace = V1Traces{ID}{experiment};

useSpectrum = rawSpectrum;

trueLowFreq = 1;
trueHighFreq  = 100;

lowFreq = find(freq>trueLowFreq, 1, 'last');
highFreq = find(freq<trueHighFreq, 1, 'first');
freqScale = highFreq:lowFreq;

figure
h(1)= subplot(2,1,1)
plot(useTrace)
colorbar

h(2)= subplot(2,1,2)
pcolor(1:length(useTrace),freq(freqScale), 10*log10(abs(useSpectrum{ID}{experiment}(freqScale,:)))); shading 'flat'
set(gca, 'yscale', 'log')
colorbar

linkaxes(h, 'x')
        
%% making a porabola kernal 

porWidth= 500; % in ms

porWidth = porWidth/(og_sf/dec_sf);
halfPorWidth = round(porWidth/2);

x = -halfPorWidth:1:halfPorWidth;

startFreq = highFreq;
endFreq = 36;%lowFreq;

a = sqrt(startFreq-endFreq)/halfPorWidth;

c = endFreq;

kernal =(a*x).^2 + endFreq;

% figure
% plot(x, kernal)


mask = zeros(length(freq),length(x));
for i = 1:length(x)
    startIndex = startFreq;
    endIndex = round(kernal(i));
    
    mask(startIndex:endIndex,i) = 1;
end

imagesc(mask)
        
lowPower = convn(10*log10(abs(useSpectrum{ID}{experiment}(:,:))), mask, 'same');
lowPower = lowPower(1,:);

[categories, centroids] = kmeans(lowPower', 2); %clustering supression vs bursts in data sets with only bursts and suppressions; kmeans will tell you to find as many catagories you want, but with 2 gaus mixture
[~, minCategory] = min(centroids);  %finds larger of position along log10 power spec --> this is the burst
threshold = max(lowPower(categories == minCategory));  %find the power at the start of the burst
suppression = lowPower <= threshold; % 1 = suppression, 0 = burst 
%suppression = imclose(suppression, ones(5,1)); %makes sure that bursts are continuous
suppression = imopen(suppression', ones(125,1)); %gets rid of single spikes
        
figure
h(1)= subplot(3,1,1)
plot(useTrace)
hold on
scatter(find(suppression), zeros(length(find(suppression)),1), 'LineWidth',2);
colorbar

h(2)= subplot(3,1,2)
pcolor(1:length(useTrace),freq(freqScale), 10*log10(abs(useSpectrum{ID}{experiment}(freqScale,:)))); shading 'flat'
set(gca, 'yscale', 'log')
colorbar

h(3)= subplot(3,1,3)
plot(lowPower(1,:))
colorbar

linkaxes(h, 'x')

figure;
histogram(lowPower, 100);





        
        %%
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

