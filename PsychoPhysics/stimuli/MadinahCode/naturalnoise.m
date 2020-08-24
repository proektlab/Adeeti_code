function[]= naturalnoise(moviemat)

try
%7/8/2016
% A temporary script to work natural noise movies into experiment pipeline
% The movie is 0.375 deg/pix, 60 frame/sec, with a gamma of 2.2,
% SX=96 (pixels),SY=108 (pixels), 1802 frames.

% I need to be able to play the movie at 60 frames/second
% Then I need to be able to put a flexibly sized aperture anywhere on the
% image, while still playing it at 60 frames/second.

% The image should be at a fixed place (its center should be the center of
% the box output by splot), and at a fixed size. The size of splot box
% should then be used to select the size of the aperture, centered on the
% movie.

% I also need to stretch the image, because the one dawei gave me is too
% small

% Based on ContrastFlicker_pipeline(my script) and AlphaImageDemo

%%%%%%%%%%%%%%%%%%
%function naturalnoise
 sca
 clc
 try
     kind=Screen(params.window,'WindowKind');
 catch
     kind=0;
 end
 
newwindowflag= (~kind || ~exist('params') || ~isfield(params,'window'));
if newwindowflag==1
   display('Opening a new on screen window');    
    params.screenNumber=1;
    params.gray=0.5;
    params.gamma=2.08;
    params.sx=950;
    params.sy=600;
    
    % PsychDefaultSetup(2);
     PsychImaging('PrepareConfiguration');
  %   PsychImaging('AddTask', 'General', 'FloatingPoint32BitIfPossible');
 %    PsychImaging('AddTask', 'General', 'EnableDataPixxM16Output');
     PsychImaging('AddTask', 'FinalFormatting', 'DisplayColorCorrection', 'SimpleGamma');
     oldRes=SetResolution(1,1920,1200,120);

     [params.window, params.windowRect]= PsychImaging('OpenWindow',params.screenNumber,params.gray);
     PsychColorCorrection('SetEncodingGamma', params.window,1/params.gamma),
%     Screen('Preference', 'VisualDebugLevel', 3);
%     Screen('Preference', 'Verbosity',1);
%     Screen(params.window,'BlendFunction',GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
   % Screen('Preference', 'ConserveVRAM', 4);



else
    %do nothing
    %Screen(params.window,'BlendFunction',GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    
end



% Setup the rectangle for the background movie. It'll be centered on the
% splot box.
ix=720;
iy=480;
totalframes=1802;
%[ix,iy,totalframes]=size(moviemat);
scale = 2; % Don't up- or downscale patch by default.
objRect = SetRect(0,0, ix, iy);
% dstRect = ArrangeRects(numRects, objRect, params.windowRect);
% [xc, yc] = RectCenter(dstRect(1,:));
dstRect(1,:)=CenterRectOnPoint(objRect * scale, params.sx, params.sy);

% Set up texture for each frame
ct=0;
cb=0;
cl=0;
cr=0;

%setup frame frequency
frameRefresh=1/60;
% Query, or hardwire, the screen's frame update
fps= 120;
waitframes = round(frameRefresh *fps );


% initialize mouse position at center
[a,b]=WindowCenter(params.window);
SetMouse(a,b,params.screenNumber);
HideCursor;


% Main mouse tracking loop
mxold=0;
myold=0;
frame=0;
missed=zeros(1,totalframes);


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



% Bump priority for speed
priorityLevel=MaxPriority(params.window);
Priority(priorityLevel);
[ifi]= Screen('GetFlipInterval', params.window, 100, 0.00005, 20);
clearflag=2;



%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%         Animation Loop         %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Blank sceen
Screen('FillRect',params.window, params.gray);
tstart = GetSecs;
vbl=Screen('Flip', params.window);
for frame=1:100
%for frame=1:totalframes-1
   

    imagetex=Screen('MakeTexture', params.window, moviemat(1+ct:ix-cb, 1+cl:iy-cr,frame)');
    Screen('DrawTexture', params.window, imagetex, [], dstRect(1,:), [], 0);
    Screen('DrawingFinished', params.window,clearflag);

    %write out TTL (uncommenting this section produces dropped frames)
        Datapixx('SetDoutValues', [1]); %indicate frame startmo
        Datapixx('RegWrRd');
        Datapixx('SetDoutValues', [0]);
        Datapixx('RegWrRd');
%     
    [vbl, ~, ~, missed(1,frame)]  = Screen('Flip', params.window, vbl + (waitframes - 0.5) * (ifi),clearflag);

end

%%
% We're done: Output average framerate:
telapsed = GetSecs - tstart
updaterate =frame / telapsed

num_missed=length(find(missed>0))
ind_missed=find(missed>0)
display(['missed ',num2str(num_missed),' out of ',num2str(frame),' frames.']);


% The same command which closes onscreen and offscreen windows also
sca
%Priority(0);

catch
    sca
    Screen('CloseAll');
    rethrow(lasterror)

end

return
