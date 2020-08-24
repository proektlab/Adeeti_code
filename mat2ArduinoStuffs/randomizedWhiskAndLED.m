%% Matlab to Arduino for Stimulation 08/31/18

%% User input of stimulation parameters
LEDPIN = 13;
LED2EEG = 12;
ledOn = 10;

WHISKPIN = 11;
WHISK2EEG = 10;
whiskerOn = 10;

allDelays = [[0 inf]; [0 0]; [0 50]; [0 100]; [inf 0]; [50 0]; [100 inf]];

timeBetweenTrial = [3,5];

numTrialsPerSet = 100;

numSets = size(allDelays,1);

%% randomizing time between trials


rng('shuffle');
randTimeBtwnTrials = min(timeBetweenTrial) + (max(timeBetweenTrial)-min(timeBetweenTrial))*rand(numTrialsPerSet,numSets);

%% Open Serial Processor 
 arduinoCom = serial('/dev/cu.usbmodem1461','BaudRate',9600);  % insert your serial
 fopen(arduinoCom);
 pause(3) 
 
 endTime = 1000;
 startTime = 0;

 
 
mat2arduino(arduinoCom, 13, 5, 0, 1000)

  fwrite(arduinoCom,255);
  
  mat2arduino(arduinoCom, 13, 5, 1000, 1000)

  fwrite(arduinoCom,255);
  
  mat2arduino(arduinoCom, 13, 5, 100, 1000)

  fwrite(arduinoCom,255);
 
 
 
 
 
 
 fwrite(arduinoCom,13); %this will send 5 to the arduino
 fwrite(arduinoCom,floor(startTime/2^8)); %this will send 5 to the arduino
 fwrite(arduinoCom,mod(startTime,2^8)); %this will send 5 to the arduino
 fwrite(arduinoCom,floor(endTime/2^8)); %this will send 5 to the arduino
 fwrite(arduinoCom,mod(endTime,2^8)); %this will send 5 to the arduino
 
 endTime = 2000;
 startTime = 1000;
 fwrite(arduinoCom,5); %this will send 5 to the arduino
 fwrite(arduinoCom,floor(startTime/2^8)); %this will send 5 to the arduino
 fwrite(arduinoCom,mod(startTime,2^8)); %this will send 5 to the arduino
 fwrite(arduinoCom,floor(endTime/2^8)); %this will send 5 to the arduino
 fwrite(arduinoCom,mod(endTime,2^8)); %this will send 5 to the arduino
 fwrite(arduinoCom,255);

 
 fscanf(arduinoCom) 
 fscanf(arduinoCom) 
 fscanf(arduinoCom) 
 fscanf(arduinoCom) 
 fscanf(arduinoCom) 
 fscanf(arduinoCom) 
 fclose(arduinoCom);