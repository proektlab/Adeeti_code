function [ zData, onset ] = normalizedThreshold(aveTrace, thresh, maxThresh, consistent, endMeasure, before, finalSampR)
% aveTrace = mean subtracted data , avaraged over all trials
% before = baseline period before stimulus (in seconds)
% endMeasure = time to look for evoked potential after flash (sec)
% thresh = threshold for latency measurement
% maxThresh = the evoked potential must cross this threshold between
% flashOnset and endMeasure 
% consistent = data points in which data needs to be above threshold
%  first normalizes data to the baseline (Zdata), then uses a threshold and
%  convolives it with a certain number of consistent points to a realiable
%  measure of latency of Evoked Potential (onset)

if nargin <5
    before = 1;
    finalSampR = 1000;
end

if nargin <4 
    endMeasure = 0.35;
end
    
if nargin <2
    thresh = 3;
    maxThresh = 5;
    consistent = 4;
end


    before = before*finalSampR; 
    endMeasure = before + (endMeasure*finalSampR);
    
    z=nanstd(aveTrace(:, 500:before),1,2);                 % compute the mean and the standard deviation of the signal before the stimulus
    m=nanmean(aveTrace(:, 500:before),2);
    
    zData=(aveTrace-repmat(m, 1, size(aveTrace,2)))./repmat(z, 1, size(aveTrace,2)); % compares each data point in the average to the mean and std before the flash (see if it comes from the same distribution)

    
 evokedPresent= @(x) abs(x)>maxThresh;
 temp=arrayfun(evokedPresent, zData(:,before:endMeasure));
 temp=sum(temp,2);
            
 good=find(temp);                   % found channel indices that have evoked potentials;
 
 
 latencyPresent= @(x) abs(x)>thresh;
 
 temp=arrayfun(latencyPresent, zData(good,before:endMeasure));  
 
 conSingal=convn(temp, ones(1,consistent)/consistent, 'same');               % convolve the pass with the consistency and normalized
 
 onset=Latency(good, conSingal, consistent, size(zData,1));
 
end


function L=Latency(goodChannel, conSignal, consistent, totChannels)
% goodChannel = indices of channels with Evoked Potential
% conSignal evoked potentials convolved with threshold. First dimension of
% conSignal must be the same as goodChannel.
% consistent is the length of the kernel that has been used for consistency
% convolution.
% totChannels is total number of Channels

    func=@(x) find(x==1, 1, 'first')-consistent./2;
    Latent=zeros(size(goodChannel));
    for i=1:length(Latent)
        temp=func(conSignal(i,:));
        if isempty(temp)
            disp('The threshold for latency may be too high');
            disp(['Channel ' num2str(goodChannel(i)) ' has an evoked potential but does not have a latency that satisifies criteria']);
            disp('Will assign latency of Nan');
            Latent(i)=NaN;
        else
            Latent(i)=temp;
        end
    end
    L=nan(totChannels,1);
    L(goodChannel)=Latent;
end
