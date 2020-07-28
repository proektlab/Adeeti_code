%% How often is the first mode in the SVD the most that is most Visually evoked on a ST basis 

clear
close all
clc

if isunix
    dirIn = '/synology/adeeti/spatialParamWaves/Awake/';
    dirPic = '/synology/adeeti/spatialParamWaves/images/SVD/';
elseif ispc
    dirIn = 'Z:/adeeti/spatialParamWaves/Awake/';
    dirPic = 'Z:\adeeti\spatialParamWaves\images\SVD\';
end

fs = 1000;
testTime = 300;
baselineStart = 100;
epStart = 500;
allMice = [6, 9, 13];

Stim = epStart;
Dur = testTime;
Win = 30;
Thresh = 3;
N_S = 10;
rearrange2Gr = 1;

%%
anesString = {'High Isoflurane', 'Low Isoflurane', 'Awake', 'Ketamine'};
shortAnesString = {'HIso', 'LIso', 'Awa', 'Ket'};

baselineTime= baselineStart:baselineStart+testTime;
epTime = epStart:epStart+testTime;

mkdir(dirPic)

cd(dirIn)
allData = dir('gab*.mat');
load('dataMatrixFlashes.mat')
spModes = [];

allMostSenResp= nan(length(allMice), length(shortAnesString),100);
allNoSensResp = nan(length(allMice), length(shortAnesString),100);
%%
for mouseID = 1:length(allMice) %1=GL6, 2=GL9, 3=GL13
    %a = 2; %1 = high iso, 2 = low iso, 3 = awake, 4 = ket
    
    [isoHighExp, isoLowExp, emergExp, awaExp1, awaLastExp, ketExp] = ...
        findAnesArchatypeExp(dataMatrixFlashes, allMice(mouseID));
    
    MFE = [isoHighExp, isoLowExp, awaLastExp, ketExp];

    
    %% load data and rearranage for SVD on interpolated data
    for experiment = 1:length(MFE)
        if isnan(MFE(experiment))
            disp(['No experiment for', anesString{experiment}]);
            continue
        end
        
        disp(allData(MFE(experiment)).name)
        load(allData(MFE(experiment)).name, 'info', 'interp1STs_long')
        useData = interp1STs_long;
        
        interpBy = 1;
        for tr = 1:size(useData,1)
            disp(['trial: ', num2str(tr)]);
            [concatChanTimeData, interpGridInd, interpNoiseInd, interpNoiseGrid] = ...
                makeInterpGridInd(squeeze(useData(tr,:,:,:)), interpBy, info);
            
            %% finding SVD of interpolated ata
            
            badChan = interpNoiseInd; %becuase interp
            numChan = size(concatChanTimeData, 1);
            
            [SVDout, SpatialAmp, SpatialPhase, TemporalAmp, TemporalPhase,GridOut ] = ...
                WaveSVD(concatChanTimeData, N_S, rearrange2Gr, interpGridInd, badChan, numChan);
            
            [RMS, ZRMS, binSensAct, mostSenResp] = TemporalImportance(TemporalAmp,Stim,Dur, Win, Thresh);
            
            if sum(binSensAct) ==0
                allNoSensResp(mouseID, experiment,tr) = 1;
            else 
                allNoSensResp(mouseID, experiment,tr) = 0;
            end 
            
            
            allMostSenResp(mouseID, experiment,tr) = mostSenResp;
        end
    end
end

%% 
m1c = 'b';
m2c = 'g';
m3c = 'r';
plotColors = {m1c, m2c, m3c};

concatMostSenResp = [];
firstModeMost = [];
numBoot = 100;

for i = 1:length(MFE)
    concatMostSenResp(i,:) = reshape(squeeze(allMostSenResp(:,i,:)), [1,size(allMostSenResp,1)*size(allMostSenResp,3)]);
    for b = 1:numBoot
        boot_ind  = randsample(size(allMostSenResp, 3),size(allMostSenResp, 3), true);
        for mouseID = 1:length(allMice)
            useModes = squeeze(allMostSenResp(mouseID,i,boot_ind));
            firstModes = zeros(size(useModes));
            firstModes(find(useModes== 1)) =1;
            firstModeMost(mouseID,i,b) = nanmean(firstModes);
            
            %tempNoSenAct =
            %noSensAct(mouseID,i,b) = nanmean(firstModes);
        end
    end
end

figure;  violinplot(concatMostSenResp', anesString)
%%
figure 
for i = 1:length(MFE)
subplot(1,4,i)
histogram(concatMostSenResp(i,:), 'normalization', 'probability')
set(gca, 'ylim', [0,0.4])
title(anesString{i})
xlabel('SVD modes')
ylabel('Probability Sensory Resp')
end

%%
%figure;  boxplot(concatMostSenResp', anesString)
figure
hold on

for mouseID = 1:3
plot(squeeze(firstModeMost(mouseID,:,1)), [plotColors{mouseID},'*'])
xticks(1:4)
xticklabels(anesString)
end

for mouseID = 1:3
plot(squeeze(firstModeMost(mouseID,:,2:end)), [plotColors{mouseID},'*'])
xticks(1:4)
xticklabels(anesString)
end

legend({'GL6', 'GL9', 'GL13'})
xlabel('Anes Exp')
ylabel('Prop that most sensory respon mode is first mode SVD')

%%

concatNoSenResp = [];
numBoot = 100;

for i = 1:length(MFE)
    concatNoSenResp(i,:) = reshape(squeeze(allNoSensResp(:,i,:)), [1,size(allNoSensResp,1)*size(allNoSensResp,3)]);
    for b = 1:numBoot
        boot_ind  = randsample(size(allNoSensResp, 3),size(allNoSensResp, 3), true);
        for mouseID = 1:length(allMice)
            noModes = squeeze(allNoSensResp(mouseID,i,boot_ind));

            noModesProb(mouseID,i,b) = nanmean(noModes);
            
            %tempNoSenAct =
            %noSensAct(mouseID,i,b) = nanmean(firstModes);
        end
    end
end


for i = 1:length(MFE)
    concatNoModes(i,:) = reshape(squeeze(noModesProb(:,i,:)), [1,size(noModesProb,1)*size(noModesProb,3)]);
end


figure; 
subplot(1,2,1)
boxplot(concatNoModes', anesString)
ylabel('Prob that no Vis resp modes are detected')
subplot(1,2,2)
violinplot(concatNoModes', anesString)
ylabel('Prob that no Vis resp modes are detected')

%%

% plotColors = {'k', 'b', 'r', 'g'};
% shortAnesString = {'HIso', 'LIso', 'Awa', 'Ket'};
% counter = 0
% figure
% for mouseID = 1:length(allMice) 
%     for experiment = 1:length(shortAnesString)
%         counter = counter +1;
%         plot(squeeze(allExpVar(mouseID,experiment,1:10))', plotColors{experiment});
%         hold on
%     end
% end
% 
% xlabel('SVD mode')
% ylabel('% variance explained')
% legend(shortAnesString)
% title('SVD modes explained of average')