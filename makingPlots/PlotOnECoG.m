function [ currentFig, colorMatrix, gridData] = PlotOnECoG(inputData, info, colorPref, dontMakeFigure)
% [ currentFig, colorMatrix, gridData] = PlotOnECoG(inputData, info, colorPref)
% dontMakeNewFigure = 1 - suppress figure generation
% defaults to making figure
%   colorPref = 1 ==> autumn, 
%             = 2 ==> winter
%             = 3 ==> jet

if nargin < 4
    dontMakeFigure = 0;
end
    
gridData=NaN(11,6);

currentFig =[];

gridIndicies = info.gridIndicies; 

for i=1:size(gridData,1)
    for j=1:size(gridData,2)
        if gridIndicies(i,j)~=0
            gridData(i,j)=inputData(gridIndicies(i,j)); %reorganizes data into grid indicies formate
        end
    end
end

colorMatrix=zeros(11,6,3);


if colorPref == 1
    colorScheme = 'autumn';
    colorInputs=colormap(autumn(length(find(~isnan(inputData)))));
    colorInputs = flipud(colorInputs);
elseif colorPref == 2
    colorScheme = 'winter';
    colorInputs=colormap(winter(length(find(~isnan(inputData)))));
    colorInputs = flipud(colorInputs);
elseif colorPref == 3
    colorScheme = 'jet';
    colorInputs=colormap(jet(length(find(~isnan(inputData)))));
end

trueInputData=inputData(find(~isnan(inputData)));

for i=1:size(colorMatrix,1)
    
    for j=1:size(colorMatrix,2)
        if ismember(gridIndicies(i,j), info.noiseChannels)
            colorMatrix(i,j,:)=[0 0 0 ]; %make noise channels black
        elseif gridIndicies(i,j) == 0
            colorMatrix(i,j,:)=[1 1 1]; %make empty channels white
        elseif isnan(gridData(i,j))
            colorMatrix(i,j,:)=[0.7 0.7 0.7]; %make nanchannels grey
        else
            temp=find(trueInputData<gridData(i,j));
            if isempty(temp)
                colorMatrix(i,j,:)=colorInputs(1,:);
            else
                colorMatrix(i,j,:)=colorInputs(length(temp)+1,:);
            end
        end
    end
    
end

if dontMakeFigure ==0
    currentFig = figure;
    imagesc(colorMatrix);
    h = gca;
    h.XTick = [];
    h.YTick = [];
    f = gcf;
    f.Position = [834 1 795 973];
    cc=colorbar;
    if colorPref <= 2
        colormap(h, flipud(colorScheme));
    else
        colormap(h, colorScheme);
    end
    cc.Ticks=[0 1];
    cc.TickLabels=[min(inputData), max(inputData)];
    
    gridIndicies = info.gridIndicies;
    
    for x=1:size(gridIndicies,1)
        for y=1:size(gridIndicies,2)
            if gridIndicies(x,y)== 0
                continue
            else
                t= text(y, x, num2str(gridIndicies(x,y)), 'HorizontalAlignment', 'center', 'FontSize', 14, 'Color', 'w');
            end
        end
    end
end
    
end

 

