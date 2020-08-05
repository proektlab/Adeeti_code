function [filtSig, info] = getAvgCohData(experiment, fr, stimIndex)

if nargin<3
    stimIndex = [0, Inf];
end
if nargin <2
    fr = 35;
end
%%

load(experiment, ['filtSig', num2str(fr)], 'info', 'indexSeries', 'uniqueSeries')
[indices] = getStimIndices(stimIndex, indexSeries, uniqueSeries);

eval(['sig =filtSig', num2str(fr),'(:,:,indices);']);
meanTotSig = squeeze(nanmean(sig,3));

s = std(meanTotSig(1:1000,:),1);
m = mean(meanTotSig(1:1000,:),1);

ztransform=(m-meanTotSig)./s;
filtSig(:,:) = ztransform;