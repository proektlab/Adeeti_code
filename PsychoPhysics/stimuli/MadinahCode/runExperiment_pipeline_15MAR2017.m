% Main file for routine mouse LGN epxeriments: find units, map receptive
% fields, etc.

%6/13/2016
%Updated to use PsychImaging Pipeline instead of the low-level screen
%functions
%% Initialize
clear all
close all
clc
sca
PsychDataPixx('Close');
cd ('/home/diegoc/Dropbox/Mouse/stimuli/');

% Here we call some default settings for setting up Psychtoolbox
clear params
rng('shuffle')

% Configure PsychToolbox imaging pipeline to use 32-bit floating point numbers.
% Our pipeline will also implement an inverse gamma mapping to correct for display gamma.
PsychDefaultSetup(2);
PsychImaging('PrepareConfiguration');
PsychImaging('AddTask', 'General', 'FloatingPoint32BitIfPossible');
PsychImaging('AddTask', 'General', 'EnableDataPixxM16Output');
PsychImaging('AddTask', 'FinalFormatting', 'DisplayColorCorrection', 'SimpleGamma');
oldVerbosity = Screen('Preference', 'Verbosity', 1); % Don't log the GL stuff
oldLevel = Screen('Preference', 'VisualDebugLevel', 3); % Disable Psychtoolbox welcome message
 oldRes=SetResolution(1,1920,1200,120);

%Screen('Preference', 'ConserveVRAM', 2^modepower);

% Is there a way to do this only for the Datapixx monitor
datapixxmode = 2;
maxpixval = 2^16-1;

try % This will only work if VPixx is connected
    PsychDataPixx('Open'); % Set up for TTL
    PsychDataPixx('SetVideoMode',datapixxmode); % See documentation. 0 will probably be sufficient for point-light stimuli
    PsychDataPixx('EnableVideoScanningBacklight'); % Scanning backlight for LED pixel on/off artifact minimization (disabled for now)
    Datapixx('StopAllSchedules');
    Datapixx('RegWrRd');
    PsychDataPixx('GetPreciseTime'); %sycnh clocks
    
    params.vpixx_monitor = true; % Indicates vpixx_monitor connected and working
catch
    params.vpixx_monitor = false;
end
 
%Constants: viewing distance, pixel size, ppd
params.distanceToMonitor=30; %cm
params = configureScreens_pipeline(params); % Set up monitors and initialize blank screen - Black background
% Make sure the GLSL shading language is supported:44
AssertGLSL;

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Enter mouse number and date
params.mouseID = 'M028';
params.Date=date;

%clc4444
display('ready');
%% 0) Gratings to find cells
display('ready');
ListenChar(-1)
fplot_pipeline
ListenChar(1)

%% 1) Splot to get the spatial RF which will be used as the aperture in all future stims
ListenChar(-1)
params.TrackID='02';
spatial_map_pipeline
sca
ListenChar(1)
%% 2) Square pulse to get cell type (ON vs OFF) identity
%enter duration for one contrast
square_pulse_twoc(1/8,params);
%square_pulse_fourc(1/4,params);`
%% 3) Apperture with varying contrast (for temporal precision)
clearvars -except params
%change the full-field contrast of 
refreshrate=15 ; %must be < and evenly  divisble into 120 Hz (e.g. 15, 30, 60)Hz
numFramesPerBlock=100;     
numBlocks=100;          
 
%create contrast loopf           
contrast=rand(1,numFramesPerBlock);         
clear missed duration record contrast2 ind_missed num_missed 
[missed,duration]=ContrastFlicker_pipeline(params,refreshrate,numBlocks,contrast);

%save parameters of this stimulus
h=datestr(clock,0);
date_str=[h(1:11),'-',h(13:14),'-',h(16:17),'-',h(19:20)];
save([params.mouseID,'_ContrastFF_',date_str,'.mat'],'params','contrast','missed','duration','numBlocks','numFramesPerBlock','refreshrate');
%% 4) RFmapping with filtered white noise, using appereture from splot
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
%% 5) Gratings of different contrasts
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


%% 6)Natural Noise movie
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