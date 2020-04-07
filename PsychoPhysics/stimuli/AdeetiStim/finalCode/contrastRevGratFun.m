function contrastRevGratFun(cps, cpd, contrast, duration, orientation, center, gratingSize, drawmask, maskStd, w, params, TTLPin, lj, arduinoCom)
% contrastRevGratFun(cps, cpd, contrast, duration, orientation, location, gratingSize, drawmask, maskStd, w, params, TTLPin, lj, arduinoCom)
% makes contrast reversing grating
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

% 10/28/19 AA
%% setting variables
if nargin < 1 || isempty(cps)
    cps = 1;
end

if nargin < 2 || isempty(cpd)
    % Default grating spatial period:
    cpd=0.04;
end

if nargin < 3 || isempty(contrast)
    contrast=1;   % Abort demo after 60 seconds.
end

if nargin < 4 || isempty(duration)
    duration=60;   % Abort demo after 60 seconds.
end

if nargin < 5 || isempty(orientation)
    orientation = 0;
end

if nargin < 6 || isempty(center)
    center = 0;
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

%% Screen variables
white=params.white;
black=params.black;
gray=params.gray;

inc=white-gray;

screenRect = Screen('Rect', w);
[screenXpixels, screenYpixels] = Screen('WindowSize', w);

%% Converting degrees into pixels and parameters for grating

cyclesPerPixel = params.pixelDeg* cpd; %spatial freq in pixels instead of degrees
gratingPixSize = round((1/params.pixelDeg)*gratingSize); %grating size in pixels instead of degrees

% need spatial frequency in radians:
spatialFreq=cyclesPerPixel*2*pi;

% need temporal frequency in radians
tempFreq = cps*2*pi;

% Define Half-Size of the grating image.
texSize=gratingPixSize/ 2;

% This is the visible size of the grating. It is twice the half-width
% of the texture plus one pixel to make sure it has an odd number of
% pixels and is therefore symmetric around the center of the texture:
visiblesize=2*texSize+1;

%masking
mask=ones(2*gratingPixSize+1, 2*gratingPixSize+1, 2) * params.gray;
[a,b]=meshgrid(-1*gratingPixSize:1*gratingPixSize,-1*gratingPixSize:1*gratingPixSize);
mask(:, :, 2)= params.white * (1 - exp(-((a/maskStd).^2)-((b/maskStd).^2)));
masktex=Screen('MakeTexture', w, mask);

% Create one single static grating image:
x = meshgrid(1:visiblesize, 1);

%% Displaying the grating at the proper location
%size of destination matrisca;x- square with the same size in pixels as we
%specified in degrees
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

%% Timing for loop
% Query duration of one monitor refresh interval:
ifi=Screen('GetFlipInterval', w);

waitframes = 1;
waitduration = waitframes * ifi;

vbl=Screen('Flip', w);
vblendtime = vbl + duration;

t = 1;

% Query maximum useable priorityLevel on this system:
priorityLevel=MaxPriority(w); %#ok<NASGU>

i =0;
while vbl < vblendtime
    i = i+1;
    OGgrating=cos(spatialFreq*x);
    makeCounterPhase = sin(tempFreq*t*waitduration);
    
    grating = gray + contrast*inc*OGgrating*makeCounterPhase;
    
    gratingtex=Screen('MakeTexture', w, grating);
    
    % Draw grating texture, rotated by "angle":
    %     Screen('DrawTexture', w, gratingtex, [], dstRect, angle);
    Screen('DrawTexture', w, gratingtex,[], dstRect, orientation)
    
    if drawmask==1
        % Draw gaussian mask over grating:
        Screen('DrawTexture', w, masktex, [], dstRect, orientation);
    end
    t= t+1;
    
    vbl = Screen('Flip', w, vbl + (waitframes - 0.5) * ifi);
    if i == 1
        % for TTL
        if isfield(params, 'useLabJack') && params.useLabJack==1
            timedTTL(lj,TTLPin,5)
        end
        if isfield(params, 'useArduino') && params.useArduino ==1
            %not really sure how to send a long signal here
            mat2arduino(arduinoCom,TTLPin, 0, 5) %writes info to arduino
            fwrite(arduinoCom,255); %% makes arduino start
        end
    end
end
Screen('Close', [gratingtex, masktex]);

