%% single trials distance with each other

clear
clc
close all

if isunix ==1 && ismac ==0
    dirIn = '/synology/adeeti/ecog/iso_awake_VEPs/goodMice/CB3/';
    emergInd = 3;
    lowIsoInd = 2;
    awakeInd1 = 4;
    awakeInd2 = 5;
elseif ispc ==1
    dirIn = 'Z:\adeeti\ecog\iso_awake_VEPs\goodMice\CB3\';
    emergInd = 3;
    lowIsoInd = 2;
    awakeInd1 = 4;
    awakeInd2 = 5;
elseif ismac ==1
    dirIn = '/Users/adeetiaggarwal/Desktop/CB3/';
    emergInd = 2;
    lowIsoInd = 1;
    awakeInd1 = 3;
    
end

cd(dirIn)
identifier = '2020*';
allData = dir(identifier);

% loading data
load(allData(emergInd).name, 'meanSubData', 'info')
emgMeanSubData = meanSubData;
avgEmg = squeeze(nanmean(emgMeanSubData,2));
load(allData(lowIsoInd).name, 'meanSubData', 'info')
lowIsoMeanSubData = meanSubData;
avgIso = squeeze(nanmean(lowIsoMeanSubData,2));
load(allData(awakeInd1).name, 'meanSubData', 'info')
awake1MeanSubData = meanSubData;
avgAwake1 = squeeze(nanmean(awake1MeanSubData,2));
if exist('awakeInd2')
    load(allData(awakeInd2).name, 'meanSubData', 'info')
    awake2MeanSubData = meanSubData;
    avgAwake2 = squeeze(nanmean(awake2MeanSubData,2));
end


%% extract V1 data, mean subtract
timeFrame = 1020:1350;

emergV1 = squeeze(emgMeanSubData(info.lowLat,:,timeFrame));
emergV1_ms = emergV1 - repmat(mean(emergV1,2), 1, size(emergV1,2));


window = 3;
for i = 1:size(emergV1_ms,1)
    emergV1_dc(i,:) = decimate(emergV1_ms(i,:),4);
end

for i = 1:size(emergV1_ms,1)
    if i <=size(emergV1_ms,1)-window
        slide_emergST(i,:) = mean(emergV1_ms(i:i+window,:),1);
        slide_emergDC(i,:) = mean(emergV1_dc(i:i+window,:),1);
    end
end

isoV1 = squeeze(lowIsoMeanSubData(info.lowLat,:,timeFrame));
isoV1_ms = isoV1 - repmat(mean(isoV1,2), 1, size(isoV1,2));

for i = 1:size(isoV1_ms,1)
    isoV1_dc(i,:) = decimate(isoV1_ms(i,:),4);
end

for i = 1:size(isoV1_ms,1)
    useTrial = randsample(size(isoV1_ms,1), window, 1);
    isoV1_boot(i,:) = mean(isoV1_ms(useTrial,:),1);
    isoV1_boot_DC(i,:) = mean(isoV1_dc(useTrial,:),1);
end
    
awa1V1 = squeeze(awake1MeanSubData(info.lowLat,:,timeFrame));
awa1V1_ms = awa1V1 - repmat(mean(awa1V1,2), 1, size(awa1V1,2));
for i = 1:size(awa1V1_ms,1)
    awa1V1_dc(i,:) = decimate(awa1V1_ms(i,:),4);

end

for i = 1:size(awa1V1_ms,1)
 useTrial = randsample(size(awa1V1_ms,1), window, 1);
 awa1_boot(i,:) = mean(awa1V1_ms(useTrial,:),1);
 awa1_boot_DC(i,:) = mean(awa1V1_dc(useTrial,:),1);
end

if exist('awake2MeanSubData')
    awa2V1 = squeeze(awake2MeanSubData(info.lowLat,:,timeFrame));
    awa2V1_ms = awa2V1 - repmat(mean(awa2V1,2), 1, size(awa2V1,2));
    for i = 1:size(awa2V1_ms,1)
        awa2V1_dc(i,:) = decimate(awa2V1_ms(i,:),4);
    end
    for i = 1:size(awa2V1_ms,1)
        useTrial = randsample(size(awa2V1_ms,1), window, 1);
        awa2_boot(i,:) = mean(awa2V1_ms(useTrial,:),1);
        awa2_boot_DC(i,:) = mean(awa2V1_dc(useTrial,:),1);
    end
end

%% cosine distance of each trial to every other trial

% for i = 1:size(emergV1_ms,1)
%     for j = 1:size(emergV1_ms,1)
%         emergST_distMat(i,j) = pdist2(emergV1_ms(i,:), emergV1_ms(j,:), 'cosine');
%     end
% end
% 
% for i = 1:size(isoV1_ms,1)
%     for j = 1:size(isoV1_ms,1)
%         isoST_distMat(i,j) = pdist2(isoV1_ms(i,:), isoV1_ms(j,:), 'cosine');
%     end
% end
% 
% for i = 1:size(awa1V1_ms,1)
%     for j = 1:size(awa1V1_ms,1)
%         awa1ST_distMat(i,j) = pdist2(awa1V1_ms(i,:), awa1V1_ms(j,:), 'cosine');
%     end
% end
% 
% if exist('awake2MeanSubData')
% for i = 1:size(awa2V1_ms,1)
%     for j = 1:size(awa2V1_ms,1)
%         awa2ST_distMat(i,j) = pdist2(awa2V1_ms(i,:), awa2V1_ms(j,:), 'cosine');
%     end
% end
% end
% 
% % making plots 
% USE_DATA =2
% 
% if USE_DATA ==1
%     ogSingleTrials = isoV1;
%     msSingleTrials = isoV1_ms;
%     distMat = isoST_distMat;
%     stringTitle = 'Iso';
% elseif USE_DATA ==2
%     ogSingleTrials = emergV1;
%     msSingleTrials =emergV1_ms;
%     distMat = emergST_distMat;
%     stringTitle = 'Emerg';
% elseif USE_DATA ==3
%     ogSingleTrials = awa1V1;
%     msSingleTrials = awa1V1_ms;
%     distMat = awa1ST_distMat;
%     stringTitle = 'Awake 1';
% elseif USE_DATA ==4
%     ogSingleTrials = awa2V1;
%     msSingleTrials = awa2V1_ms;
%     distMat =awa2ST_distMat;
%     stringTitle =  'Awake 2';
% end

% figure
% subplot(1,3,1)
% imagesc(ogSingleTrials)
% %pcolor(timeFrame,1:size(emergV1_ms,1), emergV1_ms); shading 'flat'
% colorbar
% title(['Raw ', stringTitle])
% subplot(1,3,2)
% imagesc(msSingleTrials)
% %pcolor(timeFrame,1:size(emergV1_ms,1), emergV1_ms); shading 'flat'
% colorbar
% title(['Mean Sub ', stringTitle])
% subplot(1,3,3)
% imagesc(distMat)
% colorbar
% title(['Distance Matrix: ', stringTitle])
% suptitle(stringTitle)

%% lets try PCA, cause why not

PCA_DATA =0;

if PCA_DATA ==1
no_dims = 50;
pcaIso = isoV1_boot;
pcaAwa = awa1_boot;
pcaEmg =slide_emergST;
allData = [pcaIso; pcaAwa; pcaEmg];

[mappedX, mapping,~,~,explained] = pca(allData, 'numcomponents', no_dims);

numCompts = find(cumsum(explained)>95, 1, 'first');

figure 
for i = 1%:numCompts
plot(mappedX(:,i))
hold on 
end

pcIso_comp= pcaIso*mappedX(:,1:numCompts);
pcAwa_comp= pcaAwa*mappedX(:,1:numCompts);
pcEmg_comp= pcaEmg*mappedX(:,1:numCompts);
end


%% Using LDA to distinguish iso, awake 1 and awake 2

% useIso = pcIso_comp;
% useAwake = pcAwa_comp;
% useEmerg = pcEmg_comp;

% useIso = isoV1_dc;
% useAwake = awa1V1_dc;
% useEmerg = emergV1_dc;

useIso = isoV1_boot_DC;
useAwake = awa1_boot_DC;
useEmerg = slide_emergDC;

useData1 = isoV1_boot_DC;
useData2 = awa1_boot_DC;

Y= randsample(size(useIso,1), 50);

%%

trainIso = useIso(Y,:);
trainAwake =  useAwake(Y,:);

% do on a subset of data

mixMatrix =[trainIso; trainAwake];
targets = [ones(size(trainIso,1),1); [ones(size(trainAwake,1),1)+1]];

W = LDA(mixMatrix,targets);
size(W)
%%
% W_proj1 = W(1,1:11)*mappedX(:,1:numCompts)';
% figure
% plot(W_proj1)
%W_proj2 = 


% FW= fitcdiscr(mixMatrix,targets);
% 
% seperationAxis = FW.Coeffs(1,2).Linear;
% 
% projectionTrain = mixMatrix*seperationAxis;
% 
% figure
% plot(projectionTrain)
% hold on 
% plot(L_train(:,1))
[W, L_train, P_train, L_test, P_test, mixMatrix, targets, Y]= classifyAnesAwakeLDA(50, useData1, useData2);


%% Look at the training data

L_train = [ones(length(targets),1) mixMatrix]*W';

P_train = exp(L_train) ./ repmat(sum(exp(L_train),2),[1 2]);
P_train(:,3) = zeros(size(P_train,1),1);

figure; clf 
subplot(2,1,1)
scatter(L_train(:,1), ones(1,length(L_train)), [], P_train, 'filled')
subplot(2,1,2)
scatter(L_train(:,1), L_train(:,2),[],  P_train, 'filled')
suptitle('Train Iso and Awake')

%% look at all Iso and awake data 

allConfData = [useIso;useAwake];

L_all =[ones(size(allConfData,1),1),allConfData]*W';

P_all = exp(L_all) ./ repmat(sum(exp(L_all),2),[1 2]);
P_all(:,3) = zeros(size(P_all,1),1);

figure; clf  
subplot(2,1,1)
scatter(L_all(:,1), ones(1,length(L_all)), [], P_all, 'filled')
subplot(2,1,2)
scatter(L_all(:,1), L_all(:,2),[],  P_all, 'filled')
suptitle('All Iso and Awake')



% projectionAll = allConfData*seperationAxis;
% 
% figure
% plot(projectionAll)
% hold on 
% plot(L_all(:,1))

%% Look at the test data from Iso and Awake

testTr = [1:size(useIso,1)];
testTr(Y) = [];

testIso = useIso(testTr,:);
testAwa =  useAwake(testTr,:);
allTest = [testIso; testAwa];

L_test = [ones(length(allTest),1) allTest]*W';

P_test = exp(L_test) ./ repmat(sum(exp(L_test),2),[1 2]);
P_test(:,3) = zeros(size(P_test,1),1);

figure; clf 
subplot(2,1,1)
scatter(L_test(:,1), ones(1,length(L_test)), [], P_test, 'filled')
subplot(2,1,2)
scatter(L_test(:,1), L_test(:,2),[],  P_test, 'filled')
suptitle('Test Iso and Awake')



%% Look at emergence data 

L_emg = [ones(length(useEmerg),1) useEmerg]*W';

P_emg = exp(L_emg) ./ repmat(sum(exp(L_emg),2),[1 2]);
P_emg(:,3) = zeros(size(P_emg,1),1);

figure; clf 
subplot(2,1,1)
scatter(L_emg(:,1), ones(1,length(L_emg)), [], P_emg, 'filled')
subplot(2,1,2)
scatter(L_emg(:,1), L_emg(:,2),[],  P_emg, 'filled')
suptitle('Emergence')

figure
plot(filterData(P_emg(:,1),10))
hold on
plot(filterData(P_emg(:,1),3))
plot(P_emg(:,1))

% projectionEmerg = emergV1_dc*seperationAxis;
% 
% figure
% plot(projectionEmerg)
% hold on 
% plot(L_emg(:,1))





%% Look at all data collated together

allIsoEmgAwa = [useIso;useEmerg;useAwake];

L_isoEmgAwa = [ones(length(allIsoEmgAwa),1) allIsoEmgAwa]*W';

P_isoEmgAwa = exp(L_isoEmgAwa) ./ repmat(sum(exp(L_isoEmgAwa),2),[1 2]);
P_isoEmgAwa(:,3) = zeros(size(P_isoEmgAwa,1),1);

figure; clf 
subplot(2,1,1)
scatter(L_isoEmgAwa(:,1), ones(1,length(L_isoEmgAwa)), [], P_isoEmgAwa, 'filled')
subplot(2,1,2)
scatter(L_isoEmgAwa(:,1), L_isoEmgAwa(:,2),[],  P_isoEmgAwa, 'filled')
suptitle('All Data')


plotAllIsoEmgAwa = zeros(1,length(allIsoEmgAwa));
plotAllIsoEmgAwa(length(useIso)+1:length(useIso)+length(useEmerg)) = 1;
plotAllIsoEmgAwa(length(useIso)+length(useEmerg)+1:end) = 2;


figure
subplot(2,1,1)
plot(filterData(P_isoEmgAwa(:,1),10))
hold on
plot(filterData(P_isoEmgAwa(:,1),3))
plot(P_isoEmgAwa(:,1))
legend('smooth = 10', 'smooth = 3', 'smooth = 0')
xlabel('Trial number')
ylabel('Prob of anes by LDA')
subplot(2,1,2)
plot(plotAllIsoEmgAwa)
xlabel('Trial number')
ylabel('0 = iso, 1 = emerg, 2 = awake')

figure
histogram(L_isoEmgAwa(:,1))
hold on 
histogram(L_isoEmgAwa(:,2))


figure
hist3(L_isoEmgAwa)
axis vis3d
box on

figure
subplot(2,2,1)
hist3(P_train(:,1:2), 'edges', {0:0.1:1, 0:0.1:1}, 'CdataMode', 'auto')
title('Train')
subplot(2,2,2)
hist3(P_test(:,1:2), 'edges', {0:0.1:1, 0:0.1:1}, 'CdataMode', 'auto')
title('Test')
subplot(2,2,3)
hist3(P_emg(:,1:2), 'edges', {0:0.1:1, 0:0.1:1}, 'CdataMode', 'auto')
title('Emergence')
subplot(2,2,4)
hist3(P_isoEmgAwa(:,1:2), 'edges', {0:0.1:1, 0:0.1:1}, 'CdataMode', 'auto')
title('All Data')


figure
subplot(2,2,1)
histogram(P_train(:,1), 25)
title('Train')
subplot(2,2,2)
histogram(P_test(:,1), 25)
title('Test')
subplot(2,2,3)
histogram(P_emg(:,1), 25)
title('Emergence')
subplot(2,2,4)
histogram(P_isoEmgAwa(:,1), 25)
title('All Data')





figure
plot(L_test(:,1), L_test(:,2))


%%

figure
subplot(2,1,1)
scatter(L_isoEmgAwa(:,1), ones(1,length(L_isoEmgAwa)), [], P_isoEmgAwa, 'filled')
subplot(2,1,2)
scatter(L_isoEmgAwa(:,1), L_isoEmgAwa(:,2),[],1:length(L_isoEmgAwa), 'filled')
suptitle('All Data')


plot(1:length(L_isoEmgAwa),L_isoEmgAwa(:,2))


figure
scatter(L_isoEmgAwa(:,1), L_isoEmgAwa(:,2),[],1:length(L_isoEmgAwa), 'filled')
colorbar
suptitle('All Data')





