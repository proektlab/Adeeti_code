open% Clear the workspace and the screen
sca;
close all;
clearvars;

% Here we call some default settings for setting up Psychtoolbox
PsychDefaultSetup(2);

% Get the screen numbers
screens = Screen('Screens');

% Draw to the external screen if avaliable
screenNumber = max(screens);

% Define black and white
white = WhiteIndex(screenNumber);
black = BlackIndex(screenNumber);

% Open an on screen window
[window, windowRect] = PsychImaging('OpenWindow', screenNumber, white);

% Get the size of the on screen window
[screenXpixels, screenYpixels] = Screen('WindowSize', window);

% Get the centre coordinate of the window
[xCenter, yCenter] = RectCenter(windowRect);

% Enable alpha blending for anti-aliasing
Screen('BlendFunction', window, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

% Query the frame duration
ifi = Screen('GetFlipInterval', window);

% Make a base Rect of 200 by 250 pixels
baseRect = [0 0 100 100];

% For Ovals we set a miximum diameter up to which it is perfect for
maxDiameter = max(baseRect) * 1.01;

% Center the rectangle on the centre of the screen
centeredRect = CenterRectOnPointd(baseRect, xCenter, yCenter);

% Our oval will pulse by taking the absolute value of a sine wave, we
% therefore set the amplitude of the sine wave to 1 as this will be a
% multiplicative scale factor ranging between 0 and 1.
% With 0 the dots will all be on top of one another. With 1 the gird will
% have its maximum size.
% These are the parameters for the sine wave
% See: http://en.wikipedia.org/wiki/Sine_wave
amplitude = 8;
frequency = 0.025;

angFreq = 2 * pi * frequency;
startPhase = 0;
time = 0;

% Sync us and get a time stamp
vbl = Screen('Flip', window);
waitframes = 1;

% Maximum priority level
topPriorityLevel = MaxPriority(window);
Priority(topPriorityLevel);

% Loop the animation until a key is pressed
while ~KbCheck

    % Scale the grid coordinates
    scaleFactor = abs(amplitude * sin(angFreq * time + startPhase))+1;

%     % Scale the oval size. Here we limit the minimum oval size to one pixel
%     % by using the max function as PTB won't allow the oval size to scale to
%     % zero (sensibly, as you'd be drawing no oval at all)
%     thisOvalSize = max(1, maxOvalSize .* scaleFactor);
%    
%     % Add this position to the screen center coordinate. This is the point
%     % we want our square to oscillate around
%     squareXpos = xCenter + scaleFactor;
%     squareYpos = yCenter + scaleFactor;
    
    %makes rectangle with size related to scaleFactor
    baseRect = [0, 0, 200*scaleFactor, 200*scaleFactor];
    
    %centers rectangle
    circleRect = CenterRectOnPointd(baseRect, xCenter, yCenter);
    
    % Draw the rect to the screen
    Screen('FillOval', window, black, circleRect);

    % Flip to the screen
    vbl  = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);

    % Increment the time
    time = time + ifi;
    
    %removes the part where the circle gets smaller
    if (time>8)
        time = 0;
    end

end

% Clear the screen. "sca" is short hand for "Screen CloseAll". This clears
% all features related to PTB. Note: we leave the variables in the
% workspace so you can have a look at them if you want.
sca;

