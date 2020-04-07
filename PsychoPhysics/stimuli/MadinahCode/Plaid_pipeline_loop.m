
%xcenter=900; ycenter=600; texsize=(20/0.0483); contrast_test=0.2; contrast_mask=0.2;
%DriftDemo6_madineh_pipeline(xcenter,ycenter,texsize,contrast_test,contrast_mask)

function Plaid_pipeline_loop(params,xcenter,ycenter,texsize,contrast_test,contrast_mask,sf,tf)
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
        
       PsychDataPixx('Open'); % Set up for TTL
       PsychDataPixx('SetVideoMode',2); % See documentation. 0 will probably be sufficient for point-light stimuli
       PsychDataPixx('DisableVideoScanningBacklight'); % Scann
        
        params.gamma=2.08;
        params.gray=0.5;
        params.black=0;
        params.white=1;
        [params.window,params.Rect]= PsychImaging('OpenWindow',max(Screen('Screens')),params.gray);
        %  PsychColorCorrection('SetEncodingGamma', params.window,1/params.gamma);
        Screen('Preference', 'VisualDebugLevel', 3);
        oldVerbosity = Screen('Preference', 'Verbosity', 0); % Don't log the GL stuff

        
        display('Opening a new on screen window');
    else
        %do nothing
        % PsychColorCorrection('SetEncodingGamma', params.window,1/params.gamma),
        
    end
    

    % Make sure this GPU supports shading at all:
    AssertGLSL;
    
    % Enable alpha blending for typical drawing of masked textures:

    
    Screen('BlendFunction', params.window, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    
    % Create a special texture drawing shader for masked texture drawing:
    glsl = MakeTextureDrawShader(params.window, 'SeparateAlphaChannel');
    
    % Query duration of monitor refresh interval:
    ifi=Screen('GetFlipInterval', params.window);
    ifi=1/(120);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%inputs
    %sf=(0.04);
    f=AngletoPixelSF(sf);%is cycles/pixel
    period=ceil(1/f); % pixels/cycle, rounded up.
    fr=(1/period)*2*pi; %cycles/pixel * 360 degrees/cycle = fr is degrees/pixel
    
    cyclespersecond=tf;
    angle=150;
    
    %texsize=(10/0.0483); % Half-Size of the grating image.
    visiblesize=2*texsize+1;
    
    inc=params.white-params.gray;
    
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
    gratingtex1 = Screen('MakeTexture', params.window, grating , [], [], [], [],glsl);
    
    % Build a second drifting grating texture, this time half the texsize
    % of the 1st texture:
    %texsize = ceil(texsize/2);
    %visible2size = 2*texsize+1;
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
    gratingtex2 = Screen('MakeTexture', params.window, grating, [], [], [], [],glsl);
    
    % Definition of the drawn source rectangle on the screen:
    srcRect=[0 0 visiblesize visiblesize];
    dstRect=CenterRectOnPoint(srcRect, xcenter, ycenter);
    
    
    
    waitframes = 1;
    
    % Recompute p, this time without the ceil() operation from above.
    % Otherwise we will get wrong drift speed due to rounding!
    period = 1/f; % pixels/cycle
    
    shiftperframe = cyclespersecond * period * waitframes*ifi;
    
    
    % Translate requested speed of the gratings (in cycles per second) into
    % a shift value in "pixels per frame", assuming given waitduration:
    phaseincrement = (cyclespersecond * 360) * ifi;
    
    
    % Perform initial Flip to sync us to the VBL and for getting an initial
    % VBL-Timestamp for our "WaitBlanking" emulation:
    vbl = Screen('Flip', params.window);
    
    % We run at most 'movieDurationSecs' seconds if user doesn't abort via keypress.
    
    %first we'll run test only
    movieDurationSecs=10.1; % Abort demo after 60 seconds.
    
    Datapixx('SetDoutValues', [0]);
    Datapixx('RegWrRd');
    
    order=randperm(1) %randomize presentation of test, mask, and test+mask for this particular set of contrasts
    for i=1:1
    switch (order(i))
        case 1
            vblendtime = vbl + movieDurationSecs;
            i=0;
            while (vbl < vblendtime) && ~KbCheck
                
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
                dstRect=CenterRectOnPoint(srcRect, xcenter, ycenter);
                Screen('DrawTexture', params.window, gratingtex1, srcRect, dstRect, angle, [], [contrast_test], [], [], [], [0, yoffset, 0, 0]);
                
                
                if yoffset<shiftperframe
                    cyc_start=tic;
                    
                    % Flip 'waitframes' monitor refresh intervals after last redraw.
                    vbl = Screen('Flip', params.window, vbl + (waitframes - 7/8) * ifi);
                    
                elseif (0<yoffset-(period-shiftperframe)) && (yoffset-(period-shiftperframe)<shiftperframe)
                    cycle_dur=toc(cyc_start);
                    i=0;
                    TTLval=1;
                    
                    % Flip 'waitframes' monitor refresh intervals after last redraw.
                    vbl = Screen('Flip', params.window, vbl + (waitframes - 7/8) * ifi);
                    Datapixx('SetDoutValues',  TTLval);
                    Datapixx('RegWrRd');
                    Datapixx('SetDoutValues',  0);
                    Datapixx('RegWrRd');
                else
                    
                    % Flip 'waitframes' monitor refresh intervals after last redraw.
                    vbl = Screen('Flip', params.window, vbl + (waitframes - 7/8) * ifi);
                    
                end
                
            end
            
        case 2
            
            %now for the mask only
            vblendtime = vbl + movieDurationSecs;
            i=0;
            
            % Animation loop: Run until timeout or keypress.
            while (vbl < vblendtime) && ~KbCheck
                
                % Shift the grating by "shiftperframe" pixels per frame. We pass
                % the pixel offset 'yoffset' as a parameter to
                % Screen('DrawTexture'). The attached 'glsl' texture draw shader
                % will apply this 'yoffset' pixel shift to the RGB or Luminance
                % color channels of the texture during drawing, thereby shifting
                % the gratings. Before drawing the shifted grating, it will mask it
                % with the "unshifted" alpha mask values inside the Alpha channel:
                yoffset = mod(i*shiftperframe,period);
                i=i+1;
                
                Screen('DrawTexture', params.window, gratingtex2, srcRect, dstRect, angle, [], [contrast_mask], [], [], [], [0, yoffset, 0, 0]);
                
                
                
                if yoffset<shiftperframe
                    cyc_start=tic;
                    
                    % Flip 'waitframes' monitor refresh intervals after last redraw.
                    vbl = Screen('Flip', params.window, vbl + (waitframes - 0.5) * ifi);
                    
                    
                elseif (0<yoffset-(period-shiftperframe)) && (yoffset-(period-shiftperframe)<shiftperframe)
                    cycle_dur=toc(cyc_start);
                    i=0;
                    TTLval=2;
                    
                    % Flip 'waitframes' monitor refresh intervals after last redraw.
                    vbl = Screen('Flip', params.window, vbl + (waitframes - 0.5) * ifi);
                    Datapixx('SetDoutValues',  TTLval);
                    Datapixx('RegWrRd');
                    Datapixx('SetDoutValues',  0);
                    Datapixx('RegWrRd');
                    
                else
                    % Flip 'waitframes' monitor refresh intervals after last redraw.
                    vbl = Screen('Flip', params.window, vbl + (waitframes - 0.5) * ifi);
                    
                end;
                
                
            end;
            
        case 3
            
            %now for both
            vblendtime = vbl + movieDurationSecs;
            i=0;
            
            % Animation loop: Run until timeout or keypress.
            while (vbl < vblendtime) && ~KbCheck
                
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
                Screen('DrawTexture', params.window, gratingtex1, srcRect, dstRect, angle, [], [contrast_test], [], [], [], [0, yoffset, 0, 0]);
                
                % Draw 2nd grating texture, rotated by "angle+45":
                Screen('DrawTexture', params.window, gratingtex2, srcRect, dstRect, angle, [], [contrast_mask], [], [], [], [0, yoffset, 0, 0]);
                
                
                if yoffset<shiftperframe
                    cyc_start=tic;
                    % Flip 'waitframes' monitor refresh intervals after last redraw.
                    vbl = Screen('Flip', params.window, vbl + (waitframes - 0.5) * ifi);
                    
                    
                elseif (0<yoffset-(period-shiftperframe)) && (yoffset-(period-shiftperframe)<shiftperframe)
                    cycle_dur=toc(cyc_start);
                    i=0;
                    TTLval=3;
                    
                    % Flip 'waitframes' monitor refresh intervals after last redraw.
                    vbl = Screen('Flip', params.window, vbl + (waitframes - 0.5) * ifi);
                    Datapixx('SetDoutValues',  TTLval);
                    Datapixx('RegWrRd');
                    Datapixx('SetDoutValues',  0);
                    Datapixx('RegWrRd');
                    
                else
                    % Flip 'waitframes' monitor refresh intervals after last redraw.
                    vbl = Screen('Flip', params.window, vbl + (waitframes - 0.5) * ifi);
                    
                end;
                
            end;
            
    end
    end
    
    % The same commands wich close onscreen and offscreen windows also close textures.
    %Screen('CloseAll');
    
catch
    % This "catch" section executes in case of an error in the "try" section
    % above. Importantly, it closes the onscreen window if it is open.
    Screen('CloseAll');
    psychrethrow(psychlasterror);
    
    
end %try..catch..
