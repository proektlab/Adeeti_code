%function SoundOnly([toneFs = 44100], [toneFreq = 4000], [sigFreq = 0.01, [duration = 5])
%creates an amplitude modualted sound 
%inputs     toneFs      sampling rate. usually 44100.
%           toneFreq    frequency of tone.
%           sigFreq     frequency of am signal. 0 if no am wanted.
%           duration    duration of tone.

function SoundOnly(toneFs, toneFreq, sigFreq, duration)
%% defaults
    if nargin < 1
        toneFs = [];
    end
    if nargin < 2
        toneFreq = [];
    end
    if nargin < 3
        sigFreq = [];
    end
    if nargin < 4
        duration = [];
    end
%   ^o^
    if isempty(toneFs)
        toneFs = 44100;
    end
    if isempty(toneFreq)
        toneFreq = 4000;
    end
    if isempty(sigFreq)
        sigFreq = 0.01;
    end
    if isempty(duration)
        duration = 5;
    end

%% generate and modify sound signal

    %places everything on 2 channels
    if size(sigFreq) == [1,1]
        sigFreq = [sigFreq, sigFreq];
    end
    if size(toneFreq) == [1,1]
        toneFreq = [toneFreq, toneFreq];
    end
    
    %creates signal
    if(isempty(find(sigFreq == 0, 1)))
        signal = makeTone(toneFs, sigFreq, duration);
    else
        %if no am modulation, just make the pure tone
        signal = makeTone(toneFs, toneFreq, duration);
    end

    %amplitude modulates both channels
    for i = 1:size(signal, 1)
        if(sigFreq(i) > 0)
            signal(i, :) = ammod(signal(i,:), toneFreq(i), toneFs, 1);
        end
    end

    %smooths out beginning and end of both channels
%     signal = removeClick(signal, 300, toneFs);

      nrchannels = size(signal, 1);
      %open audio port
         try
            % Try with the 'freq'uency we wanted:
            pahandle = PsychPortAudio('Open', [], [], 0, toneFs, nrchannels);
        catch
            % Failed. Retry with default frequency as suggested by device:
            disp('\nCould not open device at wanted playback frequency of %i Hz. Will retry with device default frequency.\n');
            disp('Sound may sound a bit out of tune, ...\n\n');

            psychlasterror('reset');
            pahandle = PsychPortAudio('Open', [], [], 2, [], nrchannels);

         end

        % Fill the audio playback buffer with the audio data 'wavedata':
        PsychPortAudio('FillBuffer', pahandle, signal);
        
        % Start audio playback for 'repetitions' repetitions of the sound data,
        % start it immediately (0) and wait for the playback to start, return onset
        % timestamp.
        PsychPortAudio('Start', pahandle, 0, 0, 1);
        % Wait for release of all keys on keyboard:
        WaitSecs(duration);
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