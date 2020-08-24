function [stimIndexSeriesString] = stimIndex2string4saving(stimIndex, finalSampR)

if nargin <2
    finalSampR =1000;
end

stimIndexSeriesString = ['S'];

for i = 1:size(stimIndex,2)
    if isinf(stimIndex(i))
        stimIndexSeriesString = [stimIndexSeriesString, '_Inf'];
    else
        addOn = stimIndex(i)*finalSampR;
        stimIndexSeriesString = [stimIndexSeriesString, '_' num2str(addOn)];
    end
end
end


