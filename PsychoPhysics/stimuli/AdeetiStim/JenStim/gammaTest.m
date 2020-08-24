% gammaTest.m
% Run a gamma test and calibration using PsychToolbox and optiCAL photometer.
% Code is based off of Gold Utilities scripts
% (https://github.com/TheGoldLab/Lab_Matlab_Control/blob/master/snow-dots/utilities/benchmarking/benchmarkMonitorLuminance.m)
% and adapted for Windows and PTB using scripts from PTB demos.

% Name the file you want to save for gamma correction, put setup name and
% date
gammaName = 'PTBGammaCorrectTest20190724';
%Indicate if using Mac or Windows
%OS = 'Windows'; %'Mac' or 'Windows'
% Length of time and number of frames we will use for each drawing test
numSecs = 1;

waitframes = 1;

%Number of luminances we get.
NUM_LUMINANCES = 256;

% If not set up for optiCAL device enter name below and set up
% Set to 0 to correct and 1 to test correction
if exist('correction') ==0
    correction = 0;
    % set up the directories and the source of input.
    %     if strcmpi(OS, 'Mac')
    %         % Mac example - require device name
    %         calDir = dir('/dev/tty.USA*'); % Works on Gold lab rig, Mac
    %         optiCAL = ['/dev/' calDir.name]; % Works on Gold lab rig, mac
    %     elseif strcmpi(OS, 'Windows')
    %         %For Windows, check which com the luminance sensor
    %         % is connected to and manually enter it here.
    %         optiCAL = ['COM5'];
    optiCAL = '/dev/ttyUSB0';
    %     set up the optiCAL device to start taking measurements
    OP = opticalSerial(optiCAL);
    
end

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

if correction == 0
    samples_uncorrected = samples;
elseif correction == 1
    samples_corrected = samples;
end

sca

%Plot the sample values to see if gamma correction has linearized the curve.
%cla reset;
figure
plot(samples(:,1), samples(:,2), 'ko');
set(gca, 'FontSize', 12);
xlabel('Nominal value');
ylabel('Measured value (cd/m^2)');
if correction ==0
    title('Uncorrected values')
elseif correction == 1
    title('Corrected values')
end

%makes the correction
if correction == 0
    values = samples(:,2);
    maxLum     = max(values);
    maxV                   = NUM_LUMINANCES-1;
    nominalLuminanceValues = 0:maxV;
    scaledLum  = linspace(0, maxLum, NUM_LUMINANCES);
    gammaTable = zeros(3, NUM_LUMINANCES);
    for ii = 2:NUM_LUMINANCES
        gammaTable(:,ii) = nominalLuminanceValues( ...
            find(values>=scaledLum(ii),1,'first'))./maxV.*[1 1 1];
    end
    
    % save to file
    save(gammaName, 'gammaTable');
end
%{
if correction ==0
    correction = 1;
    gammaTest;
elseif correction == 1
    fprintf('Correction done');
end
%}
% close the optiCAL device
OP.close();