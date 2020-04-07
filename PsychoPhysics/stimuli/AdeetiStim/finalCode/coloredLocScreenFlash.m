function coloredLocScreenFlash(flashDuration, color, centers, size, w, params, locationTTL, lj, arduinoCom)
% whiteScreenFlash(flashDelay, numFlashes, flashDuration, location, whiteSize, waitBlack, w, params, lj, arduinoCom)
% flashes up a full white screen with black screens in between for
% numFlashes number of white screens 
% flashDelay = interval of time between flashes in seconds 
% numFlashes = number of white screens in total 
% flashDuration = time that white screen will stay up in sec
% w = already opened window
% params = mouse parameters - need to have params.arduino

if nargin < 5
   error('You did not include either the window, params, locationTTL, labjack, or arduino')
end

if nargin < 4 || isempty(size)
   size = 70; %60 sec of black screen, 0 for not
end

if nargin < 3 || isempty(centers)
   centers = 0; %60 sec of black screen, 0 for not
end

if nargin < 2 || isempty(color) 
    color = params.white;
end

if nargin < 1
   flashDuration = (1/params.fps);
end

%get starting time
startTime = datestr(now);

%% warning in case there are no TTL parameters 
if isempty(isfield(params, 'startTTL'))
    warning('You startTTL is not a parameter in params. There will be no TTL output')
end

%% Displaying the grating at the proper location
screenRect = Screen('Rect', w);
[screenXpixels, screenYpixels] = Screen('WindowSize', w);

visiblesize = round((1/params.pixelDeg)*size); %grating size in pixels instead of degrees
dstRect=[0 0 visiblesize visiblesize];

%centering the rectangle on the
if numel(centers) ==1
    if centers ==0
        dstRect=CenterRect(dstRect, screenRect);
    elseif centers ==1
        squareXpos = [screenXpixels * 0.25];
        squareYpos = [screenYpixels * 0.25];
        dstRect = CenterRectOnPointd(dstRect, squareXpos, squareYpos);
    elseif centers ==2
        squareXpos = [screenXpixels * 0.75];
        squareYpos = [screenYpixels * 0.25];
        dstRect = CenterRectOnPointd(dstRect, squareXpos, squareYpos);
    elseif centers ==3
        squareXpos = [screenXpixels * 0.25];
        squareYpos = [screenYpixels * 0.75];
        dstRect = CenterRectOnPointd(dstRect, squareXpos, squareYpos);
    elseif centers ==4
        squareXpos = [screenXpixels * 0.75];
        squareYpos = [screenYpixels * 0.75];
        dstRect = CenterRectOnPointd(dstRect, squareXpos, squareYpos);
    end
else
    dstRect = CenterRectOnPointd(dstRect, centers(1), centers(2));
end

%% Query duration of monitor refresh interval:

ifi=Screen('GetFlipInterval', w);
% Perform initial Flip to sync us to the VBL and for getting an initial
% VBL-Timestamp for our "WaitBlanking" emulation:
vbl=Screen('Flip', w);

Screen('FillRect', w, color, dstRect);
waitframes = 1;

vbl = Screen('Flip', w, vbl + (waitframes - 0.5) * ifi);  % Flip 'waitframes' monitor refresh intervals after last redraw.

% for TTL
if isfield(params, 'useLabJack') && params.useLabJack==1
    timedTTL(lj,locationTTL,10)
end
if isfield(params, 'useArduino') && params.useArduino ==1
    mat2arduino(arduinoCom, locationTTL, 0, 10) %writes info to arduino
    fwrite(arduinoCom,255); %% makes arduino start
end

% Flip to black screen from white screen flash
Screen('FillRect', w, params.black);
whiteScreen_waitframes = flashDuration*params.fps;
% Flip 'waitframes' monitor refresh intervals after last redraw.
vbl = Screen('Flip', w, vbl + (whiteScreen_waitframes - 0.5) * ifi);

end