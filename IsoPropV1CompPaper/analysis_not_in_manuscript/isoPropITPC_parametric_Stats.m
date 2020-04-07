%% Figures and analysis necessary for the IsoPropV1 comparision paper
% 10/24/18 AA

%% general loading
clc
clear
close all

onAlexsWorkStation = 1; %1 if on workstation with complete multistim data set, 0 if on lab mac, 2 if on laptop

if onAlexsWorkStation ==1
    % Alex's computer
    dirIn = '/data/adeeti/ecog/matIsoPropMultiStim/';
    dirOut1 = '/home/adeeti/GoogleDrive/';
    dirFiltData = '/data/adeeti/ecog/matIsoPropMultiStim/Wavelets/FiltData/';
    cd(dirIn)
    load('dataMatrixFlashes.mat')
elseif onAlexsWorkStation ==0
    % Adeeti's Desktop
    dirIn = '/Users/adeeti/Desktop/data/VIS_Only_Iso_prop_2018/flashTrials/';
    dirOut1 = '/Users/adeeti/Google Drive//';
    cd(dirIn)
    load('dataMatrixFlashesVIS_ONLY.mat')
    dataMatrixFlashes = dataMatrixFlashesVIS_ONLY;
elseif onAlexsWorkStation ==2
    % Adeeti's Desktop
    dirIn = '/Users/adeetiaggarwal/Google Drive/data/matIsoPropMultiStimVIS_ONLY_/flashTrials/';
    dirOut1 = '/Users/adeetiaggarwal/Google Drive//';
    cd(dirIn)
    load('dataMatrixFlashesVIS_ONLY.mat')
    dataMatrixFlashes = dataMatrixFlashesVIS_ONLY;
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


%% Comparing ITPC for propofol vs iso figure
USE_SINGLE_EXP = 0; %1 if want to specifically write in experiments, 0 if want to loop through
experiment = [];

expID = 5;
channels = 31; % channels = [];

% parameters for bootstrapping
trueITPC = nan(length(allExp{expID}), 40, 2001);
aveTrace = nan(length(allExp{expID}), 2001);
%drug = nan(length(allExp), 1);
conc = nan(length(allExp{expID}), 1);

for experiment = 1:length(allExp{expID})
    load(dataMatrixFlashes(allExp{expID}(experiment)).expName, 'info', 'uniqueSeries', 'indexSeries', 'meanSubData', 'smallSnippits')
    
    [indices] = getStimIndices(stimIndex, indexSeries, uniqueSeries);
    useMeanSubData = meanSubData(:, indices,:);
    useSmallSnippits = smallSnippits(:, indices,:);
    
    totTrialsPerExp = size(useMeanSubData, 2);
    trialsPerSamp = totTrialsPerExp;
    totSamp = 1000;
    
    if isempty(channels)
        channels = info.lowLat;
    end
    
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
    
    trueITPC(experiment,:,:) = ITPC_AA(WAVE, channels, []);
    aveTrace(experiment,:) = squeeze(mean(useSmallSnippits(channels,:,:),2));
    drug{experiment} = info.AnesType;
    conc(experiment) = info.AnesLevel;
    
end

% plotting and shit
% plot results
screensize=get(groot, 'Screensize');
ff = figure('Position', screensize, 'color', 'w'); clf;
ff.Renderer='Painters';
clf

plotTime = [1:2001];
timeAxis = linspace(-1+plotTime(1)*.001, -1+plotTime(end)*.001, numel(plotTime));

for experiment = 1:length(allExp{expID})
    
    h1= subplot(2,length(allExp{expID}),experiment);
    plot(timeAxis, squeeze(aveTrace(experiment,plotTime)));
    set(gca, 'ylim', [min(aveTrace(:)), max(aveTrace(:))])
    set(gca, 'xlim', [timeAxis(1), timeAxis(end)])
    colorbar
    if conc(experiment)<3
        title({[drug{experiment}, ', dose ', num2str(conc(experiment)), '%']; 'Average Trace'})
    else
        title({[drug{experiment}, ', dose ', num2str(conc(experiment)), '\mug/g']; 'Average Trace'})
    end
    axis off
    if experiment == 6
        hold on
        line([200 200], [200 300], 'LineWidth', 2, 'Color', 'k');
        line([200 700], [200 200], 'LineWidth', 2, 'Color', 'k');
        
        tt=text(70, 250, '100 \muV', 'FontName', 'Arial', 'FontSize', 12);
        tt2=text(220, 150, '500 ms', 'FontName', 'Arial', 'FontSize', 12);
    end
    
    h2 = subplot(2, length(allExp{expID}), experiment+6)
    pcolor(timeAxis, Freq, squeeze(trueITPC(experiment,:,plotTime))); shading 'flat';
    set(gca, 'yscale', 'log')
    yticks([1, 5, 10, 25, 50, 100, 200])
    set(gca, 'xlim', [timeAxis(1), timeAxis(end)])
    set(gca,'clim',[0, max(trueITPC(:))])
    colorbar
    title('ITPC')
    xlabel('Time (ms)')
    ylabel('Freq (Hz)')
    
    set(gca, 'xlim', [timeAxis(1), timeAxis(end)])
    linkaxes

end

suptitle('Comparing Isoflurane and Propofol Intertrial Phase Coherence')
%saveas(ff, [dirOut1, 'ITPCsingleTrialOnlyGamma', info.expName, '.png'])

%saveas(ff, [dirOut1, 'IsoPropITPC', '.pdf'])
%% All ITPC for iso vs prop
% parameters for bootstrapping
trueITPC = nan(numSubjects, maxExposuresPerSubject, 40, 2001);

for subject = 1:numSubjects
    for experiment = 1:size(allExp{subject},2)
        load(dataMatrixFlashes(allExp{subject}(experiment)).expName, 'info', 'uniqueSeries', 'indexSeries', 'meanSubData', 'smallSnippits')
        
        [indices] = getStimIndices(stimIndex, indexSeries, uniqueSeries);
        useMeanSubData = meanSubData(:, indices,:);
        useSmallSnippits = smallSnippits(:, indices,:);

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

%saveas(ff, [dirOut1, 'allTrueITPCV1', '.png'])

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

%saveas(ff, [dirOut1, 'allTrueITPCV1', '.png'])


%% looking at the difference between the ITPCs in Iso vs Prop

isoExposures = 1:2;
propExposures = 3:4;
recoveryExposures = 5:6;

meanIso = squeeze(nanmean(nanmean(trueITPC(:,[isoExposures, recoveryExposures],:,:),2),1));
meanProp = squeeze(nanmean(nanmean(trueITPC(:,propExposures,:,:),2),1));
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


ff= figure
plot(timeAxis, squeeze(meanIso(16,plotTime)), 'b')
hold on
plot(timeAxis,squeeze(meanProp(16,plotTime)), 'r')
xlabel('Time (s)')
ylabel('ITPC at 35Hz')
title('ITPC at 35 Hz for VEPs under isoflurane and propofol')
legend('Isoflurane', 'Propofol')
%saveas(ff, [dirOut1, '35HzITPC_IsoVsProp', '.png'])

fr = find(Freq>30 &Freq<40);

ff= figure
for j = [isoExposures, propExposures, recoveryExposures]
    for i = 1:numSubjects
        subplot(3,2,j)
        plot(timeAxis,squeeze(trueITPC(i,j,fr,plotTime)))
        expString{i} = ['Subject ', num2str(i)];
        hold on
        %plot(linspace(-1+plotTime(1)*.001, -1+plotTime(end)*.001, numel(plotTime)),squeeze(meanProp(16,plotTime)), 'r')
    end
    plot(timeAxis,squeeze(nanmean(nanmean(trueITPC(:,j,fr,plotTime),2),1)), 'k', 'LineWidth', 2.5)
    expString{i+1} = 'Average';
    hold off
    xlabel('Time (s)')
    ylabel('ITPC at 35Hz')
    set(gca, 'xlim', [timeAxis(1), timeAxis(end)])
    set(gca,'ylim',[0, max(trueITPC(:))])
    if j == 1
        drugCon = 'Isoflurane high';
    elseif j == 2
        drugCon = 'Isoflurane low';
    elseif j == 3
        drugCon = 'Propofol low';
    elseif j ==4
        drugCon = 'Propofol high';
    elseif j ==5
        drugCon = 'Re-exposure isoflurane high';
    elseif j ==6
        drugCon = 'Re-exposure isoflurane low';
    end
    title(drugCon)
    legend(expString)
end
 suptitle(['ITPC at ', num2str(Freq(fr)),  'Hz for VEPs'])
 
% saveas(ff, [dirOut1, num2str(Freq(fr)), 'ITPCbyExposureWithAllData', '.png'])


%% stats between ITPC of VEP under propofol vs iso

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

% allMaxITPC
% allFreqAtMaxITPC
% allTimeAtMaxITPC

allExposureIndex = ones(size(allMaxITPC));
allAnimalIndex = ones(size(allMaxITPC));
for i = 1:size(allExposureIndex,2)
    allExposureIndex(:,i) = i;
    allAnimalIndex(i,:) = i;
end

meanITPC_perExposure = nanmean(allMaxITPC, 1);
stdITPC_perExposure = nanstd(allMaxITPC, 1);

for i = 1:length(allExp)
    stdITPC_perExposure(i) = stdITPC_perExposure(i)/sqrt(numel(allExp{i}));
end

stdITPC_perExposure = stdITPC_perExposure.*1.96;


ff = figure;
scatter(allExposureIndex(:), allMaxITPC(:), [], allAnimalIndex(:), 'filled')
hold on 
e = errorbar(1:6, meanITPC_perExposure, stdITPC_perExposure, 'o');
%e.Marker = 'o';
e.MarkerSize = 10;
e.Color = 'k';
e.MarkerFaceColor = 'k';
e.CapSize = 15;
% ylim([0,1])
xlim([0,7])
ylabel('Mean maximum ITPC')
xlabel('Anesthetic Exposure')
title(['ITPC Stats freq: ', num2str(setFreq(1)), 'Hz to ', num2str(setFreq(2)), 'Hz, time: ', num2str(epTimeFrame(1)), 'ms to ', num2str(epTimeFrame(end)), 'ms'])
 saveas(ff, [dirOut1, 'ITPC_Stats_V1_IsoProp','.png'])
 
%paired t tests
[h,p,ci,stats] = ttest(allMaxITPC(:,1), allMaxITPC(:,4)) % not stat different 
[h,p,ci,stats] = ttest(allMaxITPC(:,2), allMaxITPC(:,3)) %stat different

allIsoMaxITPC = allMaxITPC(:,1:2);
allPropMaxITPC = allMaxITPC(:,3:4);
[h,p,ci,stats] = ttest(allIsoMaxITPC(:), allPropMaxITPC(:)) %stat different 