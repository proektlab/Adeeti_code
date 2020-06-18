

baselinetTime = 1:351;
epTime = 500:850;
N = 10;

load('gaborCoh2019-07-26_14-00-00.mat')
Grid = info.gridIndicies;
BadChannels = info.noiseChannels;
Channels = info.channels;

ogData = permute(interp3Coh35, [2, 3, 1]);
size(ogData)
concatData =  reshape(ogData, [18*33, 1501]);

figure 
imagesc(concatData)

data = concatData(:,epTime);

rearr2gr = 0;

[SVDout, SpatialAmp, SpatialPhase, TemporalAmp, TemporalPhase,GridOut ] = ...
    WaveSVD(data, N, rearr2gr, Grid, BadChannels, Channels);

U = SVDout.U;
S = SVDout.S;
V = SVDout.V;

numModes = 3;
useS = S;
useS(:,numModes+1:end) = 0;

reconstData = U*useS*V';
[reconFiltSig] = hilbert2filtsig(reconstData);

figure
subplot(2,1,1)
imagesc(data)
subplot(2,1,2)
imagesc(reconFiltSig);

reconGrid = reshape(reconFiltSig, [33,18,length(epTime)]);

figure
for t = 1:length(epTime)
    subplot(1,2,1)
    imagesc(squeeze(ogData(:,:,epTime(t))))
title(['OG Time = ', num2str(t)])

    subplot(1,2,2)
imagesc(squeeze(reconGrid(:,:,t)))
title(['Reconstr Time = ', num2str(t)])
pause(0.01)
end


%%

interpBy = 3;
rearrange2Gr =1;
N = 6;

[concatChanTimeData, interpGridInd] = makeInterpGridInd(interp3Coh35, interpBy, info.gridIndicies);
%%
[SVDout, SpatialAmp, SpatialPhase, TemporalAmp, TemporalPhase,GridOut ] = ...
    WaveSVD(concatChanTimeData, N, rearrange2Gr, interpGridInd, info.noiseChannels, info.channels);



%%

useSpaAmp = squeeze(SpatialAmp(:,1));

for i = 1:size(interpGridInd,1)
    for j = 1:size(interpGridInd,2)
        gridData(i,j,:) = useSpaAmp(interpGridInd(i,j),:);
    end
end

figure
imagesc(gridData)








