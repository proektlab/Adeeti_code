function mat2arduinoDouble(arduinoCom, stimPin, stimEEG, stimOnset, stimOn)
% mat2arduino(arduinoCom, stimPin, stimEEG, stimOnset, stimOn)
% stimPin and stimEEG are in terms of int digital pins on arduino uno board
% stimOnset and StimOn are in msec
% Assume jitter of 10 usec

% 08/30/18 CB and AA
%%
endTime = stimOnset+stimOn;

 fwrite(arduinoCom,stimPin); %signifies pin for stimulation 
 fwrite(arduinoCom,floor(stimOnset/2^8)); %when does pulse start left most 8 bits
 fwrite(arduinoCom,mod(stimOnset,2^8)); %when does pulse start right most 8 bits
 fwrite(arduinoCom,floor(endTime/2^8)); %when does the pulse end left most 8 bits
 fwrite(arduinoCom,mod(endTime,2^8)); %when does the pulse end right most 8 bits
 

 fwrite(arduinoCom,stimEEG); %signifies pin for sending pulse to aquistion system  
 fwrite(arduinoCom,floor(stimOnset/2^8)); %when does pulse start left most most 8 bits
 fwrite(arduinoCom,mod(stimOnset,2^8)); %when does pulse start right most 8 bits
 fwrite(arduinoCom,floor(endTime/2^8)); %when does the pulse end left most 8 bits
 fwrite(arduinoCom,mod(endTime,2^8)); %when does the pulse end right most 8 bits
