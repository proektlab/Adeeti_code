
try
    if exist('params')
        kind=Screen(params.window,'WindowKind');
    else
        kind=0;
    end
if ~kind %if the window was closed accidentally or on purpose
    PsychDefaultSetup(2);
    PsychImaging('PrepareConfiguration');
    PsychImaging('AddTask', 'General', 'FloatingPoint32Bit');
    PsychImaging('AddTask', 'General', 'EnableDataPixxM16Output');
    PsychImaging('AddTask', 'FinalFormatting', 'DisplayColorCorrection', 'SimpleGamma');
    oldRes=SetResolution(1,1920,1200,120);
    params.gamma=2.08;
    params.gray=0.5;
    params.black=
    params.white=1;
    [params.window,params.Rect]= PsychImaging('OpenWindow',max(Screen('Screens')));
  %  PsychColorCorrection('SetEncodingGamma', params.window,1/params.gamma);
    Screen('Preference', 'VisualDebugLevel', 0);
    display('Opening a new on screen window');
else
    %do nothing
       % PsychColorCorrection('SetEncodingGamma', params.window,1/params.gamma),

end

% Retrieve video redraw interval for later control of our animation timing:
ifi = Screen('GetFlipInterval', params.window);


gratingsize=[2500 2500];
internalRotation=0;
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


% Phase is the phase shift in degrees (0-360 etc.)applied to the sine grating:
phase = 0;
rotateMode=[];
% Compute increment of phase shift per redraw:
cyclespersecond=1;
phaseincrement = (cyclespersecond * 360) * ifi;

% Build a procedural sine grating texture for a grating with a support of
% res(1) x res(2) pixels and a RGB color offset of ' -- a 50% gray.
gratingtex = CreateProceduralSineGrating(params.window, res(1), res(2), [params.gray params.gray params.gray params.black]);

%Create window for selecting grating features
[win2] = PsychImaging('OpenWindow', 0,0.5);%put up the angle selector circle
Screen('Preference', 'VisualDebugLevel', 3);
%write some text



%draw the orientation/sf selection circle

%define center of circle
xc=950; 
yc=600;
circleCenter=[xc yc];

%define diameter of circle
diam=450;
rad=diam/2;

% Select specific text font, style and size:
Screen('TextFont',win2, 'Arial');
Screen('TextSize',win2, 40);
Screen('TextStyle', win2, 1+2);
DrawFormattedText(win2, 'Press and hold c for gray screen.', 50, 50, 0, 40);
DrawFormattedText(win2, 'Press and hold f to freeze.', 50, 150, 0, 40);

DrawFormattedText(win2, 'Use up and down arrows for temporal frequency. Or type 1 for 1 Hz, 2 for 2 Hz, ...', 50, 250, 0, 30);
DrawFormattedText(win2, 'Press ESC to exit.', 50, 450, 0, 30);


%Draw the outer circle and fill it in
Screen('FillOval',win2,[51 255 102]./256,[xc-rad yc-rad, xc+rad yc+rad]);
Screen('FrameOval',win2,[0 0 0],[xc-rad yc-rad, xc+rad yc+rad],4,4);
%Draw lines at 45 degree angles
Screen('DrawLine',win2,0,xc,yc-rad,xc,yc+rad,4); %vertical line
Screen('DrawLine',win2,0,xc-rad,yc,xc+rad,yc,4); %horizontal line
Screen('DrawLine',win2,0,xc+(rad*sqrt(2)/2),yc+(rad*sqrt(2)/2),xc-(rad*sqrt(2)/2),yc-(rad*sqrt(2)/2),4); %diagonal line
Screen('DrawLine',win2,0,xc-(rad*sqrt(2)/2),yc+(rad*sqrt(2)/2),xc+(rad*sqrt(2)/2),yc-(rad*sqrt(2)/2),4); %diagonal line



%Draw lines at 0.01, 0.02, 0.04, 0.06,0.08 cycles per degree
%the outer diameter circle is 0.08 cyc/degree

Screen('FrameOval',win2,[0 0 0],[xc-rad yc-rad, xc+rad yc+rad],4,4); %0.08
Screen('FrameOval',win2,[0 0 0],[xc-(0.06/0.08)*rad yc-(0.06/0.08)*rad, xc+(0.06/0.08)*rad yc+(0.06/0.08)*rad],4,4); %0.06
Screen('FrameOval',win2,[0 0 0],[xc-(0.04/0.08)*rad yc-(0.04/0.08)*rad, xc+(0.04/0.08)*rad yc+(0.04/0.08)*rad],4,4);  %0.04
Screen('FrameOval',win2,[0 0 0],[xc-(0.02/0.08)*rad yc-(0.02/0.08)*rad, xc+(0.02/0.08)*rad yc+(0.02/0.08)*rad],4,4); %0.02
Screen('FrameOval',win2,[0 0 0],[xc-(0.01/0.08)*rad yc-(0.01/0.08)*rad, xc+(0.01/0.08)*rad yc+(0.01/0.08)*rad],4,4);  %0.01




%write the spatial frequencies on the circle
Screen('TextSize',win2, 10);
DrawFormattedText(win2, '0.08 cyc/deg', xc-20, yc-rad-5, 0, 40);
DrawFormattedText(win2, '0.06 cyc/deg', xc-20, yc-(0.06/0.08)*rad-5, 0, 40);
DrawFormattedText(win2, '0.04 cyc/deg', xc-20, yc-(0.04/0.08)*rad-5, 0, 40);
DrawFormattedText(win2, '0.02 cyc/deg', xc-20, yc-(0.02/0.08)*rad-5, 0, 40);
DrawFormattedText(win2, '0.01 cyc/deg', xc-20, yc-(0.01/0.08)*rad-5, 0, 40);


%write the angles on the circle
DrawFormattedText(win2, '0 deg', xc+rad+2, yc, 0, 40);
DrawFormattedText(win2, '90 deg', xc-30, yc+rad+10, 0, 40);
DrawFormattedText(win2, '180 deg', xc-rad-40,  yc, 0, 40);

%flip to screen
%why do i need this here?
Screen('Flip',win2);



%define how much up and down arrows change cyclespersecond
percentPerPress=.020;
cyclespersecond=2; %start at 2 cycles per second

%turn off text entry into command window
%ListenChar(-1);

%start with mouse at center (o spatial frequency)
SetMouse(circleCenter(1),circleCenter(2),win2);

% The available keys to press
escapeKey = KbName('ESCAPE');
upKey = KbName('UpArrow');
downKey = KbName('DownArrow');
leftKey = KbName('LeftArrow');
rightKey = KbName('RightArrow');


% Wait for release of all keys on keyboard, then sync us to retrace:
KbReleaseWait;
vbl = Screen('Flip', params.window);

% This is the cue which determines whether we exit the demo
exitGrating = false;
% Animation loop: Repeats until keypress...
while exitGrating==false
    
    % Check the keyboard to see if a button has been pressed
     [keyIsDown,secs,keyCode]=KbCheck; %#ok<ASGLU>
     if (keyIsDown && keyCode(escapeKey))
         % Set the abort-demo flag.
         exitGrating = true;
           break;
     end
            
    
    
    % While 'c' button is pressed, clear screen and put on gray screen
    if keyCode(KbName('c'))%
        Screen('FillRect', params.window, 0.5);
        vbl = Screen('Flip', params.window, vbl + 0.5 * ifi);
        % Otherwise, put on the grating
    else
        
        %while 'f' button is pressed, freeze the grating
        if keyCode(KbName('f'))%f (on unix is 42)ccc
            Screen('DrawTexture', params.window, gratingtex, [], [], angle, [], [], [], [], rotateMode, [phase, freq, amplitude, 0]);
            vbl = Screen('Flip', params.window, vbl + 0.5 * ifi);
        else
            %Use the mouse information to update angle and spatial frequency of
            %grating
            [x,y] = GetMouse(win2);
            
            %convert position to angle
            [theta,radius]=cart2pol(x-circleCenter(1),y-circleCenter(2));
            angle=wrapTo360(rad2deg(theta)); %rotate to match larry's orientations
            %convert radius to spatial frequency

		
            sf=radius/(rad/0.08); %converts from pixels to cycles per degree (900 pixel radius is 0.08 cycles per degree)
            freq=AngletoPixelSF(sf);
            
            %increase and decrease temporal freuency with up and down keyboard
            %buttons
            if keyCode(upKey) %increase tf
                cyclespersecond = cyclespersecond*(1+percentPerPress);
            elseif keyCode(downKey) %decrease tf
                cyclespersecond = cyclespersecond*(1-percentPerPress);
            end
            if keyCode(11)
                cyclespersecond=1;
            end
            if keyCode(12);
                cyclespersecond=2;
            end
            if keyCode(13);
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
            Screen('DrawTexture', params.window, gratingtex, [], [], angle, [], [], [], [], rotateMode, [phase, freq, amplitude, 0]);
            
            % Show it at next retrace:
            vbl = Screen('Flip', params.window, vbl + 0.5 * ifi);
        end
    end
end

% We're done. Close the window. This will also release all other resources:
Screen('CloseAll');

%turn input back in
Priority(0);
ListenChar(0);

% Store the final parameters
params.tf=cyclespersecond;
params.ort=angle;
params.sf=sf;
% Bye bye!
%return;

catch
sca
Priority(0);
ListenChar(1);
rethrow(lasterror)

end
