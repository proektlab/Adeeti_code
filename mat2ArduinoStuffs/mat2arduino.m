 function mat2arduino(arduinoCom, stimPin, stimOnset, stimOn)
% mat2arduino(arduinoCom, stimPin, stimEEG, stimOnset, stimOn)
% if just want to send one signal
% stimPin are in terms of int digital pins on arduino uno board
% stimOnset and StimOn are in msec
% Assume jitter of 10 usec

% 10/17/19 CB and AA
%%

endTime = stimOnset+stimOn;

fwrite(arduinoCom,stimPin); %signifies pin for stimulation 
 fwrite(arduinoCom,floor(stimOnset/2^8)); %when does pulse start left most 8 bits
 fwrite(arduinoCom,mod(stimOnset,2^8)); %when does pulse start right most 8 bits
 fwrite(arduinoCom,floor(endTime/2^8)); %when does the pulse end left most 8 bits
 fwrite(arduinoCom,mod(endTime,2^8)); %when does the pulse end right most 8 bits
 
 