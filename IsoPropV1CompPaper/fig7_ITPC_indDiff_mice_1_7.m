
%% load, organize, and compute ITPC for all mice
clc
clear

onAlexsWorkStation = 1; %1 if on workstation with complete multistim data set, 0 if on lab mac, 2 if on laptop

if onAlexsWorkStation ==1
    % Alex's computer
    dirIn = '/data/adeeti/ecog/matIsoPropMultiStimVIS_ONLY_/flashTrials/';
    dirOut1 = '/home/adeeti/GoogleDrive/TNI/IsoPropCompV1Paper/';
    dirFiltData = '/data/adeeti/ecog/matIsoPropMultiStim/Wavelets/FiltData/';
    cd(dirIn)
     load('dataMatrixFlashesVIS_ONLY.mat')
    dataMatrixFlashes = dataMatrixFlashesVIS_ONLY;
elseif onAlexsWorkStation ==0
    % Adeeti's Desktop
    dirIn = '/Users/adeeti/Desktop/data/VIS_Only_Iso_prop_2018/flashTrials/';
    dirOut1 = '/Users/adeeti/Google Drive/TNI/IsoPropCompV1Paper/';
    cd(dirIn)
    load('dataMatrixFlashesVIS_ONLY.mat')
    dataMatrixFlashes = dataMatrixFlashesVIS_ONLY;
elseif onAlexsWorkStation ==2
    % Adeeti's Desktop
    dirIn = '/Users/adeetiaggarwal/Google Drive/data/VIS_Only_Iso_prop_2018/flashTrials/';
    dirOut1 = '/Users/adeetiaggarwal/Google Drive/TNI/IsoPropCompV1Paper/';
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
        clearvars useSmallSnippits smallSnippits
        trueITPC(subject,experiment,:,:) = ITPC_AA(WAVE, channels, []);
    end
end

All_trueITPC = trueITPC;
%%
isoExposures = 1:2;
propExposures = 3:4;
recoveryExposures = 5:6;

meanIso = squeeze(nanmean(nanmean(All_trueITPC(1:7,[isoExposures, recoveryExposures],:,:),2),1));
meanProp = squeeze(nanmean(nanmean(All_trueITPC(1:7,propExposures,:,:),2),1));
ITPC_iso = squeeze(nanmean(All_trueITPC(1:7,[isoExposures],:,:),2));
ITPC_prop = squeeze(nanmean(All_trueITPC(1:7,[propExposures],:,:),2));

diffITPCMatrix = meanIso - meanProp;
ind_ITPDiff = ITPC_iso - ITPC_prop;

% total difference figure
screensize=get(groot, 'Screensize');
ff = figure('Position', screensize, 'color', 'w'); clf;
ff.Renderer='Painters';
clf

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

% individual diff figure 
plotTime = [750:1500];
timeAxis = linspace(-1+plotTime(1)*.001, -1+plotTime(end)*.001, numel(plotTime));
plotFreq = find(Freq>1 & Freq<150);%[1:length(Freq)];%

screensize=get(groot, 'Screensize');
ff = figure('Position', screensize, 'color', 'w'); clf;
ff.Renderer='Painters';
clf
for i = 1:7
    subplot(2,4,i);
    pcolor(timeAxis, Freq(plotFreq), squeeze(ind_ITPDiff(i, plotFreq, plotTime))); shading 'flat';
    set(gca, 'yscale', 'log')
    %yticks([1, 5, 10, 20, 30, 40, 50, 100]);
    xlabel('Time (s)')
    ylabel('Frequency (Hz)')
    c = colorbar
    set(gca,'clim',[min(ind_ITPDiff(:)), 0.5])%max(ind_ITPDiff(:))])
    c.Label.String = 'Mean ITPC differnce (ITPC_i_s_o_ - ITPC_p_r_o_p_)'
    title(['Coherence diff Mouse: ', num2str(i)])
end

%% quantification with mann whitney u tests

epTimeFrame = [1050:1200]; % ms in which the EP starts to look for maximum coherence 
setFreq = [20, 60];
epFreq = find(Freq > setFreq(1) & Freq < setFreq(2)); %specifically looking in gamma range to decrease the COI effect 

for i = 1:7
tempIso=squeeze(ITPC_iso(i, epFreq,epTimeFrame));
tempProp=squeeze(ITPC_prop(i, epFreq,epTimeFrame));
[p, h]=ranksum(tempIso(:), tempProp(:))
pValues(i) = p;
hValues(i) = h;
end


%% quantification with t tests
% 
% numSubjects = 7;
% maxExposuresPerSubject = 6;
% 
% % for the stats 
% allMaxITPC = nan(numSubjects, maxExposuresPerSubject);
% 
% epTimeFrame = [1050:1150]; % ms in which the EP starts to look for maximum coherence 
% setFreq = [20, 40];
% epFreq = find(Freq > setFreq(1) & Freq < setFreq(2)); %specifically looking in gamma range to decrease the COI effect 
% 
% for subject = 1:numSubjects
%     for experiment = 1:maxExposuresPerSubject
%         tempITPC= squeeze(All_trueITPC(subject,experiment,epFreq,epTimeFrame));
%         tempData = tempITPC(:);
%         allMaxITPC(subject, experiment) = nanmean(tempData);
%     end
% end
% 
% 
% allExposureIndex = ones(size(allMaxITPC));
% allAnimalIndex = ones(size(allMaxITPC));
% for i = 1:size(allExposureIndex,2)
%     allExposureIndex(:,i) = i;
% end
% 
% for i = 1: numSubjects
%     allAnimalIndex(i,:) = i;
% end
% 
% meanITPC_perExposure = nanmean(allMaxITPC, 1);
% stdITPC_perExposure = nanstd(allMaxITPC, 1);
% 
% for i = 1:length(allExp)
%     stdITPC_perExposure(i) = stdITPC_perExposure(i)/sqrt(numel(allExp{i}));
% end
% 
% stdITPC_perExposure = stdITPC_perExposure.*1.96;
% 
% 
% ff = figure;
% scatter(allExposureIndex(:), allMaxITPC(:), [], allAnimalIndex(:), 'filled')
% hold on 
% e = errorbar(1:6, meanITPC_perExposure, stdITPC_perExposure, 'o');
% %e.Marker = 'o';
% e.MarkerSize = 10;
% e.Color = 'k';
% e.MarkerFaceColor = 'k';
% e.CapSize = 15;
% % ylim([0,1])
% xlim([0,7])
% ylabel('Mean maximum ITPC')
% xlabel('Anesthetic Exposure')
% title(['ITPC Stats freq: ', num2str(setFreq(1)), 'Hz to ', num2str(setFreq(2)), 'Hz, time: ', num2str(epTimeFrame(1)), 'ms to ', num2str(epTimeFrame(end)), 'ms'])
% % saveas(ff, [dirOut1, 'ITPC_Stats_V1_IsoProp','.png'])
%  
% %paired t tests
% [h,p,ci,stats] = ttest(allMaxITPC(:,1), allMaxITPC(:,4)) % not stat different 
% [h,p,ci,stats] = ttest(allMaxITPC(:,2), allMaxITPC(:,3)) %stat different
% 
% allIsoMaxITPC = allMaxITPC(:,1:2);
% allPropMaxITPC = allMaxITPC(:,3:4);
% [h,p,ci,stats] = ttest(allIsoMaxITPC(:), allPropMaxITPC(:)) %stat different 
