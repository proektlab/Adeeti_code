function times = whiteScreenFlash(flashDelay, numFlashes, flashDuration, waitBlack, outputFileName, w, params, lj, arduinoCom)
% whiteScreenFlash(flashDelay, numFlashes, flashDuration, waitBlack, w, params, lj, arduinoCom)
% flashes up a full white screen with black screens in between for
% numFlashes number of white screens 
% flashDelay = interval of time between flashes in seconds 
% numFlashes = number of white screens in total 
% flashDuration = time that white screen will stay up in sec
% w = already opened window
% params = mouse parameters - need to have params.arduino
%returns times = timestamps of flashes
 
if nargin < 3
   error('You did not include either the window, params, labjack, or arduino')
end
 
if isempty(waitBlack)
   waitBlack = 60; %60 sec of black screen, 0 for not
end
 
if isempty(flashDuration)
   flashDuration = (1/params.fps);
end
 
if isempty(numFlashes)
   numFlashes = 100;
end
 
if isempty(flashDelay)
   flashDelay = [3 5];
end

if isempty(outputFileName)
    outputFileName = ['Big_Flash', datestr(now)];
end

 
%% warning in case there are no TTL parameters 
if isempty(isfield(params, 'startTTL'))
    warning('You startTTL is not a parameter in params. There will be no TTL output')
end
 
%% 60 seconds of black screen 
%set up for times
times = strings(numFlashes, 1);

%initial black screen
if ~(waitBlack == 0)
Screen('FillRect', w, params.black);
Screen('Flip', w);
disp(['Screen will stay black for ', num2str(waitBlack), ' sec before trials start'])
WaitSecs(waitBlack);
end
%% Query duration of monitor refresh interval:

%header of text file
startTime = datestr(now);
fileID = fopen([outputFileName, '.txt'],'a');
fprintf(fileID, '\n\n\nFull Screen Flash Stimulus\nTime and Date\n');
fprintf(fileID, '%s', startTime);
fprintf(fileID, '\n\n');
fprintf(fileID, ['Locations: 0 - whole screen; 1 - top left; 2 - top right; \n'...
    '3 - bottom left; 4 - bottom right; 5 - center\n\n']); %legend
fprintf(fileID, '%-10s %-25s %-10s %-10s', "trial", "start time", "location", "stimulus type"); %table top
fprintf(fileID, '\n');

 
ifi=Screen('GetFlipInterval', w);
% Perform initial Flip to sync us to the VBL and for getting an initial
% VBL-Timestamp for our "WaitBlanking" emulation:
vbl=Screen('Flip', w);
 
for i = 1:numFlashes
    % flip to white screen from black screen
    Screen('FillRect', w, params.white);
    blackSceen_waitframes = params.fps*(flashDelay(1) + (flashDelay(2) - flashDelay(1))*rand());
    times(i) = string(datestr(now)); 
    vbl = Screen('Flip', w, vbl + (blackSceen_waitframes - 0.5) * ifi);  % Flip 'waitframes' monitor refresh intervals after last redraw.
     
     % for TTL 
    if isfield(params, 'useLabJack') && params.useLabJack==1
        timedTTL(lj,params.startTTL,10)
    end
    if isfield(params, 'useArduino') && params.useArduino ==1
        mat2arduino(arduinoCom, params.startTTL, 0, 10) %writes info to arduino
        fwrite(arduinoCom,255); %% makes arduino start
    end
     
    % Flip to black screen from white screen flash
    Screen('FillRect', w, params.black);
    whiteScreen_waitframes = flashDuration*params.fps;
    
    table = vertcat(i, times(i), '0', 'fs wf');
    fprintf(fileID, '%-10s %-25s %-10s %-10s\n', table); %table line

    [~, ~, code] = KbCheck; %check for abort key (shift)
    
    if(find(code) == 63)|(find(code) == 51) %if abort key is pressed, stop trial
        disp("Trial aborted");
        fprintf(fileID, 'Trial aborted');
        Screen('Flip', w);
        break;
    end
        
    % Flip 'waitframes' monitor refresh intervals after last redraw.
    vbl = Screen('Flip', w, vbl + (whiteScreen_waitframes - 0.5) * ifi);
    disp(['Trial: ', num2str(i)])
end
 
end