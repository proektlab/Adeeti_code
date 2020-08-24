%% looking at new experiments 

%% general loading

clear
clc
close all 

onAlexsWorkStation = 1; %1 if on workstation with complete multistim data set, 0 if on lab mac, 2 if on laptop

if onAlexsWorkStation ==1
    % Alex's computer
    dirIn = '/data/adeeti/ecog/visOnly_isoProp_plexRec_DecJan2019/';
    dirOut1 = '/home/adeeti/GoogleDrive/TNI/IsoPropCompV1Paper/';
    dirFiltData = '/data/adeeti/ecog/matIsoPropMultiStim/Wavelets/FiltData/';
    cd(dirIn)
    load('dataMatrixFlashes.mat')
% elseif onAlexsWorkStation ==0
%     % Adeeti's Desktop
%     dirIn = '/Users/adeeti/Desktop/data/VIS_Only_Iso_prop_2018/flashTrials/';
%     dirOut1 = '/Users/adeeti/Google Drive/TNI/IsoPropCompV1Paper/';
%     cd(dirIn)
%     load('dataMatrixFlashesVIS_ONLY.mat')
%     dataMatrixFlashes = dataMatrixFlashesVIS_ONLY;
% elseif onAlexsWorkStation ==2
%     % Adeeti's Desktop
%     dirIn = '/Users/adeetiaggarwal/Google Drive/data/VIS_Only_Iso_prop_2018/flashTrials/';
%     dirOut1 = '/Users/adeetiaggarwal/Google Drive/TNI/IsoPropCompV1Paper/';
%     cd(dirIn)
%     load('dataMatrixFlashesVIS_ONLY.mat')
%     dataMatrixFlashes = dataMatrixFlashesVIS_ONLY;
end

lowestLatVariable = 'lowLat';
stimIndex = [0, Inf]; %if want all, stimIndex = matStimIndex; % if want
%all uniStimIndexes/multiStimIndexes, use [uniStimIndex, multiStimIndex] =
%findUniMutliStimIndex(matStimIndex), [stimIndex, ~] = findUniMutliStimIndex(matStimIndex)

% Setting up new data set for just visual only stim
expLabel =unique(vertcat(dataMatrixFlashes(:).exp));
allExp = {};
if exist('stimIndex')  && ~isempty(stimIndex)
    for i = 1:length(expLabel)
        for j = 1:size(stimIndex,1)
            [MFE] = findMyExpMulti(dataMatrixFlashes, expLabel(i), [], [], stimIndex(j,:));
            allExp{i}(:) = MFE;
        end
    end
else
    [MFE] = 1:length(dataMatrixFlashes);
end

numSubjects = size(allExp,2);
maxExposuresPerSubject = max(cellfun(@length, allExp));

%% Looking at the whole trace 

experiment = allExp{3}(1);

load(dataMatrixFlashes(experiment).expName, 'info', 'meanSubFullTrace', 'aveTrace', 'finalSampR')

eegplot(meanSubFullTrace, 'srate', finalSampR)

%% looking at the averages
timeRange= [900:1400];

for i = 1:numSubjects
    figure
    for j = 1:maxExposuresPerSubject
        experiment = allExp{i}(j);
        load(dataMatrixFlashes(experiment).expName, 'info', 'meanSubData', 'aveTrace', 'finalSampR')
        V1 = info.lowLat;
        subplot(2, 4, j)
        plot(squeeze(meanSubData(V1,:,timeRange))')
        hold on
        plot(squeeze(aveTrace(:,V1,timeRange))', 'k', 'linewidth', 3)
        title(['Butterfly V1, ', info.AnesType, ' ', num2str(info.AnesLevel)])
        
        subplot(2, 4, j+4)
        plot(squeeze(aveTrace(:,:,timeRange))')
        title(['All Averages, ', info.AnesType, ' ', num2str(info.AnesLevel)])
    end
    suptitle(['Mouse number ', num2str(i)])
end

    
%% All ITPC for iso vs prop
% parameters for bootstrapping
trueITPC = nan(numSubjects, maxExposuresPerSubject, 40, 2001);
size_snippits = [1:2001];

for subject = 1:numSubjects
    for experiment = 1:size(allExp{subject},2)
        load(dataMatrixFlashes(allExp{subject}(experiment)).expName, 'info', 'uniqueSeries', 'indexSeries', 'meanSubData', 'smallSnippits')
        
        [indices] = getStimIndices(stimIndex, indexSeries, uniqueSeries);
        useMeanSubData = meanSubData(:, indices,:);
        if ~exist('smallSnippits')
            useSmallSnippits = useMeanSubData(:,:, size_snippits);
        else
        useSmallSnippits = smallSnippits(:, indices,:);
        end

        channels = info.lowLat;
        
        % Run wavelet and getting ITPC
        WAVE=zeros(40, 2001, size(useSmallSnippits,1), size(useSmallSnippits,2));
        for i=channels
            disp(i);
            for j = 1:size(useSmallSnippits,2)
                sig=detrend(squeeze(useSmallSnippits(i, j,:)));
                % [temp,PERIOD,SCALE,COI,DJ, PARAMOUT, K] = contwt(sig,1/1000,1, 0.1);
                [temp,PERIOD,SCALE,COI,DJ, PARAMOUT, K] = contwt(sig,1/1000,1, 0.25);
                WAVE(:,:,i, j)=temp; %WAVE is in freq by time by channels by trials
                Freq=1./PERIOD;
            end
        end
        trueITPC(subject,experiment,:,:) = ITPC_AA(WAVE, channels, []);
    end
end

%% plotting all the ITPC at V1 for each experiment
plotCounter = 0;
plotTime = [750:1250];
timeAxis = linspace(-1+plotTime(1)*.001, -1+plotTime(end)*.001, numel(plotTime));
plotFreq = [1:length(Freq)];%find(Freq>10 & Freq<100);
screensize=get(groot, 'Screensize');
ff = figure('Position', screensize, 'color', 'w'); clf;
for subject = 1:numSubjects
    for experiment = 1: maxExposuresPerSubject
        plotCounter = plotCounter +1;
        h =subplot(numSubjects, maxExposuresPerSubject, plotCounter);
        if size(allExp{subject},2)<experiment
            continue
        end
        
        %pcolor(linspace(1-plotTime(1)*.001, 1-plotTime(end)*.001, numel(plotTime)), Freq, squeeze(trueITPC(subject,experiment,:,plotTime))); shading 'flat';
        pcolor(linspace(-1+plotTime(1)*.001, -1+plotTime(end)*.001, numel(plotTime)), Freq(plotFreq), squeeze(trueITPC(subject,experiment,plotFreq,plotTime))); shading 'flat';
        set(gca, 'yscale', 'log')
        yticks([1, 5, 10, 50, 100]);
        %         set(gca, 'xlim', plotTime)
        set(gca,'clim',[0, max(trueITPC(:))])
        colorbar
        
        
        if subject ==1 && (experiment == 1|| experiment == 5)
            title({'Iso High'; 'ITPC'})
        elseif subject ==1 && (experiment == 2|| experiment == 6)
            title({'Iso Low'; 'ITPC'})
        elseif subject ==1 && experiment == 3
            title({'Prop Low'; 'ITPC'})
        elseif subject ==1 && experiment == 4
            title({'Prop High'; 'ITPC'})
        else
            title('ITPC')
        end
        
        xlabel('Time (s)')
        if experiment == 1
            ylabel({['Mouse ', num2str(subject)]; ' Freq (Hz)'});
        else
            ylabel('Freq (Hz)')
        end
        
        %suptitle('True ITPC for each mouse at V1')
    end
end

%% plotting ITPC difference

isoExposures = 1:2;
propExposures = 3:4;
recoveryExposures = [];%5:6;


meanIso = squeeze(nanmean(nanmean(trueITPC(1,[isoExposures, recoveryExposures],:,:),2),1));
meanProp = squeeze(nanmean(nanmean(trueITPC(1,propExposures,:,:),2),1));
% meanIso = squeeze(nanmean(nanmean(trueITPC([1:4,6],[isoExposures, recoveryExposures],:,:),2),1));
% meanProp = squeeze(nanmean(nanmean(trueITPC([1:4,6],propExposures,:,:),2),1));

diffITPCMatrix = meanIso - meanProp;

ff = figure
plotTime = [750:1500];
timeAxis = linspace(-1+plotTime(1)*.001, -1+plotTime(end)*.001, numel(plotTime));
plotFreq = find(Freq>7 & Freq<150);%[1:length(Freq)];%
pcolor(timeAxis, Freq(plotFreq), diffITPCMatrix(plotFreq, plotTime)); shading 'flat';
set(gca, 'yscale', 'log')
yticks([1, 5, 10, 20, 30, 40, 50, 100]);
xlabel('Time (s)')
ylabel('Frequency (Hz)')
c = colorbar
c.Label.String = 'Mean ITPC differnce (ITPC_i_s_o_ - ITPC_p_r_o_p_)'
title('Average ITPC differnce between Isoflurane and Propofol')

%saveas(ff, [dirOut1, 'meanDiffITPCIsoVsProp', '.png'])

%% quantification


% for the stats 
allMaxITPC = nan(numSubjects, maxExposuresPerSubject);
allFreqAtMaxITPC = nan(numSubjects, maxExposuresPerSubject);
allTimeAtMaxITPC = nan(numSubjects, maxExposuresPerSubject);

epTimeFrame = [1080:1110]; % ms in which the EP starts to look for maximum coherence 
setFreq = [33, 40];
epFreq = find(Freq > setFreq(1) & Freq < setFreq(2)); %specifically looking in gamma range to decrease the COI effect 

%trueITPC(subject,experiment,freq,epTimeFrame);
for subject = 1:numSubjects
    for experiment = 1:maxExposuresPerSubject
        tempITPC= squeeze(trueITPC(subject,experiment,epFreq,epTimeFrame));
        [fr, ts] = ind2sub([length(epFreq), length(epTimeFrame)], find(tempITPC== max(tempITPC(:))));
%         allMaxITPC(subject, experiment) = max(tempITPC(:));
        tempData = tempITPC(:);
        allMaxITPC(subject, experiment) = nanmean(tempData);
%         allMaxITPC(subject, experiment) = max(tempData(:));
        
        if ~isempty(fr) || ~isempty(ts)
        allFreqAtMaxITPC(subject, experiment) = Freq(epFreq(fr));
        allTimeAtMaxITPC(subject, experiment) = epTimeFrame(ts);
        end
        
    end
end



