% Matlab to Arduino for Stimulation 08/31/18

%% User input of stimulation parameters

%LEDPIN = 9;  % static rig
LEDPIN = 10;  %sensory rig
LED2EEG = 8;
ledOn = 10; %in ms

allDelays =0 ;
timeBetweenTrial = [3 5]; %in s
numTrialsPerSet =10000;

%% randomizing time between trials
numSets = size(allDelays,1);
rng('shuffle');
randTimeBtwnTrials = min(timeBetweenTrial) + (max(timeBetweenTrial)-min(timeBetweenTrial))*rand(numTrialsPerSet,numSets);

%% Open Serial Processor 

if ~exist('arduinoCom')
    % arduinoCom = serial('/dev/ttyACM0','BaudRate',9600); % insert your serial  LINUX
     arduinoCom = serial('COM3','BaudRate',9600); % insert your serial PC
    % arduinoCom = serial('/dev/tty.usbmodem14201','BaudRate',9600);  % MAC
    % insert your serial MAC
end
if strcmpi(arduinoCom.Status, 'open')
    fclose(arduinoCom);
end

fopen(arduinoCom);
pause(3)

 
%% Loop for stim   
 for a = 1:size(randTimeBtwnTrials,2)
     for b = 1:size(randTimeBtwnTrials,1)
         mat2arduinoDouble(arduinoCom, LEDPIN, LED2EEG, allDelays, ledOn) %writes info to arduino 
         fwrite(arduinoCom,255); %% makes arduino start
         pause(randTimeBtwnTrials(b,a)) % random time between trials 
         disp(b)
     end
 end
 
 fclose(arduinoCom);
