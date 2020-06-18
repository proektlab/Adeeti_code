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
screensize=get(groot, 'Screensize');

%%
BOOTSTRAP =1;
NUM_BOOT = 25;
compRaw =0;
fr = 35;
interpBy = 3;
steps = [500:2000];

ISOPROP = 1;
AWAISOKET = 1;

%%

if AWAISOKET ==1
    dirOut = [dirGaborTesting, 'Awake/'];
    mkdir(dirOut);
    for g = 1%:length(allMiceAwa)
        genDirM = [genDirAwa, (allMiceAwa{g}), '/'];
        cd(genDirM)
         allDir = [dir('GL*')]; %;dir('*IP2');dir('*CB3')];
         
         if g ==1
             startD =1;
         else
             startD = 1;
         end
          
        for d = startD:length(allDir)
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

            [isoHighExp, isoLowExp, ~, ~, awaLastExp, ketExp] = ...
                findAnesArchatypeExp(dataMatrixFlashes, expIDNum);
             MFE = [isoHighExp, isoLowExp, awaLastExp, ketExp];

            %% Finding correct experiments, loading data, detrending (mean subtracting), ...
            %  decimating, and bootstrap avgs/sliding window avgs
            for a = 1:length(MFE)
                if isnan(MFE(a))
                    continue
                end
                experiment = allData(MFE(a)).name;
                disp(experiment(1:end-8));
                
                clearvars interp3STs_EP interp1STs_EP 
%                 [rawCoh35, interp1Coh35, info,~] = makeStillEcogGrids(experiment, steps, fr, interpBy, ...
%                     stimIndex, BOOTSTRAP, NUM_BOOT, compRaw);
%                  save([dirOut, 'gaborCoh', experiment(1:end-8), '.mat'], 'rawCoh35', 'interp1Coh35', 'info')
                
%                 [~, interp3BootCoh35, ~,~] = makeStillEcogGrids(experiment, steps, fr, interpBy, stimIndex, BOOTSTRAP, NUM_BOOT, compRaw);
%                 save([dirOut, 'gaborCoh', experiment(1:end-8), '.mat'], 'interp3BootCoh35', '-append')
%                 
%                 [~, interp3Coh35, ~,~] = makeStillEcogGrids(experiment, steps, fr, interpBy, stimIndex, 0, 1, 0);
%                 save([dirOut, 'gaborCoh', experiment(1:end-8), '.mat'], 'interp3Coh35', '-append')
%                      
                makeSTs = 1;
                tic
                 %[~, ~, ~,interp1STs] = makeStillEcogGrids(experiment, steps, fr, 1, stimIndex, 0, 1, 0, makeSTs);
                % [~, ~, ~,interp3STs] = makeStillEcogGrids(experiment, steps, fr, 3, stimIndex, 0, 1, 0, makeSTs);
                 
                 [interp1STs_EP, info] = makeStillEcogGrids_singleTr(experiment, 1000:1350, fr, 1, stimIndex);
                 save([dirOut, 'gaborCoh', experiment(1:end-8), '.mat'], 'interp1STs_EP', '-append')
                 
                 clearvars interp3STs_EP interp1STs_EP 
                 [interp3STs_EP, info] = makeStillEcogGrids_singleTr(experiment, 1000:1350, fr, 3, stimIndex);
                                 
                 save([dirOut, 'gaborCoh', experiment(1:end-8), '.mat'], 'interp3STs_EP', '-append')
                 toc

            end
        end
    end
end

 