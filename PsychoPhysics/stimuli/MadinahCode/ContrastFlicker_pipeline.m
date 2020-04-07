% Plots full-field randomly fluctuating contrasts in the box selected using spatial_map.m
% Modified from FastNoiseDemo PTB4
% Madineh May 2016

function[missed,duration,contrast]=ContrastFlicker_pipeline(params,refreshrate,numBlocks,contrast)
kind=Screen(params.window,'WindowKind');

try
if ~kind %if the window was closed accidentally or on purpose
    PsychDefaultSetup(2);
    PsychImaging('PrepareConfiguration');
    PsychImaging('AddTask', 'General', 'FloatingPoint32BitIfPossible');
    PsychImaging('AddTask', 'General', 'EnableDataPixxM16Output');
    PsychImaging('AddTask', 'FinalFormatting', 'DisplayColorCorrection', 'SimpleGamma');
        oldRes=SetResolution(1,1920,1200,120);

    [params.window,params.windowRect]= PsychImaging('OpenWindow',params.screenNumber);
    %PsychColorCorrection('SetEncodingGamma', params.window,1/params.gamma),
    Screen('Preference', 'VisualDebugLevel', 3);
    Screen('Preference', 'Verbosity', 1);
    Screen('Preference', 'ConserveVRAM', 3);
    display('Opening a new on screen window');
else
    %do nothing
end


%load box info
boxsize= params.windowRect(3:4);
centeredRect = CenterRectOnPointd([0 0 boxsize], 0.5*params.windowRect(3), 0.5*params.windowRect(4))


%make textures out of contrast
numFramesPerBlock=size(contrast,2);
for i=1:numFramesPerBlock
		tex(i)=Screen('MakeTexture', params.window, contrast(i)); %#ok<AGROW>
end
   


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
syncToVBL = 1; % Synchronize to vertical retrace by default.
if syncToVBL > 0
    asyncflag = 0;
else
    asyncflag = 2;
end
clearflag = 2; % Clear backbuffer to background color by default after each bufferswap.


%Set top priortiy, gand get refresh reate
topPriorityLevel = MaxPriority(params.window);
Priority(topPriorityLevel);
[ifi]= Screen('GetFlipInterval', params.window, 100, 0.00005, 20);

%decide on the frame rate of each white noise sample
frameRefresh = 1/refreshrate; 
waitframes = round(frameRefresh /(ifi));
duration=frameRefresh;
waitframes2=round(1/ifi); %wait 1 second between blocks


% Run noise image drawing loop until all blocks are run or until user interrupts with key press:
% Init framecounter to zero and take initial timestamp:
blockCount=0; %number of full repeats, each block consists of many frames
frameCount=0; %number of frame within each block
totalFrames=numBlocks*numFramesPerBlock;
missed=zeros(1,totalFrames); %initialize missed frame vector


%get initial time
tstart = GetSecs; 
[vbl, ~, ~, missed(1)]=Screen('Flip', params.window );

for i=1:totalFrames
     
    %setup counters
    frameCount=frameCount+1; %update frame counter, each block has a defined number of frames
    if frameCount==numFramesPerBlock+1; %if we've reached the last frame in a block, reset frame counter
        frameCount=1;
    else
      
    end
        
        
     %prepare to draw
    Screen('DrawTexture', params.window, tex(frameCount),[0 0 boxsize],centeredRect);
    Screen('DrawingFinished', params.window,clearflag);
    
    
    %initate buffer swap
    if frameCount==1
        Datapixx('SetDoutValues', [3]);         %if you're at blockstart, set TTL2 high
        Datapixx('RegWrRd');
        Datapixx('SetDoutValues', [0]);         %if you're at blockstart, set TTL2 high
        Datapixx('RegWrRd');
        [vbl, ~, ~, missed(i)]=Screen('Flip', params.window,vbl + (waitframes-0.5 )*ifi,clearflag); %use a half-frame slack
        
    elseif frameCount==numFramesPerBlock
       [vbl, ~, ~, missed(i)]=Screen('Flip', params.window,vbl + (waitframes2-0.5 )*ifi,clearflag); %use a half-frame slack

    else
        Datapixx('SetDoutValues', [5]);         %if you're at framestart, set TTL2 high
        Datapixx('RegWrRd');
        Datapixx('SetDoutValues', [0]);         %if you're at blockstart, set TTL2 high
        Datapixx('RegWrRd');
        [vbl, ~, ~, missed(i)]=Screen('Flip', params.window, vbl + (waitframes-0.5 )*ifi,clearflag); %use a half-frame slack
    end
    
end 


% We're done: Output average framerate:
telapsed = GetSecs - tstart
updaterate = i/ (telapsed - numBlocks) %since we wait 1 second between blocks
num_missed=length(find(missed>0))
ind_missed=find(missed>0)
display(['missed ',num2str(num_missed),' out of ',num2str(i),' frames.']);


%cleanup stuff
Priority(0);
ListenChar();

catch
    % This "catch" section executes in case of an error in the "try" section
    % above. Importantly, it closes the onscreen window if it is open.
    ListenChar();
    Priority(0);
    Screen('CloseAll');
    psychrethrow(psychlasterror);
    
    
end %try..catch..
