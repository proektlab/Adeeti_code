%% Making movie heat plot of ITPC

%% Make movie of mean signal at 30-40 Hz for all experiments
clear
clc
close all
%%
if isunix && ~ismac
    dataLoc = '/synology/';
    codeLoc = '/synology/code/';
elseif ispc
    dataLoc = 'Z:\';
    codeLoc = 'Z:\code\';
end

genDirAwa = [dataLoc, 'adeeti/ecog/iso_awake_VEPs/'];
outlineLoc = [codeLoc, 'Adeeti_code/'];
dirGaborTesting = [dataLoc,'adeeti/GaborTests/'];

allMiceAwa = [{'goodMice'}; {'maybeMice'}];

ident1Awa = '2019*';
ident2Awa = '2020*';
stimIndex = [0, Inf];


%%
BOOTSTRAP =0;
NUM_BOOT = 1;

stimIndex = [0, Inf];

%trial = 50;
fr = 35;
screensize=get(groot, 'Screensize');
%interpBy = 3;
interpBy = 100;
steps = [900:1300];


%%

allMice = [6, 9, 13];

dirOut = [dirGaborTesting, 'Awake/'];
mkdir(dirOut);

for g = 1%:length(allMiceAwa)
    genDirM = [genDirAwa, (allMiceAwa{g}), '/'];
    cd(genDirM)
    allDir = [dir('*GL6'); dir('*GL9');dir('*GL13')];
    
    for d = 1:length(allDir)
        mouseID = allDir(d).name;
        disp(mouseID)
        dirIn = [genDirM, mouseID, '/'];
        
        %% finding the correct experiments
        cd(dirIn)
        load('dataMatrixFlashes.mat')
        
        [isoHighExp, isoLowExp, emergExp, awaExp1, awaLastExp, ketExp] = findAnesArchatypeExp(dataMatrixFlashes, allMice(d));
        
        MFE = [isoHighExp, isoLowExp, awaLastExp, ketExp];
        titleString = {'High Isoflurane', 'Low Isoflurane', 'Awake', 'Ketamine'};
        
        %% finding filtered data 
        dirFILT = [dirIn,'FiltData/'];
        cd(dirFILT)
        
        allData = dir(ident1Awa);
        identifier = ident1Awa;
        
        if isempty(allData)
            allData = dir(ident2Awa);
            identifier = ident2Awa;
        end
        %% Finding correct experiments, loading data, detrending (mean subtracting), ...
        %  decimating, and bootstrap avgs/sliding window avgs
        
        for a = 1:length(MFE)
            experiment = allData(MFE(a)).name;
            disp(experiment(1:end-8));
            
            %[rawFiltDataTimes, interpFiltDataTimes, info] = makeStillEcogGrids(experiment, steps, fr, interpBy, stimIndex, BOOTSTRAP, NUM_BOOT);
            [~, interp100FiltDataTimes, ~] = makeStillEcogGrids(experiment, steps, fr, interpBy, stimIndex, BOOTSTRAP, NUM_BOOT);
            
            %save([dirOut, 'gaborCoh', experiment, '.mat'], 'rawFiltDataTimes', 'interpFiltDataTimes', 'info')
            save([dirOut, 'gaborCoh', experiment(1:end-8), '.mat'], 'interp100FiltDataTimes', '-append')
        end
    end
end

%% Try 2D FFT 
    twoDFFT_movies_GL9
%% Try 2D multitaper
    compCoh_2DMTSpec
    
    
    
    
    
    
    
