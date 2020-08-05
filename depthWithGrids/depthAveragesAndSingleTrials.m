%% Laminar single trials and averages
% 12/02/18 AA

%% Load data

%close all
clear

% if on Adeeti's laptop
dirIn = '/Users/adeetiaggarwal/Google Drive/NEURA_codeShare/Adeeti_code/1x2Shank_with_ECoG/';
dirOut = '/Users/adeetiaggarwal/Dropbox/';

% if on Alex's workstation
% dirIn = '/home/adeeti/GoogleDrive/NEURA_codeShare/Adeeti_code/1x2Shank_with_ECoG/';
% dirOut = '/data/adeeti/ecog/images/flashes_depth_ECoG_2018/CSD_simple/';
% dirGoogleDrive = '/home/adeeti/GoogleDrive/misc_figures/';

% if ~exist(dirOut,'dir')
%     mkdir(dirOut)
% end
%
% if ~exist(dirGoogleDrive,'dir')
%     mkdir(dirGoogleDrive)
% end

addpath(genpath(dirIn));

cd(dirIn)
identifier = '2018*';
allData = dir(identifier);

load('dataMatrixFlashes.mat')
load('matStimIndex.mat')


%for experiment = 1:length(allData);
experiment = 7
dirName = allData(experiment).name;

load(dirName, 'info', 'meanSubData', 'aveTrace', 'finalTime', 'finalSampR')

%extract only the laminar data and sort it so that most superficial
%channels are in the first row and deeper channels are in the later rows

forkIndicies = info.forkIndicies;
depthOnlyAllTrials = nan(2, 16, size(meanSubData, 2), size(meanSubData, 3));
depthOnlyAverages = nan(2, 16, size(aveTrace,3));

for i = 1:size(forkIndicies, 2)
    for j = 1:size(forkIndicies, 1)
        channelIndex = forkIndicies(j, i);
        depthOnlyAllTrials(i, j ,:,:) = squeeze(meanSubData(channelIndex, :,:));
        depthOnlyAverages(i, j,:) = squeeze(aveTrace(1, channelIndex,:));
        disp(num2str(channelIndex))
    end
end


%% Making figure of the averages

screensize=get(groot, 'Screensize');
ff = figure('Position', screensize, 'color', 'w'); clf;
%ff.Renderer='Painters';
clf

plotTimeLFP = [1000:1300];
plotTimeEarlyCSD = [1020:1060];
plotTimeLateCSD = [1060:1250];

LFPshift = -0.2;

for plotCount = 1:3*size(depthOnlyAverages, 1)
    if plotCount == 1||plotCount == 4
        h(plotCount) = subplot(1, 6, plotCount);
        timeAxis = linspace(-1+plotTimeLFP(1)*(1/finalSampR), -1+plotTimeLFP(end)*(1/finalSampR), numel(plotTimeLFP));
        i = ceil(plotCount/2);
        for j = 1:size(depthOnlyAverages, 2)
            shiftCount = j-1;
            if j == 1
                plot(timeAxis, squeeze(depthOnlyAverages(i, j,plotTimeLFP)))
                %set(gca, 'ylim', [min(depthOnlyAverages(:)), max(depthOnlyAverages(:))])
                set(gca, 'xlim', [timeAxis(1), timeAxis(end)])
                ylabel('Depth (mm)')
                
                h(plotCount).YTickLabel = [-800, -700, -600, -500, -400, -300, -200, -100, 0];
                hold on
                if plotCount ==1
                    title('Posteior Shank Average LFP')
                elseif plotCount ==3
                    title('Anterior Shank Average LFP')
                end
                if plotCount == 1
                    hold on
                    line([0.05 0.05], [-3.25 -3.35], 'LineWidth', 2, 'Color', 'k'); % vertical line
                    line([.05 0.1], [-3.35 -3.35], 'LineWidth', 2, 'Color', 'k'); % horizontal line
                    
                    tt=text(0, -3.3, '0.1 mV', 'FontName', 'Arial', 'FontSize', 12);
                    tt2=text(.075, -3.40, '50 ms', 'FontName', 'Arial', 'FontSize', 12);
                end
            else
                plotData = squeeze(depthOnlyAverages(i, j,plotTimeLFP))+(LFPshift*shiftCount);
                plot(timeAxis, plotData)
                %set(gca, 'ylim', [min(depthOnlyAverages(:)), max(depthOnlyAverages(:))])
                hold on
            end
        end
    elseif plotCount ==2 ||plotCount ==5
        i = floor(plotCount/2);
        LFPinput = squeeze(depthOnlyAverages(i,:,plotTimeEarlyCSD)); %in mV
        timeAxis = linspace(-1+plotTimeEarlyCSD(1)*(1/finalSampR), -1+plotTimeEarlyCSD(end)*(1/finalSampR), numel(plotTimeEarlyCSD));
        spacing = 50/1000; %in mm
        [CSDOutput] = CSDsimple_1D_AA(LFPinput, spacing);
        h(plotCount) = subplot(1, 6, plotCount);
        pcolor(timeAxis, flipud([3:14]') ,flipud(CSDOutput(3:14,:))); shading 'interp'
        colormap('jet')
        xlabel('Time (s)')
        %h(plotCount).YTickMode = 'Manual';
        %h(plotCount).YTick = linspace(1,1400, 5);
        %h(plotCount).YTickLabel = [ -600, -500, -400, -300, -200];
        ylabel('Depth (mm)')
        c = colorbar;
        c.Label.String = 'CSD in mV/mm^{2}';
        if plotCount ==2
            title('V1 20-60 ms CSD')
        elseif plotCount ==5
            title('0.5 mm Rostral to V1 60-250 ms CSD')
        end
    elseif plotCount ==3 ||plotCount ==6
        i = floor(plotCount/3);
        timeAxis = linspace(-1+plotTimeLateCSD(1)*(1/finalSampR), -1+plotTimeLateCSD(end)*(1/finalSampR), numel(plotTimeLateCSD));
        LFPinput = squeeze(depthOnlyAverages(i,:,plotTimeLateCSD)); %in mV
        spacing = 50/1000; %in mm
        [CSDOutput] = CSDsimple_1D_AA(LFPinput, spacing);
        h(plotCount) = subplot(1, 6, plotCount);
        pcolor(timeAxis, flipud([3:14]') ,flipud(CSDOutput(3:14,:))); shading 'interp'
        colormap('jet')
        xlabel('Time (s)')
        %h(plotCount).YTickMode = 'Manual';
        %h(plotCount).YTick = linspace(1,1400, 5);
        %h(plotCount).YTickLabel = [ -600, -500, -400, -300, -200];
        ylabel('Depth (mm)')
        c = colorbar;
        c.Label.String = 'CSD in mV/mm^{2}';
        if plotCount ==3
            title('V1 60-250 ms CSD')
        elseif plotCount ==6
            title('0.5 mm Rostral to V1 60-250 ms CSD')
        end
    end
end

suptitle(['Mouse #', num2str(info.exp)])

%saveas(ff, [dirOut1, 'exp', info.expName(1:end-7), 'CSD', num2str(plotTime(1)), '_', num2str(plotTime(end)), '.pdf'])
%end
%saveas(ff, [dirGoogleDrive, 'IsoPropITPC', '.pdf'])
%% looking at the CSD maybe

% LFPinput = squeeze(depthOnlyAverages(1,:,plotTime)); %in V
%
% spacing = 50/1000; %in mm
%
% diameter = 177/1000000;
%
% [csdOut] = CSD(useData, finalSampR, spacing);
%
% [CSDOutput] = CSDsimple_1D_AA(LFPinput, spacing);
%
% imagesc(CSDOutput)
% pcolor(timeAxis, flipud([1:14]') ,flipud(CSDOutput(3:14,:))); shading 'flat'
%
% figure
% pcolor(timeAxis, flipud([3:14]') ,flipud(CSDOutput(3:14,:))); shading 'flat'
% colormap('jet')
% colorbar


%%

screensize=get(groot, 'Screensize');
ff = figure('Position', screensize, 'color', 'w'); clf;
%ff.Renderer='Painters';
clf

plotTimeLFP = [1000:1300];
plotTimeEarlyCSD = [1020:1060];
plotTimeLateCSD = [1200:1300];

LFPshift = -0.2;

for plotCount = 1:4
    if plotCount == 1
        h(plotCount) = subplot(1, 4, plotCount);
        timeAxis = linspace(-1+plotTimeLFP(1)*(1/finalSampR), -1+plotTimeLFP(end)*(1/finalSampR), numel(plotTimeLFP));
        i = 1;
        for j = 1:size(depthOnlyAverages, 2)
            shiftCount = j-1;
            if j == 1
                plot(timeAxis, squeeze(depthOnlyAverages(i, j,plotTimeLFP)))
                %set(gca, 'ylim', [min(depthOnlyAverages(:)), max(depthOnlyAverages(:))])
                set(gca, 'xlim', [timeAxis(1), timeAxis(end)])
                ylabel('Depth (mm)')
                
                h(plotCount).YTickLabel = [-800, -700, -600, -500, -400, -300, -200, -100, 0];
                hold on
                if plotCount ==1
                    title('V1 Average LFP')
                elseif plotCount ==3
                    title('0.5 mm Rostral of V1 Average LFP')
                end
                if plotCount == 1
                    hold on
                    line([0.05 0.05], [-3.25 -3.35], 'LineWidth', 2, 'Color', 'k'); % vertical line
                    line([.05 0.1], [-3.35 -3.35], 'LineWidth', 2, 'Color', 'k'); % horizontal line
                    
                    tt=text(0, -3.3, '0.1 mV', 'FontName', 'Arial', 'FontSize', 12);
                    tt2=text(.075, -3.40, '50 ms', 'FontName', 'Arial', 'FontSize', 12);
                end
            else
                plotData = squeeze(depthOnlyAverages(i, j,plotTimeLFP))+(LFPshift*shiftCount);
                plot(timeAxis, plotData)
                %set(gca, 'ylim', [min(depthOnlyAverages(:)), max(depthOnlyAverages(:))])
                hold on
            end
        end
    elseif plotCount ==2
        i = 1
        LFPinput = squeeze(depthOnlyAverages(i,:,plotTimeEarlyCSD)); %in mV
        timeAxis = linspace(-1+plotTimeEarlyCSD(1)*(1/finalSampR), -1+plotTimeEarlyCSD(end)*(1/finalSampR), numel(plotTimeEarlyCSD));
        spacing = 50/1000; %in mm
        [CSDOutput] = CSDsimple_1D_AA(LFPinput, spacing);
        h(plotCount) = subplot(1, 4, plotCount);
        pcolor(timeAxis, flipud([3:14]') ,flipud(CSDOutput(3:14,:))); shading 'interp'
        colormap('jet')
        xlabel('Time (s)')
        %h(plotCount).YTickMode = 'Manual';
        %h(plotCount).YTick = linspace(1,1400, 5);
        %h(plotCount).YTickLabel = [ -600, -500, -400, -300, -200];
        ylabel('Depth (mm)')
        c = colorbar;
        c.Label.String = 'CSD in mV/mm^{2}';
        if plotCount ==2
            title(['V1 ', num2str(plotTimeEarlyCSD(1)-1000), '-', num2str(plotTimeEarlyCSD(end)-1000), ' ms CSD'])
        elseif plotCount ==5
            title(['0.5 mm Rostral to V1 ', num2str(plotTimeEarlyCSD(1)-1000), '-', num2str(plotTimeEarlyCSD(end)-1000), ' ms CSD'])
        end
    elseif plotCount ==3 
        i = 1
        timeAxis = linspace(-1+plotTimeLateCSD(1)*(1/finalSampR), -1+plotTimeLateCSD(end)*(1/finalSampR), numel(plotTimeLateCSD));
        LFPinput = squeeze(depthOnlyAverages(i,:,plotTimeLateCSD)); %in mV
        spacing = 50/1000; %in mm
        [CSDOutput] = CSDsimple_1D_AA(LFPinput, spacing);
        h(plotCount) = subplot(1, 4, plotCount);
        pcolor(timeAxis, flipud([3:14]') ,flipud(CSDOutput(3:14,:))); shading 'interp'
        colormap('jet')
        xlabel('Time (s)')
        %h(plotCount).YTickMode = 'Manual';
        %h(plotCount).YTick = linspace(1,1400, 5);
        %h(plotCount).YTickLabel = [ -600, -500, -400, -300, -200];
        ylabel('Depth (mm)')
        c = colorbar;
        set(gca, 'clim', [-10,10])
        c.Label.String = 'CSD in mV/mm^{2}';
        if plotCount ==3
            title(['V1 ', num2str(plotTimeLateCSD(1)-1000), '-', num2str(plotTimeLateCSD(end)-1000), 'ms CSD'])
        elseif plotCount ==4
            title(['0.5 mm Rostral to V1 ', num2str(plotTimeLateCSD(1)-1000), '-', num2str(plotTimeLateCSD(end)-1000), ' ms CSD'])
        end
     elseif plotCount ==4
        i = 2
        timeAxis = linspace(-1+plotTimeLateCSD(1)*(1/finalSampR), -1+plotTimeLateCSD(end)*(1/finalSampR), numel(plotTimeLateCSD));
        LFPinput = squeeze(depthOnlyAverages(i,:,plotTimeLateCSD)); %in mV
        spacing = 50/1000; %in mm
        [CSDOutput] = CSDsimple_1D_AA(LFPinput, spacing);
        h(plotCount) = subplot(1, 4, plotCount);
        pcolor(timeAxis, flipud([3:14]') ,flipud(CSDOutput(3:14,:))); shading 'interp'
        colormap('jet')
        xlabel('Time (s)')
        %h(plotCount).YTickMode = 'Manual';
        %h(plotCount).YTick = linspace(1,1400, 5);
        %h(plotCount).YTickLabel = [ -600, -500, -400, -300, -200];
        ylabel('Depth (mm)')
        c = colorbar;
        set(gca, 'clim', [-10,10])
        c.Label.String = 'CSD in mV/mm^{2}';
        if plotCount ==3
            title(['V1 ', num2str(plotTimeLateCSD(1)-1000), '-', num2str(plotTimeLateCSD(end)-1000), ' ms CSD'])
        elseif plotCount ==4
            title(['0.5 mm Rostral to V1 ', num2str(plotTimeLateCSD(1)-1000), '-', num2str(plotTimeLateCSD(end)-1000), ' ms CSD'])
        end
    end
end

suptitle(['Mouse #', num2str(info.exp)])
