function [rawFiltDataTimes, interpFiltDataTimes, info] = makeStillEcogGrids(experiment, steps, fr, interpBy, stimIndex, BOOTSTRAP, NUM_BOOT)
% [rawFiltDataTimes, interpFiltDataTimes, info] = makeStillEcogGrids(experiment, steps, fr, interpBy, stimIndex, BOOTSTRAP, NUM_BOOT)
% make sure in filtered data folder; will load filtered data at part freq,
% average over trials (with or without bootstrapping) and then interpolate
% signal and give raw signal 
% experiment = experiment name 
% steps = timepoints you want (default = 900:1300)
% fr = freq of filtSig (default = 35)
% interpBy = amount ot interp (default = 3)
% stimIndex = stimulus ID (default = [0 Inf])
% BOOTSTRAP = 1 if want to bootstrap trials for average, 0 if not ((default = 0)
% NUM_BOOT = how many bootstraps you want (default = 1)


if nargin<7
    NUM_BOOT = 1;
end
if nargin <6
    BOOTSTRAP = 0;
end
if nargin <5
    stimIndex = [0, Inf];
end
if nargin<4
    interpBy = 3;
end
if nargin <3
    fr = 3;
end
if nargin <2
    steps = 900:1400;
end



%% to make an average of signal at coherent bands
load(experiment, ['filtSig', num2str(fr)], 'info', 'indexSeries', 'uniqueSeries')
[indices] = getStimIndices(stimIndex, indexSeries, uniqueSeries);

eval(['sig =filtSig', num2str(fr),'(:,:,indices);']);
meanTotSig = squeeze(nanmean(sig,3));
s = std(meanTotSig(1:1000,:),1);

interpFiltDataTimes = nan(NUM_BOOT, length(steps), 11*interpBy, 6*interpBy);
rawFiltDataTimes = nan(NUM_BOOT, length(steps), 11, 6);

for n = 1:NUM_BOOT
    if BOOTSTRAP ==1
        boot_ind  = randsample(size(sig, 3),size(sig, 3), true);
        data_sig = sig(:,:,boot_ind);
    end
    
    data_sig = squeeze(nanmean(sig,3));
    
    m = mean(data_sig(1:1000,:),1);
    ztransform=(m-data_sig)./s;
    filtSig(n,:,:) = ztransform;
    
    %% setting up grid position matrix with data for gabor fitting
    for t = 1:length(steps) %time before in ms:size(meanSubData,3)
        [~, interpValuesFine] = plotOnGridInterp(squeeze(filtSig(n, steps(t),:)), 1, info.gridIndicies, interpBy);
        interpFiltDataTimes(n, t,:,:) = interpValuesFine;
    end
    interpFiltDataTimes = squeeze(interpFiltDataTimes);
    
    for t = 1:length(steps) %time before in ms:size(meanSubData,3)
        [ ~, ~, gridData] = PlotOnECoG(squeeze(filtSig(n, steps(t),:)), info, 3, 1);
        rawFiltDataTimes(n, t,:,:) = gridData;
    end
    rawFiltDataTimes = squeeze(rawFiltDataTimes);
end
