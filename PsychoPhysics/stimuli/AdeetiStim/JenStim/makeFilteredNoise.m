function noise = makeFilteredNoise(Fs, duration, fPass)
    noise = rand(1, Fs*duration);
    noise = bandpass(noise, fPass, Fs);
end