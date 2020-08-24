%% lets look at some variablity 

clear
close all

set(0,'defaultfigurecolor',[1 1 1])

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

allDistanceMeas{1} = 'Cosine Single Trial to Average';
allDistanceMeas{2} = 'Euclidean Single Trial to Average';
allDistanceMeas{3} = 'Cosine Invdidual Single Trials';
allDistanceMeas{4} = 'Euclidean Invdidual Single Trials';
allDistanceMeas{5} = 'Cosine Invdidual Spontaneous Activity';
allDistanceMeas{6} = 'Euclidean Invdidual Spontaneous Activity';
allDistanceMeas{7} = 'Cosine Single Trial to Spontaneous Activity';
allDistanceMeas{8} = 'Euclidean Single Trial to Spontaneous Activity';


dist_HighIso = {}; %1 - cos ST and avg, 2= euc ST and Avg, 3- cos ST, 4 - euc ST, 5 - cos Spont, 6- euc Spont, 7 - cos spont and ST, 8- euc spont and ST
for i = 1:8
    dist_HighIso{i}= [];
end

dist_LowIso = {};
for i = 1:8
    dist_LowIso{i}= [];
end


dist_Ket = {};
for i = 1:8
    dist_Ket{i}= [];
end

dist_Awake = {};
for i = 1:8
    dist_Awake{i}= [];
end

singleTrial = {};
spontAct = {};

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
            
            dist_HighIso{1} = [dist_HighIso{1}, [dotProdAvg{a,b}]]; % cos single trial to avg
            dist_HighIso{2} = [dist_HighIso{2}, [eucAvg{a,b}]];
            
            dist_HighIso{3} = [dist_HighIso{3}, [dotProdST{a,b}(find(triu(dotProdST{a,b},1)))]'];
            dist_HighIso{4} = [dist_HighIso{4}, [eucST{a,b}(find(triu(eucST{a,b},1)))]'];
            
            dist_HighIso{5} = [dist_HighIso{5}, [dotProdSpontOnly{a,b}(find(triu(dotProdSpontOnly{a,b},1)))]'];
            dist_HighIso{6} = [dist_HighIso{6}, [eucSpontOnly{a,b}(find(triu(eucSpontOnly{a,b},1)))]'];
            
            dist_HighIso{7} = [dist_HighIso{7}, [diag(dotProdST2Spont{a,b})]'];
            dist_HighIso{8} = [dist_HighIso{8}, [diag(eucST2Spont{a,b})]'];
            
            
        elseif info.AnesLevel < 1 && contains(info.AnesType, 'Iso', 'IgnoreCase', true)
            color{a,b} = [1 0 1]; %'m';
            anes{a,b} = info.AnesType;
            anesCon(a,b) = info.AnesLevel;
            expID(a,b) = info.exp;
            
            dist_LowIso{1} = [dist_LowIso{1}, [dotProdAvg{a,b}]]; % cos single trial to avg
            dist_LowIso{2} = [dist_LowIso{2}, [eucAvg{a,b}]];
            
            dist_LowIso{3} = [dist_LowIso{3}, [dotProdST{a,b}(find(triu(dotProdST{a,b},1)))]'];
            dist_LowIso{4} = [dist_LowIso{4}, [eucST{a,b}(find(triu(eucST{a,b},1)))]'];
            
            dist_LowIso{5} = [dist_LowIso{5}, [dotProdSpontOnly{a,b}(find(triu(dotProdSpontOnly{a,b},1)))]'];
            dist_LowIso{6} = [dist_LowIso{6}, [eucSpontOnly{a,b}(find(triu(eucSpontOnly{a,b},1)))]'];
            
            dist_LowIso{7} = [dist_LowIso{7}, [diag(dotProdST2Spont{a,b})]'];
            dist_LowIso{8} = [dist_LowIso{8}, [diag(eucST2Spont{a,b})]'];
            
        elseif info.AnesLevel < .1 && contains(info.AnesType, 'Awake', 'IgnoreCase', true)
            color{a,b} = [0 0 1]; %'b';
            anes{a,b} = info.AnesType;
            anesCon(a,b) = info.AnesLevel;
            expID(a,b) = info.exp;
            
            dist_Awake{1} = [dist_Awake{1}, [dotProdAvg{a,b}]]; % cos single trial to avg
            dist_Awake{2} = [dist_Awake{2}, [eucAvg{a,b}]];
            
            dist_Awake{3} = [dist_Awake{3}, [dotProdST{a,b}(find(triu(dotProdST{a,b},1)))]'];
            dist_Awake{4} = [dist_Awake{4}, [eucST{a,b}(find(triu(eucST{a,b},1)))]'];
            
            dist_Awake{5} = [dist_Awake{5}, [dotProdSpontOnly{a,b}(find(triu(dotProdSpontOnly{a,b},1)))]'];
            dist_Awake{6} = [dist_Awake{6}, [eucSpontOnly{a,b}(find(triu(eucSpontOnly{a,b},1)))]'];
            
            dist_Awake{7} = [dist_Awake{7}, [diag(dotProdST2Spont{a,b})]'];
            dist_Awake{8} = [dist_Awake{8}, [diag(eucST2Spont{a,b})]'];
            
        elseif info.AnesLevel > 1 && contains(info.AnesType, 'Ket', 'IgnoreCase', true)
            color{a,b} = [0 1 0]; %'g';
            anes{a,b} = info.AnesType;
            anesCon(a,b) = info.AnesLevel;
            expID(a,b) = info.exp;
            
            dist_Ket{1} = [dist_Ket{1}, [dotProdAvg{a,b}]]; % cos single trial to avg
            dist_Ket{2} = [dist_Ket{2}, [eucAvg{a,b}]];
            
            dist_Ket{3} = [dist_Ket{3}, [dotProdST{a,b}(find(triu(dotProdST{a,b},1)))]'];
            dist_Ket{4} = [dist_Ket{4}, [eucST{a,b}(find(triu(eucST{a,b},1)))]'];
            
            dist_Ket{5} = [dist_Ket{5}, [dotProdSpontOnly{a,b}(find(triu(dotProdSpontOnly{a,b},1)))]'];
            dist_Ket{6} = [dist_Ket{6}, [eucSpontOnly{a,b}(find(triu(eucSpontOnly{a,b},1)))]'];
            
            dist_Ket{7} = [dist_Ket{7}, [diag(dotProdST2Spont{a,b})]'];
            dist_Ket{8} = [dist_Ket{8}, [diag(eucST2Spont{a,b})]'];
            
        end
    end
end

%%

%1 - cos ST and avg, 2= euc ST and Avg, 3- cos ST, 4 - euc ST, 5 - cos Spont, 6- euc Spont, 7 - cos spont and ST, 8- euc spont and ST
        
ff= figure(1); clf;
ff.Color= 'white';

h1= subplot(4,2,1);
hold on
for a = 1:length(allExp)
    for b = 1:length(allExp{a})
        plot(dotProdAvg{a,b}, 'Color', color{a,b})
    end
end
title(allDistanceMeas{1})

h2= subplot(4,2,2);
hold on
for a = 1:length(allExp)
    for b = 1:length(allExp{a})
        plot(eucAvg{a,b}, 'Color', color{a,b})
    end
end
title(allDistanceMeas{2})

h3= subplot(4,2,3);
hold on
for a = 1:length(allExp)
    for b = 1:length(allExp{a})
        plot([dotProdST{a,b}(find(triu(dotProdST{a,b},1)))]', 'Color', color{a,b})
    end
end
title(allDistanceMeas{3})

h4= subplot(4,2,4);
hold on
for a = 1:length(allExp)
    for b = 1:length(allExp{a})
        plot([eucST{a,b}(find(triu(eucST{a,b},1)))]', 'Color', color{a,b})
    end
end
title(allDistanceMeas{4})

h5= subplot(4,2,5);
hold on
for a = 1:length(allExp)
    for b = 1:length(allExp{a})
        plot([dotProdSpontOnly{a,b}(find(triu(dotProdSpontOnly{a,b},1)))]', 'Color', color{a,b})
    end
end
title(allDistanceMeas{5})

h6= subplot(4,2,6);
hold on
for a = 1:length(allExp)
    for b = 1:length(allExp{a})
        plot([eucSpontOnly{a,b}(find(triu(eucSpontOnly{a,b},1)))]', 'Color', color{a,b})
    end
end
title(allDistanceMeas{6})


h7= subplot(4,2,7);
hold on
for a = 1:length(allExp)
    for b = 1:length(allExp{a})
        plot([diag(dotProdST2Spont{a,b})]', 'Color', color{a,b})
    end
end
title(allDistanceMeas{7})

h8= subplot(4,2,8);
hold on
for a = 1:length(allExp)
    for b = 1:length(allExp{a})
        plot([diag(eucST2Spont{a,b})]', 'Color', color{a,b})
    end
end
title(allDistanceMeas{8})



%%

cond = 8

ff= figure; clf;
ff.Color= 'white';
clf
hold on 
h(1)= subplot(4,1,1);
histogram(log10(dist_Awake{cond}), 50, 'normalization', 'pdf')
title('awake')
h(2)= subplot(4,1,2);
histogram(log10(dist_HighIso{cond}), 50, 'normalization', 'pdf')
title('high iso')
h(3)= subplot(4,1,3);
histogram(log10(dist_LowIso{cond}), 50, 'normalization', 'pdf')
title('low iso')
h(4)= subplot(4,1,4);
histogram(log10(dist_Ket{cond}), 25, 'normalization', 'pdf')
title('ketamine')
linkaxes(h, 'x')
sgtitle(allDistanceMeas{cond})
        
%% 
mouseID = 2%[];%2;
drug = [];%'awake';

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

ff = figure; clf;
ff.Color = 'white';
%col=colormap(jet(size(useSingleTrials,1)));
scatter3(T(1,:), T(2,:), T(3,:), 30, col, 'filled')
box on
title(['Drug: ', drug, ' ', num2str(mouseID)])


%%

a = 1;
mouseID = [];%2;
drug{1} = 'Isoflurane';
drug{2} = 'Awake';
drug{3} = 'Ketamine';

colorDrug{1} = [1 0 1]; %'m';
colorDrug{2} = [0 0 1]; %'b';
colorDrug{3} = [0 1 0]; %'g';

percentEx = {};

for d = 1:length(drug)
    [MFE] = findMyExpMulti(dataMatrixFlashes, mouseID, drug{d}, [], stimIndex);
    allB = MFE;
    useSingleTrials = [];
    for b = allB
        useSingleTrials = [useSingleTrials; squeeze(singleTrials{a,b})];
    end
    [T,pvar,W,L] = pca_alex(useSingleTrials');
    percentEx{d} = cumsum(pvar);
end

ff = figure;
ff.Color = 'white';
for d = 1:length(drug)
    hold on
plot(percentEx{d}, 'color', colorDrug{d}, 'linewidth', 2);
end
set(gca, 'xlim', [0 60])
xlabel('Number of Principle Components')
ylabel('Percent Variance Explained')
sgtitle('Dimentionality reduction of single trial VEPs')
legend(drug)
%%
numComp = find(percentEx>90, 1, 'first');

%awakePerv = cumsum(pvar);
%isoPerv = cumsum(pvar);

% hold on
% plot(isoPerv)



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
        
        
        
        