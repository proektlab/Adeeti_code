% Plots full-field randomly fluctuating contrasts on Viewpixx
% Update at 60 Hz
% Send out a TTL on bit 1 on every frame update
% Madineh July 2016

try
    clear all
    clc
    close all
    
    %setup imaging pipeline, include gamma correction
    PsychDefaultSetup(2);
    PsychImaging('PrepareConfiguration');
    PsychImaging('AddTask', 'General', 'FloatingPoint32BitIfPossible');
    PsychImaging('AddTask', 'General', 'EnableDataPixxM16Output');
    PsychImaging('AddTask', 'FinalFormatting', 'DisplayColorCorrection', 'SimpleGamma');
    oldRes=SetResolution(1,1920,1200,120);

    [params.window, windowRect]= PsychImaging('OpenWindow',max(Screen('Screens')));
   % PsychColorCorrection('SetEncodingGamma', params.window,1/2.08),
    Screen('Preference', 'VisualDebugLevel', 3);
    Screen('Preference', 'Verbosity', 1);
    
    display('Opening a new on screen window');
   
        
    %load box info for full-field (normally this comes included in
    %configure screen struct)
    
    boxsize=windowRect(3:4);
    centeredRect = CenterRectOnPointd([0 0 boxsize], 0.5*windowRect(3), 0.5*windowRect(4));
    
    
    %Create a vector of contrasts
    refreshrate= 60; %must be < and evenly  divisble into 120 Hz (15, 30, 60)Hz
    numFramesPerBlock=5000;
    numBlocks=1;
    totalFrames=numBlocks*numFramesPerBlock;
    contrast=rand(1,numFramesPerBlock);
    
    
    %Setup Datapixx for sending TTLs
    DataPixxFlag=Datapixx('Open'); %check to see that DataPixx is open
    if ~DataPixxFlag
        Datapixx('Open');
        Datapixx('StopAllSchedules');
        Datapixx('RegWrRd');    % Synchronize DATAPixx registers to local register cache
    end
    % We'll make sure that all the TTL digital outputs are low before we start
    Datapixx('SetDoutValues', 0);
    Datapixx('RegWrRd');
    PsychDataPixx('GetPreciseTime'); %sycnh clocks
    
        
    %Set top priortiy, and get screen refresh reate
    topPriorityLevel = MaxPriority(params.window);
    Priority(topPriorityLevel);
    [ifi]= Screen('GetFlipInterval', params.window, 100, 0.00005, 20);
    clearflag = 2; % Clear backbuffer to background color by default after each bufferswap.
    
    %decide on the frame rate of each white noise sample
    frameRefresh = 1/refreshrate;
    waitframes = round(frameRefresh /(ifi));
    
    
    %allocate missed vector and get initial time
    missed=zeros(1,totalFrames); %initialize missed frame vector
    drawtime=zeros(1,totalFrames); %for checking out how long it takes us to draw
    tstart = GetSecs;
    [vbl]=Screen('Flip', params.window); %flip to screen to get vbl
    
    for i=1:totalFrames
        
        %prepare to draw (use textures instead of Screen('FillRect') to
        %simulate process for more complex stimuli
        tex=Screen('MakeTexture', params.window, contrast(i));
        Screen('DrawTexture', params.window, tex,[0 0 boxsize],centeredRect);
        %drawtime(i)=Screen('DrawingFinished', params.window,clearflag,1);
        Screen('DrawingFinished', params.window,clearflag);
        
        
        %write out TTL (uncommenting this section produces dropped frames)
        Datapixx('SetDoutValues', [1]); %indicate frame start
        Datapixx('RegWrRd');
        Datapixx('SetDoutValues', [0]);
        Datapixx('RegWrRd');
        
        %initate buffer swap
        if i==1
            [vbl, ~, ~, missed(i)]=Screen('Flip', params.window); %use a half-frame slack
            
        else
            
            [vbl, ~, ~, missed(i)]=Screen('Flip', params.window, vbl + (waitframes-0.5 )*ifi,clearflag); %use a half-frame slack
            
        end
    end
    
    
    % We're done: Output average framerate:
    telapsed = GetSecs - tstart
    updaterate = i/ (telapsed) %since we wait 1 second between blocks
    num_missed=length(find(missed>0))
    ind_missed=find(missed>0)
    display(['missed ',num2str(num_missed),' out of ',num2str(i),' frames.']);
    
    
    %cleanup stuff
    Priority(0);
    sca
    
catch
    Priority(0);
    sca
    rethrow(lasterror)

end

