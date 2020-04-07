function [adjRight, adjLeft, adjTop, adjBottom] = findChanFromV1(V1, addChan, info)
% V1 = channel number at which latency of onset of the average is the shortest
% addChan = number of channels want to show drop of for
% retuns lists of channels with first entry as closest to V1 in each direction

if nargin <2
    addChan = 3;
end

gridIndicies = info.gridIndicies;


[xGrid, yGrid] = ind2sub(size(gridIndicies), find(gridIndicies == V1));

adjTop = nan(1, addChan);
adjBottom = nan(1, addChan);
adjLeft = nan(1, addChan);
adjRight = nan(1, addChan);

%% Finding Channels to the top (closest first, farthest last)
xCounter = 0;
for x = xGrid-addChan:xGrid-1
    y = yGrid;
    xCounter = xCounter + 1;
    if y < 1 || x< 1 || x > size(gridIndicies,1) || y > size(gridIndicies,2)
        adjTop(xCounter) = NaN;
        continue
    end
    adChan = gridIndicies(x,y);
    if adChan == 0
        adjTop(xCounter) = NaN;
    else
        adjTop(xCounter) = adChan;
    end
end
adjTop = fliplr(adjTop);

%% Finding Channels to the bottom (closest first, farthest last)
xCounter = 0;
for x = xGrid +1 :xGrid+addChan
    y = yGrid;
    xCounter = xCounter + 1;
    if y < 1 || x< 1 || x > size(gridIndicies,1) || y > size(gridIndicies,2)
        adjBottom(xCounter) = NaN;
        continue
    end
    adChan = gridIndicies(x,y);
    if adChan == 0
        adjBottom(xCounter) = NaN;
    else
        adjBottom(xCounter) = adChan;
    end
end

%% Finding Channels to the left (closest first, farthest last)
yCounter = 0;
for y = yGrid-addChan:yGrid-1
    x = xGrid;
    yCounter = yCounter + 1;
    if y < 1 || x< 1 || x > size(gridIndicies,1) || y > size(gridIndicies,2)
        adjLeft(yCounter) = NaN;
        continue
    end
    adChan = gridIndicies(x,y);
    if adChan == 0
        adjLeft(yCounter) = NaN;
    else
        adjLeft(yCounter) = adChan;
    end
end
adjLeft = fliplr(adjLeft);

%% Finding Channels to the right (closest first, farthest last)
yCounter = 0;
for y = yGrid+1:yGrid+addChan
    x = xGrid;
    yCounter = yCounter + 1;
    if y < 1 || x< 1 || x > size(gridIndicies,1) || y > size(gridIndicies,2)
        adjRight(yCounter) = NaN;
        continue
    end
    adChan = gridIndicies(x,y);
    if adChan == 0
        adjRight(yCounter) = NaN;
    else
        adjRight(yCounter) = adChan;
    end
end