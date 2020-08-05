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

dirIsoProp = [dataLoc, 'adeeti/ecog/matIsoPropMultiStimVIS_ONLY_/flashTrials/'];
outlineLoc = [codeLoc, 'Adeeti_code/'];
dirGaborTesting = [dataLoc,'adeeti/spatialParamWaves/'];


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


%%

if ISOPROP ==1
    
    dirOut = [dirGaborTesting, 'IsoProp/'];
    mkdir(dirOut);
    dirIsoPropFiltData = [dirIsoProp, 'FiltData/'];
    cd(dirIsoPropFiltData)
    allData = dir(identifierIsoProp);
    
    for a = 1:length(allData)
        experiment = allData(a).name;
        disp(experiment(1:end-8));
        
        
        %% Finding correct experiments, loading data, detrending (mean subtracting), ...
        %  decimating, and bootstrap avgs/sliding window avgs
        
        clearvars interp100Boot
        % [rawFiltDataTimes, interpFiltDataTimes, info] = makeStillEcogGrids(experiment, steps, fr, 3, stimIndex, 0, 1);
        %[~, interp100FiltDataTimes, ~] = makeStillEcogGrids(experiment, steps, fr, 3, stimIndex, 0, 1);
        for i = 1:NUM_SETs
            clearvars interp100Boot* tempBoot bootTrials*
            [~, bootTrials, ~] = makeStillEcogGrids(experiment, steps, fr, 50, stimIndex, BOOTSTRAP, NUM_BOOT, compRaw);
            %  [~, interp100Boot, ~] = makeStillEcogGrids(experiment, steps, fr, 100, stimIndex, BOOTSTRAP, NUM_BOOT);
            eval(['interp100Boot', num2str(floor(i)) '= bootTrials;'])
            tempBoot = ['interp100Boot', num2str(floor(i))];
            
            save([dirOut, 'gaborCoh', experiment(1:end-8), '.mat'], tempBoot, '-append')
        end
        
        % save([dirOut, 'gaborCoh', experiment, '.mat'], 'rawBoot', 'interp3Boot', 'interp100Boot', '-append')
    end
end


