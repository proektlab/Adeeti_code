function [filtSig] = getAvgCohData(experiment, fr)

load(experiment, ['filtSig', num2str(fr)], 'info', 'indexSeries', 'uniqueSeries')
[indices] = getStimIndices(stimIndex, indexSeries, uniqueSeries);

eval(['sig =filtSig', num2str(fr),'(:,:,indices);']);
meanTotSig = squeeze(nanmean(sig,3));
s = std(meanTotSig(1:1000,:),1);

data_sig = squeeze(nanmean(sig,3));

m = mean(data_sig(1:1000,:),1);
ztransform=(m-data_sig)./s;
filtSig(:,:) = ztransform;