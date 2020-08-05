%% lets look at some variablity 

clear
close all

dirIn = '/synology/adeeti/ecog/iso_awake_VEPs/GL_early/';
dirout = '/synology/adeeti/ecog/images/Iso_Awake_VEPs/GL_early/VariabilityShits/';

useStimIndex = 0;
useNumStim = 1;

lowestLatVariable = 'lowLat';
stimIndex = [0, Inf];%, Inf, Inf];
%stimIndex = [0, Inf]; %if want all, stimIndex = matStimIndex; % if want
%all uniStimIndexes/multiStimIndexes, use [uniStimIndex, multiStimIndex] =
%findUniMutliStimIndex(matStimIndex), [stimIndex, ~] = findUniMutliStimIndex(matStimIndex)

numStim = 1;

cd(dirIn)
load('dataMatrixFlashes.mat')
%load('matStimIndex.mat')

%% Setting up parameters

allExp = {};

if useStimIndex ==1
    if exist('stimIndex')  && ~isempty(stimIndex)
        for i = 1:size(stimIndex,1)
            [MFE] = findMyExpMulti(dataMatrixFlashes, [], [], [], stimIndex(i,:));
            allExp{i} = MFE;
        end
    end
elseif useNumStim ==1
    if exist('numStim')  && ~isempty(numStim)
        for i = 1:size(numStim,1)
            [MFE] = findMyExpMulti(dataMatrixFlashes, [], [], [], [], numStim);
            allExp{i} = MFE;
        end
    end
else
    [MFE] = 1:length(dataMatrixFlashes);
    allExp{i} = MFE;
end

mkdir(dirout);

%% dot product measure


dotProdAvg = {}; %nan(length(allExp), length(allExp{a}), size(useMeanSubData,2), 1);%, length(info.ecogChannels));
dotProdST = {}; 
eucAvg = {}; %nan(length(allExp), length(allExp{a}), size(useMeanSubData,2), 1);%, length(info.ecogChannels));
eucST = {}; 

dotProdSpontOnly = {}; %nan(length(allExp), length(allExp{a}), size(useMeanSubData,2), 1);%, length(info.ecogChannels));
dotProdST2Spont = {}; 
eucSpontOnly = {}; %nan(length(allExp), length(allExp{a}), size(useMeanSubData,2), 1);%, length(info.ecogChannels));
eucST2Spont = {}; 


color = {};
anes = {};
expID = [];
anesCon = [];
cosAvgKet = [];
cosAvgAwake = [];
cosAvgLowIso =[];
cosAvgHighIso =[];

singleTrial = {};

EP_time = [1030:1800];
spontTime = [1:numel(EP_time)];

for a = 1:length(allExp)
    for b = 1:length(allExp{a})
        experiment = allExp{a}(b);
        load(dataMatrixFlashes(experiment).expName(end-22:end-4), 'info', 'meanSubData', 'aveTrace', 'uniqueSeries', 'indexSeries')
        if ~isfield(info, lowestLatVariable)
            disp(['No variable info.' lowestLatVariable, ' . Trying next experiment.']);
            continue
        end
        channels = info.lowLat;
        
        [indices] = getStimIndices(stimIndex, indexSeries, uniqueSeries);
        useSingleTrialEPs = squeeze(meanSubData(channels, indices,EP_time));
        useSingleTrialSpont = squeeze(meanSubData(channels, indices,spontTime));
        
        [queryIndex] = ismember(stimIndex, uniqueSeries, 'rows');
        useAvgTrace = squeeze(aveTrace(queryIndex,channels,EP_time));
        mA = nanmean(useAvgTrace);
        useAvgTrace = useAvgTrace - mA;
          
        for i = 1:size(useSingleTrialEPs,1)
            mD = nanmean(useSingleTrialEPs(i,:));
            singleTrials{a,b}(i,:) = useSingleTrialEPs(i,:) - mD;
            mS = nanmean(useSingleTrialSpont(i,:));
            spontAct{a,b}(i,:) = useSingleTrialSpont(i,:) - mS;
        end
        
        for i = 1:size(singleTrials{a,b},1)
            % distances for single trials to averages 
            dotProdAvg{a,b}(i) = pdist2(singleTrials{a,b}(i,:),useAvgTrace','cosine');
            eucAvg{a,b}(i) = pdist2(singleTrials{a,b}(i,:),useAvgTrace','euclidean');
        end 

        % distances of single trials to each other 
        dotProdST{a,b} = pdist2(singleTrials{a,b}, singleTrials{a,b},'cosine');
        eucST{a,b} = pdist2(singleTrials{a,b},singleTrials{a,b},'euclidean');
        
        % distances of spont activity to each other 
        dotProdSpontOnly{a,b} = pdist2(spontAct{a,b},spontAct{a,b},'cosine');
        eucSpontOnly{a,b} = pdist2(spontAct{a,b},spontAct{a,b},'euclidean');
        
        %distances of spont activity to single trials 
        dotProdST2Spont{a,b} = pdist2(singleTrials{a,b}, spontAct{a,b},'cosine');
        eucST2Spont{a,b} = pdist2(singleTrials{a,b},spontAct{a,b},'euclidean');
        
        
        %         f or i = 1:size(useMeanSubData,1)
        %             dotProd{a, b}(i) = useMeanSubData(i,:)*useAvgTrace;
        %         end
        
        if info.AnesLevel >= 1 && contains(info.AnesType, 'Iso', 'IgnoreCase', true)
            color{a,b} = [1 0 0]; %'r';
            anes{a,b} = info.AnesType;
            anesCon(a,b) = info.AnesLevel;
            expID(a,b) = info.exp;
            cosAvgHighIso = [cosAvgHighIso, [dotProdAvg{a,b}]];
        elseif info.AnesLevel < 1 && contains(info.AnesType, 'Iso', 'IgnoreCase', true)
            color{a,b} = [1 0 1]; %'m';
            anes{a,b} = info.AnesType;
            anesCon(a,b) = info.AnesLevel;
            expID(a,b) = info.exp;
            cosAvgLowIso = [cosAvgLowIso, [dotProdAvg{a,b}]];
        elseif info.AnesLevel < .1 && contains(info.AnesType, 'Awake', 'IgnoreCase', true)
            color{a,b} = [0 0 1]; %'b';
            anes{a,b} = info.AnesType;
            anesCon(a,b) = info.AnesLevel;
            expID(a,b) = info.exp;
            cosAvgAwake = [cosAvgAwake, [dotProdAvg{a,b}]];
        elseif info.AnesLevel > 1 && contains(info.AnesType, 'Ket', 'IgnoreCase', true)
            color{a,b} = [0 1 0]; %'g';
            anes{a,b} = info.AnesType;
            anesCon(a,b) = info.AnesLevel;
            expID(a,b) = info.exp;
            cosAvgKet = [cosAvgKet, [dotProdAvg{a,b}]];
        end
    end
end
    
        
        
figure(1)
hold on
for a = 1:length(allExp)
    for b = 1:length(allExp{a})
        plot(dotProdAvg{a,b}, 'Color', color{a,b})
    end
end


figure(2)
clf
hold on 
h(1)= subplot(4,1,1);
histogram(log10(cosAvgAwake), 50, 'normalization', 'pdf')
title('awake')
h(2)= subplot(4,1,2);
histogram(log10(cosAvgHighIso), 50, 'normalization', 'pdf')
title('high iso')
h(3)= subplot(4,1,3);
histogram(log10(cosAvgLowIso), 50, 'normalization', 'pdf')
title('low iso')
h(4)= subplot(4,1,4);
histogram(log10(cosAvgKet), 25, 'normalization', 'pdf')
title('ketamine')
linkaxes(h, 'x')
        
%% 
mouseID = 2;
drug = 'awake';


[MFE] = findMyExpMulti(dataMatrixFlashes, mouseID, drug, [], stimIndex);

a = 1;
allB = MFE;

col = nan(numel(allB)*101, 3);
useSingleTrials = [];

counter = 1;

for b = allB
    useSingleTrials = [useSingleTrials; squeeze(singleTrials{a,b})];
end

col = nan(size(useSingleTrials,1), 3);

for b = allB
    numTrials = size(squeeze(singleTrials{a,b}),1);
    col(counter:counter+numTrials-1,:,:)= repmat([color{a,b}],numTrials,1);
    counter = counter+numTrials;
end

[T,pvar,W,L] = pca_alex(useSingleTrials');

percentEx = cumsum(pvar);

figure
%col=colormap(jet(size(useSingleTrials,1)));
scatter(T(1,:), T(2,:), 30, col, 'filled')
title(['Drug: ', drug, ' ', num2str(mouseID)])

figure 
plot(percentEx);

numComp = find(percentEx>90, 1, 'first');

%awakePerv = cumsum(pvar);
%isoPerv = cumsum(pvar);

% hold on
% plot(isoPerv)


%%

a = 1;
b = 7;
experiment = allExp{a}(b);

load(dataMatrixFlashes(experiment).expName(end-22:end-4))
allStarts_ms = round([allStartTimes{1}]*1000);

begin=allStarts_ms(1);

useData = squeeze(meanSubFullTrace(info.lowLat,begin:end));


win = 10; % size of window (secs) for spectrum
win_step = 1; % size of window step (secs) for spectrum (in this case we are taking 10sec windows, stepping by 1sec)
ktapers = 5;  % number of tapers for mutlitaper analysis
NW = 2*ktapers-1;  % constant for multitaper analysis

sf = 1000;
freq = [];
T= [];
rawSpectrum = [];
normMeanSpectrum= [];


% [out,taper,concentration] = swTFspecAnalog(useData,1000,Ktapers,freqsOfInterest,window,winstep,NW,pad,taper,concentration,doAdapt,includePhase)

[out, taper, concentration]=swTFspecAnalog(useData, sf, ktapers, [], win*sf, win_step*sf, NW,[],[],[],[]); %multitaper spectral analysis on the entire length of data
spectrum=squeeze(out.tfse); % size = 1 x windows x freq; tfse = power at each freq and time point
freq=out.freq_grid; %extract freq evaluated
timeAxis = out.time_grid;


figure(4)
h(1)= subplot(2,1,1)
pcolor(timeAxis, freq, log10(spectrum')); shading flat
set(gca, 'yscale', 'log')

h(2)= subplot(2,1,2)
plot((allStarts_ms-begin)/1000, dotProd{a,b})

linkaxes(h, 'x')
sgtitle([info.AnesType, ' Con: ', num2str(info.AnesLevel), ', Exp: ', num2str(info.exp)])

%figure(5)



%%

useTrials = 1:101;

D=squareform(pdist(T(1:numComp,useTrials)'));
figure 
imagesc(D);
title(['Correlation structure Mouse ', num2str(mouseID), ' Drug: ', drug])

StepLength=30;
Correlations=nan(StepLength, length(101:202));
for i=1:StepLength
    temp=diag(D, i);
    Correlations(i,1:length(temp))=temp;
end


figure
boxplot(Correlations') 
title(['Pairwise Correlation ', num2str(mouseID), ' Drug: ', drug])
        
        
        
        
        
        
        
        