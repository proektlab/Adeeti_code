%% Test 1 - one sim planer wave with noise 
useH = 2;


sim35WaveR2;
sim35WaveNumLoops;
sim35WaveMapLoopsNum;
sim35WaveMapLoops;

allDelTime = [2 5 7];
allDelCount = [1 2 5 7];
allNN = [6 8 10];

%% One wave
useH = 2;
useN = 1

%number of loops that LOOPER finds 
totLoops = squeeze(sim35WaveNumLoops(useH,:,:,useN)) %this is zero - not one
allR2 = squeeze(sim35WaveR2(useH,:,:,useN))
allMapLoops = squeeze(sim35WaveMapLoopsNum(useH,:,:,useN))


%% two waves
useH = 1
useN = 1

%number of loops that LOOPER finds 
totLoops = squeeze(twoWaveNumLoops(useH,:,:,useN)) %this is zero - not one
allR2 = squeeze(twoWaveR2(useH,:,:,useN))
allMapLoops = squeeze(twoWaveMapLoopsNum(useH,:,:,useN))


%%
mkdir(dirOut)
save([dirOut, 'simWavesLooper.mat'], 'oneWaveR2','oneWaveNumLoops',...
    'oneWaveMapLoopsNum', 'oneWaveMapLoops', 'twoWaveR2',...
    'twoWaveNumLoops', 'twoWaveMapLoopsNum', 'twoWaveMapLoops')