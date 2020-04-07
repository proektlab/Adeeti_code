function [ CohMag, CohAngle, actualFreq ] = WaveCoherence(meanSubData, timeFrame, info, lowFreqCut, highFreqCut, finalSampR, numOct, voicePerOct)
% Interelectrode phase coherence for single trials [ CohMag, CohAngle, f ] = WaveCoherence(meanSubData, timeFrame, info, lowFreqCut, highFreqCut, finalSampR)

if nargin <8
    voicePerOct = 12;
end
if nargin < 7
    numOct = floor(log2(numel(meanSubData(1,2,timeFrame))))-1;
end
if nargin < 6 
    finalSampR = 1000;
end


%% get freqs
goodChan = [1:info.channels];
goodChan(info.noiseChannels) = [];
sig1 = squeeze(meanSubData(goodChan(1), 1, timeFrame));
sig2 = squeeze(meanSubData(goodChan(1), 1, timeFrame));
[~, ~, f] = wcoherence(sig1,sig2, finalSampR);
fIndex = find(f>lowFreqCut & f<highFreqCut);
actualFreq = f(fIndex);

%% coherence measure
tic; 
CohMag = nan(size(meanSubData, 1), size(meanSubData, 1), size(meanSubData, 2), size(fIndex, 1), length(timeFrame));
CohAngle = nan(size(meanSubData, 1), size(meanSubData, 1), size(meanSubData, 2), size(fIndex, 1), length(timeFrame));
for ch1 = 1:size(meanSubData, 1)
    disp(['Calculating coherence for channel ', num2str(ch1)])
    for ch2 = ch1:size(meanSubData, 1)
        parfor tr = 1:size(meanSubData, 2)
            sig1 = squeeze(meanSubData(ch1, tr, timeFrame));
            sig2 = squeeze(meanSubData(ch2, tr, timeFrame));
            
            if ~isnan(sig1(1)) && ~isnan(sig2(1))
                [cohMag, cohComplex, f] = wcoherence(sig1,sig2, finalSampR, 'NumOctaves', numOct,'VoicesPerOctave', voicePerOct);
                
                for fr = 1:length(cohFreq)
                    if cohFreq(fr)>9
                        eval([['cohMag', num2str(floor(cohFreq(fr))), '(ch1,ch2,tr,:)'] '= squeeze(cohMag(fr,:));'])
                        eval([['cohAngle', num2str(floor(cohFreq(fr))), '(ch1,ch2,tr,:)'] '= squeeze(cohComplex(fr,:));'])
                    else
                        eval([['cohMag', num2str(floor(cohFreq(fr))), '(ch1,ch2,tr,:)'] '= squeeze(cohMag(fr,:));'])
                        eval([['cohAngle', num2str(floor(cohFreq(fr))), '(ch1,ch2,tr,:)'] '= squeeze(cohComplex(fr,:));'])
                    end
                end    
            end
        end
    end
end

toc;
