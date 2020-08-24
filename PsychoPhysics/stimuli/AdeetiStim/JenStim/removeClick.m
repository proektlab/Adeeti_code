%This function smooths out the beginning and end of a signal to remove the
%click
%inputs     signal      represents a sound
%           smoothTime  time that is smoothed out in milliseconds
%           Fs          sampling rate
function smooth = removeClick(signal, smoothTime, Fs)

    [channels, sigLength] = size(signal); %gets size of signal
    numSmooth = round(smoothTime/1000 * Fs); %number of values that will be smoothed out
    multiplier = zeros(size(signal)); %trapezoidal multiplier to smooth out beginning and end
    
    for i = 1:channels
        %find nonzero values
        firstNonZero = find(signal(i, :), 1);
        lastNonZero = find(signal(i, :), 1, 'last');
        
        %create trapezoidal multiplier
        multiplier(i, :) = [zeros(1, firstNonZero),...
            linspace(0, 1, numSmooth),...
            ones(1, lastNonZero - firstNonZero - 2*numSmooth), ...
            linspace(1, 0, numSmooth),...
            zeros(1, sigLength - lastNonZero)];
    end
    
    smooth = signal .* multiplier; %apply multiplier to signal
    
end