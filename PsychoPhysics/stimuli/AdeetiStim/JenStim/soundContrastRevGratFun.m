function soundContrastRevGratFun(w, params, angle, cpd, cps, contrast,...
    movieDurationSecs, center, gratingSize, drawmask, maskStd, toneFs, toneFreq, toneAMFreq)
% w = window from screen openned
% params = experimental conditions 
% angle = turned angle of grating- 0 is vertical bars 
% cpd = cycles per degrees - spatial frequency 
% cps = cycles per second - temporal frequency
% contrast = contrast of bars - as a decimal from 0-1
% movieDurationSecs = how long grating shows in seconds 
% center = where grating should be centered- can be screen locations ( 0 -
% center, 1 - top left quadrant, 2 - top right quadrant, 3 - bottom left
% quadrant, 4- bottom right quadrant), can also give pixel dim of the
% center that you specify [centerX, centerY]
% gratingSize = size of grating in degrees (diameter)
% drawmask = 1 for gabor mask or 0 for square grating 
% %% setting variables
% if nargin < 9
%     drawmask = [];
% end
% 
% if isempty(drawmask)
%     % By default, we DO NOT mask the grating by a gaussian transparency mask:
%     drawmask=0;
% end
% 
% if nargin < 8
%     gratingSize = [];
% end
% 
% if isempty(gratingSize)
%     % By default the visible grating is 5 degrees by 5 degrees in visual space in size:
%     gratingSize = 5;
% end
% 
% if nargin < 7
%     center = [];
% end
% 
% if isempty(center)
%     % By default the grating is centered on the center of the screen 
%     center = 0;
% end
% 
% if nargin < 6
%     movieDurationSecs = [];
% end
% 
% if isempty(movieDurationSecs)
%     % By default, the stimulus will last for 5 seconds 
%     movieDurationSecs=5;
% end
% 
% if nargin < 5
%     contrast = [];
% end
% 
% if isempty(contrast)
%     % By defualt, the contrast for the stimulus will be 100%
%     contrast=1;
% end
% 
% if nargin < 4
%     cps = [];
% end
% 
% if isempty(cps)
%     % Speed of grating in cycles per second: 1 cycle per second by default.
%     cps=1;
% end
% 
% if nargin < 3
%     cpd = [];
% end
% 
% if isempty(cpd)
%     % Sptial frequency of the grating will be 0.04 cycles per degrees (1 cycle in 20 degrees)
%     cpd=0.04;
% end
% 
% if nargin < 2
%     angle = [];
% end
% 
% if isempty(angle)
%     % Angle of the grating: We default to 0 degrees.
%     angle=0;
% end

%% Debugging Variables 
% params.distanceToMonitor=30; %cm
% params.mouseID = 'StimTest1';
% params.Date=date;
% params = configureScreens_pipelineAA(params);
% angle=90;
% cpd=0.08;
% cps=1;
% contrast= 1;
% movieDurationSecs=5;
% center = 3;
% gratingSize = 15;
% drawmask=0;

%% Sound Stuff
 %generate and modify sound signal
    
    %places everything on 2 channels
    if size(toneAMFreq == [1,1])
        toneAMFreq = [toneAMFreq, toneAMFreq];
    end
    if size(toneFreq) == [1,1]
        toneFreq = [toneFreq, toneFreq];
    end
    
    %creates signal
    signal = makeTone(toneFs, toneAMFreq, movieDurationSecs);
    
    %amplitude modulates both channels
    for i = 1:size(signal, 1)
        if(toneAMFreq(i) > 0)
            signal(i, :) = ammod(signal(i,:), toneFreq(i), toneFs, 10);
        end
    end
    
    %smooths out beginning and end of both channels
    signal = removeClick(signal, 300, toneFs);
    
    nrchannels = size(signal, 1);

%% Screen variables
% w = params.window;
% PsychDefaultSetup(2);
% Screen('Preference', 'VisualDebuglevel', 3);

white=params.white;  
black=params.black;  
gray=params.gray; 

if gray == white
    gray=white / 2;
end

inc=white-gray;
% Set the screen number to the external secondary monitor if there is one
% connected

%w = max(Screen('Screens'));
%[w, screenRect]=Screen('OpenWindow',w, [.5 .5 .5]);

% 
%Screen('BlendFunction', w, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

screenRect = Screen('Rect', w);
[screenXpixels, screenYpixels] = Screen('WindowSize', w);

if drawmask
    % Enable alpha blending for proper combination of the gaussian aperture
    % with the drifting sine grating:
    Screen('BlendFunction', w, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
end

%% Converting degrees into pixels and parameters for grating

cyclesPerPixel = params.pixelDeg* cpd; %spatial freq in pixels instead of degrees

gratingPixSize = round((1/params.pixelDeg)*gratingSize); %grating size in pixels instead of degrees

% need spatial frequency in radians:
spatialFreq=cyclesPerPixel*2*pi;

% need temporal frequency in radians
tempFreq = cps*2*pi;

% This is the visible size of the grating. It is twice the half-width
% of the texture plus one pixel to make sure it has an odd number of
% pixels and is therefore symmetric around the center of the texture:
visibleSize=2*gratingPixSize+1;

% Create one single static grating image:
x = meshgrid(1:visibleSize, 1);

% Define Half-Size of the grating image.
texsize= gratingPixSize / 2;

visiblesize=2*texsize+1;

% Create a single gaussian transparency mask and store it to a texture:
% The mask must have the same size as the visible size of the grating
% to fully cover it. Here we must define it in 2 dimensions and can't
% get easily away with one single row of pixels.
%
% We create a  two-layer texture: One unused luminance channel which we
% just fill with the same color as the background color of the screen
% 'gray'. The transparency (aka alpha) channel is filled with a
% gaussian (exp()) aperture mask:
mask=ones(2*texsize +1, 2*texsize+1, 2) * gray;
[x,y]=meshgrid(-1*texsize:1*texsize,-1*texsize:1*texsize);
mask(:, :, 2)= white * (1 - exp(-((x/maskStd).^2)-((y/maskStd).^2)));
masktex=Screen('MakeTexture', w, mask);


%% Displaying the grating at the proper location
%size of destination matrisca;x- square with the same size in pixels as we
%specified in degrees
dstRect=[0 0 visibleSize visibleSize];

%centering the rectangle on the 

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
else
    dstRect = CenterRectOnPointd(dstRect, center(1), center(2));
end

%% Timing for loop
% Query duration of one monitor refresh interval:
ifi=Screen('GetFlipInterval', w);

waitframes = 1;
waitduration = waitframes * ifi;


vbl=Screen('Flip', w);
vblendtime = vbl + movieDurationSecs;

t = 1;

% Query maximum useable priorityLevel on this system:
priorityLevel=MaxPriority(w); %#ok<NASGU>

%open audio port
 try
    % Try with the 'freq'uency we wanted:
    pahandle = PsychPortAudio('Open', [], [], 0, toneFs, nrchannels);
catch
    % Failed. Retry with default frequency as suggested by device:
    disp('\nCould not open device at wanted playback frequency of %i Hz. Will retry with device default frequency.\n');
    disp('Sound may sound a bit out of tune, ...\n\n');

    psychlasterror('reset');
    pahandle = PsychPortAudio('Open', [], [], 0, [], nrchannels);
 end

% Fill the audio playback buffer with the audio data 'wavedata':
PsychPortAudio('FillBuffer', pahandle, signal);

% Start audio playback for 'repetitions' repetitions of the sound data,
% start it immediately (0) and wait for the playback to start, return onset
% timestamp.
PsychPortAudio('Start', pahandle, 0, 0, 1);

% Wait for release of all keys on keyboard:
KbReleaseWait;

while vbl < vblendtime
   
    %tic;
    OGgrating=cos(spatialFreq*x);
    makeCounterPhase = sin(tempFreq*t*waitduration);
 
    grating = gray + contrast*inc*OGgrating*makeCounterPhase;
  
    gratingtex=Screen('MakeTexture', w, grating);

    % Draw grating texture, rotated by "angle":
%     Screen('DrawTexture', w, gratingtex, [], dstRect, angle);
    Screen('DrawTexture', w, gratingtex,[], dstRect, angle)
    %Screen('FillRect', w, [.5, 0, .5], [0 0 200 200]);

    if drawmask==1
        % Draw gaussian mask over grating:
        Screen('DrawTexture', w, masktex, [0 0 visiblesize visiblesize], dstRect, angle);
    end
    
    % Screen('DrawTexture', w, gratingtex, [0 0 20 1],[0 0 500 500], angle);
    t= t+1;

    %toc;
    vbl = Screen('Flip', w, vbl + (waitframes - 0.5) * ifi);
    
    % Abort demo if any key is pressed:
     if KbCheck
         break;
     end
end

% Stop playback:
PsychPortAudio('Stop', pahandle);

% Close the audio device:
PsychPortAudio('Close', pahandle);

% Close texture
sca;
