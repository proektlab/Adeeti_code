%% Making movie heat plot of ITPC

%% Make movie of mean signal at 30-40 Hz for all experiments
clear

experiment = '2017-02-28_18-16-48wave.mat';

onAlexsWorkStation = 1; %1 if on workstation with complete multistim data set, 0 if on lab mac, 2 if on laptop

if onAlexsWorkStation ==1
    % Alex's computer
    dirIn = '/data/adeeti/ecog/matFlashesJanMar2017/Wavelets/FiltData/';
    dropboxLocation = '/home/adeeti/Dropbox/KelzLab/';
    dirOut = dropboxLocation;
elseif onAlexsWorkStation ==0
    % Adeeti's Desktop
elseif onAlexsWorkStation ==2
    % Adeeti's Laptop
    dropboxLocation = '/Users/adeetiaggarwal/Dropbox/KelzLab/';
    dirIn = [ dropboxLocation, 'playingData/'];
    dirOut = '/Users/adeetiaggarwal/Dropbox/KelzLab/';
end


%trial = 50;
fr = 35;
start = 900; %time before in ms
endTime = 1300; %time after in ms
screensize=get(groot, 'Screensize');
movieOutput = [];

use_Polarity = 0; %1 if using polarity, 0 if not

bregmaOffsetX = 0.5; % pos is L of bregma and neg is R of bregma
bregmaOffsetY = 0.5; % pos is P to bregma and neg is A of bregma

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
cd(dirIn)
mkdir(dirOut);

%% to make an average of signal at coherent bands

load(experiment, ['filtSig', num2str(fr)], 'info')
eval(['sig = squeeze(mean(filtSig', num2str(fr), ',3));']);
m = repmat(mean(sig(1:1000,:),1), [size(sig,1), 1]);
s = repmat(std(sig(1:1000,:),1), [size(sig,1), 1]);
ztransform=(m-sig)./s;
filtSig = ztransform;
filtSig = permute(filtSig, [3, 1,2]);

clear movieOutput

%create labels
plotTitles{1} = 'Coherent gamma';
superTitle = [num2str(info.AnesLevel), '% Isoflurane'];
colorTitle = ['z-threshold voltage'];
gridIndicies = info.gridIndicies;

[movieOutput] = makeMoviesWithOutlinesFunc(filtSig, start, endTime, bregmaOffsetX, bregmaOffsetY, gridIndicies, plotTitles, superTitle, colorTitle, [], darknessOutline, dropboxLocation);

v = VideoWriter([dirOut, 'gamma_coherence_withTiledPlot.avi']);
open(v)
writeVideo(v,movieOutput)
close(v) 


%% making tiles

% f = figure('Position', screensize); clf;
% 
% s(1) = subplot(2,4,1)
% imagesc(movieOutput(1).cdata)

%%

timeSteps = start+50:50:endTime+50;

f = figure('Position', [134 49 1147 656]); clf;
f.Color = [1,1,1];

xGridAxis = fliplr(linspace(0, 2.75, 10+1));
yGridAxis = linspace(0, 5, 20+1);
lowerCax = min(filtSig(:));
upperCax = max(filtSig(:));


for step = 1:8
        g(step)=subplot(2,4,step);
        plotHandle= plotOnGridInterp(squeeze(filtSig(timeSteps(step),:)), 1, info);
        caxis([lowerCax,upperCax]);
        g(step).XTickMode = 'Manual';
        g(step).YTickMode = 'Manual';
        g(step).YTick = linspace(1,1100, 20+1);
        g(step).XTick = linspace(1,600, 10+1);
        g(step).XTickLabel = xGridAxis;
        g(step).YTickLabel = yGridAxis;
        colorbar
            c = colorbar;
            c.Label.String = 'z threshold voltages from baseline';
        title(['Time: ', num2str(-(1000-timeSteps(step))), ' msec'])
        
        ylabel('Ant-Post Distance in mm')
        xlabel('Med-Lat Distance in mm')
        
        hold on;
        a1 = axes;
        a1.Position = g(step).Position;
        h = imshow(outline);
        set(h, 'AlphaData', alpha);
        xlim(overlayWindow(1,:));
        ylim(overlayWindow(2,:));
        overlayAspectRatio = (overlayWindow(1,2) - overlayWindow(1,1))/(overlayWindow(2,2) - overlayWindow(2,1));
        dataAspectRatio = g(step).PlotBoxAspectRatio(1) / g(step).PlotBoxAspectRatio(2);
        a1.DataAspectRatioMode = 'manual';
        a1.DataAspectRatio = [overlayAspectRatio/dataAspectRatio, 1, 1];      
end

