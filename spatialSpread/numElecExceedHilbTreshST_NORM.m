%% In how many electrodes does the gamma power exceed a preset threshold done on a single trial level
% Here, the hibert of single trials  are taken to find the gamma amplitude
% for each trial. Then the single trials are z scored to the average and
% std of the single trial amplitude 
% Thresh = mean of prestim data overall trials over all channels - differnt
% for each channel (but should be almost zero because z score) - then stds
% taken above that 

%% Make movie of mean signal at 30-40 Hz for all experiments
clear
clc
close all
if isunix && ~ismac
    dataLoc = '/synology/';
    codeLoc = '/synology/code/';
elseif ispc
    dataLoc = 'Z:\';
    codeLoc = 'Z:\code\';
end

genDirAwa = [dataLoc, 'adeeti/ecog/iso_awake_VEPs/'];
outlineLoc = [codeLoc, 'Adeeti_code/'];
dirPicLoc = [dataLoc, 'adeeti/ecog/images/Iso_Awake_VEPs/spatialParams/'];
mkdir(dirPicLoc);

normToMeanOfTrials = 1;
USE_JUST_GOODMICE = 1;
USE_EMERG = 1;

preStimTime = 1:350;
preStimTimeTr = preStimTime;
epTime = 1000:1350;
thr_Multiply = [3, 5, 6];


%%

if USE_JUST_GOODMICE ==1
    allMiceAwa = [{'goodMice'}]; %; {'maybeMice'}];
    totMice = 5;
else
    allMiceAwa = [{'goodMice'}; {'maybeMice'}];
    totMice = 11;
end

ident1Awa = '2019*';
ident2Awa = '2020*';

stimIndex = [0, Inf];
fr = 35;

numThr= length(thr_Multiply);

numChan = 64;
totTimepts = 3001;

if USE_EMERG ==1
numTrials = 238;
colorsPlot = {'k', 'b', 'm', 'r', 'g'};
titleString = {'H. Iso', 'L. Iso', 'Emerg', 'Awake', 'Ket'};
else 
    numTrials = 100;
colorsPlot = {'k', 'b', 'r', 'g'};
titleString = {'H. Iso', 'L. Iso', 'Awake', 'Ket'};
end

allCond= length(titleString);
allBaseGammaPower= nan(totMice,allCond,numChan);

useTitleString= {};

%%
allExpH = nan(totMice,allCond,numChan,numTrials,totTimepts);
allInd =nan(totMice,allCond,numThr,numTrials,numChan);
allSortPeakTimes = nan(totMice,allCond,numThr,numTrials,numChan);
allSpread= nan(totMice,allCond,numThr,numTrials,numChan);
fracGridSpread = nan(totMice,numThr,allCond,numTrials);
allConsistElec = nan(totMice,numThr,allCond,numChan);

pSpd_frElctAct = nan(totMice,numThr);
P_RS_Spread= nan(totMice,numThr,allCond,allCond);
H_RS_Spread= nan(totMice, numThr,allCond,allCond);

pEct = nan(totMice,numThr);
P_RS_ConsitEl= nan(totMice,numThr,allCond,allCond);
H_RS_ConsitEl= nan(totMice, numThr,allCond,allCond);

numTrials_mouse = nan(totMice,allCond);
numChannels_mouse = nan(totMice,allCond);

allAmpOnly = nan(totMice,allCond,numTrials);


%%
mouseCounter = 0;
allMiceIDs = {};
for g = 1:length(allMiceAwa)
    genDirM = [genDirAwa, (allMiceAwa{g}), '/'];
    cd(genDirM)
    allDir = [dir('GL*'); dir('IP*');dir('CB*')];
    startD = 1;
    for d = startD:length(allDir)
        mouseID = allDir(d).name;
        disp(mouseID)
        dirIn = [genDirM, mouseID, '/'];
        
        mouseCounter = mouseCounter+1;
        allMiceIDs{mouseCounter} = mouseID;
       
        cd(dirIn)
        load('dataMatrixFlashes.mat')
        
        [isoHighExp, isoLowExp, emergExp, awaExp1, awaLastExp, ketExp] = ...
            findAnesArchatypeExp(dataMatrixFlashes);
        if USE_EMERG ==1
            MFE = [isoHighExp, isoLowExp, emergExp, awaLastExp, ketExp];
        else
            MFE = [isoHighExp, isoLowExp, awaLastExp, ketExp];
        end
        
        % finding filtered data
        dirFILT = [dirIn,'FiltData/'];
        cd(dirFILT)
        
        allData = dir(ident1Awa);
        if isempty(allData)
            allData = dir(ident2Awa);
        end
        
        % find power for gamma
        counterExp = 0;
        for a = 1:length(MFE)
            if isnan(MFE(a))
                continue
            end
            counterExp = counterExp +1;
            useTitleString{mouseCounter}{counterExp} = titleString{a};
            
            experiment = allData(MFE(a)).name;
            disp(experiment(1:end-8));
            
            load(experiment, ['filtSig', num2str(fr)], 'info', 'indexSeries', 'uniqueSeries')
            [indices] = getStimIndices(stimIndex, indexSeries, uniqueSeries);
            % randTrials = randsample(indices, 2);
            
            eval(['sig =filtSig', num2str(fr),'(:,:,indices);']);
            
            analytSig = hilbert(sig);
            ampH_raw = abs(analytSig);


%             forNormAmp = permute(ampH_raw(preStimTime,:,:), [2,3,1]);
%             forNormAmp = reshape(forNormAmp, [numChan, size(forNormAmp,2)*numel(preStimTime)]);
%             s_con = std(forNormAmp,[],2);
%             m_con = mean(forNormAmp,2);
%             s_con = s_con';
%             m_con = m_con';

            
%             meanAmp = nanmean(ampH_raw,3);
%             s = std(meanAmp(preStimTime,:),[],1);
%             m = mean(meanAmp(preStimTime,:),1);
%             allBaseGammaPower(mouseCounter, a, :) = m;
            
             meanAmp_tr = squeeze(nanmean(ampH_raw(preStimTime,:,:),1));
            s = std(meanAmp_tr,[],2);
            m = mean(meanAmp_tr,2);
            m = m';
            s = s';
            allBaseGammaPower(mouseCounter, a, :) = m;
            
            ztransform=(ampH_raw- repmat(m, [size(ampH_raw,1), 1,size(ampH_raw,3)]))./repmat(s,[size(ampH_raw,1), 1,size(ampH_raw,3)]);
            ampH = ztransform;
            
            ampH = permute(ampH, [2,3,1]);
            %  phaseH = permute(phaseH, [2,3,1]);
            
            if sum(size(squeeze(allExpH(mouseCounter,a,:,:,:))) ==size(ampH)) ==3
                allExpH(mouseCounter, a,:,:,:) = ampH;
            else
                for j = 1:size(ampH,2)
                    allExpH(mouseCounter,a,:,j,:) = ampH(:,j,:);
                end
            end
            
            for t = 1:numThr
                baseM = nanmean(nanmean(ampH(:,:,preStimTimeTr),3),2);
                %allBaseGammaPower(mouseCounter, a, :) = baseM;
                thresh = baseM+thr_Multiply(t);
                for j = 1:size(ampH,2)
                    %thresh = nanmean(max(squeeze(ampH(:,j,preStimTimeTr)),[],2))*thr_Multiply(t);
                    %thresh = baseM+thr_Multiply(t);
                    for i = 1:size(ampH,1)
                        useAmp = squeeze(ampH(i, j, epTime));
                        if isnan(useAmp(1))
                            allPeakTimes(i) = nan;
                            tempSpread(i) = nan;
                        else
                            [pks,locs] = findpeaks(useAmp);
                            temp = locs(find(pks > thresh(i), 1, 'first'));
                            if isempty(temp)
                                allPeakTimes(i) = epTime(end)-epTime(1);
                                tempSpread(i) = 0;
                            else
                                allPeakTimes(i) = temp;
                                tempSpread(i) = 1;
                            end
                        end
                    end
                    [sortPeakTimes,Ind] = sort(allPeakTimes);
                    
                    allInd(mouseCounter,a,t,j,:) = Ind;
                    allSortPeakTimes(mouseCounter,a,t,j,:) = sortPeakTimes;
                    allSpread(mouseCounter,a,t,j,:) = tempSpread;
                    
                    allAmpOnly(mouseCounter,a,j) = nansum(nansum(ampH(:,j,epTime)));
                end
            end
        end
    end
end


