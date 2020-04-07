%function COPYSoundOnly([toneFs = 44100], [toneFreq = 4000], [sigFreq = 0.01, [duration = 5])
%plays a pure tone. needs a audio port to be opened.
%inputs     toneFs      sampling rate. usually 44100.
%           toneFreq    frequency of tone.
%           sigFreq     frequency of am signal. 0 if no am wanted.
%           duration    duration of tone.
%           TTLParams   parameters for a ttl pulse sent to labjack. first
%           value is channel, second value is duration in ms. type 0 for no
%           pulse.

function SmallSoundOnly(params, pahandle, toneFreq, sigFreq, duration, TTLParams)
s = GetSecs();
%% defaults

    if nargin < 3
        toneFreq = [];
    end
    if nargin < 4
        sigFreq = [];
    end
    if nargin < 5
        duration = [];
    end
    if nargin < 6
        TTLParams = [1,1];
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

    %smooths out beginning and end of both channels
    signal = removeClick(signal, params.rampTime, params.toneFs);
    

        % Fill the audio playback buffer with the audio data 'wavedata':
        PsychPortAudio('FillBuffer', pahandle, signal);
        
        if(TTLParams ~= 0)
            lj = labJack('verbose', false); %sets up labjack
        end
        
        % Start audio playback for 'repetitions' repetitions of the sound data,
        % start it immediately (0) and wait for the playback to start, return onset
        % timestamp.
        PsychPortAudio('Start', pahandle, 1, 0, 1);
        tic
        
        if(TTLParams ~= 0)
            lj.toggleFIO(TTLParams);
        end
        
        % Wait for audio to play
        WaitSecs(duration);
        
        if(TTLParams ~= 0)
             lj.toggleFIO(TTLParams);
        end
        
         % Stop playback:
        PsychPortAudio('Stop', pahandle);
        toc
        
        lj.close();
        
end