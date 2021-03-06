function [plotHandle, interpValuesFine] = plotOnGridInterp(inputData, plotType, gridIndicies, interpBy, noiseBlk)
%  [plotHandle, interpValuesFine] = plotOnGridInterp(inputData, plotType, gridIndicies, interpBy, noiseBlk)
% input data = data to interpolates between noise channels and makes a
% pretty plot on grid
% Plot type: 1 for plot, 0 for surf
% gridIndicies = info.gridIndicies
% interpBy = 100 by default (how fine to interp)
% noiseBlk = 0 by default (1 if dont want to interpolate over noise
% channels, 0 if do want to interpolate over them)

if nargin<5 || isempty(noiseBlk)
    noiseBlk = 0;
end

if nargin<4 || isempty(interpBy)
    interpBy = 100;
end

if ~exist('plotType') || isempty(plotType)
    plotType = 1;
end
%%
gridRows = size(gridIndicies,1);
gridCols = size(gridIndicies,2);

gridPosition = NaN(numel(gridIndicies),2);

gridData=NaN(numel(gridIndicies),1);
girdDataPosition = NaN(gridRows,gridCols);

counter=1;



for i=1:size(gridIndicies,1)
    for j=1:size(gridIndicies,2)
        if gridIndicies(i,j)~=0
            gridData(counter)=inputData(gridIndicies(i,j)); %reorganizes data into grid indicies formate
            girdDataPosition(i,j) = inputData(gridIndicies(i,j));
        end
        gridPosition(counter,:) = [i,j];
        counter = counter+1;
    end
end

gridPosition(isnan(gridData),:) = [];
gridDataNoNan = gridData;
gridDataNoNan(isnan(gridData)) = [];

xInterp = linspace(1,gridCols, gridCols*interpBy);
yInterp = linspace(1,gridRows, gridRows*interpBy);

[yGridInt,xGridInt] = meshgrid(0:gridCols+1, 0:gridRows+1);

interpFunction=scatteredInterpolant(gridPosition, gridDataNoNan, 'linear', 'nearest');
interpValues = interpFunction(xGridInt,yGridInt);

F=griddedInterpolant(xGridInt, yGridInt, interpValues, 'spline');

[yGridIntFine,xGridIntFine] = meshgrid(xInterp, yInterp);
interpValuesFine=F(xGridIntFine,yGridIntFine);


cla;
if plotType ==1
    plotHandle = imagesc(interpValuesFine);
    colormap(jet(256))
    hold on;
    if noiseBlk == 1
        blackChans = ones(size(interpValuesFine,1), size(interpValuesFine,2), 3);
        transChans = zeros(size(interpValuesFine,1), size(interpValuesFine,2), 1);
        for i=1:size(gridIndicies,1)
            for j=1:size(gridIndicies,2)
                if isnan(girdDataPosition(i,j))
                    blackChans((i-1)*interpBy+1:i*interpBy,(j-1)*interpBy+1:j*interpBy,:)=[0 0 0]; %make noise channels black
                    transChans((i-1)*interpBy+1:i*interpBy,(j-1)*interpBy+1:j*interpBy,:)=[1]; %make noise channels black
                end
            end
        end
        imagesc('CData', blackChans, 'AlphaData', transChans)
    end  
    if noiseBlk == 0
        for i=1:size(gridIndicies,1)
            for j=1:size(gridIndicies,2)
                if isnan(girdDataPosition(i,j))
                    for dx = -1:1
                        for dy = -1:1
                            if dx ~= dy && dx ~= -dy
                                x = i + dx;
                                y = j + dy;
                                
                                if x >= 1 && y >= 1 && x <= gridRows && y <= gridCols && ~isnan(girdDataPosition(x,y))
                                    if dx == 1
                                        xValues = [i i];
                                        yValues = [j-1 j];
                                    elseif dx == -1
                                        xValues = [i-1 i-1];
                                        yValues = [j-1 j];
                                    elseif dy == 1
                                        xValues = [i-1 i];
                                        yValues = [j j];
                                    elseif dy == -1
                                        xValues = [i-1 i];
                                        yValues = [j-1 j-1];
                                    end
                                    
                                    plot(yValues*interpBy, xValues*interpBy, '--', 'Color', [0.8 0.8 0.8], 'LineWidth', 1)
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    
else
    plotHandle = surf(interpValuesFine);
    shading flat;
    colormap(jet(256))
end


