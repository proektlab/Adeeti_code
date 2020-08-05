%% Matlab to Arduino for Stimulation 08/31/18
% dont put things into 0, 1, 13
% make sure MAXCHANNELS on ArdMat_FastHardwareThingy is 6 or more

%% User input of stimulation parameters

LEDPIN = 9;  % static rig
% LEDPIN = 10;  %sensory rig
startWarning = 7; %warning pin

LED2EEG = 8; 

ledOnTime = 10;
delayWarning = -500; % neg for before LED light stim, pos for after
WarningUpstroke = 5;

allDelays = 0;
timeBetweenTrial = [3 5];
numTrialsPerSet = 20000;

%%
LEDOnset = abs(delayWarning);
LEDEndTime = LEDOnset + ledOnTime;
WarningStartOnset = 0;
WarningStartEndTime = WarningStartOnset + WarningUpstroke;


%% randomizing time between trials
numSets = size(allDelays,1);
rng('shuffle');
randTimeBtwnTrials = min(timeBetweenTrial) + (max(timeBetweenTrial)-min(timeBetweenTrial))*rand(numTrialsPerSet,numSets);

%% Open Serial Processor

if ~exist('arduinoCom')
    %arduinoCom = serial('/dev/ttyACM0','BaudRate',9600); % insert your serial  LINUX
    arduinoCom = serial('COM3','BaudRate',9600); % insert your serial  PC
    %arduinoCom = serial('/dev/cu.usbmodem1461','BaudRate',9600);  % insert your serial MAC
end
if strcmpi(arduinoCom.Status, 'open')
    fclose(arduinoCom);
end

fopen(arduinoCom);
pause(3)

%% Loop for stim
for a = 1:size(randTimeBtwnTrials,2)
    for b = 1:size(randTimeBtwnTrials,1)
        mat2arduinoDouble(arduinoCom, LEDPIN, LED2EEG, LEDOnset, ledOnTime) %writes info to arduino
        mat2arduino(arduinoCom, startWarning, WarningStartOnset, WarningStartEndTime) %writes info to arduino
        
        fwrite(arduinoCom,255); %% makes arduino start
        pause(randTimeBtwnTrials(b,a)) % random time between trials
        disp(b)
    end
end

fclose(arduinoCom);
