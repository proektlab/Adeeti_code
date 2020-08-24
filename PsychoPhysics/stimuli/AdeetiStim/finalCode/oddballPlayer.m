function oddballPlayer(sequence, frequencies, [duration = 2], [delay=1], outputFileName)
%this plays a sequence representing an oddball stimulus
%inputs     sequence    a vector representing a sequence of sounds. For
%                       example, [1 1 2 3] represents two standards 
%                       followed by a low oddball and then a high oddball
%           frequencies vector representing frequency in Hz of each oddball
%                       type
%           duration    duration of each oddball tone in seconds
%           delay       delay in seconds between each tone. Type in a 2x1
%                       vector such as [1 2] to get a delay time randomly
%                       generated between those two times
function oddballPlayer(sequence, frequencies, duration, delay, outputFileName)
%% default params
    if nargin < 3
        duration = [];
    end
    if nargin < 4
        delay = [];
    end
    
    if isempty(duration)
        duration = .5;
    end
    if(isempty(delay))
        delay = .5;
    end
%% plays the tones
    
    %preallocating array of oddball times
    oddballTimes = strings(1, numel(sequence));

    %set param
    params.toneFs = 44100;
    params.delay = 0;
    params.rampTime = 5;
    
    delayTime = delay - params.delay;
     
    %open audio port
    pahandle = PsychPortAudio('Open', [], [], 3, params.toneFs, 2);
    
    %get startung time
    startTime = datestr(now);
    
     for i = 1:numel(sequence)
         %play relevant sound
        SmallSoundOnly(params, pahandle, frequencies(sequence(i)), 0, duration, sequence(i));
        
        %get time of sound
        oddballTimes(i) = string(datestr(now));
        
        %delay for appropriate time
        WaitSecs(delayTime);
           
        % Abort if any key is pressed:
        if KbCheck
            break;
        end
     end
    
     % Close the audio device:
   PsychPortAudio('Close', pahandle);
      
    Priority(0);
    

    
    %print params to a text file
    
    fileID = fopen([outputFileName, '.txt'],'a');
    fprintf(fileID, '\n\n\nOddball Stimulus\nTime and Date\n');
    fprintf(fileID, '%s', startTime);
    fprintf(fileID, '\n\n');
 
    %creates a table of tones
    table = vertcat(1:numel(sequence), oddballTimes, frequencies(sequence(:)));
    fprintf(fileID, '%-10s %-25s %-10s', "trial", "start time", "tone frequency");
    fprintf(fileID, '\n');
    fprintf(fileID, '%-10s %-25s%-10s\n', table);
    
    fprintf(fileID, strcat("\n\nDuration of tones: ", num2str(duration), " seconds"));
    
    fprintf(fileID, strcat("\n\nDelay between tones: ", num2str(delay), " seconds"));
   
    fclose(fileID);
    
    % saving parameters in .mat
    oddBallParamsTable{1} = 1:numel(sequence);
    oddBallParamsTable{2} = oddballTimes;
    oddBallParamsTable{3} = sequence;
    oddBallParamsTable{4} = frequencies(sequence(:));
    
    save([outputFileName, '.mat'], 'oddBallParamsTable')
end