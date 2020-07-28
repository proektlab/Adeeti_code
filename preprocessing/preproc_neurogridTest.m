%% Analysis

%% entering in data
clear
clc

if isunix
    dirDat = '/synology/adeeti/';
    dirCode = '/synology/code/Adeeti_code/';
elseif ispc
    dirDat = 'Z:\adeeti\';
    dirCode = 'Z:\code\Adeeti_code\';
end

expDate = [{'2020-07-15'}]; %, {'2020-02-19'}];
mouseID = [{'T2_64Chan_test'}, {'T4_32Chan_test'}]; %, {'CB3'}];

mouseECoGFolder = [dirDat, 'ecog/testing_Viv_Neurogrid_ECOG/'];
useArduino = 1;

%% preprocessing

stimIndex = [0, Inf];
identifier = '2019*.mat';
START_AT = 1;
addUniStimIndexUniqueSeries = 1;
adj4arduino = 0;

for dateInd = 2:length(mouseID)
    genPicsDir =  [dirDat, 'ecog/images/testing_Viv_Neurogrid_ECOG/', mouseID{dateInd}, '/'];
    dirIn = [mouseECoGFolder, mouseID{dateInd}, '/'];
    dirOut = dirIn;
    driveLocation = dirCode;  %'/data/adeeti/Dropbox/'; %'/home/adeeti/googleDrive/'; %dropbox location for excel file and saving
    
%     cd(dirIn)
%     allData = dir(identifier);
%     if contains(mouseID{dateInd}, 'T4')
%         [CTChannels, mmInGrid] = findMyProbChannels('T4');
%         
%         [ADChannels] = convertCTOnmChan2PlexOmn(CTChannels)
%         [info] = addGridInd2allInfo(allData, 'gridIndicies', ADChannels,mmInGrid);
%         
%     elseif contains(mouseID{dateInd}, 'T2')
%         [CTChannels, mmInGrid] = findMyProbChannels('T2');
%         
%         [ADChannels] = convertCTOnmChan2PlexOmn(CTChannels);
%         [info] = addGridInd2allInfo(allData, 'gridIndicies', ADChannels,mmInGrid);
%     end
%     dirPic = [genPicsDir, 'preprocessing/'];
%     mkdir(dirPic);
%     [stFig, avFig] = makingPreprocessingPictures(dirIn, identifier,dirPic, 0,1,0);
%     
%     
%     
%     cd(dirIn)
%     allData = dir(identifier);
%     electStim = 0; %0 if sensory, 1 if electrical
%     
%     creatingBigAssMatrix
%     addingUniqueIndexSeries_infoDataMat(dirIn, identifier, stimIndex)
%     findLatency
%     
    
%     
%     %% Wavelets and making average spec pictures
%     clearvars -except dirIn identifier START_AT stimIndex genPicsDir mouseID dateInd infoSheets mouseECoGFolder dirDat dirCode
%     close all
%     dirPic1 = [genPicsDir, 'AverageSpec/'];
%     
%     dirWAVE = [dirIn, 'Wavelets/'];
%     
%     USE_SNIPPITS = 1;
%     PLOT_AVERAGE_SPEC =1;
%     waveletAnalysis
%     
%     %% Filter Data at gamma
%     
%     clearvars -except dirIn identifier START_AT stimIndex dirWAVE genPicsDir mouseID dateInd infoSheets mouseECoGFolder dirDat dirCode
%     close all
    dirWAVE =  [dirIn, 'Wavelets/'];
    
    dirFILT = [dirIn, 'FiltData/'];
    
%     lowBound = 31;
%     highBound = 38;
%     
%     filterDataandHilbertSavingAll
%     
%     %% ITPC
%     clearvars -except dirIn identifier START_AT stimIndex dirWAVE dirFILT genPicsDir mouseID dateInd infoSheets mouseECoGFolder dirDat dirCode
%     close all
%     
%     dirPicITPC = [genPicsDir, 'localITPC/'];
%     useStimIndex = 0;
%     useNumStim = 1;
%     
%     lowestLatVariable = 'lowLat';
%     stimIndex = [0, Inf]; %if want all, stimIndex = matStimIndex; % if want
%     %all uniStimIndexes/multiStimIndexes, use [uniStimIndex, multiStimIndex] =
%     %findUniMutliStimIndex(matStimIndex), [stimIndex, ~] = findUniMutliStimIndex(matStimIndex)
%     
%     numStim = 1;
%     
%     ITPC_for_all_exp
    
    
    %% Single coherence movies
    clc
    clearvars -except dirIn identifier START_AT stimIndex dirWAVE dirFILT genPicsDir ...
        mouseID dateInd infoSheets mouseECoGFolder dirDat dirCode
    close all
    
    dropboxLocation = dirCode;
    fr = 35;
    dirMovies = [genPicsDir, 'coher35MoviesOutlines/'];
    
    moviesCoherenceSinglesOnly
    %%
    %     clc
    %     clearvars -except dirIn identifier START_AT stimIndex dirWAVE dirFILT ...
    %         genPicsDir mouseID dateInd infoSheets mouseECoGFolder dirDat dirCode dropboxLocation
    %     close all
    %
    %     dirCohCompMovies = [genPicsDir, 'coherCoh/'];
    %     fr = [35];
    %
    %     compIsoAwkKetCohMovs_singMouse
    
    %
    %%
end
