%% playing with LOOPER


dirIn = 'Z:\adeeti\ecog\iso_awake_VEPs\goodMice\';
cd(dirIn);
allMice = {'CB3', 'GL11', 'GL13', 'GL6', 'GL9'};

mInd = 3;

mouseID = allMice{mInd};
cd([dirIn, mouseID]);
load('dataMatrixFlashes.mat')

useTime = [950:1150];

if contains(mouseID, 'GL')
    expIDNum = str2num(mouseID(3:end))
    expIDNum = -expIDNum;
elseif contains(mouseID, 'CB')
    expIDNum = str2num(mouseID(3:end))
elseif contains(mouseID, 'IP')
    expIDNum = 0;
end

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
    
    cd([dirIn, mouseID, '\FiltData\']);
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
% 
% avgAwake35 = squeeze(mean(awake35,3));
% 
% figure
% imagesc(avgAwake35);

useData = ket35;
size(useData)

choseTr = randsample(size(useData,3), 30, 'false');
testTr = 1:size(useData,3);
testTr(choseTr) = [];

testTr = randsample(length(testTr), 30, 'false');

smallData = useData(:,:,choseTr);
size(smallData)

testData = useData(:,:,testTr);

%smallData = smallData(useChan,:,:);

%smallData(:,:, 15) = [];


%%
analytic35 = nan(size(useData));
for chan = 1:size(useData,1)
    for tr = 1:size(useData,3)
        analytic35(chan,:,tr) = hilbert(squeeze(useData(chan,:,tr)));
    end
end

amp35 = abs(analytic35);
phase35 = angle(analytic35);
img35 = imag(analytic35);

testAmp35 = amp35(:,:,testTr);
trainAmp35 = amp35(:,:,choseTr);






figure
plot(squeeze(useData(1,:,1)))
hold on 
plot(squeeze(amp35(1,:,1)))

figure
imagesc(squeeze(mean(amp35, 2)))

figure
plot(squeeze(mean(mean(amp35, 2),3)))



%%
hib35 = [amp35; phase35];

uwphase35 = unwrap(phase35, [], 2);
figure
imagesc(squeeze(mean(uwphase35,3)))


figure
imagesc(squeeze(mean(hib35, 3)));









