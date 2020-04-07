%% looking at comparing isohigh iso low and awake

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
allLowIsoHit = [];
allAwakeHit = [];
allLowIsoConHit = [];
allHighIsoConHit = [];

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
        load('LDA_Iso_Awake.mat')
        
        %% LDA to distingish high iso from low iso
        allLowIsoHit = [allLowIsoHit, hitLowIso_rate];
        allAwakeHit = [allAwakeHit, hitAwake1_rate];
        allLowIsoConHit = [allLowIsoConHit, hitLowIso_con_rate];
        allHighIsoConHit = [allHighIsoConHit, hitHighIso_con_rate];
        
    end
end




%%

compIsoAwa(:,1) = allLowIsoHit;
compIsoAwa(:,2) = allAwakeHit;

compIsoCon(:,1) = allLowIsoConHit;
compIsoCon(:,2) = allHighIsoConHit;

figure 
boxplot(compIsoAwa(:,1:2),'Labels',{'Low Iso', 'Awake'})%, 'notch', 'on') 
xlabel('Behavioral state')

figure
boxplot(compIsoCon(:,1:2), 'Labels',{'Low Iso', 'High Iso'})%, 'notch', 'on') 
xlabel('Anes state')
