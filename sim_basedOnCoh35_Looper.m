%% Test 1:

if ispc
    dirComp = 'Z:/adeeti/';
elseif isunix
    dirComp = '/synology/adeeti/';
end

USE_TWO_TRACES =1;

dirIn = [dirComp, 'ecog/iso_awake_VEPs/goodMice/'];
dirOut = [dirComp, 'ConnorCollab/LooperAn/'];
mkdir(dirOut)
cd(dirIn);
mouseID = 'GL13';

useTime = [950:1150];
shiftUnit = 1;
flashOn = 1000;
before = 50;
analyzeTime= 200;
shiftTime = [useTime(1):useTime(end)+analyzeTime];
noiseCo = 2*10^-3;
numTr = 18;

cd([dirIn, mouseID]);
load('dataMatrixFlashes.mat')

[expIDNum] = findExpIDNum(mouseID)

[isoHighExp, isoLowExp, emergExp, awaExp1, awaLastExp, ketExp] = ...
    findAnesArchatypeExp(dataMatrixFlashes, expIDNum);

MFE = [isoHighExp, isoLowExp, awaLastExp, ketExp];
useExp = awaLastExp;

cd([dirIn, mouseID, '/FiltData/']);
load([dataMatrixFlashes(awaLastExp).expName(1:end-4), 'wave.mat'], 'filtSig35', 'info')
goodChan = [1:64];
goodChan(info.noiseChannels) = [];

data35 = permute(filtSig35, [2,1,3]);
noNanData35 = data35(goodChan,useTime,:);
sig2shift_tr1 = squeeze(data35(info.lowLat,shiftTime,1));
sig2shift_tr2 = squeeze(data35(info.lowLat,shiftTime,2));

%to make one wave out of V1 wave shifted

tr1Ind = randsample(numTr, numTr/2);


%%
% Run looper on one wave
allDelTime = [2 5 7];
allDelCount = [1 2 5 7];
allNN = [6 8 10];

sim35WaveR2 = [];
sim35WaveNumLoops = [];
sim35WaveMapLoopsNum = [];
sim35WaveMapLoops =[];


for h = 1:2
    if h==1
        USE_TWO_TRACES =0;
    elseif h == 2
        USE_TWO_TRACES =1;
    end
    
    useBuffV1_noise = [];
    useBuffV1 = [];
    
    for tr = 1:numTr
        if ismember(tr,tr1Ind)
            useShiftData = sig2shift_tr1;
        else
            if USE_TWO_TRACES ==1
                useShiftData = sig2shift_tr2;
            else
                useShiftData = sig2shift_tr1;
            end
        end
        
        buffV1 = buffer(useShiftData, analyzeTime, analyzeTime-shiftUnit);
        buffV1 = buffV1(:, analyzeTime:end);
        
        useBuffV1(tr,:,:)= buffV1(1:64,:);
        useBuffV1_noise(tr,:,:) = buffV1(1:64,:) + normrnd(0,noiseCo,size(buffV1(1:64,:)));
    end
    
    % figure
    % plot(squeeze(useBuffV1_noise(:,1,:))')
    % hold on
    % plot(squeeze(useBuffV1(:,1,:))')
    
    %%
    
    for dT = 1:length(allDelTime)
        delTime = allDelTime(dT);
        for dC = 1:length(allDelCount)
            delCount = allDelCount(dC);
            for nn = 1:length(allNN)
                NN= allNN(nn);
                
                saveData = [];
                [params] = makeLooperParams(delTime, delCount, NN);
                
                LOOPER(saveData, true, useBuffV1_noise, [], [], params);
                
                %results
                sim35WaveR2(h,dT,dC,nn) = saveData.Ouputs.RSquared;
                sim35WaveNumLoops(h,dT,dC,nn) = saveData.BestLoopCount;
                sim35WaveMapLoopsNum(h,dT,dC,nn) = numel(unique(saveData.BestStateMap(:,1)));
                sim35WaveMapLoops{h,dT,dC,nn} = saveData.BestStateMap(:,1);
            end
        end
    end
end

save([dirOut, 'sim_35Coh_LOOPer.mat'], 'sim35WaveR2', 'sim35WaveNumLoops', ...
    'sim35WaveMapLoopsNum', 'sim35WaveMapLoops')
% figure
% plot(sim35WaveMapLoops)

%%
function [params] = makeLooperParams(DelayTime, DelayCount,NearestNeighbors)
params = [];

if nargin<3||isempty(NearestNeighbors)
    params.NearestNeighbors = NearestNeighbors;
else
    params.NearestNeighbors = [6];
end

if nargin<2||isempty(DelayCount)
    params.PreprocessData.DelayCount = [2];  %, 3, 5, 10];
else
    params.PreprocessData.DelayCount =DelayCount;
end

if nargin<1||isempty(DelayTime)
    params.PreprocessData.DelayTime = [5]; %, 5, 10, 15, 20, 30];
else
    params.PreprocessData.DelayTime = DelayTime;
end

params.PreprocessData.ZScore = 1; %or 0
params.PreprocessData.Smoothing = 0; %or 0 - this is in sigma
params.UseLocalDimensions =1; %will want this as 1
params.PutativeLoopCounts = [5,4,3,2,1];
params.UseTerminalState = 1;
params.TotalStates = 40;


end




