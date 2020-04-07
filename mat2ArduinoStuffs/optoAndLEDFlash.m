%% Matlab to Arduino for Stimulation 08/31/18
% dont put things into 0, 1, 13 
% make sure MAXCHANNELS on ArdMat_FastHardwareThingy is 6 or more

%% User input of stimulation parameters

%LEDPIN = 9;  % static rig
LEDPIN = 10;  %sensory rig
startWarning = 7; %warning pin

LED2EEG = 8; 

startOptoPin = 11;
stopOptoPin = 12;

startOpto2EEG = 5;
stopOpto2EEG = 6;


ledOnTime = 10;
optoOnTime= 650;
delayOpto = -400; % neg for before LED light stim, pos for after
optoUpstroke = 5;

allDelays = 0;
timeBetweenTrial = [1 3];
numTrialsPerSet = 500;

if delayOpto<0
    LEDOnset = abs(delayOpto);
    LEDEndTime = LEDOnset + ledOnTime;
    optoStartOnset = 0;
    optoStartEndTime = optoStartOnset + optoUpstroke;
    optoStopOnset = optoOnTime;
    optoStopEndTime = optoStopOnset + optoUpstroke;
elseif delayOpto>=0
    LEDOnset = 0;
    LEDEndTime = LEDOnset + ledOnTime;
    optoStartOnset = delayOpto;
    optoStartEndTime = optoStartOnset + optoUpstroke;
    optoStopOnset = delayOpto + optoOnTime;
    optoStopEndTime = optoStopOnset + optoUpstroke;
end

%% randomizing time between trials
numSets = size(allDelays,1);
rng('shuffle');
randTimeBtwnTrials = min(timeBetweenTrial) + (max(timeBetweenTrial)-min(timeBetweenTrial))*rand(numTrialsPerSet,numSets);

%% Open Serial Processor 
%  MAC
%  arduinoCom = serial('/dev/cu.usbmodem1461','BaudRate',9600);  % insert your serial
%  PC
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
         mat2arduinoDouble(arduinoCom, LEDPIN, LED2EEG, LEDOnset, LEDEndTime) %writes info to arduino 
         mat2arduinoDouble(arduinoCom, startOptoPin, startOpto2EEG, optoStartOnset, optoStartEndTime) %writes info to arduino
         mat2arduinoDouble(arduinoCom, stopOptoPin, stopOpto2EEG, optoStopOnset, optoStopEndTime) %writes info to arduino 
         
         fwrite(arduinoCom,255); %% makes arduino start
         pause(randTimeBtwnTrials(b,a)) % random time between trials 
         disp(b)
     end
 end
 
 fclose(arduinoCom);
 