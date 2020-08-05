%DatapixxDoutTriggerDemo
% DatapixxDoutTriggerDemo()
%
% Shows how to use a digital output schedule to generate a regular pulse train
% of TTL triggers.
% The pulse train begins at a vertical sync pulse,
% then generates 16 trigger pulses per video frame for the next 100 video frames.
%
% Also see: DatapixxDoutBasicDemo
%
% History:
%
% Oct 1, 2009  paa     Written

AssertOpenGL;   % We use PTB-3

Datapixx('Open');
Datapixx('StopAllSchedules');
Datapixx('RegWrRd');    % Synchronize Datapixx registers to local register cache

% We'll make sure that all the TTL digital outputs are low before we start
Datapixx('SetDoutValues', 0);
Datapixx('RegWrRd');

% Define what we want a "trigger pulse" to look like,
% then download it to the Datapixx.
% We'll arbitrarily say that it is 1 sample high, and 3 samples low.
doutWave = [2^15-2]; % Should be able to put in 15-bit values for each entry
bufferAddress = 8e6;
Datapixx('WriteDoutBuffer', doutWave, bufferAddress);

% Define the schedule which will play the wave.
samplesPerTrigger = size(doutWave,2);
triggersPerFrame = 16;
samplesPerFrame = samplesPerTrigger * triggersPerFrame;
framesPerTrial = 100;       % We'll send triggers for 100 video frames
samplesPerTrial = samplesPerFrame * framesPerTrial;
Datapixx('SetDoutSchedule', 0, [samplesPerFrame, 2], samplesPerTrial, bufferAddress, samplesPerTrigger);

% Insert your visual stimulus setup code here, finishing up with a Screen('Flip', window);

% Tell the trigger schedule to start on the next vertical sync pulse

% THESE TWO LINES NEED TO GO AFTER PRE-CYCLE
Datapixx('StartDoutSchedule');
Datapixx('RegWrVideoSync');

% Insert visual stimulus animation code here.
% The TTL triggers will begin during the first video frame defined here.


% \\\\\\\\\\
% Split the below into a script after trial has run
% //////////


% We'll wait here until the digital output schedule has completed,
% or user aborts with a keypress.
fprintf('\nTrigger output started, press any key to abort.\n');

while 1
    Datapixx('RegWrRd');   % Update registers for GetDoutStatus
    status = Datapixx('GetDoutStatus');
    if ~status.scheduleRunning
        break;
    end
    if KbCheck
        Datapixx('StopDoutSchedule');
        Datapixx('RegWrRd');
        break;
    end
end

fprintf('\nStatus information for digital output scheduler:\n');
Datapixx('RegWrRd');   % Update registers for GetAudioStatus
disp(Datapixx('GetDoutStatus'));

% Job done
Datapixx('Close');
fprintf('\nDemo completed\n\n');
