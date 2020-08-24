%% To perform spectral analysis on all data 

%% entering in data 

% clear
% clc
% 
% genDirIn = '/synology/adeeti/plexonData_adeeti/2019-11-26/';
% genDirOut =  '/synology/adeeti/ecog/iso_awake_VEPs/GL7/';
% identifierSubjects = '2019*';
% 
% identifierFile = '*.pl2';
% START_AT= 1;

% clearvars eventsChan
% eventsChan{1} = 'EVT01';
% 
% convertPL2intoMat_Plexon_LinuxWS


%% preprocessing 
% clear
% clc
% 
 dirIn = '/synology/adeeti/ecog/iso_awake_VEPs/GL8/';
% dirPic = '/synology/adeeti/ecog/images/Iso_Awake_VEPs/GL7/preprocessing/';
% dirOut = dirIn;
 stimIndex = [0, Inf];
 identifier = '2019*.mat';
 START_AT = 1;
% 
% driveLocation = '/home/adeeti/Dropbox/';  %'/data/adeeti/Dropbox/'; %'/home/adeeti/googleDrive/'; %dropbox location for excel file and saving
% 
% excelFileName = 'ProektLab_code/Adeeti_code/preprocessing/Iso_Awake_VEPs.xlsx';
% excelSheet = 4;
% 
% MAXSTIM = 1;
% ADD_MAN_NOISE_CHANNELS = 0;
% ANALYZE_IND = 0;
% REMOVE_STIM_ARTIFACT = 0;
% 
% PicByTrialType = 0;
% PicByAnesType = 1;
% PicByAnesAndTrial = 0;

% run /home/adeeti/Dropbox/ProektLab_code/Adeeti_code/preprocessing/pipeline4processingUniStimECOG_Plexon.m

%% finding latency 
% clearvars -except dirIn identifier START_AT stimIndex

%findLatency

%% Wavelets and making average spec pictures 
clearvars -except dirIn identifier START_AT stimIndex
close all
dirPic1 = '/synology/adeeti/ecog/images/Iso_Awake_VEPs/GL8/AverageSpec/';
dirWAVE = [dirIn, 'Wavelets/'];

USE_SNIPPITS = 1;

%waveletAnalysis

%% Filter Data at gamma 

clearvars -except dirIn identifier START_AT stimIndex dirWAVE
close all
dirWAVE =  [dirIn, 'Wavelets/'];
dirFILT = [dirIn, 'FiltData/'];

%filterDataandHilbertSavingAll

%% ITPC 

clearvars -except dirIn identifier START_AT stimIndex dirWAVE dirFILT
close all

dirPicITPC = '/synology/adeeti/ecog/images/Iso_Awake_VEPs/GL8/localITPC/';

useStimIndex = 0;
useNumStim = 1;

lowestLatVariable = 'lowLat';
stimIndex = [0, Inf]; %if want all, stimIndex = matStimIndex; % if want
%all uniStimIndexes/multiStimIndexes, use [uniStimIndex, multiStimIndex] =
%findUniMutliStimIndex(matStimIndex), [stimIndex, ~] = findUniMutliStimIndex(matStimIndex)

numStim = 1;

ITPC_for_all_exp

%%
clc
clearvars -except dirIn identifier START_AT stimIndex dirWAVE dirFILT
close all

dirCoh35Movies = '/synology/adeeti/ecog/images/Iso_Awake_VEPs/GL8/coher35MoviesOutlines/'; %'Z:\adeeti\ecog\images\Iso_Awake_VEPs\GL_early\coher35MoviesOutlines\';
dropboxLocation = '/home/adeeti/Dropbox/KelzLab/'; %'C:\Users\adeeti\Dropbox\KelzLab\';

moviesCoherenceMultAnes
