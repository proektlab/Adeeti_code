%% single trials distance with each other

%% single trials distance with each other

clear
clc
close all

if isunix ==1 && ismac ==0
    dirIn = '/synology/adeeti/ecog/iso_awake_VEPs/goodMice/CB3/';
    emergExp = 3;
    isoLowExp = 2;
    awaExp1 = 4;
    awaExp2 = 5;
elseif ispc ==1
    dirIn = 'Z:\adeeti\ecog\iso_awake_VEPs\goodMice\CB3\';
    emergExp = 3;
    isoLowExp = 2;
    awaExp1 = 4;
    awaExp2 = 5;
elseif ismac ==1
    dirIn = '/Users/adeetiaggarwal/Desktop/CB3/';
    emergExp = 2;
    isoLowExp = 1;
    awaExp1 = 3;
    
end

cd(dirIn)
identifier = '2020*';
allData = dir(identifier);

timeFrame = 1020:1350; %EP timeframe
decData = 1; %will decimate data
decBy = 4; %decimate data by 4
slidingAvg = 1; % will take sliding average of data
window = 3; %sliding average with 3 single trials

%% loading data, decimating, mean sub, and sliding/boot averages

%load(allData(isoHighExp).name, 'meanSubData', 'info')
%[isoHigh_ms, isoHigh_dc, ~ ,~, isoHigh_boot,isoHigh_boot_DC] = setupInput4LDA(meanSubData, info.lowLat, timeFrame, decBy, window);

load(allData(isoLowExp).name, 'meanSubData', 'info')
[isoLow_ms, isoLow_dc, ~ ,~, isoLow_boot,isoLow_boot_DC] = setupInput4LDA(meanSubData, info.lowLat, timeFrame, decBy, window);


load(allData(emergExp).name, 'meanSubData', 'info')
[emerg_ms, emerg_dc, slide_emergST ,slide_emergDC, ~,~] = setupInput4LDA(meanSubData, info.lowLat, timeFrame, decBy, window);

load(allData(awaExp1).name, 'meanSubData', 'info')
[awa1_ms, awa1_dc, ~ ,~, awa1_boot,awa1_boot_DC] = setupInput4LDA(meanSubData, info.lowLat, timeFrame, decBy, window);

if exist('awaExp2')
load(allData(awaExp2).name, 'meanSubData', 'info')
[awa2_ms, awa2_dc, ~ ,~, awa2_boot,awa2_boot_DC] = setupInput4LDA(meanSubData, info.lowLat, timeFrame, decBy, window);
end

% load(allData(ketExp).name, 'meanSubData', 'info')
% [ket_ms, ket_dc, ~ ,~, ket_boot,ket_boot_DC] = setupInput4LDA(meanSubData, info.lowLat, timeFrame, decBy, window);

% [inputData_ms, inputData_dc, slide_data ,slide_data_dc, boot_inputData, ...
% boot_inputData_dc] = setupInput4LDA(input_meanSubData, channels, timeFrame, ...
% decBy,  window)


%% lets try PCA, cause why not

PCA_DATA =1;

if PCA_DATA ==1
    no_dims = 50;
    pcaIso = isoLow_boot;
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

useIso = pcIso_comp;
useAwake1 = pcAwa_comp;
useEmerg = pcEmg_comp;

% useIso = isoLow_boot_DC;
% useAwake1 = awa1_boot_DC;
% useEmerg = slide_emergDC;

numTrain = 50;

[W, L_train, P_train, L_test, P_test, mixMatrix, targets, Y, ~, ~]= classifyAnesAwakeLDA(numTrain, useIso, useAwake1);

size(W)

allConfData = [useIso;useAwake1];
[L_allIsoAwa, P_allIsoAwa]= projOnLDA_softmax(W, allConfData);

%% figure of LDA seperation on known data
figure; clf
subplot(3,1,1)
scatter(L_train(:,1), L_train(:,2),[],  P_train, 'filled')
title('Train Iso and Awake')
subplot(3,1,2)
scatter(L_test(:,1), L_test(:,2),[],  P_test, 'filled')
title('Test Iso and Awake')
subplot(3,1,3)
scatter(L_allIsoAwa(:,1), L_allIsoAwa(:,2),[],  P_allIsoAwa, 'filled')
title('All Iso and Awake')
suptitle('Train vs Test Projections')

%% Look at emergence data

[L_emg, P_emg]= projOnLDA_softmax(W, useEmerg);

allIsoEmgAwa = [useIso;useEmerg;useAwake1];
[L_isoEmgAwa, P_isoEmgAwa]= projOnLDA_softmax(W, allIsoEmgAwa);

figure; clf
subplot(2,1,1)
scatter(L_emg(:,1), L_emg(:,2), [], P_emg, 'filled')
title('emergence')
subplot(2,1,2)
scatter(L_isoEmgAwa(:,1), L_isoEmgAwa(:,2),[],  P_isoEmgAwa, 'filled')
title('All Data')


plotAllIsoEmgAwa = zeros(1,length(allIsoEmgAwa));
plotAllIsoEmgAwa(length(useIso)+1:length(useIso)+length(useEmerg)) = 1;
plotAllIsoEmgAwa(length(useIso)+length(useEmerg)+1:end) = 2;


figure('Color', 'w')
subplot(3,1,[1,2])
plot(filterData(P_isoEmgAwa(:,1),10))
hold on
plot(filterData(P_isoEmgAwa(:,1),3))
plot(P_isoEmgAwa(:,1))
legend('smooth = 10', 'smooth = 3', 'smooth = 0')
xlabel('Trial number')
ylabel('Prob of anes by LDA')
subplot(3,1,3)
plot(plotAllIsoEmgAwa)
xlabel('Trial number')
ylabel('0 = iso, 1 = emerg, 2 = awake')

%%
figure
subplot(2,2,1)
%hist3(P_train(:,1:2), 'edges', {0:0.1:1, 0:0.1:1}, 'CdataMode', 'auto')
hist3(L_train(:,1:2), 'edges', {-15:30, -30:30}, 'CdataMode', 'auto')
title('Train')
subplot(2,2,2)
%hist3(P_test(:,1:2), 'edges', {0:0.1:1, 0:0.1:1}, 'CdataMode', 'auto')
 hist3(L_test(:,1:2), 'edges', {-15:30, -30:30}, 'CdataMode', 'auto')
title('Test')
subplot(2,2,3)
%hist3(P_emg(:,1:2), 'edges', {0:0.1:1, 0:0.1:1}, 'CdataMode', 'auto')
 hist3(L_emg(:,1:2), 'edges', {-15:30, -30:30}, 'CdataMode', 'auto')
title('Emergence')
subplot(2,2,4)
%hist3(P_isoEmgAwa(:,1:2), 'edges', {0:0.1:1, 0:0.1:1}, 'CdataMode', 'auto')
hist3(L_isoEmgAwa(:,1:2), 'edges', {-15:30, -30:30}, 'CdataMode', 'auto')
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



%%

plot(1:length(L_isoEmgAwa),L_isoEmgAwa(:,2))


figure
scatter(L_isoEmgAwa(:,1), L_isoEmgAwa(:,2),[],1:length(L_isoEmgAwa), 'filled')
colorbar
suptitle('All Data')


