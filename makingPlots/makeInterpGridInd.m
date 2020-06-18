function [concatChanTimeData, interpGridInd, interpNoiseInd, interpNoiseGrid] = makeInterpGridInd(interpGridData, interpBy, info)
% interpGridData = time by rows by columns
gridInd= info.gridIndicies;
ogData = permute(interpGridData, [2, 3, 1]);
size(ogData);
concatChanTimeData =  reshape(ogData, [size(ogData,1)*size(ogData,2), size(ogData,3)]);

x = 1:size(concatChanTimeData,1);
interpGridInd = reshape(x, [interpBy*size(gridInd,1),interpBy*size(gridInd,2)]);



interpNoiseGrid = zeros(size(ogData,1), size(ogData,2));
for i=1:size(gridInd,1)
    for j=1:size(gridInd,2)
        if gridInd(i,j) ==0 ||ismember(gridInd(i,j), info.noiseChannels)
            interpNoiseGrid((i-1)*interpBy+1:i*interpBy,(j-1)*interpBy+1:j*interpBy,:)=[1]; %make noise channels black
        end
    end
end

interpNoiseInd = find(interpNoiseGrid ==1);



end