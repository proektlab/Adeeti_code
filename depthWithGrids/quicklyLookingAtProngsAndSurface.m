%% Looking at single trials and avarages of the 2 prong laminar data 

% 12/01/18 AA

clear
clc

dirIn =  '/data/adeeti/ecog/flashes_depth_ECoG_2018/1x2Shank_with_ECoG/';

cd(dirIn)
identifier = '*2.mat';
allData = dir(identifier);

load('dataMatrixFlashes.mat')
load('matStimIndex.mat')


experiment = 1;

dirName = allData(experiment).name;
load(dirName, 'info', 'meanSubData')

depthProbes = meanSubData(info.forkChannels,:,:);

