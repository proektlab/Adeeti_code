%function runGratings(angle, cyclespersecond, freq, gratingsize, internalRotation)

gratingsize=[2500 2500];
internalRotation=0;
%
% Here we call some default settings for setting up Psychtoolbox
PsychDefaultSetup(1);
Screen('Preference', 'VisualDebuglevel', 1);


% Make sure this is running on OpenGL Psychtoolbox:
AssertOpenGL;


res = [gratingsize gratingsize];


% Amplitude of the grating in units of absolute display intensity range: A
% setting of 0.5 means that the grating will extend over a range from -0.5
% up to 0.5, i.e., it will cover a total range of 1.0 == 100% of the total
% displayable range. As we select a background color and offset for the
% grating of 0.5 (== 50% nominal intensity == a nice neutral gray), this
% will extend the sinewaves values from 0 = total black in the minima of
% the sine wave up to 1 = maximum white in the maxima. Amplitudes of more
% than 0.5 don't make sense, as parts of the grating would lie outside the
% displayable range for your computers displays:
amplitude = 0.5;

% Choose screen with maximum id - the secondary display on a dual-display
% setup for display:
screenid = max(Screen('Screens'));

% Open a fullscreen onscreen window on that display, choose a background
% color of 128 = gray, i.e. 50% max intensity:
win = Screen('OpenWindow', screenid, 128);


% Make sure the GLSL shading language is supported:
AssertGLSL;

% Retrieve video redraw interval for later control of our animation timing:
ifi = Screen('GetFlipInterval', win);

% Phase is the phase shift in degrees (0-360 etc.)applied to the sine grating:
phase = 0;
rotateMode=[];
% Compute increment of phase shift per redraw:
cyclespersecond=1;
phaseincrement = (cyclespersecond * 360) * ifi;

% Build a procedural sine grating texture for a grating with a support of
% res(1) x res(2) pixels and a RGB color offset of 0.5 -- a 50% gray.
gratingtex = CreateProceduralSineGrating(win, res(1), res(2), [0.5 0.5 0.5 0.0]);

%Create window for selecting grating features
%write some text

%put up the angle selector circle
win2= Screen('OpenWindow', 0, 128);
% Select specific text font, style and size:
Screen('TextFont',win2, 'Arial');
Screen('TextSize',win2, 40);
Screen('TextStyle', win2, 1+2);
DrawFormattedText(win2, 'Press and hold c for gray screen.', 50, 50, 0, 40);
DrawFormattedText(win2, 'Press and hold f to freeze.', 50, 150, 0, 40);

DrawFormattedText(win2, 'Use up and down arrows for temporal frequency. Or type 1 for 1 Hz, 2 for 2 Hz, ...', 50, 250, 0, 30);
DrawFormattedText(win2, 'Press ESC to exit.', 50, 450, 0, 30);


%Draw the outer circle and fill it in
Screen('FillOval',win2,[51 255 102],[500 150, 1400 1050]);
Screen('FrameOval',win2,[0 0 0],[500 150, 1400 1050],4,4);
%Draw lines at 45 degree angles
Screen('DrawLine',win2,0,950,150,950,1050,4); %vertical line
Screen('DrawLine',win2,0,500,600,1400,600,4); %horizontal line
Screen('DrawLine',win2,0,1268,918,632,282,4); %diagonal line
Screen('DrawLine',win2,0,632,918,1268,282,4); %diagonal line
%Draw lines at 0.01, 0.02, 0.04, 0.06,0.08 cycles per degree
Screen('FrameOval',win2,[0 0 0],[897 544, 1006 656],4,4); %0.01
Screen('FrameOval',win2,[0 0 0],[837 487.5, 1062 712.5],4,4);
Screen('FrameOval',win2,[0 0 0],[725 375, 1175 825],4,4);
Screen('FrameOval',win2,[0 0 0],[612.5 262.5, 1287.5 937.5],4,4); %0.08
Screen('FrameOval',win2,[0 0 0],[500 150, 1400 1050],4,4); %0.08
%write the spatial frequencies on the circle
Screen('TextSize',win2, 10);
DrawFormattedText(win2, '0.08 cyc/deg', 920, 145, 0, 40);
DrawFormattedText(win2, '0.06 cyc/deg', 920, 257.5, 0, 40);
DrawFormattedText(win2, '0.04 cyc/deg', 920, 370, 0, 40);
DrawFormattedText(win2, '0.02 cyc/deg', 920, 482.5, 0, 40);
DrawFormattedText(win2, '0.01 cyc/deg', 920, 539, 0, 40);
%write the angles on the circle
DrawFormattedText(win2, '0 deg', 1402, 600, 0, 40);
DrawFormattedText(win2, '90 deg', 930, 1060, 0, 40);
DrawFormattedText(win2, '180 deg', 460,  600, 0, 40);

%flip to screen
%why do i need this here?
Screen('Flip',win2);


%define center of circle
circleCenter=[950 600];

%define how much up and down arrows change cyclespersecond
percentPerPress=.020;
cyclespersecond=2; %start at 2 cycles per second

%prevent keyboard entry into command window
ListenChar(-1);

%start with mouse at center (o spatial frequency)
SetMouse(circleCenter(1),circleCenter(2),win2);

% The avaliable keys to press
escapeKey = KbName('ESCAPE');
upKey = KbName('UpArrow');
downKey = KbName('DownArrow');
leftKey = KbName('LeftArrow');
rightKey = KbName('RightArrow');

% Wait for release of all keys on keyboard, then sync us to retrace:
KbReleaseWait;
vbl = Screen('Flip', win);

% This is the cue which determines whether we exit the demo
exitGrating = false;
% Animation loop: Repeats until keypress...
while exitGrating==false
    
    % Check the keyboard to see if a button has been pressed
    [keyIsDown,secs, keyCode] = KbCheck;
    
    % Exit the demo if Escape is pressed
    if keyCode(escapeKey)
        exitGrating = true;
    end
    
    % While 'c' button is pressed, clear screen and put on gray screen
    if keyCode(6) %c for clear
        Screen('FillRect', win, [128]);
        vbl = Screen('Flip', win, vbl + 0.5 * ifi);
        % Otherwise, put on the grating
    elseif keyCode(9)%f for freeze
        
        Screen('DrawTexture', win, gratingtex, [], [], angle, [], [], [], [], rotateMode, [phase, freq, amplitude, 0]);
        vbl = Screen('Flip', win, vbl + 0.5 * ifi);
    else
        %Use the mouse information to update angle and spatial frequency of
        %grating
        [x,y] = GetMouse(win2);
        
        %convert position to angle
        [theta,radius]=cart2pol(x-circleCenter(1),y-circleCenter(2));
        angle=wrapTo360(rad2deg(theta)); %rotate to match larry's orientations
        %convert radius to spatial frequency
        sf=radius/(0.5*11250); %converts from pixels to cycles per degree (900 pixel radius is 0.08 cycles per degree)
        freq=AngletoPixelSF(sf);
        
        %increase and decrease temporal freuency with up and down keyboard
        %buttons
        if keyCode(upKey) %increase tf
            cyclespersecond = cyclespersecond*(1+percentPerPress);
        elseif keyCode(downKey) %decrease tf
            cyclespersecond = cyclespersecond*(1-percentPerPress);
        end
        if keyCode(30)
            cyclespersecond=1;
        end
        if keyCode(31);
            cyclespersecond=2;
        end
        if keyCode(32);
            cyclespersecond=3;
        end
        
        phaseincrement = (cyclespersecond * 360) * (ifi);
        
        % Increment phase by 1 degree:
        phase = phase + phaseincrement;
        
        % Draw the grating, centered on the screen, with given rotation 'angle',
        % sine grating 'phase' shift and amplitude, rotating via set
        % 'rotateMode'. Note that we pad the last argument with a 4th
        % component, which is 0. This is required, as this argument must be a
        % vector with a number of components that is an integral multiple of 4,
        % i.e. in our case it must have 4 components:
        Screen('DrawTexture', win, gratingtex, [], [], angle, [], [], [], [], rotateMode, [phase, freq, amplitude, 0]);
        
        % Show it at next retrace:
        vbl = Screen('Flip', win, vbl + 0.5 * ifi);
    end
end


% We're done. Close the window. This will also release all other ressources:
Screen('CloseAll');
ListenChar();
Priority(0);

% Store the final parameters
params.tf=cyclespersecond;
params.ort=angle;
params.sf=sf;
% Bye bye!
%return;
