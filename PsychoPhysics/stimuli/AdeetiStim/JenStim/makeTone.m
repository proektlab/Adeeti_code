%this function makes a tone
%inputs:    Fs      sampling rate -- if using sound 8192 if using PTB3
%44100
%           freq    frquency of the tone [ left right ]
%           sigTime length of the tone in seconds
%           to play sound in matlab use sound(signal);

function signal = makeTone(Fs, freq, sigTime)
    if size(freq) == [1,1]
        freq = [freq, freq];
    end
    time = linspace(0, sigTime*2, Fs*sigTime);
    signal(1, :) = sin(freq(1)*pi*time); %first channel
    signal(2, :) = sin(freq(2)*pi*time); %second channel
end