%% Creating and Saving zData
before=1;
l = 3;
flashOn = [0,0];
thresh=4;
maxThresh = 8;
consistent = 4;
endMeasure = 0.35;
allData = dir('2017*mat');

for exp = 1:length(allData)
    load(allData(exp).name)
    disp(['Loading ', allData(exp).name])
    [ zData, latency ] = normalizedThreshold(aveTrace, thresh, maxThresh, consistent, endMeasure, before, finalSampR);
    
    save(['/data/adeeti/ecog/matFlashesJanMar2017Again/', allData(exp).name], 'zData', '-append')
end
