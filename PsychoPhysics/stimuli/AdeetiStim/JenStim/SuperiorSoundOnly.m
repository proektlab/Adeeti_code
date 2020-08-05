%function SuperiorSoundOnly([toneFs = 44100], [toneFreq = 4000], [sigFreq = 0.01, [duration = 5])
%creates an amplitude modualted sound. 
%inputs     toneFs      sampling rate. usually 44100.
%           toneFreq    frequency of tone.
%           sigFreq     frequency of am signal. 0 if no am wanted.
%           duration    duration of tone.
%           TTLParams   parameters for a ttl pulse sent to labjack. first
%           value is channel, second value is duration in ms. type 0 for no
%           pulse.

function SuperiorSoundOnly(params, toneFreq, sigFreq, duration, TTLParams)
%% for timing
s = GetSecs();
%% defaults

    if nargin < 2
        toneFreq = [];
    end
    if nargin < 3
        sigFreq = [];
    end
    if nargin < 4
        duration = [];
    end
    if nargin < 5
        TTLParams = 0;
    end
%   ^o^

    if isempty(toneFreq)
        toneFreq = 4000;
    end
    if isempty(sigFreq)
        sigFreq = 0.01;
    end
    if isempty(duration)
        duration = 5;
    end
    if isempty(TTLParams)
        TTLParams = 0;
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
        signal = makeTone(params.toneFs, sigFreq, duration);
    else
        %if no am modulation, just make the pure tone
        signal = makeTone(params.toneFs, toneFreq, duration);
    end

    %amplitude modulates both channels
    for i = 1:size(signal, 1)
        if(sigFreq(i) > 0)
            signal(i, :) = ammod(signal(i,:), toneFreq(i), params.toneFs, 10);
        end
    end

    %smooths out beginning and end of both channels
    signal = removeClick(signal, 10, params.toneFs);

    nrchannels = size(signal, 1);
      %open audio port
         %try
            % Try with the 'freq'uency we wanted:
            pahandle = PsychPortAudio('Open', [], [], 3, params.toneFs, nrchannels);
%         catch
%             % Failed. Retry with default frequency as suggested by device:
%             disp('\nCould not open device at wanted playback frequency of %i Hz. Will retry with device default frequency.\n');
%             disp('Sound may sound a bit out of tune, ...\n\n');
% 
%             psychlasterror('reset');
%             pahandle = PsychPortAudio('Open', [], [], 0, [], nrchannels);
%          end

        % Fill the audio playback buffer with the audio data 'wavedata':
        PsychPortAudio('FillBuffer', pahandle, signal);
        
        if(TTLParams ~= 0)
            lj = labJack('verbose', false); %sets up labjack
        end
        
        % Start audio playback for 'repetitions' repetitions of the sound data,
        % start it immediately (0) and wait for the playback to start, return onset
        % timestamp.
        PsychPortAudio('Start', pahandle, 1, s + params.delay, 1);
        
        if(TTLParams ~= 0)
            lj.toggleFIO(TTLParams);
        end
        
        % Wait for audio to play
        WaitSecs(duration);
        
         % Stop playback:
        PsychPortAudio('Stop', pahandle);
        
        % If TTLParams is anything other than 0 it will toggle params
        if(TTLParams ~= 0)
            lj.toggleFIO(TTLParams);
        end

%         % Close the audio device:
        PsychPortAudio('Close', pahandle);

end