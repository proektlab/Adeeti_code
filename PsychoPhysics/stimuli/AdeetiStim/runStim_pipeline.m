%% Adeeti pipeline for stimulus set up 

%% General Set Up
clear all
close all
clc
sca
stimDir = '/home/adeeti/PsychoPhysics/stimuli/AdeetiStim/';
cd(stimDir);

% Here we call some default settings for setting up Psychtoolbox
clear params
rng('shuffle')

% Setup PTB with some default values
PsychDefaultSetup(2);

%% Setting up parameters

%Constants: viewing distance, pixel size, ppd
params.distanceToMonitor=30; %cm
params.mouseID = 'StimTest1';
params.Date=date;

params = configureScreens_pipelineAA(params); % Set up monitors and initialize blank screen - grey background

% Make sure the GLSL shading language is supported:44
AssertGLSL;

display('ready');
%% 0) Gratings to find cells

display('ready');
ListenChar(-1)
surveyingSpatialFreq_DriftingGrating_med
ListenChar(1)

%% 1) Splot to get the spatial RF which will be used as the aperture in all future stims
ListenChar(-1)
params.TrackID='02';
spatial_map_pipeline
sca
ListenChar(1)

%% 1.5) Gratings of different contrasts
sca
%setup center of aperture and its size
%xcenter=900; ycenter=600;

%import from splot
xcenter=params.sx;
ycenter=params.sy; 

texsize=floor((30/0.0483)); 
sf=0.02;
tf=2;

%run just a test grating at different contrasts
contrasts_test=[0.05 0.1 0.2 0.3 0.4 0.6 1];
num_trials=20;
total=length(contrasts_test)*num_trials;
rand_ord=randperm(total);
for i=1:total
    ind=((mod(rand_ord(i),length(contrasts_test))==0)*length(contrasts_test))+mod(rand_ord(i),length(contrasts_test));
    test_con(i)=contrasts_test((ind));
    gratings_contrast(params,xcenter, ycenter,texsize, test_con(i),sf,tf);
end

%save parameters of this stimulus
h=datestr(clock,0);
date_str=[h(1:11),'-',h(13:14),'-',h(16:17),'-',h(19:20)];
save([params.mouseID,'_Contrast_',date_str,'.mat'],'params','texsize','contrasts_test', 'test_con', 'xcenter', 'ycenter', 'sf', 'tf'); 

%% 2) Square pulse to get cell type (ON vs OFF) identity
%enter duration for one contrast
%square_pulse_twoc(1/4,params);
square_pulse_fourc(1/4,params);

%% 2) RFmapping with filtered white noise, using appereture from splot
%create whitenoise and save
%  numBlocks=2; 
%  rectSize=57;q
%  numFramesPerBlock=5000;
%  [blurredimage,totalFrames,blockStart]=createWhiteNoise(params,rectSize,numBlocks,numFramesPerBlock);
%  save(['whitenoise.mat']); ifi
 
params.RFpixelDeg=3; %x degrees per RF pixel (RF pixels are different than larger monitor pixels!)
fullScreen_flag=1;
numBlocks=2;
[params,filtnoise]=RFmapping_pipeline(params, numBlocks,fullScreen_flag); 
%save parameters of this stimulus
h=datestr(clock,0);
date_str=[h(1:11),'-',h(13:14),'-',h(16:17),'-',h(19:20)];
save([params.mouseID,'_LPFN_',date_str,'.mat'],'params','filtnoise'); 

%% Apperture with varying contrast (for temporal precision)

clearvars -except params
%change the full-field contrast of 
refreshrate=15 ; %must be < and evenly  divisble into 120 Hz (e.g. 15, 30, 60)Hz
numFramesPerBlock=100;     
numBlocks=60;          
 
%create contrast loopf           
contrast=rand(1,numFramesPerBlock);         
clear missed duration record contrast2 ind_missed num_missed 
[missed,duration]=ContrastFlicker_pipeline(params,refreshrate,numBlocks,contrast);

%save parameters of this stimulus
h=datestr(clock,0);
date_str=[h(1:11),'-',h(13:14),'-',h(16:17),'-',h(19:20)];
save([params.mouseID,'_ContrastFF_',date_str,'.mat'],'params','contrast','missed','duration','numBlocks','numFramesPerBlock','refreshrate');

%% Natural Noise movie
sca
%rescale the movie Dawei gave me, and play it at 60Hz
cd('/home/diegoc/Desktop/Movie Files/mp4/');
addpath('/home/diegoc/Dropbox/Mouse/stimuli/');
PlayMoviesWithoutGapDemo2_test2('*.mp4');
cd ('/home/diegoc/Dropbox/Mouse/stimuli/');


%% etc (gray screen)
gray_screen_pipeline

%% Clean up and close 
% cleanUp();