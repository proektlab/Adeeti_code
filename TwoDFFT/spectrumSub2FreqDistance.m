function [condFreqVect, powerAtCondFreq, freqDist]= spectrumSub2FreqDistance(absSpec,xfreq, yfreq)
%[condFreqVect, powerAtCondFreq, freqDist]= spectrumSub2FreqDistance(absSpec,xfreq, yfreq)

%% finding distances in freq space
for x = 1:length(xfreq)
    for y = 1:length(yfreq)
        freqDist(y,x) = sqrt((xfreq(x)^2) + (yfreq(y)^2));
    end
end

condFreqVect = sort(unique(freqDist(:)));

%% organzing the power into freq
if ndims(absSpec) ==2
    for i = 1:length(condFreqVect)
        ind = find(freqDist == condFreqVect(i));
        powerAtCondFreq(i) = sum(absSpec(ind));
    end
elseif ndims(absSpec) ==3
    for t = 1:size(absSpec,1)
        useSpec = squeeze(absSpec(t,:,:));
        for i = 1:length(condFreqVect)
            ind = find(freqDist == condFreqVect(i));
            powerAtCondFreq(t,i) = nanmean(useSpec(ind));
        end
    end
end
end
