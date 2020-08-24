try
    optiCAL = '/dev/ttyUSB0';
 
     % set up the optiCAL device to start taking measurements
     OP = opticalSerial(optiCAL);

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

     %Load the gamma table of the experiment screen previously retrieved from
    %the photometer. 
    load('home/adeeti/gammaCorrectionExpMonitor.mat');
    Screen('LoadNormalizedGammaTable', screenNumber, gammaTable');

    % Open an on screen window using PsychImaging.
    [window, windowRect] = PsychImaging('OpenWindow', screenNumber, white);

    fileID = fopen('lumianceValTesting.txt','w');

   fprintf(fileID, 'white\n\n');
    for i = 1:10
 
        % get luminance reading
        OP.getLuminance(1)
        % display the luminance values in the console.
        fprintf(fileID, '%f\n', OP.values(end));
    end

    Screen('FillRect', window, (white+black)/2, windowRect);
    Screen('Flip', window);

    fprintf(fileID, '\n\ngrey\n\n');
    for i = 1:10

        % get luminance reading
        OP.getLuminance(1)
        % display the luminance values in the console.
        fprintf(fileID, '%f\n', OP.values(end));
    end
    OP.close();
    sca
    clear all 
catch
    OP.close();
    sca 
    clear all 
end