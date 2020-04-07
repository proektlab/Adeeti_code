kind=Screen(params.window,'WindowKind');
if ~kind %if the window was closed accidentally or on purpose
    PsychDefaultSetup(2);
    PsychImaging('PrepareConfiguration');
    PsychImaging('AddTask', 'General', 'FloatingPoint32BitIfPossible');
    PsychImaging('AddTask', 'General', 'EnableDataPixxM16Output');
    PsychImaging('AddTask', 'FinalFormatting', 'DisplayColorCorrection', 'SimpleGamma');
    [params.window, params.windowRect]= PsychImaging('OpenWindow',params.screenNumber, params.gray);
    PsychColorCorrection('SetEncodingGamma', params.window,1/params.gamma),
    Screen('Preference', 'VisualDebugLevel', 0);
    display('Opening a new on screen window');
else
    %do nothing
end

% Measure the vertical refresh rate of the monitor
[screenXpixels, screenYpixels] = Screen('WindowSize', params.window);

% Query the frame duration %in seconds
ifi = Screen('GetFlipInterval', params.window);


% Get the centre coordinate of the window
[xCenter, yCenter] = RectCenter(params.windowRect);

% Make a base Rect of 200 by 200 pixels
boxsize=[200,200];
baseRect = [0 0 boxsize];

% Determine the percentage by which box size will change on key press
percentPerPress=0.01;

% Here we set the initial position of the mouse to be in the centre of the
% screen
SetMouse(xCenter, yCenter, params.window);

% We now set the squares initial position to the centre of the screen
sx = xCenter;
sy = yCenter;
centeredRect = CenterRectOnPointd(baseRect, sx, sy);

% Offset toggle. This determines if the offset between the mouse and centre
% of the square has been set. We use this so that we can move the position
% of the square around the screen without it "snapping" its centre to the
% position of the mouse
offsetSet = 0;

% Sync us and get a time stamp
vbl = Screen('Flip', params.window);
waitframes = 1;

% Maximum priority level
topPriorityLevel = MaxPriority(params.window);
Priority(topPriorityLevel);

%  prevent inputs into command window
ListenChar(-1);

% The avaliable keys to press
escapeKey = KbName('ESCAPE');
upKey = KbName('UpArrow');
downKey = KbName('DownArrow');
leftKey = KbName('LeftArrow');
rightKey = KbName('RightArrow');

% This is the cue which determines whether we exit the demo
exitDemo = false;

% Loop the animation until the escape key is pressed
while exitDemo == false
    
    % Check the keyboard to see if a button has been pressed
    [keyIsDown,secs, keyCode] = KbCheck;
    
    % Exit the demo if Escape is pressed
    if keyCode(escapeKey)
        exitDemo = true;
    end
    
    
    % Get the current position of the mouse
    [mx, my, buttons] = GetMouse(params.window);
    % If the mouse has wondered off to the second (matlab) screen, push
    % it back to the stimulus screen
    if ~IsInRect(mx,my,Screen('Rect',params.window))
        SetMouse(0+boxsize(1), 600, params.window);
    end

    
    % Find the central position of the square
    [cx, cy] = RectCenter(centeredRect);
    
    % See if the mouse cursor is inside the square
    inside = IsInRect(mx, my, centeredRect);
    
    % If the mouse cursor is inside the square and a mouse button is being
    % pressed and the offset has not been set, set the offset and signal
    % that it has been set
    if inside == 1  && offsetSet == 0
        dx = mx - cx;
        dy = my - cy;
        offsetSet = 1;
    end
    
    % If we are clicking on the square allow its position to be modified by
    % moving the mouse, correcting for the offset between the centre of the
    % square and the mouse position 
    sx = mx - dx;
    sy = my - dy;
    
    
    % Change the size of the box based on keyboard arrow key inputs
    
    if keyCode(leftKey) %Shrink width
        boxsize(1) = boxsize(1)*(1-percentPerPress);
    elseif keyCode(rightKey) %Grow width
        boxsize(1) = boxsize(1)*(1+percentPerPress);
    elseif keyCode(upKey) %Grow Height
        boxsize(2) = boxsize(2)*(1+percentPerPress);
    elseif keyCode(downKey) %Shrink Height
        boxsize(2) = boxsize(2)*(1-percentPerPress);
    end
    
    
    % Center the rectangle on its new screen position
    centeredRect = CenterRectOnPointd([0 0 boxsize], sx, sy);
    
    % Flip the color based on input to the spacebar
    if buttons(1)==1
        boxcolor=params.white;
    else
        boxcolor=params.black;
    end
    
    
    
    % Draw the rect to the screen
    Screen('FillRect', params.window, boxcolor, centeredRect);
    
    % Draw a white dot where the mouse cursor is
    Screen('DrawDots', params.window, [mx my], 10, params.white, [], 2);
    
    % Flip to the screen
    vbl  = Screen('Flip', params.window, vbl + (waitframes - 0.5) * ifi);
    
    % Check to see if the mouse button has been released and if so reset
    % the offset cue
    if sum(buttons) <= 0
        offsetSet = 0;
    end
    
end
% % Done. put on grayscreen
%sca
ListenChar();

params.boxsize=boxsize;
params.sx=sx;
params.sy=sy;
params.centeredRect =  centeredRect;

save boxcoords.mat boxsize sx sy 


