%function DriftAndTone2([angle = 30], [cyclespersecond = 1], [f = 0.01], [drawmask = 1], [maskStd = 90], [gratingsize = 400], [toneFs = 44100], [toneFreq = 4000], [sigFreq = 0.5], [duration = 10])
%makes a drift stimulus and plays an amplitude modulated tone along with it
%input parameters:
%   angle = Angle of the grating with respect to the vertical direction.
%   cyclespersecond = Speed of grating in cycles per second.
%   f = Frequency of grating in cycles per pixel.
%   drawmask = If set to 1, a gaussian aperture is drawn over the grating.
%   gratingsize = Visible size of grating in screen pixels.
%   toneFs = Sampling rate of device. Usually 44100.
%   toneFreq = Frequency of pure tone that will be modulated.
%   toneAMFreq = Frequency of amplitude modulation
%   duration = duration of movie and sound in seconds.

function DriftAndTone2(angle, cyclespersecond, cpd, drawmask, maskStd, gratingsize, toneFs, toneFreq, sigFreq, duration)
%% defaults
    if nargin < 1
        angle = [];
    end
    if nargin < 2
        cyclespersecond = [];
    end
    if nargin < 3
        f = [];
    end
    if nargin < 4
        drawmask = [];
    end
    if nargin < 5
        maskStd = [];
    end
    if nargin < 6
        gratingsize = [];
    end
    if nargin < 7
        toneFs = [];
    end
    if nargin < 8
        toneFreq = [];
    end
    if nargin < 9
        sigFreq = [];
    end
    if nargin < 10
        duration = [];
    end
%   ^o^    
    if isempty(angle)
        angle = 30;
    end
    if isempty(cyclespersecond)
        cyclespersecond = 1;
    end
    if isempty(f)
        f = 0.01;
    end
    if isempty(drawmask)
        drawmask = 1;
    end
    if isempty (maskStd)
        maskStd = 90;
    end
    if isempty(gratingsize)
        gratingsize = 400;
    end
    if isempty(toneFs)
        toneFs = 44100;
    end
    if isempty(toneFreq)
        toneFreq = 4000;
    end
    if isempty(sigFreq)
        sigFreq = .5;
    end
    if isempty(duration)
        duration = 10;
    end
%% actual code
    movieDurationSecs=duration;   % Abort demo after 20 seconds.

    % Define Half-Size of the grating image.
    texsize=gratingsize / 2;

    % Screen('Preference', 'SkipSyncTests', 1);

    %generate and modify sound signal

    %places everything on 2 channels
    if size(sigFreq == [1,1])
        sigFreq = [sigFreq, sigFreq];
    end
    if size(toneFreq) == [1,1]
        toneFreq = [toneFreq, toneFreq];
    end

    %creates signal
    signal = makeTone(toneFs, sigFreq, duration);

    %amplitude modulates both channels
    for i = 1:size(signal, 1)
        if(sigFreq(i) > 0)
            signal(i, :) = ammod(signal(i,:), toneFreq(i), toneFs, 10);
        end
    end

    %smooths out beginning and end of both channels
    signal = removeClick(signal, 300, toneFs);

    nrchannels = size(signal, 1);

    try
        % This script calls Psychtoolbox commands available only in OpenGL-based 
        % versions of the Psychtoolbox. (So far, the OS X Psychtoolbox is the
        % only OpenGL-base Psychtoolbox.)  The Psychtoolbox command AssertPsychOpenGL will issue
        % an error message if someone tries to execute this script on a computer without
        % an OpenGL Psychtoolbox
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

        % Open a double buffered fullscreen window and set default background
        % color to gray:
        [w screenRect]=PsychImaging('OpenWindow',screenNumber, gray);

        if drawmask
            % Enable alpha blending for proper combination of the gaussian aperture
            % with the drifting sine grating:
            Screen('BlendFunction', w, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
        end

        % Calculate parameters of the grating:

        % First we compute pixels per cycle, rounded up to full pixels, as we
        % need this to create a grating of proper size below:
        f = params.pixelDeg* cpd;
        p=ceil(1/f);

        % Also need frequency in radians:
        fr=f*2*pi;

        % This is the visible size of the grating. It is twice the half-width
        % of the texture plus one pixel to make sure it has an odd number of
        % pixels and is therefore symmetric around the center of the texture:
        visiblesize=2*texsize+1;

        % Create one single static grating image:
        %
        % We only need a texture with a single row of pixels(i.e. 1 pixel in height) to
        % define the whole grating! If the 'srcRect' in the 'Drawtexture' call
        % below is "higher" than that (i.e. visibleSize >> 1), the GPU will
        % automatically replicate pixel rows. This 1 pixel height saves memory
        % and memory bandwith, ie. it is potentially faster on some GPUs.
        %
        % However it does need 2 * texsize + p columns, i.e. the visible size
        % of the grating extended by the length of 1 period (repetition) of the
        % sine-wave in pixels 'p':
        x = meshgrid(-texsize:texsize + p, 1);

        % Compute actual cosine grating:
        grating=gray + inc*cos(fr*x);

        % Store 1-D single row grating in texture:
        gratingtex=Screen('MakeTexture', w, grating);

        % Create a single gaussian transparency mask and store it to a texture:
        % The mask must have the same size as the visible size of the grating
        % to fully cover it. Here we must define it in 2 dimensions and can't
        % get easily away with one single row of pixels.
        %
        % We create a  two-layer texture: One unused luminance channel which we
        % just fill with the same color as the background color of the screen
        % 'gray'. The transparency (aka alpha) channel is filled with a
        % gaussian (exp()) aperture mask:
        mask=ones(2*texsize+1, 2*texsize+1, 2) * gray;
        [x,y]=meshgrid(-1*texsize:1*texsize,-1*texsize:1*texsize);
        mask(:, :, 2)= white * (1 - exp(-((x/maskStd).^2)-((y/maskStd).^2)));
        masktex=Screen('MakeTexture', w, mask);

        % Query maximum useable priorityLevel on this system:
        priorityLevel=MaxPriority(w); 

        % We don't use Priority() in order to not accidentally overload older
        % machines that can't handle a redraw every 40 ms. If your machine is
        % fast enough, uncomment this to get more accurate timing.
        Priority(priorityLevel);

        % Definition of the drawn rectangle on the screen:
        % Compute it to  be the visible size of the grating, centered on the
        % screen:
        dstRect=[0 0 visiblesize visiblesize];
        dstRect=CenterRect(dstRect, screenRect);

        % Query duration of one monitor refresh interval:
        ifi=Screen('GetFlipInterval', w);

        % Translate that into the amount of seconds to wait between screen
        % redraws/updates:

        % waitframes = 1 means: Redraw every monitor refresh. If your GPU is
        % not fast enough to do this, you can increment this to only redraw
        % every n'th refresh. All animation paramters will adapt to still
        % provide the proper grating. However, if you have a fine grating
        % drifting at a high speed, the refresh rate must exceed that
        % "effective" grating speed to avoid aliasing artifacts in time, i.e.,
        % to make sure to satisfy the constraints of the sampling theorem
        % (See Wikipedia: "Nyquist?Shannon sampling theorem" for a starter, if
        % you don't know what this means):
        waitframes = 1;

        % Translate frames into seconds for screen update interval:
        waitduration = waitframes * ifi;

        % Recompute p, this time without the ceil() operation from above.
        % Otherwise we will get wrong drift speed due to rounding errors!
        p=1/f;  % pixels/cycle    

        % Translate requested speed of the grating (in cycles per second) into
        % a shift value in "pixels per frame", for given waitduration: This is
        % the amount of pixels to shift our srcRect "aperture" in horizontal
        % directionat each redraw:
        shiftperframe= cyclespersecond * p * waitduration;

        % Perform initial Flip to sync us to the VBL and for getting an initial
        % VBL-Timestamp as timing baseline for our redraw loop:
        vbl=Screen('Flip', w);

        % We run at most 'movieDurationSecs' seconds if user doesn't abort via keypress.
        vblendtime = vbl + movieDurationSecs;
        i=0;

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
        while vbl < vblendtime
            % Shift the grating by "shiftperframe" pixels per frame:
            % the mod'ulo operation makes sure that our "aperture" will snap
            % back to the beginning of the grating, once the border is reached.
            % Fractional values of 'xoffset' are fine here. The GPU will
            % perform proper interpolation of color values in the grating
            % texture image to draw a grating that corresponds as closely as
            % technical possible to that fractional 'xoffset'. GPU's use
            % bilinear interpolation whose accuracy depends on the GPU at hand.
            % Consumer ATI hardware usually resolves 1/64 of a pixel, whereas
            % consumer NVidia hardware usually resolves 1/256 of a pixel. You
            % can run the script "DriftTexturePrecisionTest" to test your
            % hardware...
            xoffset = mod(i*shiftperframe,p);
            i=i+1;

            % Define shifted srcRect that cuts out the properly shifted rectangular
            % area from the texture: We cut out the range 0 to visiblesize in
            % the vertical direction although the texture is only 1 pixel in
            % height! This works because the hardware will automatically
            % replicate pixels in one dimension if we exceed the real borders
            % of the stored texture. This allows us to save storage space here,
            % as our 2-D grating is essentially only defined in 1-D:
            srcRect=[xoffset 0 xoffset + visiblesize visiblesize];

            % Draw grating texture, rotated by "angle":
            Screen('DrawTexture', w, gratingtex, srcRect, dstRect, angle);

            if drawmask==1
                % Draw gaussian mask over grating:
                Screen('DrawTexture', w, masktex, [0 0 visiblesize visiblesize], dstRect, angle);
            end

            % Flip 'waitframes' monitor refresh intervals after last redraw.
            % Providing this 'when' timestamp allows for optimal timing
            % precision in stimulus onset, a stable animation framerate and at
            % the same time allows the built-in "skipped frames" detector to
            % work optimally and report skipped frames due to hardware
            % overload:
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

        % Restore normal priority scheduling in case something else was set
        % before:
        Priority(0);

        %The same commands wich close onscreen and offscreen windows also close
        %textures.
        sca;

    catch
        %this "catch" section executes in case of an error in the "try" section
        %above.  Importantly, it closes the onscreen window if its open.
        sca;
        Priority(0);
        psychrethrow(psychlasterror);
    end %try..catch..

    % We're done!
return;
