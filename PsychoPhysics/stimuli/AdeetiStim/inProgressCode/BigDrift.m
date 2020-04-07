function BigDrift(cps, cpd, duration, direction, orientation, w, params, lj, arduinoCom)
% BigDrift(cyclespersecond, p, movieDurationSecs, w, params)
% full screen drifting grating
% cyclespersecond = temporal freq 
% cyclesperdegree = spatial freq
% movieDurationSecs = duration of drifting grating in sec 
% direction = drifting direction (1 for right and 0 for left normal to
% orientation of grating
% orientation = orientation of lines (in degrees)
% w = window to display on
% params = mouse and experiment parameters - need useLabJack, useArduino,
% startTTL, os as fields


% function DriftDemo3([cyclespersecond=1][, p=32], [movieDurationSecs = 60], w, params)
%

if nargin < 1
    cps = [];
end

if isempty(cps)
    % Default speed of grating in cycles per second:
    cps=1;
end

if nargin < 2
    % Default grating spatial period:
    cpd=0.04;
end

if nargin < 3
    duration=60;   % Abort demo after 60 seconds.
end

if nargin < 4
    direction = 1;
end

if nargin < 4
    orientation = 0;
end

if nargin < 6
   error('You did not include either the window, params, labjack, or arduino')
end


%% warning in case there are no TTL parameters 
if isempty(isfield(params, 'startTTL'))
    warning('You startTTL is not a parameter in params. There will be no TTL output')
end

%%
visiblesize=2048;        % Size of the grating image. Needs to be a power of two.


cpp = params.pixelDeg* cpd; %spatial freq in pixels instead of degrees

ppc = 1/cpp;

% if rem(visiblesize, cpp)~=0
%   error('Period p must divide default visiblesize of 512 pixels without remainder for this demo to work!');
% end

% % Find the color values which correspond to white and black: Usually
% % black is always 0 and white 255, but this rule is not true if one of
% % the high precision framebuffer modes is enabled via the
% % PsychImaging() commmand, so we query the true values via the
% % functions WhiteIndex and BlackIndex:
% white=WhiteIndex(screenNumber);
% black=BlackIndex(screenNumber);
% 
% % Round gray to integral number, to avoid roundoff artifacts with some
% % graphics cards:
% gray=round((white+black)/2);
% 
% % This makes sure that on floating point framebuffers we still get a
% % well defined gray. It isn't strictly neccessary in this demo:
% if gray == white
%     gray=white / 2;
% end
% 
% % Contrast 'inc'rement range for given white and gray values:
  inc = params.white-params.gray;
% 
% % Open a double buffered fullscreen window and draw a gray background 
% % to front and back buffers as background clear color:
% [w, wSize] = PsychImaging('OpenWindow',screenNumber, gray);

% Calculate parameters of the grating:
f=1/cpd;
fr=f*2*pi;    % frequency in radians.

% Create one single static 1-D grating image.
% We only need a texture with a single row of pixels(i.e. 1 pixel in height) to
% define the whole grating! If the 'srcRect' in the 'Drawtexture' call
% below is "higher" than that (i.e. visibleSize >> 1), the GPU will
% automatically replicate pixel rows. This 1 pixel height saves memory
% and memory bandwith, ie. it is potentially faster on some GPUs.
x=meshgrid(0:visiblesize-1, 1);
grating = params.gray + inc*cos(fr*x);

% Store grating in texture: Set the 'enforcepot' flag to 1 to signal
% Psychtoolbox that we want a special scrollable power-of-two texture:
%gratingtex=Screen('MakeTexture', w, grating, [], 1);
gratingtex=Screen('MakeTexture', w, grating, [], 0);

% Query duration of monitor refresh interval:
ifi=Screen('GetFlipInterval', w);    
waitframes = 1;
waitduration = waitframes * ifi;

% Translate requested speed of the grating (in cycles per second)
% into a shift value in "pixels per frame", assuming given
% waitduration: This is the amount of pixels to shift our srcRect at
% each redraw:
shiftperframe= cps * ppc * waitduration;

% Perform initial Flip to sync us to the VBL and for getting an initial
% VBL-Timestamp for our "WaitBlanking" emulation:
vbl=Screen('Flip', w);

% We run at most 'movieDurationSecs' seconds if user doesn't abort via keypress.
vblendtime = vbl + duration;
xoffset=0;

% Animationloop:
while(vbl < vblendtime)
   % Shift the grating by "shiftperframe" pixels per frame:
   xoffset = xoffset + shiftperframe;

   % Define shifted srcRect that cuts out the properly shifted rectangular
   % area from the texture:
   srcRect=[xoffset 0 xoffset + visiblesize visiblesize];

   % Draw grating texture: Only show subarea 'srcRect', center texture in
   % the onscreen window automatically:
   Screen('DrawTexture', w, gratingtex, srcRect);

   % Flip 'waitframes' monitor refresh intervals after last redraw.
   vbl = Screen('Flip', w, vbl + (waitframes - 0.5) * ifi);

   % Abort demo if any key is pressed:
   if KbCheck
      break;
   end
end

Screen('Close', gratingtex);
Screen('Flip', w);
    
% Well done!
return;
