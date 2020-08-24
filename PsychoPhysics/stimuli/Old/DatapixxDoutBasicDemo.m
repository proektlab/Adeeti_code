%function DatapixxDoutBasicDemo()
% DatapixxDoutBasicDemo()
%
% Demonstrates basic function of the Datapixx TTL digital outputs.
% Prints the number of TTL outputs in the system,
% then waits for keypresses to:
%   -Set digital output 0 high
%   -Set all digital outputs high
%   -Bring all digital outputs back low
%
% Also see: DatapixxDoutTriggerDemo
%
% History:
%
% Oct 1, 2009  paa     Written

AssertOpenGL;   % We use PTB-3

% Open Datapixx, and stop any schedules which might already be running
Datapixx('Open');
Datapixx('StopAllSchedules');
Datapixx('RegWrRd');    % Synchronize Datapixx registers to local register cache

% Show how many TTL output bits are in the Datapixx
nBits = Datapixx('GetDoutNumBits');
fprintf('\nDatapixx has %d TTL output bits\n\n', nBits);

%pause(2)

for i = [1:11]
% Bring 1 output high
%HitKeyToContinue('\nHit any key to bring digital output bit 0 high:');
disp(num2str(i))
Datapixx('SetDoutValues', i);
Datapixx('RegWrRd');
pause(1)

% Bring all the outputs high
%HitKeyToContinue('\nHit any key to bring all the digital outputs high:');

%disp(num2str(i))
%pause(1)

% Bring all the outputs low
%HitKeyToContinue('\nHit any key to bring all the digital outputs low:');
Datapixx('SetDoutValues', 0);
Datapixx('RegWrRd');

pause(1)
end

% Job done
Datapixx('Close');
fprintf('\n\nDemo completed\n\n');
