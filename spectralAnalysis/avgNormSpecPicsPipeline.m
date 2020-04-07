%% Sequence to run 

clear
close all
USE_SNIPPITS = 1;

%% baseline normalized wavelets on grating mice GT2 
dirIn = '/synology/adeeti/ecog/matGratingTesting/GT2/';
dirPic1 = '/synology/adeeti/ecog/images/gratingTesting/GT2/AverageSpec/';
identifier = '2019*.mat';

makeNormSpecPics

%% baseline normalized wavelets on grating mice GT4
dirIn = '/synology/adeeti/ecog/matGratingTesting/GT4/';
dirPic1 = '/synology/adeeti/ecog/images/gratingTesting/GT4/AverageSpec/';
identifier = '2019*.mat';

makeNormSpecPics

%% baseline normalized wavelets on grating mice GT4
dirIn = '/synology/adeeti/ecog/iso_awake_VEPs/GL_early/';
dirPic1 = '/synology/adeeti/ecog/images/Iso_Awake_VEPs/GL_early/AverageSpec/';
identifier = '2019*.mat';

makeNormSpecPics