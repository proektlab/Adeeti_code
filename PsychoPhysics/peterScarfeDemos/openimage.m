% Clear the workspace and the screen
sca;
close all;
clearvars;

% Here we call some default settings for setting up Psychtoolbox
PsychDefaultSetup(2);

try
    commandwindow;
    myimgfile='dvdlogo';
    nr=max(Screen('Screens'));
    [w, screenRect]=Screen('OpenWindow',nr, 0,[],32,2); % open screen
    ima=imread(myimgfile, 'jpg');
    
    Screen('PutImage', w, ima); % put image on screen
    Screen('Flip',w); % now visible on screen
    while KbCheck; end % clear keyboard queue
    while ~KbCheck; end % wait for a key press
    Screen('CloseAll'); % close screen
catch
    %this "catch" section executes in case of an error in the "try" section
    %above.  Importantly, it closes the onscreen window if its open.
    Screen('CloseAll');
    rethrow(lasterror);
end %try..catch..

