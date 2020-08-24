%Jennifer Luo
%6/17/19
%This program makes a square move in an oval while gradually changing
%colors

% Clear the workspace and the screen
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
[window, windowRect] = PsychImaging('OpenWindow', screenNumber, black);

% Get the size of the on screen window
[screenXpixels, screenYpixels] = Screen('WindowSize', window);

% Query the frame duration
ifi = Screen('GetFlipInterval', window);

% Get the centre coordinate of the window
[xCenter, yCenter] = RectCenter(windowRect);

% Make a base Rect of 200 by 200 pixels
baseRect = [0 0 200 200];

% Our square will oscilate with a sine wave function to the left and right
% of the screen. These are the parameters for the sine wave
% See: http://en.wikipedia.org/wiki/Sine_wave
amplitudeX = screenXpixels * 0.4;
amplitudeY = screenYpixels * 0.4;
frequency = 0.2;
angFreq = 2 * pi * frequency;
startPhase = 0;
time = 0;

%generate initial random colors
currentColor = rand(1,3);
nextColor = rand(1,3);

%allows the current square color move towards the next square color
colorDiff = nextColor - currentColor;

%this prevents flickering of colors
colorChanged = false;

%this allows the color multiplier to always move the color towards the next
%color
multiplierFlip = false;

% Sync us and get a time stamp
vbl = Screen('Flip', window);
waitframes = 1;

% Maximum priority level
topPriorityLevel = MaxPriority(window);
Priority(topPriorityLevel);

% Loop the animation until a key is pressed
while ~KbCheck
    
    % Position of the square on this frame
    xpos = amplitudeX * sin(angFreq * time + startPhase);
    ypos = amplitudeY * sin(angFreq * time + startPhase +pi/2);
    

    if((xpos < (-amplitudeX + 5)||xpos > amplitudeX - 5) && ~colorChanged)
        %generate a new color to move towards
        currentColor = nextColor;
        nextColor = rand(1,3); 
        colorDiff = nextColor - currentColor;
        
        %notes that color has recently changed
        colorChanged = true;
        
        multiplierFlip = false;
    end
    
    if(abs(xpos) < 10)
        colorChanged = false;
    end
    
    if(xpos > amplitudeX - 5)
        multiplierFlip = true;
    end
    

    % Use the x position of the square to determine its color
    colorMultiplier = ((xpos / amplitudeX) + 1)/2;
    
    %ensures that that color multiplier is 0 after a color change
    if(multiplierFlip)
        colorMultiplier = 1 - colorMultiplier;
    end
    squareColor = currentColor + colorDiff .* colorMultiplier;

    % Add this position to the screen center coordinate. This is the point
    % we want our square to oscillate around
    squareXpos = xCenter + xpos;
    squareYpos = yCenter + ypos;

    % Center the rectangle on the centre of the screen
    centeredRect = CenterRectOnPointd(baseRect, squareXpos, squareYpos);

    % Draw the rect to the screen
    Screen('FillRect', window, squareColor, centeredRect);

    % Flip to the screen
    vbl  = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);

    % Increment the time
    time = time + ifi;
end
 
% Clear the screen
sca;
