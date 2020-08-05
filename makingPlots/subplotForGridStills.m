function [g] = subplotForGridStills(d, t, data, gridIndicies, subPlotSize, bregX, bregY, plotTitles, colorScale, colorTitle, fontSize)



%%
if isunix
    outlineLoc = '/synology/code/Adeeti_code/';
elseif ispc
    outlineLoc = 'Z:\code\Adeeti_code\';
end
%%
interpBy = 100;
noiseBlack = 0;
darknessOutline = 80;

outline = imread([outlineLoc, 'MouseBrainAreas.png']);

mmInGridX = 2.75;
mmInGridY = 5;

PIXEL_TO_MM = (2254 - 503)/2;

BREGMA_PIXEL_X = 5520;
BREGMA_PIXEL_Y = 3147;

bregmaOffsetPixelX = bregX * PIXEL_TO_MM;
bregmaOffsetPixelY = bregY * PIXEL_TO_MM;
overlayWindow = [[0 round(mmInGridX*PIXEL_TO_MM)]; [0 round(mmInGridY*PIXEL_TO_MM)]];
overlayWindow(1,:) = overlayWindow(1,:) - round(mmInGridX*PIXEL_TO_MM) + BREGMA_PIXEL_X - bregmaOffsetPixelX;
overlayWindow(2,:) = overlayWindow(2,:) + BREGMA_PIXEL_Y + bregmaOffsetPixelY;

outline = imgaussfilt(outline, 4);
alpha = outline(:,:,1) / max(max(outline(:,:,1))) * darknessOutline;

%%
xGridAxis = fliplr(linspace(0, 2.75, 5+1));
yGridAxis = linspace(0, 5, 10+1);
lowerCax = min(data(:));
upperCax = max(data(:));

%%
g(d)=subplot(subPlotSize(1),subPlotSize(2),d);
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
set(gca, 'FontSize',fontSize)
colorbar
c = colorbar;
if ~isempty(colorTitle)
    c.Label.String = colorTitle;
    c.Label.FontSize = fontSize;
end

if ~isempty(plotTitles)
    title([plotTitles], 'FontSize', fontSize)
end

ylabel('Ant-Post Distance in mm', 'FontSize', fontSize)
xlabel('Med-Lat Distance in mm', 'FontSize', fontSize)

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

