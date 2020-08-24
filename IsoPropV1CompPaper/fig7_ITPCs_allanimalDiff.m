%% Figures and analysis necessary for the IsoPropV1 comparision paper
% 10/24/18 AA
% 03/24/19 AA

%% general loading
clc
clear
close all

onAlexsWorkStation = 0; %1 if on workstation with complete multistim data set, 0 if on lab mac, 2 if on laptop

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
    % Adeeti's Laptop
    dirIn = '/Users/adeetiaggarwal/Google Drive/data/matIsoPropMultiStimVIS_ONLY_/flashTrials/';
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


%% All ITPC for iso vs prop
% parameters for bootstrapping
trueITPC = nan(numSubjects, maxExposuresPerSubject, 40, 2001);
size_snippits = [1:2001];

allNormAvgSpec= nan(numSubjects, maxExposuresPerSubject, 40, 2001);
baselineTime = [400:700];

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
    avgWAVE = abs(nanmean(WAVE,4));
    baselineSpecMean = nanmean(avgWAVE(:,baselineTime,:),2);
    %baselineSpecSTD = nanstd(avgWAVE(:,baselineTime,:),0,2);
    normAvgSpec = 10*(log10(avgWAVE) -log10(repmat(baselineSpecMean, 1,size(avgWAVE,2), 1)));
    
    allNormAvgSpec(subject, experiment,:,:) = squeeze(normAvgSpec(:,:,channels));
    trueITPC(subject,experiment,:,:) = ITPC_AA(WAVE, channels, []);
    end
end

%% defining experiments and parameters for statistics
highIsoExp = 1;
lowIsoExp = 2;
lowPropExp = 3;
highPropExp = 4;
recHighIsoExp = 5;
recLowIsoExp = 6;

isoExposures = 1:2;
propExposures = 3:4;
recoveryExposures = [];%5:6;

epTimeFrame = [1050:1200]; % ms in which the EP starts to look for maximum coherence 
setFreq = [20, 60];
epFreq = find(Freq > setFreq(1) & Freq < setFreq(2)); %specifically looking in gamma range to decrease the COI effect 

%% parcilating ITPC and spec matrices based on experinments 

ITPC_pool_iso = squeeze(nanmean(trueITPC(:,[isoExposures],:,:),2));
ITPC_pool_prop = squeeze(nanmean(trueITPC(:,[propExposures],:,:),2));

ITPC_high_iso = squeeze(nanmean(trueITPC(:,[highIsoExp],:,:),2));
ITPC_low_iso = squeeze(nanmean(trueITPC(:,[lowIsoExp],:,:),2));
ITPC_low_prop = squeeze(nanmean(trueITPC(:,[lowPropExp],:,:),2));
ITPC_high_prop = squeeze(nanmean(trueITPC(:,[highPropExp],:,:),2));
ITPC_high_rec = squeeze(nanmean(trueITPC(:,[recHighIsoExp],:,:),2));
ITPC_low_rec = squeeze(nanmean(trueITPC(:,[recLowIsoExp],:,:),2));

meanPoolIso = squeeze(nanmean(ITPC_pool_iso,1));
meanPoolProp = squeeze(nanmean(ITPC_pool_prop,1));

meanHighIso = squeeze(nanmean(ITPC_high_iso,1));
meanLowIso = squeeze(nanmean(ITPC_low_iso,1));
meanLowProp = squeeze(nanmean(ITPC_low_prop,1));
meanHighProp = squeeze(nanmean(ITPC_high_prop,1));
meanHighRec = squeeze(nanmean(ITPC_high_rec,1));
meanLowRec = squeeze(nanmean(ITPC_low_rec,1));


meanSpecPoolIso = squeeze(nanmean(nanmean(allNormAvgSpec(:,[isoExposures, recoveryExposures],:,:),2),1));
meanSpecPoolProp = squeeze(nanmean(nanmean(allNormAvgSpec(:,propExposures,:,:),2),1));

% meanIso = squeeze(nanmean(nanmean(trueITPC([1:4,6],[isoExposures, recoveryExposures],:,:),2),1));
% meanProp = squeeze(nanmean(nanmean(trueITPC([1:4,6],propExposures,:,:),2),1));

%% pooled iso and propofol 

% defining matricies
diffSpecMatrix = meanSpecPoolIso- meanSpecPoolProp;
diffITPCMatrix = meanPoolIso - meanPoolProp;
ind_ITPDiff = ITPC_pool_iso - ITPC_pool_prop;

% pooled iso and propofol 
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

% non-parametric statsics statistics 
tempIso=squeeze(meanSpecPoolIso(epFreq,epTimeFrame));
tempProp=squeeze(meanSpecPoolProp(epFreq,epTimeFrame));
[pSpec, hSpec]=ranksum(tempIso(:), tempProp(:))

tempIso=squeeze(meanPoolIso(epFreq,epTimeFrame));
tempProp=squeeze(meanPoolProp(epFreq,epTimeFrame));
[pSpec, hSpec]=ranksum(tempIso(:), tempProp(:))

%% low iso-high iso

diff_isoCon_ITPCMatrix = meanLowIso- meanHighIso ;

% pooled iso and propofol 
ff = figure
plotTime = [750:1500];
timeAxis = linspace(-1+plotTime(1)*.001, -1+plotTime(end)*.001, numel(plotTime));
plotFreq = find(Freq>7 & Freq<150);%[1:length(Freq)];%
pcolor(timeAxis, Freq(plotFreq), diff_isoCon_ITPCMatrix(plotFreq, plotTime)); shading 'flat';
set(gca, 'yscale', 'log')
yticks([1, 5, 10, 20, 30, 40, 50, 100]);
xlabel('Time (s)')
ylabel('Frequency (Hz)')
c = colorbar
c.Label.String = 'Mean ITPC differnce (ITPC_l_o_w_ _i_s_o_ - ITPC_h_i_g_h_ _i_s_o_)'
title('Average ITPC differnce between low and high Isoflurane Concentrations')

%saveas(ff, [dirOut1, 'meanDiffITPCIsoVsProp', '.png'])

% non-parametric statsics statistics 
tempIso=squeeze(meanLowIso(epFreq,epTimeFrame));
tempProp=squeeze(meanHighIso(epFreq,epTimeFrame));
[pSpec, hSpec]=ranksum(tempIso(:), tempProp(:))


%% low prop-high prop

diff_propCon_ITPCMatrix = meanLowProp- meanHighProp ;

% pooled iso and propofol 
ff = figure
plotTime = [750:1500];
timeAxis = linspace(-1+plotTime(1)*.001, -1+plotTime(end)*.001, numel(plotTime));
plotFreq = find(Freq>7 & Freq<150);%[1:length(Freq)];%
pcolor(timeAxis, Freq(plotFreq), diff_propCon_ITPCMatrix(plotFreq, plotTime)); shading 'flat';
set(gca, 'yscale', 'log')
yticks([1, 5, 10, 20, 30, 40, 50, 100]);
xlabel('Time (s)')
ylabel('Frequency (Hz)')
c = colorbar
c.Label.String = 'Mean ITPC differnce (ITPC_l_o_w_ _p_r_o_p_ - ITPC_h_i_g_h_ _p_r_o_p_)'
title('Average ITPC differnce between low and high Propofol Concentrations')

%saveas(ff, [dirOut1, 'meanDiffITPCIsoVsProp', '.png'])

% non-parametric statsics statistics 
tempIso=squeeze(meanLowProp(epFreq,epTimeFrame));
tempProp=squeeze(meanHighProp(epFreq,epTimeFrame));
[pSpec, hSpec]=ranksum(tempIso(:), tempProp(:))

%% low iso-low prop

diff_lowCon_ITPCMatrix = meanLowIso- meanLowProp ;

% pooled iso and propofol 
ff = figure
plotTime = [750:1500];
timeAxis = linspace(-1+plotTime(1)*.001, -1+plotTime(end)*.001, numel(plotTime));
plotFreq = find(Freq>7 & Freq<150);%[1:length(Freq)];%
pcolor(timeAxis, Freq(plotFreq), diff_lowCon_ITPCMatrix(plotFreq, plotTime)); shading 'flat';
set(gca, 'yscale', 'log')
yticks([1, 5, 10, 20, 30, 40, 50, 100]);
xlabel('Time (s)')
ylabel('Frequency (Hz)')
c = colorbar
c.Label.String = 'Mean ITPC differnce (ITPC_l_o_w_ _i_s_o_ - ITPC_l_o_w_ _p_r_o_p_)'
title('Average ITPC differnce between low doses of Isoflurane and Propofol')

%saveas(ff, [dirOut1, 'meanDiffITPCIsoVsProp', '.png'])

% non-parametric statsics statistics 
tempIso=squeeze(meanLowIso(epFreq,epTimeFrame));
tempProp=squeeze(meanLowProp(epFreq,epTimeFrame));
[pSpec, hSpec]=ranksum(tempIso(:), tempProp(:))

%% high iso-high prop

diff_highCon_ITPCMatrix = meanHighIso- meanHighProp ;

% pooled iso and propofol 
ff = figure
plotTime = [750:1500];
timeAxis = linspace(-1+plotTime(1)*.001, -1+plotTime(end)*.001, numel(plotTime));
plotFreq = find(Freq>7 & Freq<150);%[1:length(Freq)];%
pcolor(timeAxis, Freq(plotFreq), diff_highCon_ITPCMatrix(plotFreq, plotTime)); shading 'flat';
set(gca, 'yscale', 'log')
yticks([1, 5, 10, 20, 30, 40, 50, 100]);
xlabel('Time (s)')
ylabel('Frequency (Hz)')
c = colorbar
c.Label.String = 'Mean ITPC differnce (ITPC_h_i_g_h_ _i_s_o_ - ITPC_h_i_g_h_ _p_r_o_p_)'
title('Average ITPC differnce between high doses of Isoflurane and Propofol')

%saveas(ff, [dirOut1, 'meanDiffITPCIsoVsProp', '.png'])

% non-parametric statsics statistics 
tempIso=squeeze(meanHighIso(epFreq,epTimeFrame));
tempProp=squeeze(meanHighProp(epFreq,epTimeFrame));
[pSpec, hSpec]=ranksum(tempIso(:), tempProp(:))

%% Non parameteric stats

for i = numSubjects
tempIso=squeeze(ITPC_pool_iso(i, epFreq,epTimeFrame));
tempProp=squeeze(ITPC_pool_prop(i, epFreq,epTimeFrame));
[p, h]=ranksum(tempIso(:), tempProp(:))
pValues(i) = p;
hValues(i) = h;
end

