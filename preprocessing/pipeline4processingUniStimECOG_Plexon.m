% Preprocessing code on workstation
% snippits already made from convertPL2intoMat_Plexon or
% convertPL2intoMat_Plexon_LinuxWS

% clear
% clc
%
% dirIn = '/synology/adeeti/ecog/iso_awake_VEPs/GL7/';
% dirPic = '/synology/adeeti/ecog/images/Iso_Awake_VEPs/GL7/preprocessing/';
% dirOut = dirIn;
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
%
% identifier = '2019*.mat';
% START_AT= 1;
mkdir(dirOut)
mkdir(dirPic)

%% Making info files

makeInfoFiles_Plexon(driveLocation, excelFileName, excelSheet, dirIn, identifier, dirOut, MAXSTIM)

%% Finding noise Channels
if ADD_MAN_NOISE_CHANNELS ==1
    numbOfSamp = 8;
    cd(dirOut)
    allData = dir(identifier);
    [info] = adddManNoiseChan_allExpMouse(allData,  ANALYZE_IND, numbOfSamp);
end

%% Removing artifact region in LFP singal and interpolating over signal
if REMOVE_STIM_ARTIFACT == 1
    artifactRegion = [1000:1015];
    for i = 1:length(allData)
        load(allData(i).name, 'dataSnippits')
        [interpSnippits] = removingArtifactAndInterpolating(dataSnippits, artifactRegion);
        save(allData(i).name, 'dataSnippits', '-append')
    end
end

%% Creating big ass matrix
cd(dirIn)
allData = dir(identifier);
electStim = 0; %0 if sensory, 1 if electrical

creatingBigAssMatrix

%% Adding Unique Series and Index Series to plexon data
addUniStimIndexUniqueSeries = 1;
adj4arduino = 0;

addingUniqueIndexSeries_uniStim(dirIn, identifier, stimIndex, adj4arduino)
addingUniqueIndexSeries_infoDataMat(dirIn, identifier, stimIndex)

%% Creating stimIndexMatrix
cd(dirIn)
[matStimIndex] = creatingStimMatrix(dirIn);

%% Clean data, mean subtract make average pictures
close all

START_AT = 1;
flashOn = [0,0];
before = 1;
after = 2;
markTime = -before:.1:after;
screensize=get(groot, 'Screensize');

if ~exist('dirPic')
    mkdir(dirPic)
end

cd(dirIn)
allData = dir(identifier);

for experiment = START_AT:length(allData)
    dirName = allData(experiment).name;
   [meanSubData, meanSubFullTrace] = meanSubAndAvgTrace(dirName, before, after);
end

%% Making Preprocessing pics 
[stFig, avFig] = makingPreprocessingPictures(dirIn, identifier, dirPic, ...
    PicByTrialType, PicByAnesType, PicByAnesAndTrial, before, after, flashOn);
close all
