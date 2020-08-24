%% Convert meanSubData for CSD form

%% need data in time by xGridLoc by yGridLoc

dataDir = '/Users/adeeti/Google Drive/data/playingWithMutliStim/';

load('2018-07-07_16-37-19.mat', 'meanSubData', 'info')

nx = 11;
ny = 6;
dx = 0.5;
dy = 0.5;
h = 0.1;

inputData = squeeze(meanSubData(:,1,:));
gridIndicies = info.gridIndicies;

gridPosition = NaN(66,2);
gridData=NaN(66,1);
%girdDataPosition = NaN(11,6);


for t = 1:size(inputData,2)
    counter=1;
    for i=1:size(gridIndicies,1)
        for j=1:size(gridIndicies,2)
            if gridIndicies(i,j)~=0
                gridData(counter)=inputData(gridIndicies(i,j),t); %reorganizes data into grid indicies formate
                girdDataPosition(i,j) = inputData(gridIndicies(i,j),t);
            end
            gridPosition(counter,:) = [i,j];
            counter = counter+1;
        end
    end
    
    gridPosition(isnan(gridData),:) = [];
    gridDataNoNan = gridData;
    gridDataNoNan(isnan(gridData)) = [];
    
    [yGridInt,xGridInt] = meshgrid(1:6, 1:11);
    
    interpFunction=scatteredInterpolant(gridPosition, gridDataNoNan, 'linear', 'nearest');
    interpValues = interpFunction(xGridInt,yGridInt);
    finalGridData(t, :,:) = interpValues;
end

dataName = [info.expName(1:end-4),'_gridCSD'];

initlin2d(dataName,nx,ny,dx,dy,h);

csd = icsd2d(finalGridData, F);

%% 