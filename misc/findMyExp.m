function [myFavoriteExp] = findMyExp(dataMatrixFlashes, exp, iso, int, dur)
%find experiment name for you with criteria 
% syntax: findMyExp(dataMatrixFlashes, exp, iso, int, dur)

    expVector = ones(1, length(dataMatrixFlashes));
    isoVector = ones(1, length(dataMatrixFlashes));
    intVector = ones(1, length(dataMatrixFlashes));
    durVector = ones(1, length(dataMatrixFlashes));

    if nargin > 1 && ~isempty(exp)
        expVector = [dataMatrixFlashes.exp]== exp;
    end
    if nargin > 2 &&~isempty(iso)
        isoVector = [dataMatrixFlashes.AnesLevel]== iso;
    end
    if nargin > 3 &&~isempty(int)
        intVector = [dataMatrixFlashes.IntensityPulse]== int;
    end
    if nargin > 4 &&~isempty(dur)
        durVector = [dataMatrixFlashes.LengthPulse]== dur;
    end
    
    myFavoriteExp = find(expVector & isoVector & durVector & intVector);
end
