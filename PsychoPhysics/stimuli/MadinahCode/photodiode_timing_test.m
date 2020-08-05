%To test the latency and jitter (variable latency) of stimulus
%presentations relative stimulus frame TTLs (send to neuralynx from
%ViewPixx), I test the relative timing between shifts in the response of a
%photodiode to screen changes and the TTL that indicates those screen
%changes. This program allows the user to select a movable box of variable
%size. Once this is specified, the contrast of the box changes in full
%(from black to white) at 60 cycles per second. A TTL is sent every time
%the frame is updated.

%6/27/2016 Madineh at Upenn
% Define black and white
params.white = WhiteIndex(params.screenNumber);
params.black = BlackIndex(params.screenNumber);
params.gray = GrayIndex(params.screenNumber);

%see if our vpixx window is still open, if not, open a new one
kind=Screen(params.window,'WindowKind');
if ~kind %if the window was closed accidentally or on purpose
    [params.window, params.windowRect]= PsychImaging('OpenWindow',params.screenNumber, params.black);
    Screen('Preference', 'VisualDebugLevel', 0);
    display('Opening a new on screen window');
else
    %do nothing
end





% Measure the vertical refresh rate of the monitor
[screenXpixels, screenYpixels] = Screen('WindowSize', params.window);

% Query the frame duration %in seconds
ifi = Screen('GetFlipInterval', params.window);
params.fps=120; %veiwpixx monitor


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

% check to see that DataPixx is open
DataPixxFlag=Datapixx('Open');
if ~DataPixxFlag
    Datapixx('Open');
    Datapixx('StopAllSchedules');
    Datapixx('RegWrRd');    % Synchronize DATAPixx registers to local register cache
end
% We'll make sure that all the TTL digital outputs are low before we start
Datapixx('SetDoutValues', 0);
Datapixx('RegWrRd');

%set frame timing
vbl = Screen('Flip', params.window);

%sync stuff
syncToVBL = 1; % Synchronize to vertical retrace by default.
if syncToVBL > 0
    asyncflag = 0;
else
    asyncflag = 2;
end
dontclear = 0; % Clear backbuffer to background color by default after each bufferswap.


%decide on the frame rate of each white noise sample
frameRefresh = 1/(120); % frame rate in s (0.03=30 Hz)
waitframes = round(frameRefresh *params.fps);


% Maximum priority level
topPriorityLevel = MaxPriority(params.window);
Priority(topPriorityLevel);

% Loop the animation until a key is pressed

% The avaliable keys to press
escapeKey = KbName('ESCAPE');
upKey = KbName('UpArrow');
downKey = KbName('DownArrow');
leftKey = KbName('LeftArrow');
rightKey = KbName('RightArrow');
spaceKey=KbName('Space');

%turn off char listen   ing
ListenChar(1)
% This is the cue which determines whether we exit the demo
exitDemo = false;

% Loop the animation until the escape key is pressed, indicating that
% you're happy with box position and size
while exitDemo == false
    
    % Check the keyboard to see if a button has been pressed
    [keyIsDown,secs, keyCode] = KbCheck;
    
    % Exit the demo if Escape is pressed
    if keyCode(spaceKey)
        exitDemo = true;
    end
    
    
    % Get the current position of the mouse
    [mx, my, buttons] = GetMouse(params.window);
    
    % Find the central position of the square
    [cx, cy] = RectCenter(centeredRect);
    
    % See if the mouse cursor is inside the square
    inside = IsInRect(mx, my, centeredRect);
    
    % If the mouse cursor is inside the square and a mouse button is being
    % pressed and the offset has not been set, set the offset and signal
    % that it has been set
   % if inside == 1 && sum(buttons(1)) > 0 && offsetSet == 0
    if inside == 1  && offsetSet == 0
        dx = mx - cx;
        dy = my - cy;
        offsetSet = 1;
    end
    
    % If we are clicking on the square allow its position to be modified by
    % moving the mouse, correcting for the offset between the centre of the
    % square and the mouse position
    
   % if inside == 1 && sum(buttons(1)) > 0

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
    
    % Flip the color on every frame
    if buttons(2)==1
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

clc
pause
display('Now that box is selected, we will proceed with timing test');

%% decide on the frame rate of each white noise sample
clear missed num_missed ind_missed 
frameRefresh = 1/ 2; % frame rate in s (0.03=30 Hz)
duration=frameRefresh;
waitframes = round(frameRefresh /ifi);

missed=[];
count=0;
numFrames=1000;
tstart = GetSecs;
  
while count<numFrames && ~KbCheck
    count=count+1;
         
    % Flip the color on every frame
    if mod(count,2)
        boxcolor=params.white;
        %boxcolor=130;

        Datapixx('SetDoutValues', [2]);

    else
        boxcolor=params.black;
        %boxcolor=120;

        Datapixx('SetDoutValues', [1]);
    end
    
    
    
    % Draw the rect to the screen
    Screen('FillRect', params.window, boxcolor, centeredRect);
    

    % Flip to the screen
    if count==1
        [vbl, ~, ~, missed(count)]=Screen('Flip', params.window);
        record(count,1)=vbl;
    else
        [vbl, ~, ~, missed(count)]=Screen('Flip', params.window, vbl + (waitframes-7/8)*ifi);
        record(count,1)=vbl;
    end
    
    %send out a TTL
    Datapixx('RegWrRd');
    pause(0.0001)
    Datapixx('SetDoutValues', 0);
    Datapixx('RegWrRd');
    
    if  missed(count)>0
        Datapixx('SetDoutValues', [3]);
        Datapixx('RegWrRd');
        pause(0.0001)
        Datapixx('SetDoutValues', 0);
        Datapixx('RegWrRd');
    end
    

end
   
% We're done: Output average framerate:     
telapsed = GetSecs - tstart
updaterate = count / telapsed 
params.totalFramesContrast=count;
num_missed=length(find(missed>=0))
ind_missed=find(missed>=0)
display(['missed ',num2str(num_missed),' out of ',num2str(count),' frames.']);
figure; 
plot(1:length(record)-1,(duration-diff(record(:,1)))*1000), title('Difference in duration from ideal'), ylabel('ms')
hold on;
plot(ind_missed,0.005.*(ones(1,num_missed)),'r*')

% Done. Close Screen, release all ressouces:
%save diode_timing_test_60.mat


