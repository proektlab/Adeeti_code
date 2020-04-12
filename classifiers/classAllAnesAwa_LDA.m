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
        anesLabels = [];
        allAnes = [];
        allAwake = [];
        awaLabels = [];
        for a = 1:length(allData)
            load(allData(a).name, 'meanSubData', 'info')
            useData = squeeze(meanSubData(info.lowLat,:,timeFrame));
            
            if contains( info.AnesType, 'iso', 'IgnoreCase', true) && info.AnesLevel==1.2
                allAnes= [allAnes; useData];
                anesLabels = [anesLabels; ones(size(useData,1),1)];
                
            elseif contains(info.AnesType, 'iso', 'IgnoreCase', true) && info.AnesLevel==0.6
                allAnes= [allAnes; useData];
                anesLabels = [anesLabels; 2*ones(size(useData,1),1)];
                
            elseif contains(info.AnesType, 'awa', 'IgnoreCase', true)
                allAwake= [allAwake; useData];
                awaLabels = [awaLabels; zeros(size(useData,1),1)];
                
            elseif contains(info.AnesType, 'ket', 'IgnoreCase', true)
                aallAnes= [allAnes; useData];
                anesLabels = [anesLabels; 3*ones(size(useData,1),1)];
                
            elseif contains(info.AnesType, 'eme', 'IgnoreCase', true)
                continue
            end
        end
        %% lets try PCA, cause why not
        PCA_DATA =1;
        
        if PCA_DATA ==1
            no_dims = 50;
            pcaAnes = allAnes;
            pcaAwa = allAwake;
            allData4PCA = [pcaAnes; pcaAwa];
            
            [mappedX, mapping,~,~,explained] = pca(allData4PCA, 'numcomponents', no_dims);
            
            numCompts = find(cumsum(explained)>95, 1, 'first');
            
            pcAnes_comp= pcaAnes*mappedX(:,1:numCompts);
            pcAwa_comp= pcaAwa*mappedX(:,1:numCompts);
        end
        
        %% Initializing
        
        classAnes = [];
        realAnes = [];
        classAwa = [];
        realAwa = [];
        
        hitAnes = [];
        hitAnes_rate =  [];
        falsePosAnes = [];
        
        hitsAwa_compAllAn = [];
        hitAwa_rate_compAllAn = [];
        falsePosAwa__compAllAn = [];
        
        
        %% Using LDA to distinguish low iso, awake 1
        numTrain = 50;
        
        [W, L_train, P_train, L_test, P_test, mixMatrix, targets, Y_1, Y_2, allTest, testTargets]=...
            classifyAnesAwakeLDA(numTrain, pcAnes_comp, pcAwa_comp);
        
        thresh = 0.5;
        undet_thresh = .20;
        
        classAnes = find(P_test(:,1)>thresh-undet_thresh);
        realAnes = find(testTargets ==1);
        classAwa = find(P_test(:,2)>thresh-undet_thresh);
        realAwa = find(testTargets ==2);
        
        hitAnes = ismember(classAnes, realAnes);
        hitAnes_rate =  numel(find(hitAnes ==1))/numel(realAnes)

        hitsAwa_compAllAn = ismember(classAwa, realAwa);
        hitAwa_rate_compAllAn = numel(find(hitsAwa_compAllAn ==1))/numel(realAwa)
        
        falsePosAnes = numel(find(hitAnes ==0))/(numel(find(hitsAwa_compAllAn ==1))+ numel(find(hitAnes ==0)))
        falsePosAwa__compAllAn = numel(find(hitsAwa_compAllAn ==0))/(numel(find(hitAnes ==1))+ numel(find(hitsAwa_compAllAn ==0)))
        
        
        save('LDA_Iso_Awake.mat', 'hitAnes_rate', 'falsePosAnes', 'hitAwa_rate_compAllAn', ...
            'falsePosAwa__compAllAn', '-append')
    end
end

