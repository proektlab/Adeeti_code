%% lets look at some variablity

clc
clear
close all

set(0,'defaultfigurecolor',[1 1 1])

if isunix && ~ismac
    dataLoc = '/synology/';
    codeLoc = '/synology/code/';
elseif ispc
    dataLoc = 'Z:\';
    codeLoc = 'Z:\code\';
end

genDirAwa = [dataLoc, 'adeeti/ecog/iso_awake_VEPs/']; %'Z:\adeeti\ecog\iso_awake_VEPs\GL_early\';

dirOut = [dataLoc, 'adeeti/ecog/images/Iso_Awake_VEPs/V1_variability/'];
mkdir(dirOut)

useStimIndex = 0;
useNumStim = 1;

lowestLatVariable = 'lowLat';
stimIndex = [0, Inf];%, Inf, Inf];

allMiceAwa = [{'goodMice'}; {'maybeMice'}];

goodMiceInd= [1:5];
maybeMiceInd = [6:11];

totMice = numel([goodMiceInd])%, maybeMiceInd]);
totTrials = 100;
colorsPlot = {'k', 'b', 'r', 'g'};
titleString = {'H. Iso', 'L. Iso', 'Awake', 'Ket'};

totCond= length(titleString);

%% Setting up parameters

useAvgTrace= {};

dotProdAvg = {}; %nan(totMice, totCond, totTrials)
dotProdST = {};
eucAvg = {}; %nan(length(allExp), length(allExp{a}), size(useMeanSubData,2), 1);%, length(info.ecogChannels));
eucST = {};

dotProdSpontOnly = {}; %nan(length(allExp), length(allExp{a}), size(useMeanSubData,2), 1);%, length(info.ecogChannels));
dotProdST2Spont = {};
eucSpontOnly = {}; %nan(length(allExp), length(allExp{a}), size(useMeanSubData,2), 1);%, length(info.ecogChannels));
eucST2Spont = {};

allDistanceMeas{1} = 'Cosine Single Trial to Average';
allDistanceMeas{2} = 'Euclidean Single Trial to Average';
allDistanceMeas{3} = 'Cosine Individual Single Trials';
allDistanceMeas{4} = 'Euclidean Individual Single Trials';
allDistanceMeas{5} = 'Cosine Individual Spontaneous Activity';
allDistanceMeas{6} = 'Euclidean Individual Spontaneous Activity';
allDistanceMeas{7} = 'Cosine Single Trial to Spontaneous Activity';
allDistanceMeas{8} = 'Euclidean Single Trial to Spontaneous Activity';


dist_cos_HighIso = {};
dist_euc_HighIso = {};
dist_cos_LowIso = {};
dist_euc_LowIso = {};
dist_cos_Ket = {};
dist_euc_Ket = {};
dist_cos_Awake = {};
dist_euc_Awake = {};%1 - cos ST and avg, 2= euc ST and Avg, 3- cos ST, 4 - euc ST, 5 - cos Spont, 6- euc Spont, 7 - cos spont and ST, 8- euc spont and ST

for i = 1:4
    dist_cos_HighIso{i} = [];
    dist_euc_HighIso{i} = [];
    dist_cos_LowIso{i} = [];
    dist_euc_LowIso{i} = [];
    dist_cos_Ket{i} = [];
    dist_euc_Ket{i} = [];
    dist_cos_Awake{i} = [];
    dist_euc_Awake{i} = [];
end


singleTrial = {};
spontAct = {};

EP_time = [1030:1800];
spontTime = [1:numel(EP_time)];


%%

mouseCounter = 0;

for g = 1%:length(allMiceAwa)
    genDirM = [genDirAwa, (allMiceAwa{g}), '/'];
    cd(genDirM)
    allDir = [dir('GL*'); dir('IP*');dir('CB*')];
    startD = 1;
    for d = startD:length(allDir)
        mouseID = allDir(d).name;
        disp(mouseID)
        dirIn = [genDirM, mouseID, '/'];
        
        mouseCounter = mouseCounter+1;
        allMiceIDs{mouseCounter} = mouseID;
        
        cd(dirIn)
        load('dataMatrixFlashes.mat')
        
        [isoHighExp, isoLowExp, emergExp, awaExp1, awaLastExp, ketExp] = ...
            findAnesArchatypeExp(dataMatrixFlashes);
        MFE = [isoHighExp, isoLowExp, awaLastExp, ketExp];
        
        trueCondCount = 0;
        for a = 1:length(MFE)
            if isnan(MFE(a))
                continue
            end
            trueCondCount = trueCondCount +1;
            experimentName = dataMatrixFlashes(MFE(a)).expName(end-22:end);
            disp(experimentName)
            
            %load data
            load(experimentName, 'info', 'meanSubData', 'aveTrace', 'uniqueSeries', 'indexSeries')
            if ~isfield(info, lowestLatVariable)
                disp(['No variable info.' lowestLatVariable, ' . Trying next experiment.']);
                continue
            end
            V1 = info.lowLat;
            
            [indices] = getStimIndices(stimIndex, indexSeries, uniqueSeries);
            useSingleTrialEPs = squeeze(meanSubData(V1, indices,EP_time));
            useSingleTrialSpont = squeeze(meanSubData(V1, indices,spontTime));
            
            [queryIndex] = ismember(stimIndex, uniqueSeries, 'rows');
            tempAvg = squeeze(aveTrace(queryIndex,V1,EP_time));
            
            %mean subtract data
            mA = nanmean(tempAvg);
            useAvgTrace{mouseCounter,a} = tempAvg - mA;
            
            for i = 1:size(useSingleTrialEPs,1)
                mD = nanmean(useSingleTrialEPs(i,:));
                singleTrials{mouseCounter,a}(i,:) = useSingleTrialEPs(i,:) - mD;
                mS = nanmean(useSingleTrialSpont(i,:));
                spontAct{mouseCounter,a}(i,:) = useSingleTrialSpont(i,:) - mS;
            end
            
            % distances for single trials to averages
            for i = 1:size(singleTrials{mouseCounter,a},1)
                dotProdAvg{mouseCounter,a}(i) = pdist2(singleTrials{mouseCounter,a}(i,:),useAvgTrace{mouseCounter,a}','cosine');
                eucAvg{mouseCounter,a}(i) = pdist2(singleTrials{mouseCounter,a}(i,:),useAvgTrace{mouseCounter,a}','euclidean');
            end
            
            % distances of single trials to each other
            dotProdST{mouseCounter,a} = pdist2(singleTrials{mouseCounter,a}, singleTrials{mouseCounter,a},'cosine');
            eucST{mouseCounter,a} = pdist2(singleTrials{mouseCounter,a},singleTrials{mouseCounter,a},'euclidean');
            
            % distances of spont activity to each other
            dotProdSpontOnly{mouseCounter,a} = pdist2(spontAct{mouseCounter,a},spontAct{mouseCounter,a},'cosine');
            eucSpontOnly{mouseCounter,a} = pdist2(spontAct{mouseCounter,a},spontAct{mouseCounter,a},'euclidean');
            
            %distances of spont activity to single trials
            dotProdST2Spont{mouseCounter,a} = pdist2(singleTrials{mouseCounter,a}, spontAct{mouseCounter,a},'cosine');
            eucST2Spont{mouseCounter,a} = pdist2(singleTrials{mouseCounter,a},spontAct{mouseCounter,a},'euclidean');
            
        end
    end
end

%% reorganizing data

for a = 1:totCond
    if a ==1
        dist_cos_HighIso{1} = [dotProdAvg{:,a}]; % cos single trial to avg
        dist_euc_HighIso{1} = [eucAvg{:,a}]; % cos single trial to avg
        
        for m = 1:size(dotProdST,1)
            dist_cos_HighIso{2} = [dist_cos_HighIso{2}, [dotProdST{m,a}(find(triu(dotProdST{m,a},1)))]'];
            dist_euc_HighIso{2} = [dist_euc_HighIso{2}, [eucST{m,a}(find(triu(eucST{m,a},1)))]'];
            
            dist_cos_HighIso{3} = [dist_cos_HighIso{3}, [dotProdSpontOnly{m,a}(find(triu(dotProdSpontOnly{m,a},1)))]'];
            dist_euc_HighIso{3} = [dist_euc_HighIso{3}, [eucSpontOnly{m,a}(find(triu(eucSpontOnly{m,a},1)))]'];
            
            dist_cos_HighIso{4} = [dist_cos_HighIso{4}, [diag(dotProdST2Spont{m,a})]'];
            dist_euc_HighIso{4} = [dist_euc_HighIso{4}, [diag(eucST2Spont{m,a})]'];
        end
        
        
    elseif a ==2
        dist_cos_LowIso{1} = [dotProdAvg{:,a}]; % cos single trial to avg
        dist_euc_LowIso{1} = [eucAvg{:,a}]; % cos single trial to avg
        
        for m = 1:size(dotProdST,1)
            dist_cos_LowIso{2} = [dist_cos_LowIso{2}, [dotProdST{m,a}(find(triu(dotProdST{m,a},1)))]'];
            dist_euc_LowIso{2} = [dist_euc_LowIso{2}, [eucST{m,a}(find(triu(eucST{m,a},1)))]'];
            
            dist_cos_LowIso{3} = [dist_cos_LowIso{3}, [dotProdSpontOnly{m,a}(find(triu(dotProdSpontOnly{m,a},1)))]'];
            dist_euc_LowIso{3} = [dist_euc_LowIso{3}, [eucSpontOnly{m,a}(find(triu(eucSpontOnly{m,a},1)))]'];
            
            dist_cos_LowIso{4} = [dist_cos_LowIso{4}, [diag(dotProdST2Spont{m,a})]'];
            dist_euc_LowIso{4} = [dist_euc_LowIso{4}, [diag(eucST2Spont{m,a})]'];
        end
        
        
    elseif a == 3
        dist_cos_Awake{1} = [dotProdAvg{:,a}]; % cos single trial to avg
        dist_euc_Awake{1} = [eucAvg{:,a}]; % cos single trial to avg
        
        for m = 1:size(dotProdST,1)
            dist_cos_Awake{2} = [dist_cos_Awake{2}, [dotProdST{m,a}(find(triu(dotProdST{m,a},1)))]'];
            dist_euc_Awake{2} = [dist_euc_Awake{2}, [eucST{m,a}(find(triu(eucST{m,a},1)))]'];
            
            dist_cos_Awake{3} = [dist_cos_Awake{3}, [dotProdSpontOnly{m,a}(find(triu(dotProdSpontOnly{m,a},1)))]'];
            dist_euc_Awake{3} = [dist_euc_Awake{3}, [eucSpontOnly{m,a}(find(triu(eucSpontOnly{m,a},1)))]'];
            
            dist_cos_Awake{4} = [dist_cos_Awake{4}, [diag(dotProdST2Spont{m,a})]'];
            dist_euc_Awake{4} = [dist_euc_Awake{4}, [diag(eucST2Spont{m,a})]'];
         end
        
        
    elseif a ==4
        dist_cos_Ket{1} = [dotProdAvg{:,a}]; % cos single trial to avg
        dist_euc_Ket{1} = [eucAvg{:,a}]; % cos single trial to avg
        
        for m = 1:size(dotProdST,1)
            dist_cos_Ket{2} = [dist_cos_Ket{2}, [dotProdST{m,a}(find(triu(dotProdST{m,a},1)))]'];
            dist_euc_Ket{2} = [dist_euc_Ket{2}, [eucST{m,a}(find(triu(eucST{m,a},1)))]'];
            
            dist_cos_Ket{3} = [dist_cos_Ket{3}, [dotProdSpontOnly{m,a}(find(triu(dotProdSpontOnly{m,a},1)))]'];
            dist_euc_Ket{3} = [dist_euc_Ket{3}, [eucSpontOnly{m,a}(find(triu(eucSpontOnly{m,a},1)))]'];
            
            dist_cos_Ket{4} = [dist_cos_Ket{4}, [diag(dotProdST2Spont{m,a})]'];
            dist_euc_Ket{4} = [dist_euc_Ket{4}, [diag(eucST2Spont{m,a})]'];
        end
    end
end


%% reorganizing data
for i = [1:4] % loop through conditions
    temp = max([numel(dist_cos_HighIso{i}), numel(dist_cos_LowIso{i}), ...
        numel(dist_cos_Awake{i}), numel(dist_cos_Ket{i})]);
    for j = 1:4
        if j ==1
            data = dist_cos_HighIso{i};
        elseif j ==2
            data = dist_cos_LowIso{i};
        elseif j == 3
            data = dist_cos_Awake{i};
        elseif j== 4
            data = dist_cos_Ket{i};
        end
        
        if i ==1
            if j ==1
                cos_ST_avg = nan(temp, 4);
            end
            cos_ST_avg(1:numel(data),j) = data;
        elseif i ==2
            if j ==1
                cos_ST_ST = nan(temp, 4);
            end
            cos_ST_ST(1:numel(data),j) = data;
        elseif i ==3
            if j ==1
                cos_Spont_Spont = nan(temp, 4);
            end
            cos_Spont_Spont(1:numel(data),j) = data;
        elseif i ==4
            if j ==1
                cos_ST_Spont = nan(temp, 4);
            end
            cos_ST_Spont(1:numel(data),j) = data;
        end
    end
    
end


anesCondLabels = {'High Iso', 'Low Iso', 'Awake', 'Ket'};

figure 
b(1) = subplot(2,2,1)
imagesc(cos_ST_avg)
title(allDistanceMeas{1})
xticklabels(anesCondLabels)
colorbar
b(2) = subplot(2,2,2)
imagesc(cos_ST_ST)
title(allDistanceMeas{3})
xticklabels(anesCondLabels)
colorbar
b(3) = subplot(2,2,3)
imagesc(cos_Spont_Spont)
title(allDistanceMeas{5})
xticklabels(anesCondLabels)
colorbar
b(4) = subplot(2,2,4)
imagesc(cos_ST_Spont)
title(allDistanceMeas{7})
xticklabels(anesCondLabels)
colorbar




%% looking at distance data individually 

%1 - cos ST and avg, 2= euc ST and Avg, 3- cos ST, 4 - euc ST, 5 - cos Spont, 6- euc Spont, 7 - cos spont and ST, 8- euc spont and ST

ff= figure(1); clf;
ff.Color= 'white';

for m = 1:totMice
    for a = 1:totCond
        h1= subplot(4,2,1);
        hold on
        plot(dotProdAvg{m,a}, 'Color', colorsPlot{a})
        title(allDistanceMeas{1})
        
        h2= subplot(4,2,2);
        hold on
        plot(eucAvg{m,a}, 'Color', colorsPlot{a})
        title(allDistanceMeas{2})
        
        h3= subplot(4,2,3);
        hold on
        plot([dotProdST{m,a}(find(triu(dotProdST{m,a},1)))]', 'Color', colorsPlot{a})
        title(allDistanceMeas{3})
        
        h4= subplot(4,2,4);
        hold on
        plot([eucST{m,a}(find(triu(eucST{m,a},1)))]', 'Color', colorsPlot{a})
        title(allDistanceMeas{4})
        
        h5= subplot(4,2,5);
        hold on
        plot([dotProdSpontOnly{m,a}(find(triu(dotProdSpontOnly{m,a},1)))]', 'Color', colorsPlot{a})
        title(allDistanceMeas{5})
        
        h6= subplot(4,2,6);
        hold on
        plot([eucSpontOnly{m,a}(find(triu(eucSpontOnly{m,a},1)))]', 'Color', colorsPlot{a})
        title(allDistanceMeas{6})

        h7= subplot(4,2,7);
        hold on
        plot([diag(dotProdST2Spont{m,a})]', 'Color', colorsPlot{a})
        title(allDistanceMeas{7})
        
        h8= subplot(4,2,8);
        hold on
        plot([diag(eucST2Spont{m,a})]', 'Color', colorsPlot{a})
        legend(titleString)
        title(allDistanceMeas{8})
    end
end

%% looking at distributions

anesCondLabels = {'High Iso', 'Low Iso', 'Awake', 'Ketamine'};
condTitles = {allDistanceMeas{1}, allDistanceMeas{3}, allDistanceMeas{5}, allDistanceMeas{7}};
cond = 3;

ff= figure; clf;
ff.Color= 'white';
clf
hold on
g(1)= subplot(4,2,1);
histogram(log10(dist_cos_HighIso{cond}), 50, 'normalization', 'pdf')
title([anesCondLabels{1}, ' Log10'])
g(2)= subplot(4,2,3);
histogram(log10(dist_cos_LowIso{cond}), 50, 'normalization', 'pdf')
title([anesCondLabels{2}, ' Log10'])
g(3)= subplot(4,2,5);
histogram(log10(dist_cos_Awake{cond}), 50, 'normalization', 'pdf')
title([anesCondLabels{3}, ' Log10'])
g(4)= subplot(4,2,7);
histogram(log10(dist_cos_Ket{cond}), 50, 'normalization', 'pdf')
title([anesCondLabels{4}, ' Log10'])

g(2)= subplot(4,2,2);
histogram(dist_cos_HighIso{cond}, 50, 'normalization', 'pdf')
title(anesCondLabels{1})
g(4)= subplot(4,2,4);
histogram(dist_cos_LowIso{cond}, 50, 'normalization', 'pdf')
title(anesCondLabels{2})
g(6)= subplot(4,2,6);
histogram(dist_cos_Awake{cond}, 50, 'normalization', 'pdf')
title(anesCondLabels{3})
g(8)= subplot(4,2,8);
histogram(dist_cos_Ket{cond}, 50, 'normalization', 'pdf')
title(anesCondLabels{4})
%linkaxes(g, 'x')
sgtitle(condTitles{cond})



%% looking at box plots

anesCondLabels = {'High Iso', 'Low Iso','Awake', 'Ketamine'};

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
pST_avg = kruskalwallis(cos_ST_avg(:,1:4),[],'off');  %chi square - 768.31 p-value = 4.7481e-164

[pRankSum_pST_avg(1), h, stats]=ranksum(cos_ST_avg(:,1), cos_ST_avg(:,2))  
[pRankSum_pST_avg(2), h, stats]=ranksum(cos_ST_avg(:,1), cos_ST_avg(:,3))  
[pRankSum_pST_avg(3), h, stats]=ranksum(cos_ST_avg(:,1), cos_ST_avg(:,4))
[pRankSum_pST_avg(4), h, stats]=ranksum(cos_ST_avg(:,2), cos_ST_avg(:,3))
[pRankSum_pST_avg(5), h, stats]=ranksum(cos_ST_avg(:,2), cos_ST_avg(:,4))
[pRankSum_pST_avg(6), h, stats]=ranksum(cos_ST_avg(:,3), cos_ST_avg(:,4))

%pRankSum_pST_avg = 1.0e-05 * [0.0378    0.0000    0.0000    0.0000
%0.1102    0.0000]

% ST to ST 
pST_ST = kruskalwallis(cos_ST_ST(:,1:4),[],'off');  %chi square - 32274.87 p-value = 0

[pRankSum_pST_ST(1), h, stats]=ranksum(cos_ST_ST(:,1), cos_ST_ST(:,2))  
[pRankSum_pST_ST(2), h, stats]=ranksum(cos_ST_ST(:,1), cos_ST_ST(:,3))  
[pRankSum_pST_ST(3), h, stats]=ranksum(cos_ST_ST(:,1), cos_ST_ST(:,4))
[pRankSum_pST_ST(4), h, stats]=ranksum(cos_ST_ST(:,2), cos_ST_ST(:,3))
[pRankSum_pST_ST(5), h, stats]=ranksum(cos_ST_ST(:,2), cos_ST_ST(:,4))
[pRankSum_pST_ST(6), h, stats]=ranksum(cos_ST_ST(:,3), cos_ST_ST(:,4))

%pRankSum_pST_ST =1.0e-125 * [0.5869     0     0     0     0    0] 

% Spont to Spont 
pSpont_Spont = kruskalwallis(cos_Spont_Spont);  %chi square - 110.707 p-value = 1.05999e-23

[pRankSum_Spont_Spont(1), h, stats]=ranksum(cos_Spont_Spont(:,1), cos_Spont_Spont(:,2))  
[pRankSum_Spont_Spont(2), h, stats]=ranksum(cos_Spont_Spont(:,1), cos_Spont_Spont(:,3))  
[pRankSum_Spont_Spont(3), h, stats]=ranksum(cos_Spont_Spont(:,1), cos_Spont_Spont(:,4))
[pRankSum_Spont_Spont(4), h, stats]=ranksum(cos_Spont_Spont(:,2), cos_Spont_Spont(:,3))
[pRankSum_Spont_Spont(5), h, stats]=ranksum(cos_Spont_Spont(:,2), cos_Spont_Spont(:,4))
[pRankSum_Spont_Spont(6), h, stats]=ranksum(cos_Spont_Spont(:,3), cos_Spont_Spont(:,4))

%pRankSum_Spont_Spont = [0.0000    0.0000    0.0000    0.1587    0.7180
%0.0542]

% ST to Spont 
pST_Spont= kruskalwallis(cos_ST_Spont);  %chi square - 2.48 p-value = 0.4786




    
    
