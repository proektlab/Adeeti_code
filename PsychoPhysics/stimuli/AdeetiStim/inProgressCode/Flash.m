function Flash(flashDelay, duration, flashDuration, w, params)
    % Query duration of monitor refresh interval:
    ifi=Screen('GetFlipInterval', w);    
    % Perform initial Flip to sync us to the VBL and for getting an initial
    % VBL-Timestamp for our "WaitBlanking" emulation:
    vbl=Screen('Flip', w);

    % We run at most 'movieDurationSecs' seconds if user doesn't abort via keypress.
    vblendtime = vbl + duration;
    while(vbl < vblendtime)
        Screen('FillRect', w, params.white);
        waitframes = 60*(flashDelay(1) + (flashDelay(2) - flashDelay(1))*rand());
       % Flip 'waitframes' monitor refresh intervals after last redraw.
        vbl = Screen('Flip', w, vbl + (waitframes - 0.5) * ifi);
        Screen('FillRect', w, params.black);
        waitframes = flashDuration*60;
       % Flip 'waitframes' monitor refresh intervals after last redraw.
        vbl = Screen('Flip', w, vbl + (waitframes - 0.5) * ifi);

       % Abort demo if any key is pressed:
       if KbCheck
          break;
       end
    end
end