%% Contrast Reversing Grating general code
% creates contrast reversing gradiant based on DriftDemo2
% 05/30/18 AA

clear 
clc
close all 
%sca

contrast = 0.6;
gratingsize = 400;

% Spatial Frequencyt Grating cycles/pixel: By default 0.05 cycles per pixel.
cyclesPerPixel=0.005; % cycles/pixel

% Temporal speed of grating in cycles per second: 1 cycle per second by default.
cyclesPerSecond=1;

% Angle of the grating: We default to 30 degrees.
angle=30;
movieDurationSecs=20;   % Abort demo after 20 seconds.


% Define Half-Size of the grating image.
texsize=gratingsize / 2;

Screen('Preference', 'SkipSyncTests', 0);

% This script calls Psychtoolbox commands available only in OpenGL-based
% versions of the Psychtoolbox. (So far, the OS X Psychtoolbox is the
% only OpenGL-base Psychtoolbox.)  The Psychtoolbox command AssertPsychOpenGL will issue
% an error message if someone tries to execute this script on a computer without
% an OpenGL Psychtoolbox
AssertOpenGL;

% Get the list of screens and choose the one with the highest screen number.
% Screen 0 is, by definition, the display with the menu bar. Often when
% two monitors are connected the one without the menu bar is used as
% the stimulus display.  Chosing the display with the highest dislay number is
% a best guess about where you want the stimulus displayed.
screens=Screen('Screens');
screenNumber=max(screens);

% Find the color values which correspond to white and black: Usually
% black is always 0 and white 255, but this rule is not true if one of
% the high precision framebuffer modes is enabled via the
% PsychImaging() commmand, so we query the true values via the
% functions WhiteIndex and BlackIndex:
white=WhiteIndex(screenNumber);
black=BlackIndex(screenNumber);

% Round gray to integral number, to avoid roundoff artifacts with some
% graphics cards:
gray=round((white+black)/2);

% This makes sure that on floating point framebuffers we still get a
% well defined gray. It isn't strictly neccessary in this demo:
if gray == white
    gray=white / 2;
end

% Contrast 'inc'rement range for given white and gray values:
inc=white-gray;

% Open a double buffered fullscreen window and set default background
% color to gray:
[w screenRect]=Screen('OpenWindow',screenNumber, gray);

Screen('BlendFunction', w, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

%%

% Calculate parameters of the grating:

% First we compute pixels per cycle, rounded up to full pixels, as we
% need this to create a grating of proper size below:
%p=ceil(1/cyclesPerPixel);

% Also need spatial frequency in radians:
spatialFreq=cyclesPerPixel*2*pi;

% Also need temporal frequency in radians
tempFreq = cyclesPerSecond*2*pi;

% This is the visible size of the grating. It is twice the half-width
% of the texture plus one pixel to make sure it has an odd number of
% pixels and is therefore symmetric around the center of the texture:
visiblesize=2*texsize+1;

% Create one single static grating image:
%
% We only need a texture with a single row of pixels(i.e. 1 pixel in height) to
% define the whole grating! If the 'srcRect' in the 'Drawtexture' call
% below is "higher" than that (i.e. visibleSize >> 1), the GPU will
% automatically replicate pixel rows. This 1 pixel height saves memory
% and memory bandwith, ie. it is potentially faster on some GPUs.
%
% However it does need 2 * texsize + p columns, i.e. the visible size
% of the grating extended by the length of 1 period (repetition) of the
% sine-wave in pixels 'p':
x = meshgrid(1:visiblesize,1);
% x = meshgrid(-texsize:texsize+p, 1)

% Query duration of one monitor refresh interval:
ifi=Screen('GetFlipInterval', w);

% Translate that into the amount of seconds to wait between screen
% redraws/updates:

% waitframes = 1 means: Redraw every monitor refresh. If your GPU is
% not fast enough to do this, you can increment this to only redraw
% every n'th refresh. All animation paramters will adapt to still
% provide the proper grating. However, if you have a fine grating
% drifting at a high speed, the refresh rate must exceed that
% "effective" grating speed to avoid aliasing artifacts in time, i.e.,
% to make sure to satisfy the constraints of the sampling theorem
% (See Wikipedia: "Nyquist?Shannon sampling theorem" for a starter, if
% you don't know what this means):
waitframes = 1;

% Translate frames into seconds for screen update interval:
waitduration = waitframes * ifi;

% Definition of the drawn rectangle on the screen:
% Compute it to  be the visible size of the grating, centered on the
% screen:
dstRect=[0 0 visiblesize visiblesize];
dstRect=CenterRect(dstRect, screenRect);

% Query maximum useable priorityLevel on this system:
priorityLevel=MaxPriority(w); %#ok<NASGU>

% Perform initial Flip to sync us to the VBL and for getting an initial
% VBL-Timestamp as timing baseline for our redraw loop:
vbl=Screen('Flip', w);

% We run at most 'movieDurationSecs' seconds if user doesn't abort via keypress.
vblendtime = vbl + movieDurationSecs;


%%
t = 1;
while vbl < vblendtime
    %tic;
    OGgrating=cos(spatialFreq*x);
    makeCounterPhase = sin(tempFreq*t*waitduration);
 
    grating = gray + contrast*inc*OGgrating*makeCounterPhase;
  
    gratingtex=Screen('MakeTexture', w, grating);

    % Draw grating texture, rotated by "angle":
%     Screen('DrawTexture', w, gratingtex, [], dstRect, angle);
    Screen('DrawTexture', w, gratingtex, [], dstRect, angle)
    
    
    % Screen('DrawTexture', w, gratingtex, [0 0 20 1],[0 0 500 500], angle);
    t= t+1;
    
    %toc;
    vbl = Screen('Flip', w, vbl + (waitframes - 0.5) * ifi);
    
        % Abort demo if any key is pressed:
    if KbCheck
        break;
    end
end

Screen('Close')
%sca

