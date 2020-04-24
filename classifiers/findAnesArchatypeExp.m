function [isoHighExp, isoLowExp, emergExp, awaExp1, awaLastExp, ketExp] = findAnesArchatypeExp(dataMatrixFlashes, expID, stimIndex)
% [isoHighExp, isoLowExp, emergExp, awaExp1, awaLastExp, ketExp] = findAnesArchatypeExp(dataMatrixFlashes, expID, stimIndex)
if nargin <2
    expID = [];
end
if nargin <3
    stimIndex = [0 Inf];
end
%%
isoHighExp = nan;
isoLowExp = nan;
emergExp = nan;
awaExp1 = nan;
awaLastExp = nan;
ketExp = nan;

%find high iso
temp = findMyExpMulti(dataMatrixFlashes, expID, 'iso', 1.2, stimIndex, []);
if isempty(temp)
    temp = findMyExpMulti(dataMatrixFlashes, expID, 'iso', 1.0, stimIndex, []);
end
if ~isempty(temp)
     isoHighExp = temp(end);
end

%find low iso
temp = findMyExpMulti(dataMatrixFlashes, expID, 'iso', 0.6, stimIndex, []);
if isempty(temp)
    temp = findMyExpMulti(dataMatrixFlashes, expID, 'iso', 0.4, stimIndex, []);
end
if ~isempty(temp)
    isoLowExp = temp(1);
end

%find emergence
temp = findMyExpMulti(dataMatrixFlashes, expID, 'emerg', 2000, stimIndex, []);
if ~isempty(temp)
    emergExp = temp(1);
end

%find awake
temp = findMyExpMulti(dataMatrixFlashes, expID, 'awa', 0, stimIndex, []);
if ~isempty(temp)
    awaExp1 = temp(1);
    if length(temp)>1
        awaLastExp= temp(end);
    end
end

% find ket
temp = findMyExpMulti(dataMatrixFlashes, expID, 'ket', 100, stimIndex, []);
if ~isempty(temp)
    ketExp = temp(1);
end