%% lets look at some variablity

clc
clear
close all

set(0,'defaultfigurecolor',[1 1 1])

dirAwake = '/synology/adeeti/ecog/iso_awake_VEPs/'; %'Z:\adeeti\ecog\iso_awake_VEPs\GL_early\';

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

useAvgTrace= {};

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
allDistanceMeas{3} = 'Cosine Individual Single Trials';
allDistanceMeas{4} = 'Euclidean Individual Single Trials';
allDistanceMeas{5} = 'Cosine Individual Spontaneous Activity';
allDistanceMeas{6} = 'Euclidean Individual Spontaneous Activity';
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
        tempAvg = squeeze(aveTrace(queryIndex,channels,EP_time));
        mA = nanmean(tempAvg);
        useAvgTrace{a,b} = tempAvg - mA;
        
        for i = 1:size(useSingleTrialEPs,1)
            mD = nanmean(useSingleTrialEPs(i,:));
            singleTrials{a,b}(i,:) = useSingleTrialEPs(i,:) - mD;
            mS = nanmean(useSingleTrialSpont(i,:));
            spontAct{a,b}(i,:) = useSingleTrialSpont(i,:) - mS;
        end
        
        for i = 1:size(singleTrials{a,b},1)
            % distances for single trials to averages
            dotProdAvg{a,b}(i) = pdist2(singleTrials{a,b}(i,:),useAvgTrace{a,b}','cosine');
            eucAvg{a,b}(i) = pdist2(singleTrials{a,b}(i,:),useAvgTrace{a,b}','euclidean');
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




%% reorganizing data
for i = [1:8] % loop through conditions
    temp = max([numel(dist_Awake{i}), numel(dist_HighIso{i}), numel(dist_LowIso{i}), numel(dist_Ket{i})]);
    
    for j = 1:4
        if j ==1
            data = dist_Awake{i};
        elseif j ==2
            data = dist_HighIso{i};
        elseif j == 3
            data = dist_LowIso{i};
        elseif j== 4
            data = dist_Ket{i};
        end
        
        if i ==1
            if j == 1
                cos_ST_avg = nan(temp, 4);
            end
            cos_ST_avg(1:numel(data),j) = data;
        elseif i ==3
            if j == 1
                cos_ST_ST = nan(temp, 4);
            end
            cos_ST_ST(1:numel(data),j) = data;
        elseif i ==5
            if j == 1
                cos_Spont_Spont = nan(temp, 4);
            end
            cos_Spont_Spont(1:numel(data),j) = data;
        elseif i ==7
            if j == 1
                cos_ST_Spont = nan(temp, 4);
            end
            cos_ST_Spont(1:numel(data),j) = data;
        end
    end
    
end


anesCondLabels = {'Awake', 'High Iso', 'Low Iso', 'Ketamine'};

figure 
subplot(2,2,1)
imagesc(cos_ST_avg)
title(allDistanceMeas{1})
subplot(2,2,2)
imagesc(cos_ST_ST)
title(allDistanceMeas{3})
subplot(2,2,3)
imagesc(cos_Spont_Spont)
title(allDistanceMeas{5})
subplot(2,2,4)
imagesc(cos_ST_avg)
title(allDistanceMeas{7})


%% looking at distance data individually 

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



%% looking at distributions

anesCondLabels = {'Awake', 'High Iso', 'Low Iso', 'Ketamine'};
cond = 3;

ff= figure; clf;
ff.Color= 'white';
clf
hold on
h(1)= subplot(4,1,1);
histogram(log10(dist_Awake{cond}), 50, 'normalization', 'pdf')
title(anesCondLabels{1})
h(2)= subplot(4,1,2);
histogram(log10(dist_HighIso{cond}), 50, 'normalization', 'pdf')
title(anesCondLabels{2})
h(3)= subplot(4,1,3);
histogram(log10(dist_LowIso{cond}), 50, 'normalization', 'pdf')
title(anesCondLabels{3})
h(4)= subplot(4,1,4);
histogram(log10(dist_Ket{cond}), 25, 'normalization', 'pdf')
title(anesCondLabels{4})
linkaxes(h, 'x')
sgtitle(allDistanceMeas{cond})



%% looking at box plots

anesCondLabels = {'Awake', 'High Iso', 'Low Iso', 'Ketamine'};

figure
subplot(1, 4, 1)
boxplot(cos_ST_avg, 'notch', 'on','Labels', anesCondLabels)
ylabel('Cosine Distance', 'FontSize', 16)
xlabel('Anesthetic Exposure', 'FontSize', 16)
title(allDistanceMeas{1}(8:end))

subplot(1, 4, 2)
boxplot(cos_ST_ST, 'notch', 'on','Labels', anesCondLabels)
ylabel('Cosine Distance', 'FontSize', 16)
xlabel('Anesthetic Exposure', 'FontSize', 16)
title(allDistanceMeas{3}(8:end))

subplot(1, 4, 3)
boxplot(cos_Spont_Spont, 'notch', 'on','Labels', anesCondLabels)
ylabel('Cosine Distance', 'FontSize', 16)
xlabel('Anesthetic Exposure', 'FontSize', 16)
title(allDistanceMeas{5}(8:end))


subplot(1, 4, 4)
boxplot(cos_ST_Spont, 'notch', 'on','Labels', anesCondLabels)
ylabel('Cosine Distance', 'FontSize', 16)
xlabel('Anesthetic Exposure', 'FontSize', 16)
title(allDistanceMeas{7}(8:end))

%% Stats 

% ST to avg 
pST_avg = kruskalwallis(cos_ST_avg(:,1:4));  %chi square - 449.75 p-value = 3.6964e-97

[pRankSum_pST_avg(1), h, stats]=ranksum(cos_ST_avg(:,1), cos_ST_avg(:,2))  
[pRankSum_pST_avg(2), h, stats]=ranksum(cos_ST_avg(:,1), cos_ST_avg(:,3))  
[pRankSum_pST_avg(3), h, stats]=ranksum(cos_ST_avg(:,1), cos_ST_avg(:,4))
[pRankSum_pST_avg(4), h, stats]=ranksum(cos_ST_avg(:,2), cos_ST_avg(:,3))
[pRankSum_pST_avg(5), h, stats]=ranksum(cos_ST_avg(:,2), cos_ST_avg(:,4))
[pRankSum_pST_avg(6), h, stats]=ranksum(cos_ST_avg(:,3), cos_ST_avg(:,4))

%pRankSum_pST_avg = 1.0e-08 *[0.0000    0.0000    0.5613    0.0002    0.0000    0.0000]

% ST to ST 
pST_ST = kruskalwallis(cos_ST_ST(:,1:4));  %chi square - 17464 p-value = 0

[pRankSum_pST_ST(1), h, stats]=ranksum(cos_ST_ST(:,1), cos_ST_ST(:,2))  
[pRankSum_pST_ST(2), h, stats]=ranksum(cos_ST_ST(:,1), cos_ST_ST(:,3))  
[pRankSum_pST_ST(3), h, stats]=ranksum(cos_ST_ST(:,1), cos_ST_ST(:,4))
[pRankSum_pST_ST(4), h, stats]=ranksum(cos_ST_ST(:,2), cos_ST_ST(:,3))
[pRankSum_pST_ST(5), h, stats]=ranksum(cos_ST_ST(:,2), cos_ST_ST(:,4))
[pRankSum_pST_ST(6), h, stats]=ranksum(cos_ST_ST(:,3), cos_ST_ST(:,4))

%pRankSum_pST_ST = 1.0e-174 *[0         0    0.0000    0.1889         0         0]

% Spont to Spont 
pSpont_Spont = kruskalwallis(cos_Spont_Spont(:,1:4));  %chi square - 6.58 p-value = 0.866

% ST to Spont 
pST_Spont= kruskalwallis(cos_ST_Spont(:,1:4));  %chi square - 1.99 p-value = 0.5755


%%






RMS






