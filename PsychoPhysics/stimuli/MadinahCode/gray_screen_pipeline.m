%gray_screen_pipeline
%just a gray screen

% Open fullscreen onscreen window on that screen. Background color is
% gray, double buffering is enabled. Return a 'win'dowhandle and a

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



Screen('FillRect', params.window, params.gray, params.windowRect);
Screen('Flip', params.window);

% Now we have drawn to the screen we wait for a keyboard button press (any
% key) to terminate the demo.
KbStrokeWait;

%sca