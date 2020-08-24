%% Baseline Normalized Wavelet based average of spectrograms
% 12/18/18 AA

clear
close all

dirIn = '/data/adeeti/ecog/matIsoPropMultiStim/';
dirPic1 = '/data/adeeti/ecog/images/IsoPropMultiStim/baselineNormAverageSpec/';
%dirOut = '/data/adeeti/ecog/matBaselineIsoPropMultiStim/Wavelets/';

identifier = '2018*.mat';
load('matStimIndex.mat')
load('dataMatrixFlashes.mat')

USE_SNIPPITS = 1;

if USE_SNIPPITS == 1
    SNIPPITS_SIZE = 2001;
else
    SNIPPITS_SIZE = nan;
end

cd(dirIn)
if ~exist(dirPic1)
    mkdir(dirPic1)
    mkdir([dirPic1, 'V_0_W/'])
    mkdir([dirPic1, 'V_50_W/'])
    mkdir([dirPic1, 'V_100_W/'])
    mkdir([dirPic1, 'V_Only/'])
    mkdir([dirPic1, 'W_50_V/'])
    mkdir([dirPic1, 'W_100_V/'])
    mkdir([dirPic1, 'W_Only/'])
end

allData = dir(identifier);
screensize=get(groot, 'Screensize');
%%
for experiment = 1:length(allData)
    dirName = allData(experiment).name(1:end-4);
    
    % find what kind and how much of each trials do we have
    load(allData(experiment).name, 'meanSubData', 'finalSampR', 'info', 'uniqueSeries', 'indexSeries')
    
    if USE_SNIPPITS == 1
        smallSnippits = meanSubData(:,:,1:SNIPPITS_SIZE); %smallSnippits, meanSubData, dataSnippets
        % WAVE=zeros(100, 2001, size(Snippets,1), size(Snippets,2));
        %WAVE=zeros(40, SNIPPITS_SIZE, size(smallSnippits,1), size(smallSnippits,2));
        for i=1:size(smallSnippits,1)
            disp(i);
            %tic
            for j = 1:size(smallSnippits,2)
                sig=detrend(squeeze(smallSnippits(i, j,:)));
                % [temp,PERIOD,SCALE,COI,DJ, PARAMOUT, K] = contwt(sig,1/1000,1, 0.1);
                [temp,PERIOD,SCALE,COI,DJ, PARAMOUT, K] = contwt(sig,1/finalSampR,1, 0.25); % EEG data, 1/finalSampR, 1 = pad with zeros, 0.25 = default scale res
                if i ==1 && j ==1
                    WAVE=zeros(length(PERIOD), SNIPPITS_SIZE, size(smallSnippits,1), size(smallSnippits,2));
                end
                WAVE(:,:,i, j)=temp;
                Freq=1./PERIOD;
            end
        end
    else
        %WAVE=zeros(40, size(meanSubData,2), size(meanSubData,1));
        for i=1:size(meanSubData,1)
            disp(i);
            sig=detrend(squeeze(meanSubData(i,:)));
            % [temp,PERIOD,SCALE,COI,DJ, PARAMOUT, K] = contwt(sig,1/1000,1, 0.1);
            [temp,PERIOD,SCALE,COI,DJ, PARAMOUT, K] = contwt(sig,1/finalSampR,1, 0.25); % EEG data, 1/finalSampR, 1 = pad with zeros, 0.25 = default scale res
            if i ==1
                WAVE=zeros(length(PERIOD), size(meanSubData,2), size(meanSubData,1));
            end
            WAVE(:,:,i)=temp;
            Freq=1./PERIOD;
        end
    end
    avgWAVE = abs(nanmean(WAVE,4));
    
    baselineTime = [400:700];
    baselineSpecMean = nanmean(avgWAVE(:,baselineTime,:),2);
    %baselineSpecSTD = nanstd(avgWAVE(:,baselineTime,:),0,2);
    normAvgSpec = 10*(log10(avgWAVE) -log10(repmat(baselineSpecMean, 1,size(avgWAVE,2), 1)));
    
    % plot averages
    close all
    plotTime= [500:1500];
    timeAxis = linspace(-1+plotTime(1)*.001, -1+plotTime(end)*.001, numel(plotTime));
    currentFig = figure('Position', screensize); clf
    
    gridIndicies = info.gridIndicies;
    for i = 1:64
        [electrodeX(i), electrodeY(i)] = ind2sub(size(gridIndicies), find(gridIndicies == i));
    end
    
    for ch = 1:size(smallSnippits, 1)
        trueChannel = ch;%info.goodChannels(ch);
        channelIndex = sub2ind([6 11], electrodeY(trueChannel), electrodeX(trueChannel));
        h(ch) = subplot(11,6,channelIndex);
        pcolor(plotTime, Freq, normAvgSpec(:,plotTime, ch)); shading flat;
        set(gca, 'Yscale', 'Log')
        colorbar
        title(num2str(trueChannel));
    end
    
    set(h, 'clim', [min(normAvgSpec(:)), max(normAvgSpec(:))])
    set(h, 'XTick', [-0.25, 0, 0.25], 'YTick', [1, 10, 100])
    [stimIndexSeriesString] = stimIndex2string4saving(info.stimIndex, finalSampR);
    
    suptitle(['Average scalogram, Mouse: ', num2str(info.exp), ', ', info.AnesType, ': ', num2str(info.AnesLevel), ', stim: ', stimIndexSeriesString, 'Time: ', num2str(timeAxis(1)), ':', num2str(timeAxis(end)), ' s']);
    if ismember(info.stimIndex, matStimIndex(1,:), 'rows')
        saveas(currentFig, [dirPic1, 'V_0_W/', dirName, '.png'])
    elseif ismember(info.stimIndex, matStimIndex(2,:), 'rows')
        saveas(currentFig, [dirPic1, 'V_50_W/', dirName, '.png'])
    elseif ismember(info.stimIndex, matStimIndex(3,:), 'rows')
        saveas(currentFig, [dirPic1, 'V_100_W/', dirName, '.png'])
    elseif ismember(info.stimIndex, matStimIndex(4,:), 'rows')
        saveas(currentFig, [dirPic1, 'V_Only/', dirName, '.png'])
    elseif ismember(info.stimIndex, matStimIndex(5,:), 'rows')
        saveas(currentFig, [dirPic1, 'W_50_V/', dirName, '.png'])
    elseif ismember(info.stimIndex, matStimIndex(6,:), 'rows')
        saveas(currentFig, [dirPic1, 'W_100_V/', dirName, '.png'])
    elseif ismember(info.stimIndex, matStimIndex(7,:), 'rows')
        saveas(currentFig, [dirPic1, 'W_Only/', dirName, '.png'])
    end
    close all
    
end
