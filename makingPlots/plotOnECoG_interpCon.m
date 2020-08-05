function [gridData] = plotOnECoG_interpCon(concatInterpData, interpGridInd)

for i = 1:size(interpGridInd,1)
    for j = 1:size(interpGridInd,2)
        gridData(i,j,:) = concatInterpData(interpGridInd(i,j),:);
    end
end

