
try
    
    PsychDefaultSetup(2);
    PsychImaging('PrepareConfiguration');
    PsychImaging('AddTask', 'General', 'FloatingPoint32Bit');
    PsychImaging('AddTask', 'General', 'EnableDataPixxM16Output');
    PsychImaging('AddTask', 'FinalFormatting', 'DisplayColorCorrection', 'SimpleGamma');
    params.gray=0.5;
    params.black=0;
    params.white=1;
    
%     datapixxmode = 2;
%     maxpixval = 2^16-1;
%     
%     try % This will only work if VPixx is connected
         PsychDataPixx('Open'); % Set up for TTL
       PsychDataPixx('SetVideoMode',2); % See documentation. 0 will probably be sufficient for point-light stimuli
        PsychDataPixx('DisableVideoScanningBacklight'); % Scanning backlight for LED pixel on/off artifact minimization (disabled for now)
%         Datapixx('StopAllSchedules');
%         Datapixx('RegWrRd');
%         PsychDataPixx('GetPreciseTime'); %sycnh clocks
%         
%         params.vpixx_monitor = true; % Indicates vpixx_monitor connected and working
%     catch
%         params.vpixx_monitor = false;
%     end
%     
    
    
    [params.window,params.Rect]= PsychImaging('OpenWindow',max(Screen('Screens')),params.gray);
    display('Opening a new on screen window');
    
    
    % Make sure this GPU supports shading at all:
    AssertGLSL;
    
    % Enable alpha blending for typical drawing of masked textures:
    Screen('BlendFunction', params.window, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    
    % Create a special texture drawing shader for masked texture drawing:
    glsl = MakeTextureDrawShader(params.window, 'SeparateAlphaChannel');
    
    % Query duration of monitor refresh interval:
    ifi=Screen('GetFlipInterval', params.window);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%setup grating parameters
    pixelsperdeg=0.0483; %0.0483 is the number of degrees per pixel.
    texsize=floor(20/pixelsperdeg); 
    sf=(0.04);%this is cycles/degree
    f=sf*pixelsperdeg;%is cycles/pixel
    period=ceil(1/f); % pixels/cycle, rounded up.
    fr=(1/period)*2*pi; %cycles/pixel * 360 degrees/cycle = fr is degrees/pixel
    
    cyclespersecond=(2);
    angle=180;
    
    visiblesize=2*texsize+1;
    
    inc=params.white-params.gray;
    
    %set the constrast of the two gratings
    contrast_test=0.52;
    contrast_mask=0.32                          
    
    % Create one single static grating image:
    x = meshgrid(-texsize:texsize + period, -texsize:texsize);
    grating = params.gray + inc*cos(fr*x);
    
    
    % Create circular aperture for the alpha-channel:
    [x,y]=meshgrid(-texsize:texsize, -texsize:texsize);
    circle = params.white * (x.^2 + y.^2 <= (texsize)^2);
    
    % Set 2nd channel (the alpha channel) of 'grating' to the aperture
    % defined in 'circle':
    grating(:,:,2) = 0;
    grating(1:2*texsize+1, 1:2*texsize+1, 2) = circle;
    
    % Store alpha-masked grating in texture and attach the special 'glsl'
    % texture shader to it:
    gratingtex1 = Screen('MakeTexture', params.window, grating , [], [], [1], [],glsl);
    
    % Build a second drifting grating texture, just like the first (we'll
    % change the angle in the DrawTexture command later).
    % Store alpha-masked grating in texture and attach the special 'glsl'
    % texture shader to it:
    gratingtex2 = Screen('MakeTexture', params.window, grating, [], [], [1], [],glsl);
    
    % Definition of the drawn source rectangle on the screen:
    srcRect=[0 0 visiblesize visiblesize];
    
    % Set refresh rate
    waitframes = 1;
    
    % Recompute p, this time without the ceil() operation from above.
    % Otherwise we will get wrong drift speed due to rounding!
    %period = 1/f; % pixels/cycle
    
    shiftperframe = cyclespersecond * period * waitframes*ifi;
    
    
    % Translate requested speed of the gratings (in cycles per second) into
    % a shift value in "pixels per frame", assuming given waitduration:
    phaseincrement = (cyclespersecond * 360) * ifi;
    
    
    % Perform initial Flip to sync us to the VBL and for getting an initial
    % VBL-Timestamp for our "WaitBlanking" emulation:
    vbl = Screen('Flip', params.window);

    
    % We run at most 'movieDurationSecs' seconds if user doesn't abort via keypress.
    
    %first we'll run test only
    movieDurationSecs=30.0; % Abort demo after 60 seconds.
    
    vblendtime = vbl + movieDurationSecs;
    i=0;
    
    
    % Animation loop: Run until timeout or keypress.
    while (vbl < vblendtime) %&& ~KbCheck
        
        [keyIsDown,~,keyCode]=KbCheck();
        if keyIsDown
            if keyCode(KbName('ESCAPE'))
                break
            end   
          
            WaitSecs(1)
            KbStrokeWait;
        end
                        
        
        % Shift the grating by "shiftperframe" pixels per frame. We pass
        % the pixel offset 'yoffset' as a parameter to
        % Screen('DrawTexture'). The attached 'glsl' texture draw shader
        % will apply this 'yoffset' pixel shift to the RGB or Luminance
        % color channels of the texture during drawing, thereby shifting
        % the gratings. Before drawing the shifted grating, it will mask it
        % with the "unshifted" alpha mask values inside the Alpha channel:
        yoffset = mod(i*shiftperframe,period);
        i=i+1;
        
        % Draw first grating texture, rotated by "angle":
        Screen('DrawTexture', params.window, gratingtex1, srcRect, [], angle, [], [contrast_test], [], [], [], [0, yoffset, 0, 0]);
        
        % Draw 2nd grating texture, rotated by "angle+45":
        Screen('DrawTexture', params.window, gratingtex2, srcRect, [], angle+90, [], [contrast_mask], [], [], [], [0, yoffset, 0, 0]);
        
        %Flip to screen
        vbl = Screen('Flip', params.window, vbl + (waitframes - 0.5) * ifi);
%         imageArray=Screen('GetImage', params.window,[],['frontBuffer'],1,1);
%         
%         figure; 
%         imwrite(squeeze(imageArray(:,:,1)),'Plaid_GetImage_Output.png');
%         break
        
    end
    
    
    % The same commands wich close onscreen and offscreen windows also close textures.
    Screen('CloseAll');
    
catch
    % This "catch" section executes in case of an error in the "try" section
    % above. Importantly, it closes the onscreen window if it is open.
    Screen('CloseAll');
    psychrethrow(psychlasterror);
    
end %try..catch..


