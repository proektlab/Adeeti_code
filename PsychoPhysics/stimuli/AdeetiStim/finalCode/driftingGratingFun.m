function driftingGratingFun(cps, cpd, contrast, duration, orientation, center, gratingSize, drawmask, maskStd, w, params, TTLPin, lj, arduinoCom)
% driftingGratingFun(cps, cpd, contrast, duration, orientation, location, gratingSize, drawmask, maskStd, w, params, TTLPin, lj, arduinoCom)
% drifting grating
% cps = temporal freq in cycles per second
% cpd = spatial freq in cycles per degree
% contrast = from 0 to 1 where 1 is the highest contrast
% duration = duration of drifting grating in sec
% orientation = orientation of lines (in degrees)
% center = where grating should be centered- can be screen locations ( 0 -
% center, 1 - top left quadrant, 2 - top right quadrant, 3 - bottom left
% quadrant, 4- bottom right quadrant), can also give pixel dim of the
% center that you specify [centerX, centerY]
% gratingSize b= size of the grating in degrees (diameter)
% drawmask = 1 for mask and 0 for no mask
% w = window to display on
% params = mouse and experiment parameters - need useLabJack, useArduino,
% startTTL, os as fields
% lj = labjack object
% arduinoCom = arduino communication port

% 10/28/19 AA + JL   based on DriftDemo2
%% Paraneters
if nargin < 1 || isempty(cps)
    cps = 1;
end
if nargin < 2 || isempty(cpd)
    % Default grating spatial period:
    cpd=0.04;
end
if nargin < 3 || isempty(contrast)
    contrast=1;  
end
if nargin < 4 || isempty(duration)
   duration =60;   % Abort demo after 60 seconds.
end
if nargin < 5 || isempty(orientation)
    orientation = 0;
end
if nargin < 6 || isempty(center)
    center = params.dims/2;
end
if nargin < 7 || isempty(gratingSize)
    gratingSize = 50;
end
if nargin < 8 || isempty(drawmask)
    drawmask = 1;
end
if nargin < 9 || isempty(maskStd)
    maskStd  = gratingSize/(0.05*2*2);
end
if nargin < 10
    error('You did not include either the window, params, TTLPin, labjack, or arduino')
end
%% screen variables
% Contrast 'inc'rement range for given white and gray values:
inc=params.white-params.gray;

screenRect = Screen('Rect', w);
[screenXpixels, screenYpixels] = Screen('WindowSize', w);

%% Setting up grating
cpp = params.pixelDeg* cpd; %spatial freq in pixels instead of degrees
gratingPixSize = round((1/params.pixelDeg)*gratingSize); %grating size in pixels instead of degrees

% Define Half-Size of the grating image.
texSize=gratingPixSize/ 2;

% First we compute pixels per cycle, rounded up for setting up grating
ppc=ceil(1/cpp);

% Also need spatial frequency in radians:
spatial_fr=cpp*2*pi;

% This is the visible size of the grating. It is twice the half-width
% of the texture plus one pixel for symmetry around center:
visiblesize=2*texSize+1;

% Create one single static grating image: 2 * texsize extended by the 
% length of 1 period (repetition) of the sine-wave in pixels 'p':
x = meshgrid(-texSize:texSize + ppc, 1);

% Compute actual cosine grating:
grating= params.gray +contrast*inc*cos(spatial_fr*x);

% Store 1-D single row grating in texture:
gratingtex=Screen('MakeTexture', w, grating);

% Create a single gaussian transparency mask and store it to a texture:
mask=ones(2*texSize+1, 2*texSize+1, 2) * params.gray;
[x,y]=meshgrid(-1*texSize:1*texSize,-1*texSize:1*texSize);
mask(:, :, 2)= params.white * (1 - exp(-((x/maskStd).^2)-((y/maskStd).^2)));

masktex=Screen('MakeTexture', w, mask);

% Query duration of one monitor refresh interval:
ifi=1/params.fps;
waitframes = 1; % waitframes = 1 means: Redraw every monitor refresh.

% Translate frames into seconds for screen update interval:
waitduration = waitframes * ifi;

% Recompute ppc, this time without the ceil() for no driftspeed rounding errors.
ppc_noRound=1/cpp;  % pixels/cycle

% Translate requested speed of the grating (in cycles per second) into
% a shift value in "pixels per frame", for given waitduration: This is
% the amount of pixels to shift our srcRect "aperture" in horizontal
% directionat each redraw:
shiftperframe= cps * ppc_noRound * waitduration;

%% Displaying the grating at the proper location
dstRect=[0 0 visiblesize visiblesize];

%centering the rectangle on the
if numel(center) ==1
    if center ==0
        dstRect=CenterRect(dstRect, screenRect);
    elseif center ==1
        squareXpos = [screenXpixels * 0.25];
        squareYpos = [screenYpixels * 0.25];
        dstRect = CenterRectOnPointd(dstRect, squareXpos, squareYpos);
    elseif center ==2
        squareXpos = [screenXpixels * 0.75];
        squareYpos = [screenYpixels * 0.25];
        dstRect = CenterRectOnPointd(dstRect, squareXpos, squareYpos);
    elseif center ==3
        squareXpos = [screenXpixels * 0.25];
        squareYpos = [screenYpixels * 0.75];
        dstRect = CenterRectOnPointd(dstRect, squareXpos, squareYpos);
    elseif center ==4
        squareXpos = [screenXpixels * 0.75];
        squareYpos = [screenYpixels * 0.75];
        dstRect = CenterRectOnPointd(dstRect, squareXpos, squareYpos);
    end
else
    dstRect = CenterRectOnPointd(dstRect, center(1), center(2));
end

%% Setting up timing
vbl=Screen('Flip', w); % VBL-Timestamp as timing baseline for our redraw loop:
vblendtime = vbl + duration;
i=0;

%% Animationloop:
while vbl < vblendtime
    % Shift the grating by "shiftperframe" pixels per frame:
    % the mod'ulo operation makes sure that our "aperture" will snap
    % back to the beginning of the grating, once the border is reached.
    xoffset = mod(i*shiftperframe,ppc);
    i=i+1;
    
    % Define shifted srcRect that cuts out the properly shifted rectangular
    % area from the texture: We cut out the range 0 to visiblesize in
    % the vertical direction although the texture is only 1 pixel in
    % height! 
    srcRect=[xoffset, 0, xoffset + visiblesize, visiblesize];
    
    % Draw grating texture, rotated by "angle":
    Screen('DrawTexture', w, gratingtex, srcRect, dstRect, orientation);
    
    if drawmask==1
        % Draw gaussian mask over grating:
        Screen('DrawTexture', w, masktex, [0 0 visiblesize visiblesize], dstRect, orientation);
    end
    
    vbl = Screen('Flip', w, vbl + (waitframes - 0.5) * ifi); % Flip 'waitframes' monitor refresh intervals after last redraw.
    if i == 1
        % for TTL on the first flip of stim presentation 
        if isfield(params, 'useLabJack') && params.useLabJack==1
            timedTTL(lj,TTLPin,5)
        end
        if isfield(params, 'useArduino') && params.useArduino ==1
            mat2arduino(arduinoCom, TTLPin, 0, 5) %writes info to arduino
            fwrite(arduinoCom,255); %% makes arduino start
        end
    end
end

Screen('Close', [gratingtex, masktex]);
end
