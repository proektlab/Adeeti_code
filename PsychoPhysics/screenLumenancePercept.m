waitframes = 1;

%Number of luminances we get.
NUM_LUMINANCES = 256;

% If not set up for optiCAL device enter name below and set up
% Set to 0 to correct and 1 to test correction
% if exist('correction') ==0
%     correction = 0;
%     optiCAL = '/dev/ttyUSB0';
%     OP = opticalSerial(optiCAL);
%     
% end

% %Skip PTB calibration.
Screen('Preference', 'SkipSyncTests', 1);

% Here we call some default settings for setting up Psychtoolbox
PsychDefaultSetup(2);

% Get the screen numbers. This gives us a number for each of the screens
% attached to our computer.
screens = Screen('Screens');

% To draw we select the maximum of these numbers. So in a situation where we
% have two screens attached to our monitor we will draw to the external
% screen.
screenNumber = max(screens);

% Define black and white (white will be 1 and black 0). This is because
% in general luminace values are defined between 0 and 1 with 255 steps in
% between. All values in Psychtoolbox are defined between 0 and 1
white = WhiteIndex(screenNumber);
black = BlackIndex(screenNumber);

if correction ==1
    %Load the gamma table of the experiment screen previously retrieved from
    %the photometer.
    Screen('LoadNormalizedGammaTable', screenNumber, gammaTable');
end

% Open an on screen window using PsychImaging.
[window, windowRect] = PsychImaging('OpenWindow', screenNumber, black);


% Measure the vertical refresh rate of the monitor
ifi = Screen('GetFlipInterval', window);

numFrames = round(numSecs / ifi);

% Retreive the maximum priority number
topPriorityLevel = MaxPriority(window);

% Create a matrix to store the color and luminance.
samples = zeros(NUM_LUMINANCES, 2);

%Set the timing of the screen flips.
vbl = Screen('Flip', window);


for ii = 1:NUM_LUMINANCES
    
    %Create the vector to store the luminance vectors and the values
    %between 0-1.
    rgbvector = ii./NUM_LUMINANCES.*ones(1,3);
    
    % Color the screen
    Screen('FillRect', window, rgbvector);
    
    % Flip to the screen
    vbl = Screen('Flip', window, vbl + (waitframes - 0.5));
    
    % get luminance reading
    OP.getLuminance(1);
    
    % save the values
    samples(ii,:) = [rgbvector(1) OP.values(end)];
    
    % display the luminance values in the console.
    disp(OP.values(end))
    
    
end

sca

