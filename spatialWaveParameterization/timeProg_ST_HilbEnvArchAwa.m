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
stimIndex = [0, Inf];

stimIndex = [0, Inf];

%trial = 50;
fr = 35;
screensize=get(groot, 'Screensize');
%interpBy = 3;
interpBy = 100;
steps = [900:1300];

colorsPlot = {'k', 'b', 'r', 'g'};

mkdir(dirPicLoc);


%%
for g = 1:length(allMiceAwa)
    genDirM = [genDirAwa, (allMiceAwa{g}), '/'];
    cd(genDirM)
    allDir = [dir('GL*'); dir('IP*');dir('CB*')];
    
    for d = 1:length(allDir)
        mouseID = allDir(d).name;
        disp(mouseID)
        dirIn = [genDirM, mouseID, '/'];
        
        %% finding the correct experiments
        cd(dirIn)
        load('dataMatrixFlashes.mat')
        
        [isoHighExp, isoLowExp, emergExp, awaExp1, awaLastExp, ketExp] = findAnesArchatypeExp(dataMatrixFlashes);
        
        MFE = [isoHighExp, isoLowExp, awaLastExp, ketExp];
        titleString = {'H. Iso', 'L. Iso', 'Awake', 'Ket'};
        
        %% finding filtered data
        dirFILT = [dirIn,'FiltData/'];
        cd(dirFILT)
        
        allData = dir(ident1Awa);
        identifier = ident1Awa;
        
        if isempty(allData)
            allData = dir(ident2Awa);
            identifier = ident2Awa;
        end
        %% Finding correct experiments, loading data, detrending (mean subtracting), ...
        %  decimating, and bootstrap avgs/sliding window avgs
        
        counterExp = 0;
        allExpNum =[];
        allExpH = [];
        useTitleString= {};
        allInd =[];
        allSortPeakTimes = [];
        
        for a = 1:length(MFE)
            if isnan(MFE(a))
                continue
            end
            counterExp = counterExp +1;
            useTitleString{counterExp} = titleString{a};
            
            experiment = allData(MFE(a)).name;
            disp(experiment(1:end-8));
            
            load(experiment, ['filtSig', num2str(fr)], 'info', 'indexSeries', 'uniqueSeries')
            goodChan = info.ecogChannels;
            goodChan(info.noiseChannels)= [];
            numGoodChan= numel(goodChan);
            
            
            [indices] = getStimIndices(stimIndex, indexSeries, uniqueSeries);
            randTrials = randsample(indices, 2);
            
            
            eval(['sig =filtSig', num2str(fr),'(:,:,randTrials);']);
            s = std(sig(1:1000,:,:),[],1);
            m = mean(sig(1:1000,:,:),1);
            
            ztransform=(m-sig)./s;
            filtSig= ztransform;
            
            analytSig = hilbert(filtSig);
            
            ampH = abs(analytSig);
            phaseH = angle(analytSig);
            
            ampH = permute(ampH, [2,3,1]);
            phaseH = permute(phaseH, [2,3,1]);
%%
            allExpH(counterExp,:,:,:) = ampH;
            
            epTime = 1000:1350;
            preStim = 1:1000;
            
            for j = 1:size(ampH,2)
                thresh = nanmean(max(squeeze(ampH(:,j,preStim)),[],2));
                for i = 1:size(ampH,1)
                    useAmp = squeeze(ampH(i, j, epTime));
                    if isnan(useAmp(1))
                        allPeakTimes(i) = nan;
                    else
                        [pks,locs] = findpeaks(useAmp);
                        temp = locs(find(pks > thresh, 1, 'first'));
                        if isempty(temp)
                            allPeakTimes(i) = 350;
                        else
                            allPeakTimes(i) = temp;
                        end
                    end
                end
                
                
                [sortPeakTimes,Ind] = sort(allPeakTimes);
                if unique(Ind) ==0
                    Ind = goodChan;
                end
                allInd(counterExp,j,:) = Ind;
                allSortPeakTimes(counterExp,j,:) = sortPeakTimes;
            end
        end
        allExpNum = counterExp;
        %%
        close all
        plotTime = [970:1200];
        ff= figure;
        clf
        ff.Color = 'White';
        ff.Position = [1 -138 827 954]; %screensize;
        
        useChanNum = min(20,numGoodChan);
        
        for a = 1:allExpNum
            for j = 1:size(allInd,2)
                useH = squeeze(allExpH(a,:,j,:));
                upY =  max(max(useH(:,plotTime)));
                %upY = 0.95*upY;
                lowY= min(min(useH(:,plotTime)));
                for i = 1:useChanNum
                    h(i)= subplot(useChanNum,allExpNum*size(allInd,2),allExpNum*2*(i-1)+(a*2-1)+(j-1));
                    plot(squeeze(useH(allInd(a,j,i),plotTime)), 'linewidth', 1.5)
                    hold on
                    plot( [1000-plotTime(1),1000-plotTime(1)], [lowY, upY], 'g')
                    set(gca, 'ylim', [lowY, upY])
                    ylabel(num2str(allInd(a,j,i)))
                    axis off
                    h(i).YAxis.Label.Visible='on';
                    if i ==1
                        title([useTitleString{a}, ' Tr ', num2str(j)])
                    end
                end
            end
        end
        sgtitle([mouseID, 'Hilbert Envelope'])
        saveas(ff, [dirPicLoc, mouseID, '_ST_HilbEnv.png'])
    end
end
