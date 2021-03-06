
sequence = [];

for i = 1:10  %runs 5 times for a total of 1600 tones - there is no break in between these - will need to record all in one go
    
    tempSequence = oddballSequencer([280, 20, 20], 2, 2); % creates sequence of oddballs: oddballSequencer([numberOfStand, numberLow, numberHigh], startingBuffer, bufferBtwnOddbals);
    
    sequence = [sequence, tempSequence];
    
    %tones for testing so that you dont annoy everyone that much
end
%%


oddballPlayer(sequence, [5500, 5000, 6000], .050, .5, ['oddBallParamsMouse1_Iso', num2str(i)]); %runs oddballs: oddballPlayer(sequenceOfTones, [standTone, lowTone, highTone], durationTone, delayBtwnTones)

%oddballPlayer(sequence, [400, 350, 450],.050, .375); %lower pitch

%% Instructions 
%this should run out of the box with just running oddballScript in the
%command line 
%if pause or quit program using control+C, then will need to close labjack
%and close audioport 
%run command: lj.close(); 
%run commands: PsychPortAudio('Close'); Priority(0);


%% tones for testing 

%oddballPlayer([1, 2, 3, 1, 2, 3, 1, 2, 3, 1, 2, 3],  [4000 3500 4500], 1, 1, 'testParamsOddBall')

oddballPlayer([1, 2, 3],  [400 350 450], 1, 1, 'testParamsOddBall')



%% for just playing one tone repeatedly 
% 
% sequence = oddballSequencer([100, 0, 0], 2, 2); % creates sequence of oddballs: oddballSequencer([numberOfStand, numberLow, numberHigh], startingBuffer, bufferBtwnOddbals);
% 
% oddballPlayer(sequence, [5500, 5000, 6000], .050, .5, ['oBParamsMouse1_aw_100tones', num2str(i)]);
