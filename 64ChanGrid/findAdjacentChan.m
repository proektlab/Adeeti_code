function [adjVector] = findAdjacentChan(info)

%finds channels that are next to channel in question
%input: vector with number of channels as the first dimention
%[adjVector] = findAdjacentChan(numOfChannels)
% order: UL, UM, UR
%        ML, ch, MR
%        LL, LM, LR

gridIndicies = info.gridIndicies;
numOfChannels = info.channels;
adjVector = [];
            
for ch = 1:numOfChannels
    [xGrid, yGrid] = ind2sub(size(gridIndicies), find(gridIndicies == ch));
    adjacencyID = 0;
    for x = xGrid-1:xGrid+1
        for y = yGrid-1:yGrid+1
            adjacencyID = adjacencyID +1;
            if y < 1 || x< 1 || x > size(gridIndicies,1) || y > size(gridIndicies,2)
                adjVector(ch, adjacencyID) = NaN;
                continue
            end  
           adChan = gridIndicies(x,y);
           if adChan == 0
               adjVector(ch, adjacencyID) = NaN;
           else
           adjVector(ch, adjacencyID) = adChan;
           end
        end
    end
end

