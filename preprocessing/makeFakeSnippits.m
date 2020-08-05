function [fakeSnippits] = makeFakeSnippits(meanSubData, smallSnippets)

%% Concatinating data and randomizing flash onset

data = meanSubData;
concatData = reshape(permute(data, [1 3 2]), size(data,1), (size(data,2)*size(data,3)));
data = concatData;

numTrials = size(meanSubData,2);

fakeFlashes = randsample([1000:size(data,2)-1000], numTrials, false);

%% Making smallSnippits around fakeFlahses

sizeSnippit = size(smallSnippets, 3);
before = floor(size(smallSnippets, 3)/2);
after = before;

fakeSnippits = nan(size(smallSnippets));

for ff = 1:numTrials
    tempFlash = fakeFlashes(ff);
    temp = data(:, tempFlash-before:tempFlash+after);
    fakeSnippits(:, ff, :) = temp;
end