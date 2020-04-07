% Plots 2D white noise in the box selected using spatial_map.m
% Modified from FastNoiseDemo PTB4
% Madineh May 2016

function[params,filtnoise,missed]=RFmapping_pipeline(params, numBlocks,fullScreen_flag)


kind=Screen(params.window,'WindowKind');
if ~kind %if the window was closed accidentally or on purpose
    PsychDefaultSetup(2);
    PsychImaging('PrepareConfiguration');
    PsychImaging('AddTask', 'General', 'FloatingPoint32BitIfPossible');
    PsychImaging('AddTask', 'General', 'EnableDataPixxM16Output');
    PsychImaging('AddTask', 'FinalFormatting', 'DisplayColorCorrection', 'SimpleGamma');
    oldRes=SetResolution(1,1920,1200,120);

    [params.window, params.windowRect]= PsychImaging('OpenWindow',max(Screen('Screens')),params.gray);
    PsychColorCorrection('SetEncodingGamma', params.window,1/params.gamma);

    % Screen('Preference', 'VisualDebugLevel', 3);
    Screen('Preference', 'ConserveVRAM', 2);
    display('Opening a new on screen window');
else
    %do nothing
end

maxRFpixelsx= ceil(1900*params.pixelDeg*1/params.RFpixelDeg);
maxRFpixelsy= ceil(1200*params.pixelDeg*1/params.RFpixelDeg);

%determine size of aperture
if fullScreen_flag
    boxsize=[1900 1200];
    numRFpixelsx=ceil(boxsize(1)*params.pixelDeg*1/params.RFpixelDeg);
    numRFpixelsy=ceil(boxsize(2)*params.pixelDeg*1/params.RFpixelDeg);
    xcenter=950;
    ycenter=600;
else
    % load parameters for box
    boxsize=params.boxsize.*1.0;
    % calculate number of pixels given the spatial resolution (#degrees per RF pixel=2 degrees)
    %numRFpixels=boxwidth(pixels)*params.pixeldeg(deg/pixels)*(1/2)(RFpixels/deg)
    numRFpixelsx=ceil(boxsize(1)*params.pixelDeg*1/params.RFpixelDeg);
    numRFpixelsy=ceil(boxsize(2)*params.pixelDeg*1/params.RFpixelDeg);
    xcenter=params.sx;
    ycenter=params.sy;
end

%throw an error if number of RF pixels is greater than 55 (full screen)
if numRFpixelsx>maxRFpixelsx || numRFpixelsy> maxRFpixelsy
    Warning(['The number of RF pixels exceeds full screen.'])
    numRFpixelsx=maxRFpixelsx;
    numRFpixelsx=maxRFpixelsy;
    
end

scale = params.RFpixelDeg/params.pixelDeg; % Don't up- or downscale patch by default.
% Compute destination rectangle locations for the random noise patches:
% 'objRect' is a rectangle of the size 'numRFpixels' by 'numRFpixels' pixels of
% our Matlab noise image matrix:
objRect = SetRect(0,0, numRFpixelsx, numRFpixelsy);
dstRect=CenterRectOnPoint(objRect * scale, xcenter, ycenter);

%load the noise
[filtnoise,totalFrames,blockStart]=LoadWhiteNoise(numRFpixelsy,numRFpixelsx,numBlocks);

% The avaliable keys to press
escapeKey = KbName('ESCAPE');
upKey = KbName('UpArrow');
downKey = KbName('DownArrow');
leftKey = KbName('LeftArrow');
rightKey = KbName('RightArrow');


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


%sync stuff
% syncToVBL = 1=Synchronize bufferswaps to retrace. 0=Swap immediately when
% drawing is finished. Value zero is useful for benchmarking the whole
% system, because your measured framerate will not be limited by the
% monitor refresh rate -- Gives you a feeling of how much headroom is left
% in your loop.
%
% clearflag = If set to 2 then the backbuffer is not automatically cleared
% to background color after a flip. Can save up to 1 millisecond on old
% graphics hardware.
clearflag = 2; % Clear backbuffer to background color by default after each bufferswap.



%get timestamp and flip to screen
topPriorityLevel = MaxPriority(params.window);
Priority(topPriorityLevel);
ifi = Screen('GetFlipInterval', params.window);
if ifi>0.009
    display('Monitor Refresh Rate is Wrong. Run XOrgConfCreator and try again');
    return
end

%decide on the frame rate of each white noise sample
frameRefresh = 1/60; % frame rate in s (0.03=30 Hz)
waitframes = round(frameRefresh *1/ifi);

% Run noise image drawing loop until all blocks are run or until user interrupts with key press:
% Init framecounter to zero and take initial timestamp:
missed=zeros(size(totalFrames));
exitGrating=false;

tstart = GetSecs;
vbl = Screen('Flip', params.window);

BlockCount=0
while exitGrating==false 
    for count=1:totalFrames
        
        % Check the keyboard to see if a button has been pressed
        [keyIsDown,secs,keyCode]=KbCheck; %#ok<ASGLU>
        if (keyIsDown && keyCode(escapeKey))
            % Set the abort-demo flag.
            exitGrating = true;
            break;
        end
        
        
        
        % Convert it to a texture 'tex':
        tex=Screen('MakeTexture', params.window, filtnoise{count});
        Screen('DrawTexture', params.window, tex, [], dstRect, [], 0);
        Screen('DrawingFinished', params.window,clearflag);
        
        
      % initate buffer swap
        if ismember(count,blockStart)
            BlockCount=BlockCount+1
            Datapixx('SetDoutValues', [5]);
            Datapixx('RegWrRd');
            %pause(0.001);
            Datapixx('SetDoutValues', 0);
            Datapixx('RegWrRd');
            
            [vbl, ~, ~, missed(count)]=Screen('Flip', params.window, vbl + (waitframes-0.5 )*ifi,clearflag); %use a half-frame slack
            
      else
            
            Datapixx('SetDoutValues', 2);
            Datapixx('RegWrRd');
            %pause(0.001);
            Datapixx('SetDoutValues', 0);
            Datapixx('RegWrRd');
            [vbl, ~, ~, missed(count)]=Screen('Flip', params.window, vbl + (waitframes-0.5 )*ifi,clearflag); %use a half-frame slack
            
      end
        
    end
end


% We're done: Output average framerate:
telapsed = GetSecs - tstart
updaterate = count / telapsed

num_missed=length(find(missed>0))
ind_missed=find(missed>0)
display(['missed ',num2str(num_missed),' out of ',num2str(count),' frames.']);

params.totalFramesWhiteNoise=count;


% Now we have drawn to the screen we wait for a keyboard button press (any
% key) to terminate the demo.
Screen('FillRect', params.window,  0.5, params.windowRect);
Screen('Flip', params.window);

Priority(0);

return



