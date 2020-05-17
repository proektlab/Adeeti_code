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
        titleString = {'High Isoflurane', 'Low Isoflurane', 'Awake', 'Ketamine'};
        
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
        
        counter = 0;
        allExp =[];
        useTitleString= {};
        allInd =[];
         allSortPeakTimes = [];
         
        
        for a = 1:length(MFE)
            if isnan(MFE(a))
                continue
            end
            counter = counter +1;
            useTitleString{counter} = titleString{a};

            experiment = allData(MFE(a)).name;
            disp(experiment(1:end-8));
            
            [filtSig, info] = getAvgCohData(experiment, fr);
            
             goodChan = info.ecogChannels;
             goodChan(info.noiseChannels)= [];
             numGoodChan= numel(goodChan);

            analytSig= hilbert(filtSig);
            ampH = abs(analytSig);
            phaseH = angle(analytSig);
            
            ampH =ampH';
            phaseH =phaseH';
            
            allExpH(counter,:,:) = ampH;
            
            epTime = 1000:1350;
            preStim = 1:1000;
            thresh = nanmean(max(ampH,[],2));
            
            for i = 1:size(ampH,1)
                useAmp = squeeze(ampH(i,epTime));
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
            allInd(counter,:) = Ind;
            allSortPeakTimes(counter,:) = sortPeakTimes;
        end
        allExp = counter;
        %%
        close all
        plotTime = [970:1200];
        ff= figure;
        clf
        ff.Color = 'White';
        ff.Position = [1 -138 691 954];
       
        
        for a = 1:allExp
            useH = squeeze(allExpH(a,:,:));
            upY =  max(max(useH(:,plotTime)));
            lowY= min(min(useH(:,plotTime)));
            
            for i = 1:numGoodChan
                h(i)= subplot(numGoodChan,allExp,allExp*(i-1)+a);
                plot(squeeze(useH(allInd(a,i),plotTime)), 'linewidth', 1.5)
                hold on
                plot( [1000-plotTime(1),1000-plotTime(1)], [lowY, upY], 'g')
                set(gca, 'ylim', [lowY, upY])
                ylabel(num2str(allInd(a,i)))
                axis off
                h(i).YAxis.Label.Visible='on';
                if i ==1
                    title(useTitleString{a})
                end
            end
        end
        sgtitle([mouseID, 'Hilbert Envelope'])
        saveas(ff, [dirPicLoc, mouseID, 'HilbEnv.png'])
    end
end
