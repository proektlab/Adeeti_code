% Matlab to Arduino for Stimulation 08/31/18

%% User input of stimulation parameters

LEDPIN = 7; % sensory rig
%LEDPIN = 8; %static rig
ledOn = 10; %in ms

LED2EEGfirst = 5;
LED2EEGsecond = 4;

allDelays = [0 20 50 100 200 300 500];
numDelays = size(allDelays,2);
timeBetweenTrial = [3 4]; %in s
numTrialsPerSet = 80;

%% randomizing time between trials
numSets = 1;

allDelayTrials = repmat(allDelays, 1, numDelays*numTrialsPerSet);
rng('shuffle');
randTimeBtwnTrials = min(timeBetweenTrial) + (max(timeBetweenTrial)-min(timeBetweenTrial))*rand(numTrialsPerSet*numDelays,numSets);
randDelaysInd = randperm(numDelays*numTrialsPerSet);
randDelays = allDelayTrials(randDelaysInd);
%% Open Serial Processor 

if ~exist('arduinoCom')
    arduinoCom = serial('/dev/ttyACM0','BaudRate',9600); % insert your serial  LINUX
    % arduinoCom = serial('COM3','BaudRate',9600); % insert your serial PC
    % arduinoCom = serial('/dev/tty.usbmodem14201','BaudRate',9600);  % MAC
end
if strcmpi(arduinoCom.Status, 'open')
    fclose(arduinoCom);
end

fopen(arduinoCom);
pause(3)
 
%% Loop for stim   
 for a = 1:size(randTimeBtwnTrials,1)
         mat2arduinoDouble(arduinoCom, LEDPIN, LED2EEGfirst, 0, ledOn) %writes info to arduino 
         mat2arduinoDouble(arduinoCom, LEDPIN, LED2EEGsecond, randDelays(a), ledOn) %writes info to arduino 
         fwrite(arduinoCom,255); %% makes arduino start
         pause(randTimeBtwnTrials(a)) % random time between trials 
         disp(a)
 end
 
 fclose(arduinoCom);
