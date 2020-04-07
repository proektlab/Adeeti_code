function [fakeSnippits] = makeFakeSnippitsFullTrace(fullTrace, info, numTrials, snipLength)
% [fakeSnippits] = makeFakeSnippitsFullTrace(fullTrace, info, numTrials, snipLength)
% fullTrace of data - not trials concatonated together
% info file for offsets for the full trace for when flashes are present
% info.trials will work for number of trials 
% snipLength = length of snippets for wavelet, etc


%% Concatinating data and randomizing flash onset

startOffSet = info.startOffSet;
endOffSet = info.endOffSet;

if size(fullTrace,2)<endOffSet
    endOffSet = size(fullTrace,2);
end

before = floor(snipLength/2);
after = before;

data = fullTrace(:,startOffSet:endOffSet);

fakeFlashes = randsample([before:size(data,2)-after], numTrials, false);

%% Making smallSnippits around fakeFlahses

fakeSnippits = nan(size(fullTrace,1), numTrials, snipLength);

for ff = 1:numTrials
    tempFlash = fakeFlashes(ff);
    temp = data(:, tempFlash-before:tempFlash+after);
    fakeSnippits(:, ff, :) = temp;
end