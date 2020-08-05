function []=square_pulse_fourc(duration,params)
%Just a square pulse of bright vs dark in the square we already created
kind=Screen(params.window,'WindowKind');
if ~kind %if the window was closed accidentally or on purpose
    PsychDefaultSetup(2);
    PsychImaging('PrepareConfiguration');
    PsychImaging('AddTask', 'General', 'FloatingPoint32BitIfPossible');
    PsychImaging('AddTask', 'General', 'EnableDataPixxM16Output');
    PsychImaging('AddTask', 'FinalFormatting', 'DisplayColorCorrection', 'SimpleGamma');
    SetResolution(1,1920,1200,120);
    [params.window, params.windowRect]= PsychImaging('OpenWindow',params.screenNumber, params.gray);
    PsychColorCorrection('SetEncodingGamma', params.window,1/params.gamma),
    %Screen('LoadNormalizedGammaTable', params.window, linspace(0, 1, 256)' * [1, 1, 1]);
    Screen('Preference', 'VisualDebugLevel', 0);
    display('Opening a new on screen window');
else
    %do nothing
end

% Query the frame duration %in seconds
ifi = Screen('GetFlipInterval', params.window);
%% decide on the frame rate of each white noise sample
clear missed num_missed ind_missed 
waitframes = round(duration/ifi);

missed=[];
numFrames=10000;
tstart = GetSecs;


count=0; 
boxcolor=params.white; %first color is white, signaled by TTL=3
Screen('FillRect', params.window, boxcolor, params.centeredRect);
Datapixx('SetDoutValues', [3]);
Datapixx('RegWrRd');
vbl=Screen('Flip',params.window);

while count<numFrames && ~KbCheck
    %update count
    count=count+1;
    
    % update color
    if mod(count,4)==0
        boxcolor=params.white;      
        TTLval=3;
    elseif mod(count,4)==1
        boxcolor=params.gray;
        TTLval=5;
    elseif mod(count,4)==2
        boxcolor=params.black;
        TTLval=7;
    else 
        boxcolor=params.gray;
        TTLval=5;
    end
    
    % Draw the rect to the screen
    Screen('FillRect', params.window, boxcolor, params.centeredRect);
    
    % Flip to the screen
    [vbl, ~, ~, missed(count)]=Screen('Flip', params.window, vbl + (waitframes-7/8)*ifi);
    %send TTL
    Datapixx('SetDoutValues',  TTLval);
    Datapixx('RegWrRd');
  
    

end
   
% We're done: Output average framerate:     
telapsed = GetSecs - tstart
updaterate = count / telapsed 
params.totalFramesContrast=count;
num_missed=length(find(missed>=0))
ind_missed=find(missed>=0)
display(['missed ',num2str(num_missed),' out of ',num2str(count),' frames.']);

return
