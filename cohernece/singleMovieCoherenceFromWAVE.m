function [movieOutput, filtSigFr] = singleMovieCoherenceFromWAVE(info, filtSigFr, dropboxLocation, start, endTime)
%% Single Movie Coherence
%[movieOutput, filtSigFr] = singleMovieCoherenceFromWAVE(WAVE, info, fr, dropboxLocation, start, endTime)
% to be added into code for semi online processing mainly
% 09/20/19 AA


if nargin < 5
    endTime = 1300; %time after in ms
end
if nargin < 4
    start = 900; %time before in ms
end
if nargin < 3
    dropboxLocation = 'C:\Users\Plexon\Google Drive\NEURA_codeShare\Adeeti_code\';
end

%%

screensize=get(groot, 'Screensize');
movieOutput = [];

use_Polarity = 0; %1 if using polarity, 0 if not

bregmaOffsetX = info.bregmaOffsetX; % pos is L of bregma and neg is R of bregma
bregmaOffsetY = info.bregmaOffsetY; % pos is P to bregma and neg is A of bregma

darknessOutline = 80; %0 = no outline, 255 is max for black outlines, 80 is good middle ground

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

%%
% to make an average of signal at coherent bands

close all;

disp('Generating coherence movie');

sig = squeeze(mean(filtSigFr,3));
m = mean(sig(1:1000,:),1);
s = std(sig(1:1000,:),1);
ztransform=(repmat(m, 2001, 1)-sig)./repmat(s, 2001, 1);
filtSig = ztransform;

clear movieOutput

f = figure('Position', [672 50 609 655], 'Color', 'w'); clf;

xGridAxis = fliplr(linspace(0, 2.75, 5+1));
yGridAxis = linspace(0, 5, 10+1);
lowerCax = min(filtSig(:));
upperCax = max(filtSig(:));
counter = 1;

for t = start:endTime %time before in ms:size(meanSubData,3)
        g=subplot(1,1,1);
        plotHandle= plotOnGridInterp(squeeze(filtSig(t,:)), 1, info.gridIndicies);
        caxis([lowerCax,upperCax]);
        g.XTickMode = 'Manual';
        g.YTickMode = 'Manual';
        g.YTick = linspace(1,1100, 10+1);
        g.XTick = linspace(1,600, 5+1);
        g.XTickLabel = xGridAxis;
        g.YTickLabel = yGridAxis;
        set(gca, 'FontSize',22)
        colorbar
        c = colorbar;
        c.Label.String = 'z threshold voltages from baseline';
        c.Label.FontSize = 22;
        ylabel('Ant-Post Distance in mm', 'FontSize', 22)
        xlabel('Med-Lat Distance in mm', 'FontSize', 22)
        
        hold on;
        a1 = axes;
        a1.Position = g.Position;
        h = imshow(outline);
        set(h, 'AlphaData', alpha);
        xlim(overlayWindow(1,:));
        ylim(overlayWindow(2,:));
        overlayAspectRatio = (overlayWindow(1,2) - overlayWindow(1,1))/(overlayWindow(2,2) - overlayWindow(2,1));
        dataAspectRatio = g.PlotBoxAspectRatio(1) / g.PlotBoxAspectRatio(2);
        a1.DataAspectRatioMode = 'manual';
        a1.DataAspectRatio = [overlayAspectRatio/dataAspectRatio, 1, 1];
        
    s= suptitle(['Time: ', num2str(t-1000), ' msec']);
    set(s, 'FontSize', 30, 'FontWeight','bold')
    drawnow
    movieOutput(counter) = getframe(gcf);
    counter = counter +1;
end

end

