%% Setting up experiment for dPCA

%% single trials distance with each other

clc
clear
close all

if isunix && ~ismac
    genDir = '/synology/adeeti/ecog/iso_awake_VEPs/';
    picsDir =  '/synology/adeeti/ecog/images/Iso_Awake_VEPs/';
    dropboxLocation = '/home/adeeti/Dropbox/ProektLab_code/Adeeti_code/'; %'C:\Users\adeeti\Dropbox\KelzLab\';
elseif ispc
    genDir = 'Z:\adeeti\ecog\iso_awake_VEPs\';
    picsDir =  'Z:\adeeti\ecog\images\Iso_Awake_VEPs\';
    dropboxLocation = 'C:\Users\adeeti\Dropbox\ProektLab_code\Adeeti_code\';
end

allMice = [{'goodMice'}; {'maybeMice'}];

cd(genDir)

ident1 = '2019*';
ident2 = '2020*';
stimIndex = [0, Inf];

timeFrame = 1020:1350; %EP timeframe
decBy = 4; %decimate data by
window = 3; %sliding average with 3 single trials

%%

mouseCounter = 0
for g = 1:length(allMice)
    genDirM = [genDir, (allMice{g}), '/'];
    picsDirM = [picsDir, (allMice{g}), '/'];
    
    cd(genDirM)
    allDir = [dir('GL*'); dir('*IP2');dir('*CB3')];
    
    startD = 1;
    
    for d = startD:length(allDir)
        cd([genDirM, allDir(d).name])
        mouseID = allDir(d).name;
        disp(mouseID)
        genPicsDir =  [picsDirM, mouseID, '/'];
        dirIn = [genDirM, mouseID, '/'];
        
        allData = dir(ident1);
        identifier = ident1;
        
        if isempty(allData)
            allData = dir(ident2);
            identifier = ident2;
        end
        
        %% Finding correct experiments, loading data, detrending (mean subtracting), ...
        %  decimating, and bootstrap avgs/sliding window avgs
        load('dataMatrixFlashes.mat')
        
        mouseCounter = mouseCounter+1;
        
        clearvars isoHighExp isoLowExp emergExp awaExp1
        
        % find high iso
        temp = findMyExpMulti(dataMatrixFlashes, [], 'iso', 1.2, stimIndex, []);
        if isempty(temp)
            temp = findMyExpMulti(dataMatrixFlashes, [], 'iso', 1.0, stimIndex, []);
        end
        if ~isempty(temp)
            isoHighExp = temp(1);
            load(allData(isoHighExp).name, 'meanSubData', 'info')
            useData = reshape(meanSubData, [1 3 2]);
            allTheData(:,1,mouseCounter,:,:)= useData;
            %[isoHigh_ms, isoHigh_dc, ~ ,~, isoHigh_boot,isoHigh_boot_DC] =  setupInput4LDA(meanSubData, info.lowLat, timeFrame, decBy, window);
        end
        
        % find low iso
        temp = findMyExpMulti(dataMatrixFlashes, [], 'iso', 0.6, stimIndex, []);
        if isempty(temp)
            temp = findMyExpMulti(dataMatrixFlashes, [], 'iso', 0.4, stimIndex, []);
        end
        if ~isempty(temp)
            isoLowExp = temp(1);
            load(allData(isoLowExp).name, 'meanSubData', 'info')
            useData = reshape(meanSubData, [1 3 2]);
            allTheData(:,2,mouseCounter,:,:)= useData;
            %[isoLow_ms, isoLow_dc, ~ ,~, isoLow_boot,isoLow_boot_DC] = setupInput4LDA(meanSubData, info.lowLat, timeFrame, decBy, window);
        end
        
        % find emergence
        temp = findMyExpMulti(dataMatrixFlashes, [], 'emerg', 2000, stimIndex, []);
        if ~isempty(temp)
            emergExp = temp(1);
            load(allData(emergExp).name, 'meanSubData', 'info')
            useData = reshape(meanSubData, [1 3 2]);
            allTheData(:,3,mouseCounter,:,:)= useData;
            %[emerg_ms, emerg_dc, slide_emergST ,slide_emergDC, ~,~] = setupInput4LDA(meanSubData, info.lowLat, timeFrame, decBy, window);
        end
        
        % find awake
        temp = findMyExpMulti(dataMatrixFlashes, [], 'awa', 0, stimIndex, []);
        if ~isempty(temp)
            awaExp1 = temp(1);
            load(allData(awaExp1).name, 'meanSubData', 'info')
            useData = reshape(meanSubData, [1 3 2]);
            allTheData(:,4,mouseCounter,:,:)= useData;
            %[awa1_ms, awa1_dc, ~ ,~, awa1_boot,awa1_boot_DC] = setupInput4LDA(meanSubData, info.lowLat, timeFrame, decBy, window);
            if length(temp)>1
                awaExp2 = temp(end);
                load(allData(awaExp2).name, 'meanSubData', 'info')
                useData = reshape(meanSubData, [1 3 2]);
                allTheData(:,5,mouseCounter,:,:)= useData;
                %[awa2_ms, awa2_dc, ~ ,~, awa2_boot,awa2_boot_DC] = setupInput4LDA(meanSubData, info.lowLat, timeFrame, decBy, window);
            end
        end
        
        % find ket
        temp = findMyExpMulti(dataMatrixFlashes, [], 'ket', 100, stimIndex, []);
        if ~isempty(temp)
            ketExp = temp(1);
            load(allData(ketExp).name, 'meanSubData', 'info')
            useData = reshape(meanSubData, [1 3 2]);
            allTheData(:,2,mouseCounter,:,:)= useData;
            %[ket_ms, ket_dc, ~ ,~, ket_boot,ket_boot_DC] = setupInput4LDA(meanSubData, info.lowLat, timeFrame, decBy, window);
        end
        
        
    end
end


%%


dirIn = 'Z:\adeeti\ecog\iso_awake_VEPs\goodMice\GL13\';
cd(dirIn)

allData = dir('2020*mat');

expIndexes = [1, 2, 4, 6];
timeFrame = 1020:1350; %EP timeframe


for a = expIndexes
    load(allData(a).name, 'meanSubData', 'info')
    if a ==1
        allChan = [1:64];
        allChan(info.noiseChannels) = [];
        allTheData = nan(length(allChan),4,length(timeFrame), 101);
    end
    
    useData = permute(meanSubData(allChan,:,timeFrame), [1 3 2]);
    
    if contains( info.AnesType, 'iso', 'IgnoreCase', true) && info.AnesLevel==1.2
        allTheData(:,1,:,:)= useData;
    end
    if contains(info.AnesType, 'iso', 'IgnoreCase', true) && info.AnesLevel==0.6
        allTheData(:,2,:,:)= useData;
    end
    if contains(info.AnesType, 'awa', 'IgnoreCase', true)
        allTheData(:,3,:,:)= useData;
    end
    if contains(info.AnesType, 'ket', 'IgnoreCase', true)
        allTheData(:,4,:,:)= useData;
    end
end


sum(isnan(allTheData(:)))

%%

allAnesData = [squeeze(allTheData(info.lowLat,1,:,:))'; squeeze(allTheData(info.lowLat,2,:,:))'; ...
    squeeze(allTheData(info.lowLat,4,:,:))'];
size(allAnesData)

allAwa = [squeeze(allTheData(info.lowLat,3,:,:))'];
size(allAwa)

PCA_DATA =1;

if PCA_DATA ==1
    no_dims = 50;
    pcaAnes = allAnesData;
    pcaAwa = allAwa;
    allData = [pcaAnes; pcaAwa];
    
    [mappedX, mapping,~,~,explained] = pca(allData, 'numcomponents', no_dims);
    
    numCompts = find(cumsum(explained)>95, 1, 'first');
    
    figure
    for i = 1%:numCompts
        plot(mappedX(:,i))
        hold on
    end
    
    pcAnes_comp= pcaAnes*mappedX(:,1:numCompts);
    pcAwa_comp= pcaAwa*mappedX(:,1:numCompts);
    
end


%%
numTrain = 50;

[W, L_train, P_train, L_test, P_test, mixMatrix, targets, Y_1, Y_2, allTest, testTargets]=...
    classifyAnesAwakeLDA(numTrain, pcAnes_comp, pcAwa_comp);

% size(W)

% figure
% histogram(P_test, 25)





thresh = 0.5;
undet_thresh = .20;

classAnes = find(P_test(:,1)>thresh-undet_thresh);
realAnes = find(testTargets ==1);
classAwa = find(P_test(:,2)>thresh-undet_thresh);
realAwa = find(testTargets ==2);

hitAnes = ismember(classAnes, realAnes);
hitAnes_rate =  numel(find(hitAnes ==1))/numel(realAnes);
falseNegAnes = numel(find(hitAnes ==0))/numel(realAnes);

hitsAwa = ismember(classAwa, realAwa);
hitAwa_rate = numel(find(hitsAwa ==1))/numel(realAwa);
falseNegAwa_con = numel(find(hitsAwa ==0))/numel(realAwa);











