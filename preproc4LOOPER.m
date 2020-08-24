%% playing with LOOPER

if ispc
    dirComp = 'Z:/adeeti/';
elseif isunix
    dirComp = '/synology/adeeti/';
end

dirIn = [dirComp, 'ecog/iso_awake_VEPs/goodMice/'];
dirOut = [dirComp, 'ConnorCollab/LooperAn/'];

mkdir(dirOut)

cd(dirIn);
allMice = {'CB3', 'GL11', 'GL13', 'GL6', 'GL9'};

mInd = 3;

mouseID = allMice{mInd};
cd([dirIn, mouseID]);
load('dataMatrixFlashes.mat')

useTime = [950:1150];

[expIDNum] = findExpIDNum(mouseID)

[isoHighExp, isoLowExp, emergExp, awaExp1, awaLastExp, ketExp] = ...
    findAnesArchatypeExp(dataMatrixFlashes, expIDNum);

MFE = [isoHighExp, isoLowExp, awaLastExp, ketExp];
%%
for i = 1:length(MFE)
    if isnan(MFE(i))
        continue
    end
    
    cd([dirIn, mouseID]);
    load(dataMatrixFlashes(MFE(i)).expName, 'meanSubData', 'info')
    goodChan = [1:64];
     goodChan(info.noiseChannels) = [];
    if i ==1
        highIsoVEPs = permute(meanSubData, [1,3,2]);
        highIsoVEPs = highIsoVEPs(goodChan,useTime,:);
    elseif i ==2
        lowIsoVEPs = permute(meanSubData, [1,3,2]);
        lowIsoVEPs = lowIsoVEPs(goodChan,useTime,:);
    elseif i ==3
        awakeVEPs = permute(meanSubData, [1,3,2]);
        awakeVEPs = awakeVEPs(goodChan,useTime,:);
    elseif i ==4
        ketVEPs = permute(meanSubData, [1,3,2]);
        ketVEPs = ketVEPs(goodChan,useTime,:);
    end
    
    cd([dirIn, mouseID, '/FiltData/']);
     load([dataMatrixFlashes(MFE(i)).expName(1:end-4), 'wave.mat'], 'filtSig35', 'info')
     goodChan = [1:64];
     goodChan(info.noiseChannels) = [];
     
     if i ==1
        highIso35 = permute(filtSig35, [2,1,3]);
        highIso35 = highIso35(goodChan,useTime,:);
    elseif i ==2
        lowIso35 = permute(filtSig35, [2,1,3]);
        lowIso35 = lowIso35(goodChan,useTime,:);
    elseif i ==3
        awake35 = permute(filtSig35, [2,1,3]);
        awake35 = awake35(goodChan,useTime,:);
    elseif i ==4
        ket35 = permute(filtSig35, [2,1,3]);
        ket35 = ket35(goodChan,useTime,:);
    end

end

%%
numTr = 10;

useData = awake35;
size(useData)

trainTr = randsample(size(useData,3), numTr, 'false');
testTr = 1:size(useData,3);
testTr(trainTr) = [];
testTr = randsample(testTr, numTr, 'false');

trainData = useData(:,:,trainTr);
testData = useData(:,:,testTr);

disp('Done')

analytic35 = nan(size(useData));
for chan = 1:size(useData,1)
    for tr = 1:size(useData,3)
        analytic35(chan,:,tr) = hilbert(squeeze(useData(chan,:,tr)));
    end
end
amp35 = abs(analytic35);
phase35 = angle(analytic35);
img35 = imag(analytic35);
real35 = real(analytic35);

hilb35 = [real35;img35];

trainAnalytic35 = analytic35(:,:,trainTr);
trainAmp35 = amp35(:,:,trainTr);
trainHilb35 = hilb35(:,:,trainTr);

testAnalytic35 = analytic35(:,:,testTr);
testAmp35 = amp35(:,:,testTr);
testHilb35 = hilb35(:,:,testTr);

disp('Finished breaking up Phase and Amp')

%%
% uwphase35 = unwrap(phase35, [], 2);
% figure
% imagesc(squeeze(mean(uwphase35,3)))

% 
% figure 
% plot(squeeze(saveData.BestStateMap(:,1)))

%%


saveData = [];
params = [];

params.PreprocessData.DelayCount = [5];  %, 3, 5, 10];
params.PreprocessData.DelayTime = [10]; %, 5, 10, 15, 20, 30];
params.PreprocessData.ZScore = 1; %or 0
params.PreprocessData.Smoothing = 0; %or 0 - this is in sigma
params.UseLocalDimensions =1; %will want this as 1
params.PutativeLoopCounts = [5,4,3,2,1];
params.UseTerminalState = 1;
params.TotalStates = 40;

LOOPER(saveData, true, trainData, [], [], params);

saveData.BestStateMap(:,1);
numLoops = saveData.BestLoopCount
reconR2 = saveData.Ouputs.RSquared


