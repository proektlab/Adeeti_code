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
dirIsoProp = [dataLoc, 'adeeti/ecog/matIsoPropMultiStimVIS_ONLY_/flashTrials/'];
outlineLoc = [codeLoc, 'Adeeti_code/'];
dirGaborTesting = [dataLoc,'adeeti/spatialParamWaves/'];

allMiceAwa = [{'goodMice'}; {'maybeMice'}];

ident1Awa = '2019*';
ident2Awa = '2020*';
identifierIsoProp = '20*.mat*';
stimIndex = [0, Inf];


%%
BOOTSTRAP =1;
NUM_BOOT = 1;
NUM_SETs = 25;
compRaw =0;

stimIndex = [0, Inf];

%trial = 50;
fr = 35;
screensize=get(groot, 'Screensize');
%interpBy = 3;
interpBy = 50;
steps = [900:1300];

ISOPROP = 1;
AWAISOKET = 1;


%%

if AWAISOKET ==1
    dirOut = [dirGaborTesting, 'Awake/'];
    mkdir(dirOut);
    for g = 2%:length(allMiceAwa)
        genDirM = [genDirAwa, (allMiceAwa{g}), '/'];
        cd(genDirM)
         allDir = [dir('GL*'); dir('*IP2');dir('*CB3')];
         
         if g ==2
             startD =1;
         else
             startD = 1;
         end
          
        for d = startD%:length(allDir)
            mouseID = allDir(d).name;

            dirIn = [genDirM, mouseID, '/'];
            cd(dirIn)
            load('dataMatrixFlashes.mat')
            dirFILT = [dirIn,'FiltData/'];
            cd(dirFILT)
            
            
            allData = dir(ident1Awa);
            identifier = ident1Awa;
            
            if isempty(allData)
                allData = dir(ident2Awa);
                identifier = ident2Awa;
            end
            
            if contains(mouseID, 'GL')
                expIDNum = str2num(mouseID(3:end))
            elseif contains(mouseID, 'CB')
                expIDNum = str2num(mouseID(3:end))
                expIDNum = -expIDNum;
            elseif contains(mouseID, 'IP')
                expIDNum = 0;
            end

            [isoHighExp, isoLowExp, emergExp, awaExp1, awaLastExp, ketExp] = ...
                findAnesArchatypeExp(dataMatrixFlashes, expIDNum);
            

             MFE = [isoHighExp, isoLowExp, awaLastExp, ketExp];
            
            
            
            %% Finding correct experiments, loading data, detrending (mean subtracting), ...
            %  decimating, and bootstrap avgs/sliding window avgs
            for a = 3%:length(MFE)
                if isnan(MFE(a))
                    continue
                end
                experiment = allData(MFE(a)).name;
                disp(experiment(1:end-8));
                
                clearvars interp50Boot
                
                [rawFiltDataTimes, interpFiltDataTimes, info] = makeStillEcogGrids(experiment, steps, fr, 3, stimIndex, 0, 1);
                [~, interp100FiltDataTimes, ~] = makeStillEcogGrids(experiment, steps, fr, 100, stimIndex, 0, 1);
                save([dirOut, 'gaborCoh', experiment(1:end-8), '.mat'], 'rawFiltDataTimes', 'interp100FiltDataTimes', 'interpFiltDataTimes', 'info')
                
                for i = 1:NUM_SETs
                    clearvars interp50Boot* tempBoot bootTrials*
                    [~, bootTrials, ~] = makeStillEcogGrids(experiment, steps, fr, interpBy, stimIndex, BOOTSTRAP, NUM_BOOT, compRaw);
                    %  [~, interp100Boot, ~] = makeStillEcogGrids(experiment, steps, fr, 100, stimIndex, BOOTSTRAP, NUM_BOOT);
                    eval(['interp50Boot', num2str(floor(i)) '= bootTrials;'])
                    tempBoot = ['interp50Boot', num2str(floor(i))];
                    
                    save([dirOut, 'gaborCoh', experiment(1:end-8), '.mat'], tempBoot, '-append')
                end
                
                
            end
        end
    end
end

 