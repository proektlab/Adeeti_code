function [singleTrials, info] = makeStillEcogGrids_singleTr(experiment, steps, fr, interpBy, stimIndex)
% [rawFiltDataTimes, interpFiltDataTimes, info, singleTrials] = makeStillEcogGrids(experiment, steps, ...
% fr, interpBy, stimIndex, BOOTSTRAP, NUM_BOOT, compRaw, justTrials)
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

eval(['sigTest =filtSig', num2str(fr),'(:,:,indices);']);

sig4SingTr = sigTest;
singleTrials = nan(size(sigTest,3), length(steps), 11*interpBy, 6*interpBy);
for m = 1:size(singleTrials,1)
    disp(['Tr: ', num2str(m)])
    for t = 1:length(steps)
        [~, gridTrial] = plotOnGridInterp(squeeze(sig4SingTr(steps(t),:,m)), 1, info.gridIndicies, interpBy);
        singleTrials(m,t,:,:) = gridTrial;
    end
end




