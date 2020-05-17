%% Making movie heat plot of ITPC

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

allMiceAwa = [{'goodMice'}; {'maybeMice'}];

ident1Awa = '2019*';
ident2Awa = '2020*';
totMice = 11;
stimIndex = [0, Inf];
fr = 35;

screensize=get(groot, 'Screensize');

preStimTime = 1:800;
preStimTimeTr = 1:300;
epTime = 1000:1350;
thr_Multiply = [1, 1.5, 2, 2.5, 3];
numThr= length(thr_Multiply);


numChan = 64;
numTrials = 100;
totTimepts = 3001;
colorsPlot = {'k', 'b', 'r', 'g'};
titleString = {'H. Iso', 'L. Iso', 'Awake', 'Ket'};

allCond= length(titleString);

pSpread = nan(totMice,numThr);
P_RS_Spread= nan(totMice,numThr,allCond,allCond);
H_RS_Spread= nan(totMice, numThr,allCond,allCond);
pEct = nan(totMice,numThr);

mkdir(dirPicLoc);

%%
mouseCounter = 0;
allMiceIDs = {}
for g = 1:length(allMiceAwa)
    genDirM = [genDirAwa, (allMiceAwa{g}), '/'];
    cd(genDirM)
    allDir = [dir('GL*'); dir('IP*');dir('CB*')];
    
    if g == 1
        startD = 1;
    else
        startD = 1;
    end
    
    for d = startD:length(allDir)
        mouseID = allDir(d).name;
        disp(mouseID)
        dirIn = [genDirM, mouseID, '/'];
        
        mouseCounter = mouseCounter+1;
        allMiceIDs{mouseCounter} = mouseID;
        %% finding the correct experiments
        cd(dirIn)
        load('dataMatrixFlashes.mat')
        
        [isoHighExp, isoLowExp, emergExp, awaExp1, awaLastExp, ketExp] = findAnesArchatypeExp(dataMatrixFlashes);
        
        MFE = [isoHighExp, isoLowExp, awaLastExp, ketExp];

        
        %% finding filtered data
        dirFILT = [dirIn,'FiltData/'];
        cd(dirFILT)
        
        allData = dir(ident1Awa);
        identifier = ident1Awa;
        
        if isempty(allData)
            allData = dir(ident2Awa);
            identifier = ident2Awa;
        end
        
        useTitleString= {};
        allExpNum= sum(~isnan(MFE));
        allCond= length(MFE);
        
        
        allExpH = nan(allCond,numChan,numTrials,totTimepts);
        
        allInd =nan(allCond,numThr,numTrials,numChan);
        allSortPeakTimes = nan(allCond,numThr,numTrials,numChan);
        allSpread= nan(allCond,numThr,numTrials,numChan);   
        
        allConsistElec = nan(numThr,allCond,numChan);
        
        %% find power for gamma
        counterExp = 0;
        validExpInd = [];
        for a = 1:length(MFE)
            if isnan(MFE(a))
                continue
            end
            
            validExpInd = [validExpInd, a];
            counterExp = counterExp +1;
            useTitleString{counterExp} = titleString{a};
            
            experiment = allData(MFE(a)).name;
            disp(experiment(1:end-8));
            
            load(experiment, ['filtSig', num2str(fr)], 'info', 'indexSeries', 'uniqueSeries')
            goodChan = info.ecogChannels;
            goodChan(info.noiseChannels)= [];
            numGoodChan= numel(goodChan);
            
            [indices] = getStimIndices(stimIndex, indexSeries, uniqueSeries);
            % randTrials = randsample(indices, 2);
            
            eval(['sig =filtSig', num2str(fr),'(:,:,indices);']);
            s = std(sig(preStimTime,:,:),[],1);
            m = mean(sig(preStimTime,:,:),1);
            
            ztransform=(m-sig)./s;
            filtSig= ztransform;
            
            analytSig = hilbert(filtSig);
            
            ampH = abs(analytSig);
            phaseH = angle(analytSig);
            
            ampH = permute(ampH, [2,3,1]);
            phaseH = permute(phaseH, [2,3,1]);
            
            if sum(size(squeeze(allExpH(a,:,:,:))) ==size(ampH)) ==3
                allExpH(a,:,:,:) = ampH;
            else
                for j = 1:size(ampH,2)
                    allExpH(a,:,j,:) = ampH(:,j,:);
                end
            end
            
            for t = 1:numThr
                for j = 1:size(ampH,2)
                    thresh = nanmean(max(squeeze(ampH(:,j,preStimTimeTr)),[],2))*thr_Multiply(t);
                    for i = 1:size(ampH,1)
                        useAmp = squeeze(ampH(i, j, epTime));
                        if isnan(useAmp(1))
                            allPeakTimes(i) = nan;
                            tempSpread(i) = nan;
                        else
                            [pks,locs] = findpeaks(useAmp);
                            temp = locs(find(pks > thresh, 1, 'first'));
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
                    
                    
                    allInd(a,t,j,:) = Ind;
                    allSortPeakTimes(a,t,j,:) = sortPeakTimes;
                    allSpread(a,t,j,:) = tempSpread;
                end
            end
        end
        
        %% stats
        for t = 1:numThr
            testSpread = squeeze(nanmean(allSpread(:,t,:,:),4));  %validExpInd
            testSpread = testSpread';
            pSpread(mouseCounter,t) = kruskalwallis(testSpread);
            
            for i = 1:length(MFE)
                for j = i+1:length(MFE)
                    if isnan(MFE(i)) || isnan(MFE(j))
                        continue
                    end
                    [pTemp, hTemp, stats]=ranksum(testSpread(:,i), testSpread(:,j));
                   
                    P_RS_Spread(mouseCounter,t,i,j) = pTemp;
                    H_RS_Spread(mouseCounter,t,i,j) = hTemp;
                end
            end
            
            consitSpread = squeeze(nansum(allSpread(:,t,:,:),3));
            allConsistElec(t,:,:) = consitSpread;
            
            pEct(mouseCounter,t) = kruskalwallis(consitSpread');
            
        end
        
        %% Looking at number of electrodes activated per each trial - spread 
        
        %         close all
        %         plotTime = [970:1200];
        %         maxCutPVal = 0.0001;
        %         edges = 0:0.05:1;
        %         ff= figure;
        %         clf
        %         ff.Color = 'White';
        %         ff.Position = [1 -138 827 954]; %screensize;
        %
        %         useChanNum = min(20,numGoodChan);
        %         counter = 0;
        %         for t= 1:numThr
        %             if pSpread(t) <maxCutPVal
        %                 pSpread(t) = maxCutPVal;
        %             end
        %             for a = 1:allExpNum
        %                 counter = counter +1;
        %                 b(counter)= subplot(numThr,allExpNum,a+(t-1)*allExpNum);
        %                 h(counter) = histogram(squeeze(nanmean(allSpread(a,t,:,:),3)),edges);
        %                 % set(gca, ylim
        %
        %                 if t ==1
        %                     title([useTitleString{a}, ' Thr: ', num2str(thr_Multiply(t)), ' p=', num2str(pSpread(t))])
        %                 elseif a ==2 && t~=1
        %                     title([' Thr: ', num2str(thr_Multiply(t)), ' p=', num2str(pSpread(t))])
        %                 end
        %             end
        %         end
        %
        %         sgtitle([mouseID, ' Fraction of Active Electrodes'])
        %         saveas(ff, [dirPicLoc, mouseID, '_ST_numElec_multThr.png'])
        
        
        %% Looking at how many trials each electrodes was active on  - for ind electrodes
%         close all
%         maxCutPVal = 0.0001;
%         edges = 0:0.05:1;
%         ff= figure;
%         clf
%         ff.Color = 'White';
%         ff.Position = screensize;
%         
%         useChanNum = min(20,numGoodChan);
%         
%         for t= 1:numThr
%             if pEct(t) <maxCutPVal
%                 pEct(t) = maxCutPVal;
%             end
%             b(t)= subplot(1,numThr,t);
%             counter = 0;
%             for a = 1:length(MFE)
%                 if(isnan(MFE(a)))
%                     continue
%                 end
%                 counter = counter +1;
%             plot(squeeze(allConsistElec(t,counter,:))', colorsPlot{a}) ;
%             hold on
%             end
%             
%             legend(useTitleString)
%             set(gca, 'ylim', [min(allConsistElec(:)), max(allConsistElec(:))])
%             title([' Thr: ', num2str(thr_Multiply(t)), ' p=', num2str(pEct(t))])
%         end
%         sgtitle([mouseID, ' activity pattern of electrodes'])
%           saveas(ff, [dirPicLoc, mouseID, '_ST_whichElec_multThr.png'])
        
        %% Looking at fraction of trials electrodes were active on 
        
                close all
                ff= figure('Color', 'w', 'Position', screensize);
                clf
        
                counter = 0;
                edges = 0:5:100;
                
                for t= 1:numThr
                    b(t)= subplot(1,numThr,t);
                    for a = 1:allExpNum
                        counter = counter +1;
                        histogram(allConsistElec(t,a,:), edges, 'FaceColor', colorsPlot{a})
                        hold on 
                        legend(useTitleString)
                        title([' Thr: ', num2str(thr_Multiply(t))])
%                         if t ==1
%                             title([useTitleString{a}, ' Thr: ', num2str(thr_Multiply(t)), ' p=', num2str(pSpread(t))])
%                         elseif a ==2 && t~=1
%                             title([' Thr: ', num2str(thr_Multiply(t)), ' p=', num2str(pSpread(t))])
%                         end
                    end
                end
        
                sgtitle([mouseID, ' Fraction of trials each electrode is active'])
                saveas(ff, [dirPicLoc, mouseID, '_ST_fracTrEleActive_multThr.png'])
        
    end
end


%%

%%

close all

titleThresh = [];
for i = 1:length(thr_Multiply)
titleThresh{i} = ['Thresh = ', num2str(thr_Multiply(i))];
end
[ff, pTable] = deconstPspreadTable(P_RS_Spread, [], [1:3], titleString, titleThresh,allMiceIDs);
%% 
