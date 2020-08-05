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

if ismac
    cd ('/Users/contreras/Dropbox/Mouse/stimuli/');
elseif IsLinux
    cd ('/home/diegoc/Dropbox/Mouse/stimuli/');
end
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
% Make sure the GLSL shading language is supported:
AssertGLSL;

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Enter mouse number and date
params.mouseID = 'M021';
params.Date=date;

%clc
display('ready');
%% 0) Gratings to find cells
sca
ListenChar(2)
fplot_pipeline
ListenChar(1)

%% 1) Splot to get the spatial RF which will be used as the aperture in all future stims
% 
ListenChar(2)
params.TrackID='01';
spatial_map_pipeline
sca

ListenChar(1)




%% 1.5) Plaid
sca
%setup center of aperture and its size
%xcenter=900; ycenter=600;



%import from splot
xcenter=params.sx;
ycenter=params.sy; 


texsize=floor((20/0.0483)); 
sf=0.02;


tf=1;

%run just a test grating at different contrasts
contrasts_test=[0.04, 0.08, 0.16,0.25, 0.32, 0.5, 0.64,0.8,1];
num_trials=10;
total=length(contrasts_test)*num_trials;

for i=1:total
    ind=((mod(i,length(contrasts_test))==0)*length(contrasts_test))+mod(i,length(contrasts_test));
    test_con(i)=contrasts_test(ind);
    test_pipeline_loop2(params,xcenter, ycenter,texsize, test_con(i),sf,tf);



end
save([params.mouseID,'_',params.TrackID,'_contrast_gratings.mat'],'texsize','contrasts_test', 'test_con', 'xcenter', 'ycenter', 'sf', 'tf');


% %run the full plaid programz
% %fix mask contrast, change test `contrast
% contrasts_test=[0.04, 0.08, 0.16,0.25, 0.32];
% contrasts_mask=[0.1 0.2 0.4];
% 
% total=length(contrasts_mask)*length(contrasts_test)
% order=1:total;
% order_rand=randperm(total);
% %from order pull out index i of mask contrast and index j of test_contrast

% for i=1:total
%     index_test=((mod(order_rand(i),length(contrasts_test))==0)*length(contrasts_test))+mod(order_rand(i),length(contrasts_test));
%     index_mask=((mod(order_rand(i),length(contrasts_test))==0)*-1)+floor(order_rand(i)/length(contrasts_test))+1;
%     test_con(i)=contrasts_test(index_test);
%     mask_con(i)=contrasts_mask(index_mask);
%     Plaid_pipeline_loop(params,xcenter, ycenter,texsize, test_con(i), mask_con(i),sf,tf);
% end
% Screen('Preference', 'Verbosity', 3); % Don't log the GL stuff
% save([params.mouseID,'_',params.TrackID,'_plaid_params.mat'],'texsize','test_con','mask_con','contrasts_mask', 'contrasts_test', 'order_rand', 'xcenter', 'ycenter', 'sf', 'tf');

%% 2) Square pulse to get cell type (ON vs OFF) identity
          
square_pulse
%% 2) RFmapping with filtered white noise, using appereture from splot
%create whitenoise and save
%  numBlocks=2; 
%  rectSize=57;
%  numFramesPerBlock=5000;
%  [blurredimage,totalFrames,blockStart]=createWhiteNoise(params,rectSize,numBlocks,numFramesPerBlock);
%  save(['whitenoise.mat']); ifi

 
params.RFpixelDeg=3; %x degrees per RF pixel (RF pixels are different than larger monitor pixels!)
fullScreen_flag=0;
%now get RF 
numBlocks=2;
[params,filtnoise]=RFmapping_pipeline(params, numBlocks,fullScreen_flag); 
save([params.mouseID,'_',params.TrackID,'_stim_params.mat'],'params','filtnoise'); 

% %% etc (gray screen)
% % gray_screen_pipeline
%% Apperture with varying contrast (for temporal precision)
% 
clearvars -except params
%change the full-field contrast of 
refreshrate=1 ; %must be < and evenly  divisble into 120 Hz (15, 30, 60)Hz
numFramesPerBlock=500;     
numBlocks=30;          
 
%create contrast loopf           
contrast=rand(1,numFramesPerBlock);         
 
clear missed duration record contrast2 ind_missed num_missed 
[missed,duration]=ContrastFlicker_pipeline(params,refreshrate,numBlocks,contrast);
save([params.mouseID,'_',params.TrackID,'_stim_params.mat'],'params','filtnoise','contrast'); 

%% Natural Noise movie
sca
% %rescale the movie Dawei gave me, and play it at 60Hz
cd('/home/diegoc/Desktop/Movie Files/mp4/');
addpath('/home/diegoc/Dropbox/Mouse/stimuli/');
PlayMoviesWithoutGapDemo2_test2('*.mp4');6

% %% Clean up and close 
% cleanUp();
