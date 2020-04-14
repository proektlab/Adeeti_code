function [rawFiltDataTimes, interpFiltDataTimes, info] = makeStillEcogGrids(experiment, steps, fr, interpBy, stimIndex, BOOTSTRAP, NUM_BOOT)
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
