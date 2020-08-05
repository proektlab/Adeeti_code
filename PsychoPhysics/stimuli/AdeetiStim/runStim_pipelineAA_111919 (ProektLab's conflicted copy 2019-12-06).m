%% stimulus paradigm set up: Run Experiment
% 05/30/18 AA original outline
% 11/05/19 AA final script

%% General Set Up
clear

close all
clc
sca
stimDir = '/home/adeeti/Dropbox/ProektLab_code/Adeeti_code/PsychoPhysics/stimuli/AdeetiStim/';
cd(stimDir);
addpath(genpath(stimDir));

% Here we call some default settings for setting up Psychtoolbox
clear params
rng('shuffle')

% Setup PTB with some default values
PsychDefaultSetup(2);
%PsychImaging('PrepareConfiguration');
%PsychImaging('AddTask', 'FinalFormatting', 'DisplayColorCorrection', 'SimpleGamma');

%% Setting up parameters
%Mouse details
params.distanceToMonitor=30; %cm
params.mouseID = 'StimTest1'; 
params.Date=date;

% Computer details
params.monitorInUse = 'testing';
params.os = 1; %1 for on linux, 0 for windows, 2 for mac

% TTL details
params.useArduino = 0; %0 for no arduino, 1 for arduino
params.useLabJack = 1;
params.startTTL = 16; %number of pin for TTL for the start of a trial
params.ulTTL = 17; %number of pin for TTL for the start of a grating in the upper left 
params.urTTL = 18; %number of pin for TTL for the start of a grating in the upper right 
params.llTTL = 19; %number of pin for TTL for the start of a grating in the lower left 
params.lrTTL = 16; %number of pin for TTL for the start of a grating in the lower right 


display('ready');
all_screens = Screen('Screens');

% If more than one monitor connected, display stimuli on all
% non-primary monitors. If only one monitor connected, display stimuli
% on that monitor.

if max(all_screens) == 0
    screens = all_screens;
    warning('No external monitors are connected. Are you sure you want to continue?')
else
    screens = all_screens(all_screens > 0);
end
screenNumber = max(screens);

%save screen and screen colors
params.screenNumber = screenNumber;
params.white = WhiteIndex(screenNumber);
params.black = BlackIndex(screenNumber);
params.gray = params.white/2;
[w, screenRect]=PsychImaging('OpenWindow',params.screenNumber, params.gray);

params = configureScreens_final(w, params); % Set up monitors and initialize blank screen - grey background

Screen('BlendFunction', w, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

AssertOpenGL
%oldGamma =Screen('LoadNormalizedGammaTable', w, params.gammaTable');

%maximize priority for good timing
topPriorityLevel = MaxPriority(w);
Priority(topPriorityLevel);

%% setting up TTL device
if params.useLabJack
    %lj = labJack('verbose', true, 'deviceID', 3);
    lj = labJack('verbose', false, 'deviceID', 3);
end
if params.useArduino
    if ~exist('arduinoCom')
        if params.os ==1
            % ln -s /dev/ttyACM0 /dev/ttyS101
            arduinoCom = serial('/dev/ttyACM0','BaudRate',9600); % insert your serial  LINUX
        end
    end
    if strcmpi(arduinoCom.Status, 'open')
        fclose(arduinoCom);
    end
    fopen(arduinoCom);
    pause(3)
end

Screen('FillRect', w, params.black);
Screen('Flip', w);

%% Params for Flash full screen flash
fParam.flashDelay = [3 5];
fParam.numFlashes = 100;
fParam.flashDuration = 0.1;%1/params.fps;
fParam.waitBlack = 60; %1 for if wanting 60 sec of black screen, 0 for not

whiteScreenFlash(fParam.flashDelay, fParam.numFlashes, fParam.flashDuration, fParam.waitBlack, w, params, lj);

%% Change locations white box

% setting up locations 
numTrialsPerCenter = 50;
locations = [1 2 3 4]; %0 -center, 1 - top left quadrant, 2 - top right quadrant, 3 - bottom left
% quadrant, 4- bottom right quadrant
locationTTLs = [params.ulTTL, params.urTTL, params.llTTL, params.lrTTL];
allCenters = [];
for i = locations
    allCenters = [ allCenters, locations(i)*ones(1,numTrialsPerCenter)];
end
permLocations = allCenters(randperm(length(allCenters)));


% setting up parameters for grating 
swParam.flashDelay = [3 5];
swParam.numFlashes = numTrialsPerCenter*numel(locations);
swParam.color = params.white;
swParam.flashDuration = 0.1; 
swParam.whiteSize = 25;


for i = 1:swParam.numFlashes
    if i ==1
        Screen('FillRect', w, params.black);
        Screen('Flip', w);
        disp('Screen black for 60 seconds')
        pause(60)
    end
    
    loc = permLocations(i);
    locTTL = locationTTLs(loc);
   
    coloredLocScreenFlash(swParam.flashDuration, swParam.color, loc, swParam.whiteSize, w, params, locTTL, lj)

    Screen('FillRect', w, params.black);
    Screen('Flip', w);
    disp(['Quadrants white flash: ', num2str(i)])
    blankSceen_waitframes = swParam.flashDelay(1) + (swParam.flashDelay(2) - swParam.flashDelay(1))*rand();
    pause(blankSceen_waitframes)
end






%% Params for full screen static gratings (big grating)
Screen('FillRect', w, params.gray);
Screen('Flip', w);
pause(5)

bDParam.cps = 0;
bDParam.cpd = 0.09;
bDParam.contrast = 1;
bDParam.duration = 1;
bDParam.orientation = 0; %to switch direction of drifiting, add 180 to orientation
bDParam.center = 0; %[params.windowRect(3:4)/2 - 2048, params.windowRect(3:4)/2 + 2048];
bDParam.gratingSize = 70;
bDParam.drawmask = 0; %1; 0 for no mask, 1 for mask
bDParam.maskStd = bDParam.gratingSize/(params.pixelDeg*2*2);
bDParam.numDrifts = 100;
bDParam.trialDelay = [3 4];

for i = 1:bDParam.numDrifts
    driftingGratingFun(bDParam.cps, bDParam.cpd, bDParam.contrast, bDParam.duration,...
        bDParam.orientation, bDParam.center,...
        bDParam.gratingSize, bDParam.drawmask, bDParam.maskStd, w, params, params.startTTL, lj);
    
    %driftingGratingFun(cps, cpd, contrast, duration, orientation, center, gratingSize, drawmask, maskStd, w,  params, TTLPin, lj, arduinoCom)
    
    Screen('FillRect', w, params.gray);
    Screen('Flip', w);
    disp(['Full Screen DG Trial: ', num2str(i)])
    blankSceen_waitframes = bDParam.trialDelay(1) + (bDParam.trialDelay(2) - bDParam.trialDelay(1))*rand();
    pause(blankSceen_waitframes)
end





%% Params for full screen drifting gratings (big drift)
Screen('FillRect', w, params.gray);
Screen('Flip', w);
pause(5)

bDParam.cps = 3;
bDParam.cpd = 0.09;
bDParam.contrast = 1;
bDParam.duration = 1;
bDParam.orientation = 0; %to switch direction of drifiting, add 180 to orientation
bDParam.center = 0; %[params.windowRect(3:4)/2 - 2048, params.windowRect(3:4)/2 + 2048];
bDParam.gratingSize = 70;
bDParam.drawmask = 0; %1; 0 for no mask, 1 for mask
bDParam.maskStd = bDParam.gratingSize/(params.pixelDeg*2*2);
bDParam.numDrifts = 100;
bDParam.trialDelay = [3 4];

for i = 1:bDParam.numDrifts
    driftingGratingFun(bDParam.cps, bDParam.cpd, bDParam.contrast, bDParam.duration,...
        bDParam.orientation, bDParam.center,...
        bDParam.gratingSize, bDParam.drawmask, bDParam.maskStd, w, params, params.startTTL, lj);
    
    %driftingGratingFun(cps, cpd, contrast, duration, orientation, center, gratingSize, drawmask, maskStd, w,  params, TTLPin, lj, arduinoCom)
    
    Screen('FillRect', w, params.gray);
    Screen('Flip', w);
    disp(['Full Screen DG Trial: ', num2str(i)])
    blankSceen_waitframes = bDParam.trialDelay(1) + (bDParam.trialDelay(2) - bDParam.trialDelay(1))*rand();
    pause(blankSceen_waitframes)
end






%% Change locations static gratings 
% setting up locations 
numTrialsPerCenter = 50;
locations = [1 2 3 4]; %0 -center, 1 - top left quadrant, 2 - top right quadrant, 3 - bottom left
% quadrant, 4- bottom right quadrant
locationTTLs = [params.ulTTL, params.urTTL, params.llTTL, params.lrTTL];
allCenters = [];
for i = locations
    allCenters = [ allCenters, locations(i)*ones(1,numTrialsPerCenter)];
end
permLocations = allCenters(randperm(length(allCenters)));

Screen('FillRect', w, params.gray);
Screen('Flip', w);
pause(5)

% setting up parameters for grating 
bDParam.cps = 0;
bDParam.cpd = 0.09;
bDParam.contrast = 1;
bDParam.duration = 1;
bDParam.orientation = 0; %to switch direction of drifiting, add 180 to orientation
bDParam.gratingSize = 50;
bDParam.drawmask = 1; %1; 0 for no mask, 1 for mask
bDParam.maskStd = bDParam.gratingSize/(params.pixelDeg*2*2);
bDParam.numDrifts = length(allCenters);
bDParam.trialDelay = [3 4];


for i = 1:bDParam.numDrifts
    loc = permLocations(i);
    locTTL = locationTTLs(loc);
    
    driftingGratingFun(bDParam.cps, bDParam.cpd, bDParam.contrast, bDParam.duration,...
        bDParam.orientation, loc, bDParam.gratingSize, bDParam.drawmask,...
        bDParam.maskStd, w, params, locTTL, lj);
    %driftingGratingFun(cps, cpd, contrast, duration, orientation, center, gratingSize, drawmask, maskStd, w,  params, TTLPin, lj, arduinoCom)
    
    Screen('FillRect', w, params.gray);
    Screen('Flip', w);
    disp(['Quadrants DG Trial: ', num2str(i)])
    blankSceen_waitframes = bDParam.trialDelay(1) + (bDParam.trialDelay(2) - bDParam.trialDelay(1))*rand();
    pause(blankSceen_waitframes)
end






%% Change locations drifting gratings 
% setting up locations 
numTrialsPerCenter = 50;
locations = [1 2 3 4]; %0 -center, 1 - top left quadrant, 2 - top right quadrant, 3 - bottom left
% quadrant, 4- bottom right quadrant
locationTTLs = [params.ulTTL, params.urTTL, params.llTTL, params.lrTTL];
allCenters = [];
for i = locations
    allCenters = [ allCenters, locations(i)*ones(1,numTrialsPerCenter)];
end
permLocations = allCenters(randperm(length(allCenters)));

Screen('FillRect', w, params.gray);
Screen('Flip', w);
pause(5)

% setting up parameters for grating 
bDParam.cps = 3;
bDParam.cpd = 0.09;
bDParam.contrast = 1;
bDParam.duration = 1;
bDParam.orientation = 0; %to switch direction of drifiting, add 180 to orientation
bDParam.gratingSize = 50;
bDParam.drawmask = 1; %1; 0 for no mask, 1 for mask
bDParam.maskStd = bDParam.gratingSize/(params.pixelDeg*2*2);
bDParam.numDrifts = length(allCenters);
bDParam.trialDelay = [3 4];


for i = 1:bDParam.numDrifts
    loc = permLocations(i);
    locTTL = locationTTLs(loc);
    
    driftingGratingFun(bDParam.cps, bDParam.cpd, bDParam.contrast, bDParam.duration,...
        bDParam.orientation, loc, bDParam.gratingSize, bDParam.drawmask,...
        bDParam.maskStd, w, params, locTTL, lj);
    %driftingGratingFun(cps, cpd, contrast, duration, orientation, center, gratingSize, drawmask, maskStd, w,  params, TTLPin, lj, arduinoCom)
    
    Screen('FillRect', w, params.gray);
    Screen('Flip', w);
    disp(['Quadrants DG Trial: ', num2str(i)])
    blankSceen_waitframes = bDParam.trialDelay(1) + (bDParam.trialDelay(2) - bDParam.trialDelay(1))*rand();
    pause(blankSceen_waitframes)
end








%% Full screen Contrast Reversing Grating
Screen('FillRect', w, params.gray);
Screen('Flip', w);
pause(5)

cRParam.cps = 1.5;
cRParam.cpd = .09;
cRParam.contrast = 1;
cRParam.duration = 2;
cRParam.orientation = 0; %to switch direction of drifiting, add 180 to orientation
cRParam.center = 0;%[params.windowRect(3:4)/2 - 2048, params.windowRect(3:4)/2 + 2048];
cRParam.gratingSize = 70;
cRParam.drawmask = 0;
cRParam.maskStd =  cRParam.gratingSize/(params.pixelDeg*2*2);
cRParam.numDrifts = 100;
cRParam.trialDelay = [3 5];

for i = 1:cRParam.numDrifts
    contrastRevGratFun(cRParam.cps, cRParam.cpd, cRParam.contrast, cRParam.duration,...
        cRParam.orientation, cRParam.center,...
        cRParam.gratingSize, cRParam.drawmask, cRParam.maskStd, w, params, params.startTTL, lj);
    % contrastRevGratFun(cps, cpd, contrast, duration, orientation, location, gratingSize, drawmask, maskStd, w,  params, TTLPin, lj, arduinoCom)
    
    Screen('FillRect', w, params.gray);
    Screen('Flip', w);
    disp(['Full Screen CRG Trial: ', num2str(i)])
    blankSceen_waitframes = cRParam.trialDelay(1) + (cRParam.trialDelay(2) - cRParam.trialDelay(1))*rand();
    pause(blankSceen_waitframes)
end




%% End of Experiment
sca;
Priority(0);
lj.close;
