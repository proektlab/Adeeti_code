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
    dirFiltData = '/data/adeeti/ecog/matIsoPropMultiStim/Wavelets/FiltData/';
    dirOut1 = '/data/adeeti/ecog/images/IsoPropCompV1Paper/';
    dirDropbox = '/data/adeeti/Dropbox/';
    cd(dirIn)
    load('dataMatrixFlashes.mat')
    load('matStimIndex.mat')
elseif onAlexsWorkStation ==0
    % Adeeti's Desktop
    dirIn = '/Users/adeeti/Desktop/data/VIS_Only_Iso_prop_2018/flashTrials/';
    dirOut1 = '/Users/adeeti/Google Drive/TNI/';
    cd(dirIn)
    load('dataMatrixFlashesVIS_ONLY.mat')
    dataMatrixFlashes = dataMatrixFlashesVIS_ONLY;
elseif onAlexsWorkStation ==2
    % Adeeti's Laptop
    dirIn = '/Users/adeetiaggarwal/Google Drive/data/VIS_Only_Iso_prop_2018/flashTrials/';
    dirOut1 = '/Users/adeeti/Google Drive/TNI/IsoPropCompV1Paper/';
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

% initializing variabiles 
allNormAvgSpec= nan(numSubjects, maxExposuresPerSubject, 40, 2001);
trueITPC = nan(numSubjects, maxExposuresPerSubject, 40, 2001);
aveTrace = nan(numSubjects, maxExposuresPerSubject, 2001);
%drug = nan(length(allExp), 1);
conc = nan(maxExposuresPerSubject, 1);
baselineTime = [400:700];

for expID = 1:numSubjects
    for experiment = 1:maxExposuresPerSubject
        if experiment > length(allExp{expID})
            continue
        end
        load(dataMatrixFlashes(allExp{expID}(experiment)).expName, 'info', 'uniqueSeries', 'indexSeries', 'meanSubData', 'smallSnippits')
        channels = info.lowLat; % channels = []
        [indices] = getStimIndices(stimIndex, indexSeries, uniqueSeries);
        useMeanSubData = meanSubData(:, indices,:);
        useSmallSnippits = smallSnippits(:, indices,:);
        
        totTrialsPerExp = size(useMeanSubData, 2);
        trialsPerSamp = totTrialsPerExp;
        totSamp = 1000;
        
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
        
        avgWAVE = abs(nanmean(WAVE,4));
        baselineSpecMean = nanmean(avgWAVE(:,baselineTime,:),2);
        %baselineSpecSTD = nanstd(avgWAVE(:,baselineTime,:),0,2);
        normAvgSpec = 10*(log10(avgWAVE) -log10(repmat(baselineSpecMean, 1,size(avgWAVE,2), 1)));
        
        allNormAvgSpec(expID, experiment,:,:) = squeeze(normAvgSpec(:,:,channels));
        
        trueITPC(expID, experiment,:,:) = ITPC_AA(WAVE, channels, []);
        aveTrace(expID, experiment,:) = squeeze(mean(useSmallSnippits(channels,:,:),2));
        
        if expID == 1
            drug{experiment} = info.AnesType;
            conc(experiment) = info.AnesLevel;
        end
    end
end

%% plotting and shit
% plot results
screensize=get(groot, 'Screensize');
ff = figure('Position', screensize, 'color', 'w'); clf;
ff.Renderer='Painters';
clf

plotTime = [500:1500];
timeAxis = linspace(-1+plotTime(1)*.001, -1+plotTime(end)*.001, numel(plotTime));
plotFreq = find(Freq>1 & Freq<150);%[1:length(Freq)];%

expID = 5;

for experiment = 1:maxExposuresPerSubject
    
%     h1= subplot(3,length(allExp{expID}),experiment);
%     plot(timeAxis, squeeze(aveTrace(experiment,plotTime)));
%     set(gca, 'ylim', [min(aveTrace(:)), max(aveTrace(:))])
%     set(gca, 'xlim', [timeAxis(1), timeAxis(end)])
%     colorbar
%     if conc(experiment)<3
%         title({[drug{experiment}, ', dose ', num2str(conc(experiment)), '%']; 'Average Trace'})
%     else
%         title({[drug{experiment}, ', dose ', num2str(conc(experiment)), '\mug/g']; 'Average Trace'})
%     end
%     axis off
%     if experiment == 6
%         hold on
%         line([-.450 -.450], [-100 -50], 'LineWidth', 2, 'Color', 'k'); %vertical line
%         line([-.450 0.05], [-100 -100], 'LineWidth', 2, 'Color', 'k'); %horizontal line 
%         
%         tt=text(-.450, -75, '50 \muV', 'FontName', 'Arial', 'FontSize', 12);
%         tt2=text(-.450, -100, '500 ms', 'FontName', 'Arial', 'FontSize', 12);
%     end
    
    h2 = subplot(2, maxExposuresPerSubject, experiment);
    pcolor(timeAxis, Freq(plotFreq), squeeze(allNormAvgSpec(expID, experiment,plotFreq,plotTime))); shading 'flat';
    set(gca, 'yscale', 'log')
    yticks([1, 5, 10, 25, 50, 100, 200])
    set(gca, 'xlim', [timeAxis(1), timeAxis(end)])
    set(gca,'clim',[-20, 20])
    colorbar
    title('Average Evoked Power')
    xlabel('Time (s)')
    ylabel('Freq (Hz)')
    set(gca, 'xlim', [timeAxis(1), timeAxis(end)])
    
    h3 = subplot(2, maxExposuresPerSubject, experiment+6);
    pcolor(timeAxis, Freq(plotFreq), squeeze(trueITPC(expID, experiment,plotFreq,plotTime))); shading 'flat';
    set(gca, 'yscale', 'log')
    yticks([1, 5, 10, 25, 50, 100, 200])
    set(gca, 'xlim', [timeAxis(1), timeAxis(end)])
    set(gca,'clim',[0, max(trueITPC(:))])
    colorbar
    title('ITPC')
    xlabel('Time (s)')
    ylabel('Freq (Hz)')
    set(gca, 'xlim', [timeAxis(1), timeAxis(end)])

end

suptitle(['Comparing Isoflurane and Propofol ITPC Mouse: ', num2str(expID)])
%saveas(ff, [dirOut1, 'ITPCsingleTrialOnlyGamma', info.expName, '.png'])

%saveas(ff, [dirOut1, 'IsoPropITPC', '.pdf'])
%saveas(ff, [dirDropbox, 'IsoPropITPC', '.pdf'])
