%% making butterfly plotz

genDir = '/Users/adeetiaggarwal/Dropbox/KelzLab/Playing_data/1x2Shank_with_ECoG/';

cd(genDir)
%'/synology/adeeti/ecog/iso_awake_VEPs/';
EpTime = 900:1400;

allData = dir('*.mat');

experimentID = 1;

load(allData(experimentID).name, 'info')

%% if want to fiter data at a particular freq band 
finalSampR = 1000;
filtbound = [30 40]; % Hz
trans_width = 0.2; % fraction of 1, thus 20%
filt_order = 50; %filt_order = round(3*(EEG.srate/filtbound(1)));

%dropboxLocation = 'C:\Users\Plexon\Google Drive\NEURA_codeShare\Adeeti_code\';

[filterweights] = buildBandPassFiltFunc_AA(finalSampR, filtbound, trans_width, filt_order);

%% 

titleLegend = {'Awake', 'High Isoflurane', 'Low Isoflurane'};
ff = figure;
ff.Renderer = 'Painters';
ff.Color = 'white';
clf
a = 1;
for b = 1:length(experimentID)
    load(dataMatrixFlashes(experimentID(b)).expName(end-22:end), 'meanSubData', 'aveTrace', 'info')
    
    h(b) = subplot(2,length(experimentID),b)
    plot(squeeze(meanSubData(info.lowLat,:,EpTime))', 'color', [0.8, 0.8, 0.8], 'LineWidth', 0.5);
    hold on 
    plot(squeeze(aveTrace(1,info.lowLat,EpTime)), 'k', 'linewidth', 2.5);
    line([100 100], [-0.7, 0.4], 'LineWidth', 2, 'Color', 'g');
    set(gca, 'ylim', [-0.7, 0.4])
    set(gca, 'xlim', [0, 500])
    axis off
    if b == 1
        line([10 10], [-0.5 -0.4], 'LineWidth', 2, 'Color', 'k'); % vertical line
        line([10 110], [-0.5 -0.5], 'LineWidth', 2, 'Color', 'k'); % horizontal line
        tt=text(5, -0.5, '100 uV', 'FontName', 'Arial', 'FontSize', 12); % vertical line
        tt2=text(50, -0.6, '100 ms', 'FontName', 'Arial', 'FontSize', 12); % horizontal line
    end
    
    
    filtered_data = zeros(size(meanSubData,2), size(meanSubData,3));
    for tr = 1:size(meanSubData,2)
        filtered_data(tr,:) = filtfilt(filterweights,1,squeeze(meanSubData(info.lowLat,tr,:)));
    end
    
    
    h(b+length(experimentID)) = subplot(2,length(experimentID),b+length(experimentID))
    plot(squeeze(filtered_data(:,EpTime))', 'color', [0.8, 0.8, 0.8], 'LineWidth', 0.5);
    hold on 
    plot(squeeze(nanmean(filtered_data(:,EpTime),1))', 'k', 'linewidth', 2.5);
    line([100 100], [-0.25, 0.25], 'LineWidth', 2, 'Color', 'g');
    set(gca, 'ylim', [-0.25, 0.25])
    set(gca, 'xlim', [0, 500])
    axis off
    if b == 1
        line([10 10], [-0.15 -0.1], 'LineWidth', 2, 'Color', 'k'); % vertical line
        line([10 110], [-0.15 -0.15], 'LineWidth', 2, 'Color', 'k'); % horizontal line
        tt=text(5, -0.15, '50 uV', 'FontName', 'Arial', 'FontSize', 12); % vertical line
        tt2=text(50, -0.16, '100 ms', 'FontName', 'Arial', 'FontSize', 12); % horizontal line
    end
    
    title(titleLegend{b})
end

suptitle(mouseID)