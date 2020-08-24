%% Looking at individual trials

dirIn =   '/Volumes/LabData/adeeti/ecog/iso_awake_VEPs/GL13/';
dirPicAvg = '/data/adeeti/ecog/images/2018IsoFlashes/averageCompCh/';
dirPicSing = '/data/adeeti/ecog/images/2018IsoFlashes/singleTrialsCompCh/';

%dirInFilt = '/data/adeeti/ecog/matFlashesJanMar2017/Wavelets/FiltData/'
% dirPicFilt35 = '/data/adeeti/ecog/images/FiltSingTrials_35/';
% dirPicFilt7 = '/data/adeeti/ecog/images/FiltSingTrials_7/';

identifier = '2020*mat';

USE_FILT = 0; %1 for using filtered data and 0 for using data in time domain
frequency = 7;

mkdir(dirPicAvg)
mkdir(dirPicSing)
% mkdir(dirPicFilt35)
% mkdir(dirPicFilt7)

before =.2;
after = .1;
mark = .1;

LEN_TRIALS = 6;

screensize=get(groot, 'Screensize');

%% In time domain

cd(dirIn)
allData = dir(identifier);

load(allData(1).name, 'finalSampR', 'finalTime', 'info');

strAroundV1 = {'Above', 'Left', 'Rgiht', 'Below'};
strGrid = {'UL', 'UR', 'LL', 'LR'};

cornerGrid = findCornersGrid(info); %UL,UR, LL, LR

flashOn = [0,0];

load(allData(1).name, 'finalSampR', 'finalTime');

startPlot = find(finalTime > (-before - 1/(finalSampR*10)) & finalTime < (-before + 1/(finalSampR*10)));
endPlot = find(finalTime > (after - 1/(finalSampR*10)) & finalTime < (after + 1/(finalSampR*10)));

markTime = -before:mark:after;
%%
for experiment = 1:length(allData)
    dirName = allData(experiment).name(1:19)
    
    load(allData(experiment).name, 'info')
    NUM_TRIALS = randsample(info.trials, LEN_TRIALS);
    
    if USE_FILT
        load([dirInFilt, dirName, 'wave.mat'], ['H', num2str(frequency)])
        
        eval(['sig = H', num2str(frequency), ';'])
        
        [singleTrials] = hilbert2filtsig(sig);
        averages = squeeze(mean(singleTrials(:,:,:),3));
        
        singleTrials = permute(singleTrials, [2, 3,1]);
        averages = permute(averages, [2,1]);
        finalTime = linspace(-1, 1, size(averages, 2));
        
    else
        load(allData(experiment).name, 'finalTime', 'meanSubData', 'aveTrace')
        singleTrials = meanSubData;
        averages = aveTrace;
    end
    
    disp(dirName)
    V1 = info.V1;
    noiseChannels = info.noiseChannels;
    
    for i = 1:size(cornerGrid, 1)
        yInd = find(ismember(cornerGrid(i,:), noiseChannels)==0, 1, 'first');
        if isempty(yInd)
            yInd = 1;
        end
        plotCorn(i) = cornerGrid(i, yInd);
    end
    
    
    allAdj = findAdjacentChan(info.channels, info);
    for i = 2:2:8
        V1adj(i/2) =allAdj(V1,i); %A,L,R,B
    end
    
    %% Averages
    
    USE_DATA = averages;
    
    currentFig=figure('color', 'w', 'position', [80 1 1069 973]);
    h=zeros(10,1);
    
    h(1)=subplot(5,2,1);
    plot(finalTime(startPlot:endPlot), USE_DATA(V1,startPlot:endPlot), 'k', 'linewidth', 1);
    set(gca, 'ylim', [min(USE_DATA(:)),  max(USE_DATA(:))])
    set(gca, 'xlim', [-before, after])
    yAxis = get(gca, 'YLim');
    hold on
    for t = 1:length(markTime)
        line([markTime(t), markTime(t)], yAxis, 'Color', [.9 .9 .9])
    end
    plot(flashOn, yAxis, 'r')
    ylabel(['V1 ch: ', num2str(V1)]);
    title('Channels around V1')
    hold off
    
    %plot close to V1
    for i =1:length(V1adj)
        if isnan(V1adj(i))
            continue
        end
        
        h(2*i+1)=subplot(5,2,2*i+1);
        plot(finalTime(startPlot:endPlot), USE_DATA(V1adj(i),startPlot:endPlot), 'k', 'linewidth', 1);
        set(gca, 'ylim', yAxis)
        set(gca, 'xlim', [-before, after])
        
        hold on
        for t = 1:length(markTime)
            line([markTime(t), markTime(t)], yAxis, 'Color', [.9 .9 .9])
        end
        plot(flashOn, yAxis, 'r')
        ylabel([strAroundV1{i}, ' Ch ', num2str(V1adj(i))]);
        hold off
    end
    
    h(2)=subplot(5,2,2);
    plot(finalTime(startPlot:endPlot), USE_DATA(V1,startPlot:endPlot), 'k', 'linewidth', 1);
    set(gca, 'ylim', [min(USE_DATA(:)),  max(USE_DATA(:))])
    set(gca, 'xlim', [-before, after])
    yAxis = get(gca, 'YLim');
    
    hold on
    for t = 1:length(markTime)
        line([markTime(t), markTime(t)], yAxis, 'Color', [.9 .9 .9])
    end
    plot(flashOn, yAxis, 'r')
    ylabel(['V1 Ch: ', num2str(V1)]);
    title('Channels around Grid')
    hold off
    
    %plot around the grid
    for i =1:size(plotCorn,2)
        h(2*i+2)=subplot(5,2,2*i+2);
        plot(finalTime(startPlot:endPlot), USE_DATA(plotCorn(i),startPlot:endPlot), 'k', 'linewidth', 1);
        
        set(gca, 'ylim', yAxis)
        set(gca, 'xlim', [-before, after])
        
        hold on
        for t = 1:length(markTime)
            line([markTime(t), markTime(t)], yAxis, 'Color', [.9 .9 .9])
        end
        plot(flashOn, yAxis, 'r')
        ylabel([strGrid{i}, ' Ch ', num2str(plotCorn(i))]);
        hold off
    end
    
    %set(gca, 'Xcolor', 'none', 'Ycolor', 'none');
    
    suptitle(['Averages Mouse: ', info.date, ', Iso: ', num2str(info.AnesLevel), ', Dur: ', num2str(info.LengthPulse), ', Int: ', num2str(info.IntensityPulse)])
    
    saveas(currentFig, [dirPicAvg, dirName, 'avg', '.png'])
    close(currentFig)
    
    %% Single trials
    
    currentFig=figure('color', 'w', 'position', screensize);
    h=zeros(9*length(NUM_TRIALS),1);
    
    for tr = 1:LEN_TRIALS
        trial = NUM_TRIALS(tr);
        
        USE_DATA = squeeze(singleTrials(:,trial,:));
        
        h(tr)=subplot(9,LEN_TRIALS, tr);
        plot(finalTime(startPlot:endPlot), USE_DATA(V1,startPlot:endPlot), 'k', 'linewidth', 1);
        set(gca, 'ylim', [min(USE_DATA(:)),  max(USE_DATA(:))])
        set(gca, 'xlim', [-before, after])
        yAxis = get(gca, 'YLim');
        hold on
        for t = 1:length(markTime)
            line([markTime(t), markTime(t)], yAxis, 'Color', [.9 .9 .9])
        end
        plot(flashOn, yAxis, 'r')
        if tr == 1
            ylabel(['V1 ch: ', num2str(V1)]);
        end
        title(['Trial ', num2str(trial)])
        hold off
        plotCounter = 1;
        
        %plot close to V1
        for i =1:length(V1adj)
            if isnan(V1adj(i))
                continue
            end
            h(tr+(LEN_TRIALS*plotCounter))=subplot(9,length(NUM_TRIALS),tr+(LEN_TRIALS*plotCounter));
            plot(finalTime(startPlot:endPlot), USE_DATA(V1adj(i),startPlot:endPlot), 'k', 'linewidth', 1);
            set(gca, 'ylim', yAxis)
            set(gca, 'xlim', [-before, after])
            
            hold on
            for t = 1:length(markTime)
                line([markTime(t), markTime(t)], yAxis, 'Color', [.9 .9 .9])
            end
            plot(flashOn, yAxis, 'r')
            if tr ==1
                ylabel([strAroundV1{i}, ' Ch ', num2str(V1adj(i))]);
            end
            hold off
            plotCounter = plotCounter+1;
        end
        
        %plot around the grid
        for i =1:size(plotCorn,2)
            h(tr+(LEN_TRIALS*plotCounter))=subplot(9,length(NUM_TRIALS),tr+(LEN_TRIALS*plotCounter));
            plot(finalTime(startPlot:endPlot), USE_DATA(plotCorn(i),startPlot:endPlot), 'k', 'linewidth', 1);
            set(gca, 'ylim', yAxis)
            set(gca, 'xlim', [-before, after])
            hold on
            for t = 1:length(markTime)
                line([markTime(t), markTime(t)], yAxis, 'Color', [.9 .9 .9])
            end
            plot(flashOn, yAxis, 'r')
            if tr ==1
                ylabel([strGrid{i}, ' Ch ', num2str(plotCorn(i))]);
            end
            hold off
            plotCounter = plotCounter+1;
        end
        
    end
    
    %set(gca, 'Xcolor', 'none', 'Ycolor', 'none');
    %%
    suptitle(['Single Trials Mouse: ', info.date, ', Iso: ', num2str(info.AnesLevel), ', Dur: ', num2str(info.LengthPulse), ', Int: ', num2str(info.IntensityPulse)])
    
    saveas(currentFig, [dirPicSing, dirName, 'singTr', '.png'])
    close(currentFig)
    
end
