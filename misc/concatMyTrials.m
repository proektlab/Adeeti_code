function [concatData] = concatMyTrials(data, finalSampR, plotMyEEG)
% input data for concatinating (e.g., meanSubData, dataSnippits
%plotMyEEG = 1 to open EEGplot
concatData = reshape(permute(data, [1 3 2]), size(data,1), (size(data,2)*size(data,3)));
concatFinalTime = linspace(0, size(concatData, 2)/finalSampR, size(concatData, 2));

if plotMyEEG ==1
eegplot(concatData, 'srate', finalSampR)
end
