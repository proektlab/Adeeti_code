function [matStimIndex] = creatingStimMatrix(dirIn)

load('dataMatrixFlashes.mat')

if isfield(dataMatrixFlashes, 'numberStim')
    numStim = unique([dataMatrixFlashes.numberStim]);
    if numel(numStim) > 1
        disp('There is at least one file that does not have the same stimulation paradigm as the others. This may be a mistake in info file and dataMatrixFlashes generation');
    elseif numel(numStim) == 0
        disp('You have recorded that there are no stimuli in this file; will treat as baseline measurement.');
    else
        if numStim ==1
            numStim = 2;
        end
        matStimIndex = (reshape([dataMatrixFlashes.stimIndex], [numStim, size(dataMatrixFlashes,2)]))';
        matStimIndex = unique(matStimIndex, 'rows');
    end
else
    disp('You have recorded that there are no stimuli in this file; will treat as baseline measurement.');
end

if exist('matStimIndex')
    save([dirIn, 'matStimIndex.mat'], 'matStimIndex')
end