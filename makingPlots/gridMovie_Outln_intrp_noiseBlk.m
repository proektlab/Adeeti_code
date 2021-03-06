function [movieOutput] = gridMovie_Outln_intrp_noiseBlk(data, info, start, endTime, ...
      plotTitles, superTitle, colorTitle, colorScale, darknessOutline, dropboxLocation, ...
      interpBy, noiseBlack, electrode1, electrode2)
% [movieOutput] = gridMovie_Outln_intrp_noiseBlk(data, info, start, endTime, ...
%      plotTitles, superTitle, colorTitle, colorScale, darknessOutline, dropboxLocation, ...
%      interpBy, noiseBlack, electrode1, electrode2)
% compares movies with interpolation to movies without interpolation
% creates movie output from data, start, endTime, and adds on the outlines
% data has to be full data for the plot, (numPlots, time, channel)
% start time has to be in ms from start of trace as first time point,
% default is 900
% endTime is the timepoint that will finish plotting - defualt is 1300
% bregmaOffsetX and bregmaOffsetY can be taken from info files, should be
% in mm
% darknessOutline is in 0-255 scale, defualt is 80
% dropbox location si the location of the path towards dropbox, default is
% from lab workstation '/data/adeeti/Dropbox/'
% 8/14/18 AA
% 10/01/18 AA editted to make larger font

%% Presets

if nargin < 14
    electrode2 = [];
end

if nargin <13
    electrode1 = [];
end

if nargin < 12
    noiseBlack = [0,1];
end

if nargin <11
    interpBy = [100,1];
end

if nargin <10
    if isunix && ~ismac
        dropboxLocation = '/synology/code/Adeeti_code/';
    elseif ispc
        dropboxLocation = 'C:\Users\adeeti\Dropbox\ProektLab_code\Adeeti_code\';
    end
end

if nargin <9
    darknessOutline = 80; %0 = no outline, 255 is max for black outlines, 80 is good middle ground
end
if nargin <8
    colorScale = []; %[] is auto for all the scale
end

if nargin <7
    colorTitle = [];
end
if nargin <6
    superTitle = [];
end
if nargin <5
    plotTitles = [];
end
if nargin <3
    endTime = 1300;
    start = 900;
end

screensize=get(groot, 'Screensize');
%% setting up outline

outline = imread([dropboxLocation, 'MouseBrainAreas.png']);

if isfield(info, 'mmInGrid')
    mmInGridX = info.mmInGrid(1);
    mmInGridY = info.mmInGrid(2);
else
    mmInGridX = 2.75;
    mmInGridY = 5;
end

if isfield(info, 'bregmaOffsetX')
    bregmaOffsetX = info.bregmaOffsetX;
else
    bregmaOffsetX = 0.5;
end

if isfield(info, 'bregmaOffsetY')
    bregmaOffsetY = info.bregmaOffsetY;
else
    bregmaOffsetY = 0.5;
end


PIXEL_TO_MM = (2254 - 503)/2;

BREGMA_PIXEL_X = 5520;
BREGMA_PIXEL_Y = 3147;

bregmaOffsetPixelX = bregmaOffsetX * PIXEL_TO_MM;
bregmaOffsetPixelY = bregmaOffsetY * PIXEL_TO_MM;
overlayWindow = [[0 round(mmInGridX*PIXEL_TO_MM)]; [0 round(mmInGridY*PIXEL_TO_MM)]];
overlayWindow(1,:) = overlayWindow(1,:) - round(mmInGridX*PIXEL_TO_MM) + BREGMA_PIXEL_X - bregmaOffsetPixelX;
overlayWindow(2,:) = overlayWindow(2,:) + BREGMA_PIXEL_Y + bregmaOffsetPixelY;

outline = imgaussfilt(outline, 4);
alpha = outline(:,:,1) / max(max(outline(:,:,1))) * darknessOutline;

%% making movieOutput
gridIndicies = info.gridIndicies;
gridRows= size(gridIndicies,1);
gridCols= size(gridIndicies,2);

counter = 1;
clear movieOutput

if size(data,1) == 1
    f = figure('Position', [517,1,1669,973], 'color', 'w'); clf;
else
    f = figure('Position', screensize, 'color', 'w'); clf;
end

xGridAxis = fliplr(linspace(0, mmInGridX, gridCols));
yGridAxis = linspace(0, mmInGridY, gridRows);
lowerCax = min(data(:));
upperCax = max(data(:));

for t = start:endTime %time before in ms:size(meanSubData,3)
    for d = 1:size(data, 1)
        %% plot interpolated data j = 1, and non interpolated data j =2
        for j = 1:2
            if j == 1
                g(2*d-1)=subplot(1,size(data, 1)*2,2*d-1);
            elseif j ==2
                g(2*d)=subplot(1,size(data, 1)*2,2*d);
            end
            
            plotHandle= plotOnGridInterp(squeeze(data(d, t,:)), 1, gridIndicies, interpBy(j), noiseBlack(j));
            if isempty(colorScale)
                caxis([lowerCax,upperCax]);
            else
                caxis(colorScale);
            end
            
            g(d).XTickMode = 'Manual';
            g(d).YTickMode = 'Manual';
            g(d).YTick = linspace(1,gridRows*interpBy(1), gridRows);
            g(d).XTick = linspace(1,gridCols*interpBy(1), gridCols);
            g(d).XTickLabel = xGridAxis;
            g(d).YTickLabel = yGridAxis;
            set(gca, 'FontSize',22)
            colorbar
            c = colorbar;
            if ~isempty(colorTitle)
                c.Label.String = colorTitle;
                c.Label.FontSize = 22;
            end
            
            if ~isempty(plotTitles)
                if j ==1
                    title([plotTitles{d}, 'interp by ', num2str(interpBy(j))], 'FontSize', 22)
                elseif j ==2
                    title([plotTitles{d}], 'FontSize', 22)
                end
            end
            
            ylabel('Ant-Post Distance in mm', 'FontSize', 22)
            xlabel('Med-Lat Distance in mm', 'FontSize', 22)
            
            if ~isempty(electrode1)
                hold on
                [x1, y1] = ind2sub(size(gridIndicies), find(gridIndicies ==electrode1));
                [xCircle1, yCircle1] = plotCircle(x1*100, y1*100, 50);
                plot(yCircle1, xCircle1, '--', 'Color', 'b', 'linewidth', 2)
            end
            if ~isempty(electrode2)
                hold on
                [x2, y2] = ind2sub(size(gridIndicies), find(gridIndicies ==electrode2));
                [xCircle2, yCircle2] = plotCircle(x2*100, y2*100, 50);
                plot(yCircle2, xCircle2, '--', 'Color', 'r', 'linewidth', 2)
            end
            
            hold on;
            a1 = axes;
            a1.Position = g(d).Position;
            h = imshow(outline);
            set(h, 'AlphaData', alpha);
            xlim(overlayWindow(1,:));
            ylim(overlayWindow(2,:));
            overlayAspectRatio = (overlayWindow(1,2) - overlayWindow(1,1))/(overlayWindow(2,2) - overlayWindow(2,1));
            dataAspectRatio = g(d).PlotBoxAspectRatio(1) / g(d).PlotBoxAspectRatio(2);
            a1.DataAspectRatioMode = 'manual';
            a1.DataAspectRatio = [overlayAspectRatio/dataAspectRatio, 1, 1];
        end
        
    end
    if ~isempty(superTitle)
        s = sgtitle({superTitle, ['Time: ', num2str(t-1000), ' ms']});
        set(s, 'FontSize', 30, 'FontWeight','bold')
    else
        s = sgtitle(['Time: ', num2str(t-1000), ' msec']);
        set(s, 'FontSize', 30, 'FontWeight','bold')
    end
    drawnow
    
    movieOutput(counter) = getframe(gcf);
    counter = counter +1;
end

