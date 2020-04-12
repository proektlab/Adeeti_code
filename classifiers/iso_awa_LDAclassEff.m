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
        
        clearvars isoHighExp isoLowExp emergExp awaExp1
        
        % find high iso
        temp = findMyExpMulti(dataMatrixFlashes, [], 'iso', 1.2, stimIndex, []);
        if isempty(temp)
            temp = findMyExpMulti(dataMatrixFlashes, [], 'iso', 1.0, stimIndex, []);
        end
        if ~isempty(temp)
            isoHighExp = temp(1);
            load(allData(isoHighExp).name, 'meanSubData', 'info')
        end
        [isoHigh_ms, isoHigh_dc, ~ ,~, isoHigh_boot,isoHigh_boot_DC] =  setupInput4LDA(meanSubData, info.lowLat, timeFrame, decBy, window);
        
        % find low iso
        temp = findMyExpMulti(dataMatrixFlashes, [], 'iso', 0.6, stimIndex, []);
        if isempty(temp)
            temp = findMyExpMulti(dataMatrixFlashes, [], 'iso', 0.4, stimIndex, []);
        end
        if ~isempty(temp)
            isoLowExp = temp(1);
            load(allData(isoLowExp).name, 'meanSubData', 'info')
            [isoLow_ms, isoLow_dc, ~ ,~, isoLow_boot,isoLow_boot_DC] = setupInput4LDA(meanSubData, info.lowLat, timeFrame, decBy, window);
        end
        
        % find emergence
        temp = findMyExpMulti(dataMatrixFlashes, [], 'emerg', 2000, stimIndex, []);
        if ~isempty(temp)
            emergExp = temp(1);
            load(allData(emergExp).name, 'meanSubData', 'info')
            [emerg_ms, emerg_dc, slide_emergST ,slide_emergDC, ~,~] = setupInput4LDA(meanSubData, info.lowLat, timeFrame, decBy, window);
        end
        
        % find awake
        temp = findMyExpMulti(dataMatrixFlashes, [], 'awa', 0, stimIndex, []);
        if ~isempty(temp)
            awaExp1 = temp(1);
            load(allData(awaExp1).name, 'meanSubData', 'info')
            [awa1_ms, awa1_dc, ~ ,~, awa1_boot,awa1_boot_DC] = setupInput4LDA(meanSubData, info.lowLat, timeFrame, decBy, window);
%             if length(temp)>1
%                 awaExp2 = temp(end);
%                 load(allData(awaExp2).name, 'meanSubData', 'info')
%                 [awa2_ms, awa2_dc, ~ ,~, awa2_boot,awa2_boot_DC] = setupInput4LDA(meanSubData, info.lowLat, timeFrame, decBy, window);
%             end
        end
        
%         % find ket
%         temp = findMyExpMulti(dataMatrixFlashes, [], 'ket', 100, stimIndex, []);
%         if ~isempty(temp)
%             ketExp = temp(1);
%             load(allData(ketExp).name, 'meanSubData', 'info')
%             [ket_ms, ket_dc, ~ ,~, ket_boot,ket_boot_DC] = setupInput4LDA(meanSubData, info.lowLat, timeFrame, decBy, window);
%         end
        
        % [inputData_ms, inputData_dc, slide_data ,slide_data_dc, boot_inputData, ...
        % boot_inputData_dc] = setupInput4LDA(input_meanSubData, channels, timeFrame, ...
        % decData, decBy, slidingAvg,  window)
        
        
        %% lets try PCA, cause why not
        
        PCA_DATA =1;
        
        if PCA_DATA ==1
            no_dims = 50;
            if exist('isoHighExp')
                pcaHighIso = isoHigh_boot;
            else
                pcaHighIso = [];
            end
            if exist('isoLowExp')
                pcaLowIso = isoLow_boot;
            else
                pcaLowIso = [];
            end
            pcaAwa = awa1_boot;
            allData2PCA = [pcaHighIso; pcaLowIso; pcaAwa];
            
            [mappedX, mapping,~,~,explained] = pca(allData2PCA, 'numcomponents', no_dims);
            numCompts = find(cumsum(explained)>95, 1, 'first');
            
            if exist('isoHighExp')
                pcHighIso_comp= pcaHighIso*mappedX(:,1:numCompts);
            else
                pcHighIso_comp = [];
            end
            if exist('isoLowExp')
                pcLowIso_comp= pcaLowIso*mappedX(:,1:numCompts);
            else
                pcLowIso_comp = [];
            end
            pcAwa_comp= pcaAwa*mappedX(:,1:numCompts);
        end
        
        %% Initializing 
        
        classLowIso = [];
        realLowIso = [];
        classAwake1 = [];
        realAwake1 = [];
        
        hitsLowIso = [];
        hitLowIso_rate = [];
        falsePoslowIso = [];
        
        hitsAwake1 = [];
        hitAwake1_rate = [];
        falsePoAwake = [];
       
        realLowIso_con = [];
        classHighIso_con = [];
        classHighIso_con =[];
        realHighIso_con = [];
        
        hitsLowIso_con =[];
        hitLowIso_con_rate =[];
        falsePosLowIso_con =[];
        
        hitsHighIso_con = [];
        hitHighIso_con_rate = [];
        falsePosHighIso_con= [];

        %% Using LDA to distinguish low iso, awake 1
        
        pcLowIso_comp= pcaLowIso*mappedX(:,1:numCompts);
        useLowIso = pcLowIso_comp;
        useAwake1 = pcAwa_comp;
        %useAwake2 = awa2_boot_DC;
        
        numTrain = 50;
        
        [W, L_train, P_train, L_test, P_test, mixMatrix, targets, Y_1, Y_2, testMatrix, testTargets]= ...
            classifyAnesAwakeLDA(numTrain, useLowIso, useAwake1);
        
        allConfData = [useLowIso;useAwake1];
        [L_allIsoAwa, P_allIsoAwa]= projOnLDA_softmax(W, allConfData);
        
        thresh = 0.5;
        undet_thresh = .20;
        
        
        classLowIso = find(P_test(:,1)>thresh-undet_thresh);
        realLowIso = find(testTargets ==1);
        classAwake1 = find(P_test(:,2)>thresh-undet_thresh);
        realAwake1 = find(testTargets ==2);
        
        hitsLowIso = ismember(classLowIso, realLowIso);
        hitLowIso_rate =  numel(find(hitsLowIso ==1))/numel(realLowIso);
        
        hitsAwake1 = ismember(classAwake1, realAwake1);
        hitAwake1_rate = numel(find(hitsAwake1 ==1))/numel(realAwake1);
        
        falsePoslowIso = numel(find(hitsLowIso ==0))/(numel(find(hitsAwake1 ==1))+ numel(find(hitsLowIso ==0)))
        falsePoAwake = numel(find(hitsAwake1 ==0))/(numel(find(hitsLowIso ==1))+ numel(find(hitsAwake1 ==0)))
       
        save('LDA_Iso_Awake.mat', 'hitLowIso_rate', 'falsePoslowIso', 'hitAwake1_rate', 'falsePoAwake')
        %% LDA to distingish high iso from low iso
        if exist('isoHighExp')
        useLowIso = pcLowIso_comp;
        usehighIso = pcHighIso_comp;
        %useAwake2 = awa2_boot_DC;
        
        numTrain = 50;
        
        [W, L_train, P_train, L_test, P_test, mixMatrix, targets, Y_1, Y_2, testMatrix, testTargets]= ...
            classifyAnesAwakeLDA(numTrain, useLowIso, usehighIso);
        
        allConfData = [useLowIso;usehighIso];
        [L_allIsoCon, P_allIsoCon]= projOnLDA_softmax(W, allConfData);
        
        thresh = 0.5;
        undet_thresh = .20;

        classLowIso_con = find(P_test(:,1)>thresh-undet_thresh);
        realLowIso_con = find(testTargets ==1);
        classHighIso_con = find(P_test(:,2)>thresh-undet_thresh);
        realHighIso_con = find(testTargets ==2);
        
        hitsLowIso_con = ismember(classLowIso_con, realLowIso_con);
        hitLowIso_con_rate =  numel(find(hitsLowIso_con ==1))/numel(realLowIso_con);

        hitsHighIso_con = ismember(classHighIso_con, realHighIso_con);
        hitHighIso_con_rate = numel(find(hitsHighIso_con ==1))/numel(realHighIso_con);

        falsePosLowIso_con = numel(find(hitsLowIso_con ==0))/(numel(find(hitsHighIso_con ==1))+ numel(find(hitsLowIso_con ==0)))
        falsePosHighIso_con = numel(find(hitsHighIso_con ==0))/(numel(find(hitsLowIso_con ==1))+ numel(find(hitsHighIso_con ==0)))
        
        save('LDA_Iso_Awake.mat', 'hitLowIso_con_rate', 'falsePosLowIso_con', 'hitHighIso_con_rate', 'falsePosHighIso_con', '-append')
        end
    end
end

