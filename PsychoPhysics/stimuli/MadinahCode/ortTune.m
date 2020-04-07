clear all
close all
clc
sca

% Set up monitor and prepare for experiment
clear params
rng('shuffle')

global oldLevel; % Keep as global to allow resetting in error states
oldLevel = Screen('Preference', 'VisualDebugLevel', 3); % Disable Psychtoolbox welcome message
%ListenChar(2); % Disable dumping of key commands to terminal

% Setup screen - should put this in a wrapped function
% Set up monitors and initialize blank screen - Black background
 params.vpixx_monitor = true; % Indicates vpixx_monitor connected and working
params = configureScreens(params,'gray');

AssertOpenGL;
PsychDefaultSetup(1);




% Initial stimulus parameters for the grating patch:
cyclespersecond=1;
freq=0.001; %translate this to cycles per degree
gratingsize=900;
internalRotation=0;
angle=0;
rotateMode = [];
 
% if nargin < 5 || isempty(internalRotation)
%     internalRotation = 0;
% end
% 
% if internalRotation
%     rotateMode = kPsychUseTextureMatrixForRotation;
% else
%     rotateMode = [];
% end
% 
% if nargin < 4 || isempty(gratingsize)
%     gratingsize = 360;
% end

% res is the total size of the patch in x- and y- direction, i.e., the
% width and height of the mathematical support:
res = [gratingsize gratingsize];

% if nargin < 3 || isempty(freq)
%     % Frequency of the grating in cycles per pixel: Here 0.01 cycles per pixel:
%     freq = 1/360;
% end
% 
% if nargin < 2 || isempty(cyclespersecond)
%     cyclespersecond = 1;
% end
% 
% if nargin < 1 || isempty(angle)
%     % Tilt angle of the grating:
%     angle = 0;
% end

% Amplitude of the grating in units of absolute display intensity range: A
% setting of 0.5 means that the grating will extend over a range from -0.5
% up to 0.5, i.e., it will cover a total range of 1.0 == 100% of the total
% displayable range. As we select a background color and offset for the
% grating of 0.5 (== 50% nominal intensity == a nice neutral gray), this
% will extend the sinewaves values from 0 = total black in the minima of
% the sine wave up to 1 = maximum white in the maxima. Amplitudes of more
% than 0.5 don't make sense, as parts of the grating would lie outside the
% displayable range for your computers displays:
amplitude = 0.5;

% Open a fullscreen onscreen window on that display, choose a background
% color of 128 = gray, i.e. 50% max intensity:
[win,rect] = Screen('OpenWindow', params.screenNumber, params.gray);

% Phase is the phase shift in degrees (0-360 etc.)applied to the sine grating:
phase = 0;

% Compute increment of phase shift per redraw:
phaseincrement = (cyclespersecond * 360) * (1/params.fps);
 
% Build a procedural sine grating texture for a grating with a support of
% res(1) x res(2) pixels and a RGB color offset of 0.5 -- a 50% gray.
gratingtex = CreateProceduralSineGrating(win, res(1), res(2), [0.5 0.5 0.5 0.0]);

% Wait for release of all keys on keyboard, then sync us to retrace:
KbReleaseWait;
vbl = Screen('Flip', win);


% Init framecounter to zero and take initial timestamp:
tstart = GetSecs;

while ~KbCheck
    tcurrent= GetSecs;
if tcurrent-tstart<5    % Update some grating animation parameters:
    
    % Increment phase by 1 degree:
    phase = phase + phaseincrement;
    
    % Draw the grating, centered on the screen, with given rotation 'angle',
    % sine grating 'phase' shift and amplitude, rotating via set
    % 'rotateMode'. Note that we pad the last argument with a 4th
    % component, which is 0. This is required, as this argument must be a
    % vector with a number of components that is an integral multiple of 4,
    % i.e. in our case it must have 4 components:
    Screen('DrawTexture', win, gratingtex, [], [], angle, [], [], [], [], rotateMode, [phase, freq, amplitude, 0]);

    % Show it at next retrace:
    vbl = Screen('Flip', win, vbl + 0.5 * (1/params.fps));
    
    tcurrent=GetSecs;
else
    tstart=GetSecs;
    tcurrent=GetSecs;
    
    
    
    Screen('FillRect', win, params.gray, rect);
    Screen('Flip', win);
%     %send TTL
%       Datapixx('SetDoutValues', [1]);
%             Datapixx('RegWrRd');
%             pause(0.01)
%             Datapixx('SetDoutValues', 0);
%             Datapixx('RegWrRd');
            
    Screen('WaitBlanking',win,params.fps*2);
    

    
end
end
% We're done. Close the window. This will also release all other ressources:
Screen('CloseAll');

%return

