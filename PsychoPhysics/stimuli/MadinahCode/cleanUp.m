%cleans up VPixx experiment
ShowCursor(params.screens(1));
Screen('Preference', 'VisualDebugLevel', oldLevel );
ListenChar(0);
Priority(0);
Screen('CloseAll');

if params.vpixx_monitor
    % Terminate TTL schedule and close port
    PsychDatapixx('StopDoutSchedule');
    PsychDatapixx('RegWrRd');
    PsychDatapixx('Close');
end

% Get rid of exploreSequence history if it's online
clear exploreSequence 

rng('default')