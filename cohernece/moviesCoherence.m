%% Making movie heat plot of ITPC

%% Make movie of mean signal at 30-40 Hz for all experiments
clear

dirIn1 = '/data/adeeti/ecog/iso_awake_VEPs/';
dirIn2 = '/data/adeeti/ecog/iso_awake_VEPs/FiltData/';
dirOut = '/data/adeeti/ecog/images/Iso_Awake_VEPs/coher35MoviesOutlines/';
identifier = '2017*.mat';

%trial = 50;
fr = 35;
start = 900; %time before in ms
endTime = 1500; %time after in ms
screensize=get(groot, 'Screensize');
movieOutput = [];

use_Polarity = 0; %1 if using polarity, 0 if not

bregmaOffsetX = 1; % pos is L of bregma and neg is R of bregma
bregmaOffsetY = 1; % pos is P to bregma and neg is A of bregma

darknessOutline = 80; %0 = no outline, 255 is max for black outlines, 80 is good middle ground

%% setting up outline
outline = imread('/home/adeeti/Dropbox/MouseBrainAreas.png');

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

cd(dirIn1)
load('dataMatrixFlashes.mat')

cd(dirIn2)
mkdir(dirOut);
allData = dir(identifier);



%% finding experiments with the same characteristics

expLabel =unique(vertcat(dataMatrixFlashes(:).exp));
intPulse = unique(vertcat(dataMatrixFlashes(:).IntensityPulse));
durationPulse = unique(vertcat(dataMatrixFlashes(:).LengthPulse));
isoLevel = unique(vertcat(dataMatrixFlashes(:).AnesLevel));

for exp = 1:length(expLabel)
    for int = 1:length(intPulse)
        for dur = 1:length(durationPulse)
            compExp = find([dataMatrixFlashes.exp] == expLabel(exp) & [dataMatrixFlashes.IntensityPulse] == intPulse(int) & [dataMatrixFlashes.LengthPulse] == durationPulse(dur));
            
            %disp(['exp: ' num2str(expLabel(exp)) 'int: ' num2str(intPulse(int)) 'dur: ' num2str(durationPulse(dur)) ]);
            
            for t = 1:length(compExp)
                temp = dataMatrixFlashes(compExp(t)).name;
                compIso{exp, int, dur, t} = [temp(length(temp)-22:end-4), 'wave.mat'];
            end
            
        end
    end
end

%%


% to make an average of signal at coherent bands

for exp = 1:length(expLabel)
    for int = 1:length(intPulse)
        for dur = 1:length(durationPulse)
            close all;
            
            disp(['Exp: ', num2str(expLabel(exp)), ' int: ', num2str(intPulse(int)), ' dur: ', num2str(durationPulse(dur))]);
            plotIndex = 0;
            validExperiments = findMyExp(dataMatrixFlashes, expLabel(exp), [],  intPulse(int), durationPulse(dur));
            numExp = length(validExperiments);
            if numExp ==0
                numExp = 1;
            end
            
            for drugCon = 1:size(compIso, 4)
                if ~exist(compIso{exp, int, dur, drugCon})
                    continue
                end
                plotIndex = plotIndex+1;
                load(compIso{exp, int, dur, drugCon}, ['filtSig', num2str(fr)], 'info')
                eval(['sig = squeeze(mean(filtSig', num2str(fr), ',3));']);
                m = mean(sig(1:1000,:),1);
                s = std(sig(1:1000,:),1);
                ztransform=(m-sig)./s;
                filtSig(drugCon,:,:) = ztransform;
                isoCon(drugCon) = info.AnesLevel;
                if isfield(info, 'polarity')
                    polString{drugCon} = info.polarity;
                end
            end
            
            if plotIndex
                counter = 1;
                clear movieOutput
                if numExp == 1
                    f = figure('Position', [834 1 795 973]); clf;
                else
                    f = figure('Position', screensize); clf;
                end
                
                xGridAxis = fliplr(linspace(0, 2.75, 10+1));
                yGridAxis = linspace(0, 5, 20+1);
                lowerCax = min(filtSig(:));
                upperCax = max(filtSig(:));
                
                for t = start:endTime %time before in ms:size(meanSubData,3)
                    for drugCon = 1:numExp
                        g(drugCon)=subplot(1,numExp,drugCon);
                        plotHandle= plotOnGridInterp(squeeze(filtSig(drugCon, t,:)), 1, info.gridIndicies);
                        caxis([lowerCax,upperCax]);
                        g(drugCon).XTickMode = 'Manual';
                        g(drugCon).YTickMode = 'Manual';
                        g(drugCon).YTick = linspace(1,1100, 20+1);
                        g(drugCon).XTick = linspace(1,600, 10+1);
                        g(drugCon).XTickLabel = xGridAxis;
                        g(drugCon).YTickLabel = yGridAxis;
                        colorbar
                        c = colorbar;
                        c.Label.String = 'z threshold voltages from baseline';
                       
                        if use_Polarity
                        title(['Iso ', num2str(isoCon(drugCon)), '%, Polarity: ', polString{drugCon}])
                        else
                        %title(['Prop ', num2str(isoCon(drugCon)), 'ug/g'])
                        title(['Iso ', num2str(isoCon(drugCon)), '%'])
                        end
                        
                        ylabel('Ant-Post Distance in mm')
                        xlabel('Med-Lat Distance in mm')
                        
                        hold on;
                        a1 = axes;
                        a1.Position = g(drugCon).Position;
                        h = imshow(outline);
                        set(h, 'AlphaData', alpha);
                        xlim(overlayWindow(1,:));
                        ylim(overlayWindow(2,:));
                        overlayAspectRatio = (overlayWindow(1,2) - overlayWindow(1,1))/(overlayWindow(2,2) - overlayWindow(2,1));
                        dataAspectRatio = g(drugCon).PlotBoxAspectRatio(1) / g(drugCon).PlotBoxAspectRatio(2);
                        a1.DataAspectRatioMode = 'manual';
                        a1.DataAspectRatio = [overlayAspectRatio/dataAspectRatio, 1, 1];
                        
                    end
                    suptitle({['Mouse ID: ', num2str(expLabel(exp)), ' int: ', num2str(intPulse(int)), ' dur: ', num2str(durationPulse(dur))], ['Time: ', num2str(t-1000), ' msec']})
                    drawnow
                    movieOutput(counter) = getframe(gcf);
                    counter = counter +1;
                end
                
                v = VideoWriter([dirOut, 'Exp', num2str(expLabel(exp)), 'int', num2str(intPulse(int)), 'dur', num2str(durationPulse(dur)) '.avi']);
                open(v)
                writeVideo(v,movieOutput)
                close(v)
                close(f)
            end
            
        end
    end
end
