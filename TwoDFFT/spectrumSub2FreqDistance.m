function [condFreqVect, powerAtCondFreq, freqDist]= spectrumSub2FreqDistance(absSpec,xfreq, yfreq, norm2TotPower)
%[condFreqVect, powerAtCondFreq, freqDist]= spectrumSub2FreqDistance(absSpec,xfreq, yfreq, norm2TotPower)
% norm2TotPower = 1 for normalize to total power per frame, 0 if not

if nargin<3
    norm2TotPower =1;
end
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
        powerAtCondFreq(i) = mean(absSpec(ind));
        %         if norm2TotPower ==1
        %         powerAtCondFreq(i) = mean(absSpec(ind))/sum(absSpec(:));
        %         else
        %             powerAtCondFreq(i) = mean(absSpec(ind));
        %         end
    end
    if norm2TotPower ==1
        powerAtCondFreq = powerAtCondFreq./sum(powerAtCondFreq);
    end
    
elseif ndims(absSpec) ==3
    for t = 1:size(absSpec,1)
        useSpec = squeeze(absSpec(t,:,:));
        for i = 1:length(condFreqVect)
            ind = find(freqDist == condFreqVect(i));
            powerAtCondFreq(t,i) = mean(useSpec(ind));
            %             if norm2TotPower ==1
            %             powerAtCondFreq(t,i) = mean(useSpec(ind))/sum(useSpec(:));
            %             else
            %                 powerAtCondFreq(t,i) = mean(useSpec(ind));
            %             end
            %
        end
        if norm2TotPower ==1
            powerAtCondFreq(t,:) = powerAtCondFreq(t,:)./sum(powerAtCondFreq(t,:));
        end
    end
end

