%% Stats on ITPC measures and making graphs for each experiment

clc
clear
close all

dirIn = '/data/adeeti/ecog/matIsoPropMultiStim/';
dirOut1 = '/data/adeeti/ecog/images/IsoPropMultiStim/localITPC/V1withStats';

cd(dirIn)
load('dataMatrixFlashes.mat')
load('matStimIndex.mat')

lowestLatVariable = 'lowLat';

USE_SINGLE_EXP = 0; %1 if want to specifically write in experiments, 0 if want to loop through
experiment = [];

stimIndex = [0, Inf]; %if want all, stimIndex = matStimIndex; % if want
%all uniStimIndexes/multiStimIndexes, use [uniStimIndex, multiStimIndex] =
%findUniMutliStimIndex(matStimIndex), [stimIndex, ~] = findUniMutliStimIndex(matStimIndex)

drug = 'prop';

%% Setting up parameters

allExp = [];
if exist('stimIndex')  && ~isempty(stimIndex)
    for i = 1:size(stimIndex,1)
        [MFE] = findMyExpMulti(dataMatrixFlashes, [], drug, [], stimIndex(i,:));
        allExp = [allExp, MFE];
    end
else
    [MFE] = 1:length(dataMatrixFlashes);
end

mkdir(dirOut1);
%% parameters for bootstrapping

for experiment = 12%:length(allExp)
    load(dataMatrixFlashes(allExp(experiment)).expName, 'info', 'uniqueSeries', 'indexSeries', 'meanSubData', 'smallSnippits')
    
    [indices] = getStimIndices(stimIndex, indexSeries, uniqueSeries);
    useMeanSubData = meanSubData(:, indices,:);
    useSmallSnippits = smallSnippits(:, indices,:);
    
    totTrialsPerExp = size(useMeanSubData, 2);
    trialsPerSamp = totTrialsPerExp;
    totSamp = 1000;
    
    channels = info.lowLat;
    
    %% Making fake data flashes onsets (rand time of starts)
    
    [fakeSnippits] = makeFakeSnippits(useMeanSubData, useSmallSnippits);
    
    %% Run wavelet on fake data
    fakeWAVE=zeros(40, 2001, size(fakeSnippits,1), size(fakeSnippits,2));
    for i=1:size(fakeWAVE,3)
        disp(i);
        for j = 1:size(fakeSnippits,2)
            sig=detrend(squeeze(fakeSnippits(i, j,:)));
            % [temp,PERIOD,SCALE,COI,DJ, PARAMOUT, K] = contwt(sig,1/1000,1, 0.1);
            [temp,PERIOD,SCALE,COI,DJ, PARAMOUT, K] = contwt(sig,1/1000,1, 0.25);
            fakeWAVE(:,:,i, j)=temp; %WAVE is in freq by time by channels by trials
            Freq=1./PERIOD;
        end
    end
    
    %% Run wavelet on real data
    WAVE=zeros(40, 2001, size(useSmallSnippits,1), size(useSmallSnippits,2));
    for i=1:size(WAVE,3)
        disp(i);
        for j = 1:size(useSmallSnippits,2)
            sig=detrend(squeeze(useSmallSnippits(i, j,:)));
            % [temp,PERIOD,SCALE,COI,DJ, PARAMOUT, K] = contwt(sig,1/1000,1, 0.1);
            [temp,PERIOD,SCALE,COI,DJ, PARAMOUT, K] = contwt(sig,1/1000,1, 0.25);
            WAVE(:,:,i, j)=temp; %WAVE is in freq by time by channels by trials
            Freq=1./PERIOD;
        end
    end
    
    %% Run ITPC on fake data
    clear exp
    
    statsFakeITPC = nan(totSamp, length(channels), size(WAVE, 1), size(WAVE, 2));
    
    for i = 1:totSamp
        trials = randsample(totTrialsPerExp, trialsPerSamp, 'true');
        %     useWAVE = fakeWAVE(:, :, : , trials);
        [ITPCmeasures] = ITPC_AA(fakeWAVE, channels, trials);
        statsFakeITPC(i, :, :, :) = ITPCmeasures;
        disp(['Calculating ', num2str(i), ' out of ', num2str(totSamp)])
    end
    
    % fakeITPC = ITPC_AA(fakeWAVE);
    
    stErrorFakeITPC = squeeze(std(statsFakeITPC, [], 1));
    meanFakeITPC = squeeze(mean(statsFakeITPC, 1));
    
    %% Run ITPC on real data
    clear exp
    
    statsRealITPC = nan(totSamp, length(channels), size(WAVE, 1), size(WAVE, 2));
    
    for i = 1:totSamp
        trials = randsample(totTrialsPerExp, trialsPerSamp, 'true');
        %     useWAVE = fakeWAVE(:, :, : , trials);
        [ITPCmeasures] = ITPC_AA(WAVE, channels, trials);
        statsRealITPC(i, :, :, :) = ITPCmeasures;
        disp(['Calculating ', num2str(i), ' out of ', num2str(totSamp)])
    end
    
    trueITPC = ITPC_AA(WAVE);
    
    stErrorRealITPC = squeeze(std(statsRealITPC, [], 1));
    meanRealITPC = squeeze(mean(statsRealITPC, 1));
    
    %ztrueITPC = (squeeze(trueITPC(15,:,:)) - meanFakeITPC) ./ stErrorFakeITPC; %zcores for the real data
    
    %% T test to compare how real data compares with fake data
    % Welch's t test- equal sample size, unequal variances
    
    tVals = (meanRealITPC- meanFakeITPC)./sqrt((stErrorFakeITPC.^2+stErrorRealITPC.^2));
    pVals = tcdf(tVals,trialsPerSamp-1);
    
    %% plotting and shit
    % plot results
    ff = figure;
   % ff.Renderer='Painters';
    clf
    use_p_value = 1;
    
    h1= subplot(3,1,1)
    plot(squeeze(mean(useSmallSnippits(channels,:,:),2)));
    colorbar
    title('Average trace')
    
    
    h2 = subplot(3, 1, 2)
    pcolor(1:size(useSmallSnippits,3), Freq, squeeze(trueITPC(channels,:,:))); shading 'flat';
    set(gca, 'yscale', 'log')
    colorbar
    title('True ITPC')
    
    h3=  subplot(3, 1, 3)
    if use_p_value == 1;
        pcolor(1:size(useSmallSnippits,3), Freq, log10(squeeze(1-pVals))); shading 'flat';
        set(gca, 'yscale', 'log')
        colorbar
        title('P-Value ITPC')
        set(gca,'clim',[-8 0])
    else
        pcolor(1:size(useSmallSnippits,3), Freq, squeeze(tVals)); shading 'flat';
        set(gca, 'yscale', 'log')
        colorbar
        title('t-Value ITPC')
    end
    suptitle(['ITPC for channel ', num2str(channels)])
    
    linkaxes([h1 h2 h3], 'x')
    set(gca, 'xlim', [0, 2001])
    linkaxes
    %saveas(ff, [dirOut1, 'ITPCsingleTrialOnlyGamma', info.expName, '.png'])
    
    saveas(ff, [dirOut1, 'ITPCforF30', '.pdf'])
    
end