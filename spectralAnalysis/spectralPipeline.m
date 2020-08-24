%% To perform spectral analysis on all data 

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

expDate = [{'2020-07-04'}]; %, {'2020-02-19'}];
mouseID = [{'CB6'}]; %, {'CB3'}];
identifierSubjects = '2020*';
mouseECoGFolder = [dirDat, 'ecog/iso_awake_VEPs/'];
infoSheets = [11]; %];

for i = 1:length(expDate)
genPicsDir =  [dirDat, 'ecog/images/Iso_Awake_VEPs/', mouseID{i}, '/'];
genDirIn = [dirDat, 'plexonData_adeeti/', expDate{i}, '/'];
genDirOut =  [mouseECoGFolder, mouseID{i}, '/'];

identifierFile = '*.pl2';
START_AT= 1;

clearvars eventsChan
eventsChan{1} = 'EVT01';

convertPL2intoMat_Plexon_LinuxWS

clearvars -except genDirOut genPicsDir mouseID expDate identifierSubjects mouseECoGFolder infoSheets dirDat dirCode
end

%% preprocessing 
% clear
% clc
%
for dateInd = 1:length(mouseID)
genPicsDir =  [dirDat, 'ecog/images/Iso_Awake_VEPs/', mouseID{dateInd}, '/'];
dirIn = [mouseECoGFolder, mouseID{dateInd}, '/'];
dirPic = [genPicsDir, 'preprocessing/'];
 dirOut = dirIn;
 stimIndex = [0, Inf];
 identifier = '2020*.mat';
 START_AT = 1;

driveLocation = dirCode;  %'/data/adeeti/Dropbox/'; %'/home/adeeti/googleDrive/'; %dropbox location for excel file and saving

excelFileName = 'preprocessing/Iso_Awake_VEPs.xlsx';
excelSheet = infoSheets(dateInd);

MAXSTIM = 1;
ADD_MAN_NOISE_CHANNELS = 0;
ANALYZE_IND = 0;
REMOVE_STIM_ARTIFACT = 0;

PicByTrialType = 0;
PicByAnesType = 1;
PicByAnesAndTrial = 0;

run pipeline4processingUniStimECOG_Plexon.m

%% finding latency 
clearvars -except dirIn identifier START_AT stimIndex genPicsDir mouseID dateInd infoSheets mouseECoGFolder dirDat dirCode

findLatency

%% Wavelets and making average spec pictures 
clearvars -except dirIn identifier START_AT stimIndex genPicsDir mouseID dateInd infoSheets mouseECoGFolder dirDat dirCode
close all
dirPic1 = [genPicsDir, 'AverageSpec/'];

dirWAVE = [dirIn, 'Wavelets/'];

USE_SNIPPITS = 1;
PLOT_AVERAGE_SPEC =1;
waveletAnalysis

%% Filter Data at gamma 

clearvars -except dirIn identifier START_AT stimIndex dirWAVE genPicsDir mouseID dateInd infoSheets mouseECoGFolder dirDat dirCode
close all
dirWAVE =  [dirIn, 'Wavelets/'];

dirFILT = [dirIn, 'FiltData/'];

lowBound = 20;
highBound = 80;

filterDataandHilbertSavingAll

%% ITPC 
clearvars -except dirIn identifier START_AT stimIndex dirWAVE dirFILT genPicsDir mouseID dateInd infoSheets mouseECoGFolder dirDat dirCode
close all

dirPicITPC = [genPicsDir, 'localITPC/'];
useStimIndex = 0;
useNumStim = 1;

lowestLatVariable = 'lowLat';
stimIndex = [0, Inf]; %if want all, stimIndex = matStimIndex; % if want
%all uniStimIndexes/multiStimIndexes, use [uniStimIndex, multiStimIndex] =
%findUniMutliStimIndex(matStimIndex), [stimIndex, ~] = findUniMutliStimIndex(matStimIndex)

numStim = 1;

ITPC_for_all_exp

%%
% clc
% clearvars -except dirIn identifier START_AT stimIndex dirWAVE dirFILT genPicsDir mouseID dateInd infoSheets mouseECoGFolder
% close all
% 
% dirCoh35Movies = [genPicsDir, 'coher35MoviesOutlines/']; 
% dropboxLocation = '/home/adeeti/Dropbox/ProektLab_code/Adeeti_code/'; %'C:\Users\adeeti\Dropbox\KelzLab\';
% 
% moviesCoherenceMultAnes

%%

clc
clearvars -except dirIn identifier START_AT stimIndex dirWAVE dirFILT genPicsDir mouseID dateInd infoSheets mouseECoGFolder dirDat dirCode
close all

fr = 35;
dirCoh35Movies = [genPicsDir, 'coher35MoviesOutlines/']; 
dropboxLocation = '/home/adeeti/Dropbox/ProektLab_code/Adeeti_code/'; %'C:\Users\adeeti\Dropbox\KelzLab\';

%% 
moviesCoherenceSinglesOnly
%% 
end
