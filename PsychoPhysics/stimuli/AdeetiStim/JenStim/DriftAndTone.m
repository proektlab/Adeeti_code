%this creates a big drifting gradient and plays a constant tone along with it
%code borrowed from DriftDemo and BasicSoundOutputDemo
%inputs:    driftSpatialFreq        spatial frequency of drift gradient in
%                                   pixels
%           driftTempFreq           temporal frequency of temporal gradient
%           reverseGrat             reverses direction of grating. 0 for
%                                   left, 1 for right
%           toneFs                  sampling rate of device. usually 44100
%           toneFreq                frequency of pure tone
%           toneFmFreq              frequency of frequency modulation on
%                                   the tone
%           duration                duration of drift and tone

function DriftAndTone(driftSpatialFreq, driftTempFreq, reverseGrat, toneFs, toneFreq, toneAMFreq, duration)
    %variables for drifting    
    visiblesize=256; 
    movieDurationSecs = duration;
    
                
    %generate and modify sound signal
    
    %places everything on 2 channels
    if size(toneAMFreq == [1,1])
        toneAMFreq = [toneAMFreq, toneAMFreq];
    end
    if size(toneFreq) == [1,1]
        toneFreq = [toneFreq, toneFreq];
    end
    
    %creates signal
    signal = makeTone(toneFs, toneAMFreq, duration);
    
    %amplitude modulates both channels
    for i = 1:size(signal, 1)
        if(toneAMFreq(i) > 0)
            signal(i, :) = ammod(signal(i,:), toneFreq(i), toneFs, 10);
        end
    end
    
    %smooths out beginning and end of both channels
    signal = removeClick(signal, 300, toneFs);
    
    nrchannels = size(signal, 1);

    % This script calls Psychtoolbox commands available only in OpenGL-based 
    % versions of the Psychtoolbox. The Psychtoolbox command AssertPsychOpenGL will issue
    % an error message if someone tries to execute this script on a computer without
    % an OpenGL Psychtoolbox.
    AssertOpenGL;

    % Get the list of screens and choose the one with the highest screen number.
    % Screen 0 is, by definition, the display with the menu bar. Often when 
    % two monitors are connected the one without the menu bar is used as 
    % the stimulus display.  Chosing the display with the highest dislay number is 
    % a best guess about where you want the stimulus displayed.  
    screens=Screen('Screens');
    screenNumber=max(screens);

    % Find the color values which correspond to white and black: Usually
    % black is always 0 and white 255, but this rule is not true if one of
    % the high precision framebuffer modes is enabled via the
    % PsychImaging() commmand, so we query the true values via the
    % functions WhiteIndex and BlackIndex:
    white=WhiteIndex(screenNumber);
    black=BlackIndex(screenNumber);

    % Round gray to integral number, to avoid roundoff artifacts with some
    % graphics cards:
    gray=round((white+black)/2);

    % This makes sure that on floating point framebuffers we still get a
    % well defined gray. It isn't strictly neccessary in this demo:
    if gray == white
        gray=white / 2;
    end

    % Contrast 'inc'rement range for given white and gray values:
    inc=white-gray;

    % Open a double buffered fullscreen window and draw a gray background 
    % to front and back buffers as background clear color:
    [w, wSize] = PsychImaging('OpenWindow',screenNumber, gray);

    % Calculate parameters of the grating:
    f=1/driftTempFreq;
    fr=f*2*pi;    % frequency in radians.

    % Create one single static 1-D grating image.
    % We only need a texture with a single row of pixels(i.e. 1 pixel in height) to
    % define the whole grating! If the 'srcRect' in the 'Drawtexture' call
    % below is "higher" than that (i.e. visibleSize >> 1), the GPU will
    % automatically replicate pixel rows. This 1 pixel height saves memory
    % and memory bandwith, ie. it is potentially faster on some GPUs.
    x=meshgrid(0:visiblesize-1, 1);
    grating=gray + inc*cos(fr*x);

    % Store grating in texture: Set the 'enforcepot' flag to 1 to signal
    % Psychtoolbox that we want a special scrollable power-of-two texture:
    gratingtex=Screen('MakeTexture', w, grating, [], 1);

    % Query duration of monitor refresh interval:
    ifi=Screen('GetFlipInterval', w);    
    waitframes = 1;
    waitduration = waitframes * ifi;

    % Translate requested speed of the grating (in cycles per second)
    % into a shift value in "pixels per frame", assuming given
    % waitduration: This is the amount of pixels to shift our srcRect at
    % each redraw:
    shiftperframe= driftSpatialFreq * driftTempFreq * waitduration;

    % Perform initial Flip to sync us to the VBL and for getting an initial
    % VBL-Timestamp for our "WaitBlanking" emulation:
    vbl=Screen('Flip', w);

    % We run at most 'movieDurationSecs' seconds if user doesn't abort via keypress.
    vblendtime = vbl + movieDurationSecs;
    xoffset=0;
    
    %open audio port
     try
        % Try with the 'freq'uency we wanted:
        pahandle = PsychPortAudio('Open', [], [], 0, toneFs, nrchannels);
    catch
        % Failed. Retry with default frequency as suggested by device:
        disp('\nCould not open device at wanted playback frequency of %i Hz. Will retry with device default frequency.\n');
        disp('Sound may sound a bit out of tune, ...\n\n');

        psychlasterror('reset');
        pahandle = PsychPortAudio('Open', [], [], 0, [], nrchannels);
     end

    % Fill the audio playback buffer with the audio data 'wavedata':
    PsychPortAudio('FillBuffer', pahandle, signal);

    % Start audio playback for 'repetitions' repetitions of the sound data,
    % start it immediately (0) and wait for the playback to start, return onset
    % timestamp.
    PsychPortAudio('Start', pahandle, 0, 0, 1);

    % Wait for release of all keys on keyboard:
    KbReleaseWait;

    % Animationloop:
    while(vbl < vblendtime)
       % Shift the grating by "shiftperframe" pixels per frame:
       xoffset = xoffset + (reverseGrat*-1) * shiftperframe;

       % Define shifted srcRect that cuts out the properly shifted rectangular
       % area from the texture:
       srcRect=[xoffset 0 xoffset + visiblesize visiblesize];

       % Draw grating texture: Only show subarea 'srcRect', center texture in
       % the onscreen window automatically:
       Screen('DrawTexture', w, gratingtex, srcRect, [0 0 1280 1024]);

       % Flip 'waitframes' monitor refresh intervals after last redraw.
       vbl = Screen('Flip', w, vbl + (waitframes - 0.5) * ifi);

       % Abort demo if any key is pressed:
       if KbCheck
          break;
       end
    end

    % Stop playback:
    PsychPortAudio('Stop', pahandle);

    % Close the audio device:
    PsychPortAudio('Close', pahandle);

    % Close texture
    sca;

end