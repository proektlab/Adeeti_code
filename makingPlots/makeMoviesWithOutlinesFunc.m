function [movieOutput] = makeMoviesWithOutlinesFunc(data, start, endTime, bregmaOffsetX, bregmaOffsetY, gridIndicies, plotTitles, superTitle, colorTitle, colorScale, darknessOutline, dropboxLocation, interpBy, noiseBlack, electrode1, electrode2)
% [movieOutput] = makeMoviesWithOutlinesFunc(data, start, endTime,
% bregmaOffsetX, bregmaOffsetY, darknessOutline, dropboxLocation, interpBy, noiseBlack, electrode1, electrode2)
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

if nargin < 16
    electrode2 = [];
end

if nargin <15
    electrode1 = [];
end

if nargin < 14
    noiseBlack = 0;
end

if nargin <13
    interpBy = 100;
end

if nargin <12
    if isunix
        dropboxLocation = '/home/adeeti/Dropbox/ProektLab_code/Adeeti_code/'; 
    elseif ispc
        dropboxLocation = 'C:\Users\adeeti\Dropbox\ProektLab_code\Adeeti_code\';
    end
end

if nargin <11
    darknessOutline = 80; %0 = no outline, 255 is max for black outlines, 80 is good middle ground
end
if nargin <10
    colorScale = []; %[] is auto for all the scale 
end

if nargin <9
    colorTitle = [];
end
if nargin <8
    superTitle = [];
end
if nargin <7
    plotTitles = [];
end
if nargin <5
    bregmaOffsetX = 0.5;
    bregmaOffsetY = 0.5;
end
if nargin <3
    endTime = 1300;
    start = 900;
end

screensize=get(groot, 'Screensize');
%% setting up outline
outline = imread([dropboxLocation, 'MouseBrainAreas.png']);

mmInGridX = 2.75;
mmInGridY = 5;

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


counter = 1;
clear movieOutput
if size(data,1) == 1
    f = figure('Position', [789 -32 845 1003], 'color', 'w'); clf;
elseif size(data,1) == 2
    f = figure('Position', [517,1,1669,973], 'color', 'w'); clf;
else
    f = figure('Position', screensize, 'color', 'w'); clf;
end

xGridAxis = fliplr(linspace(0, 2.75, 5+1));
yGridAxis = linspace(0, 5, 10+1);
lowerCax = min(data(:));
upperCax = max(data(:));

for t = start:endTime %time before in ms:size(meanSubData,3)
    for d = 1:size(data, 1)
        g(d)=subplot(1,size(data, 1),d);
        plotHandle= plotOnGridInterp(squeeze(data(d, t,:)), 1, gridIndicies, interpBy, noiseBlack);
        if isempty(colorScale)
        caxis([lowerCax,upperCax]);
        else
            caxis(colorScale);
        end
        
        g(d).XTickMode = 'Manual';
        g(d).YTickMode = 'Manual';
        g(d).YTick = linspace(1,1100, 10+1);
        g(d).XTick = linspace(1,600, 5+1);
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
        title([plotTitles{d}], 'FontSize', 22)
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
    if ~isempty(superTitle)
        s = sgtitle({superTitle, ['Time: ', num2str(t-1000), ' ms']});
        set(s, 'FontSize', 30, 'FontWeight','bold')
    else 
        s = sgtitle(['Time: ', num2str(t-1000), ' msec']);
        set(s, 'FontSize', 30, 'FontWeight','bold')
    end
    drawnow
    pause(0.25)
    movieOutput(counter) = getframe(gcf);
    counter = counter +1;
end
end
