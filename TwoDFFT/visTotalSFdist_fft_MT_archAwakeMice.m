clear
clc
close all

%%
if isunix
    location = '/synology/adeeti/';
elseif ispc
    location = 'Z:/adeeti/';
end

dirMat = [location, '/spatialParamWaves/Awake/'];
dirIn = [dirMat, 'FFTs/'];
dirPic = [location, '/spatialParamWaves/images/agg2DFFTDist/Awake/'];

mkdir(dirPic)
norm2TotPower = 0;
numSets = 25;
tapers = 7;
inDims = [5000,2750];

interpBy = 50;
gridSpacing = 500;
samplingFreq = 1;
plotTime =50:200;
time4figs = -50:151;

cd(dirMat)
load('dataMatrixFlashes.mat')

cd(dirIn)
allData = dir('gab*');
%
allMice = unique([dataMatrixFlashes.exp]);

colorsPlot = {'k', 'b', 'r', 'g'};

titleString = {'High Isoflurane', 'High Iso CI', 'Low Isoflurane', 'Low  Iso CI', ...
    'Awake', 'Awake CI', 'Ketamine', 'Ketamine CI'};

%% for initializing sizes
[isoHighExp, isoLowExp, emergExp, awaExp1, awaLastExp, ketExp] = ...
    findAnesArchatypeExp(dataMatrixFlashes, allMice(10));

load(allData(isoHighExp).name, 'FFT2DcondFreqVect', 'MTcondFreqVect','info')

% MT_size= size(MTcondFreqVect,1);
FFT_size= size(FFT2DcondFreqVect,1);

%% Going through exp
for mouseID = 1:length(allMice)
    [isoHighExp, isoLowExp, emergExp, awaExp1, awaLastExp, ketExp] = ...
        findAnesArchatypeExp(dataMatrixFlashes, allMice(mouseID));
    
    MFE = [isoHighExp, isoLowExp, awaLastExp, ketExp];

    meanPreStimFFT = nan(length(MFE),FFT_size);
    stdPreStimFFT = nan(length(MFE),FFT_size);
    ub_preFFT =  nan(length(MFE),FFT_size);
    lb_preFFT = nan(length(MFE),FFT_size);
    
    meanPostStimFFT =nan(length(MFE),FFT_size);
    stdPostStimFFT = nan(length(MFE),FFT_size);
    ub_postFFT =  nan(length(MFE),FFT_size);
    lb_postFFT = nan(length(MFE),FFT_size);
    
%     meanPreStimMT = nan(length(MFE),MT_size);
%     stdPreStimMT = nan(length(MFE),MT_size);
%     ub_preMT =  nan(length(MFE),MT_size);
%     lb_preMT = nan(length(MFE),MT_size);
%     
%     meanPostStimMT = nan(length(MFE),MT_size);
%     stdPostStimM = nan(length(MFE),MT_size);
%     ub_postMT = nan(length(MFE),MT_size);
%     lb_postMT = nan(length(MFE),MT_size);
    
    allPowerFFT= nan(length(MFE), numSets, length(plotTime), FFT_size);
%     allPowerMT= nan(length(MFE),numSets, length(plotTime),MT_size);
    expTypeTracker = {};
    counter = 0;
    for expInd = 1:length(MFE)
        if isnan(MFE(expInd))
            continue
        end
        counter = counter+ 1;
        disp(allData(MFE(expInd)).name)
        expTypeTracker{counter} = titleString{2*expInd-1};
        counter = counter+ 1;
        expTypeTracker{counter} = titleString{2*expInd};
        
        for n =1:numSets
            load(allData(MFE(expInd)).name, 'FFT2DcondFreqVect', 'FFT2PowerAtFreq', ...
                'MTcondFreqVect', 'MTPowerAtFreq', 'info')
            allPowerFFT(expInd,:,:,:) = FFT2PowerAtFreq;
%             allPowerMT(expInd,:,:,:) = MTPowerAtFreq;
        end
    end
    
    %% finding the evoked power 
    preStimTime = 1:25;
    postStimTime = 60:150;
    
    preStimFFT = squeeze(nanmean(allPowerFFT(:,:,preStimTime,:),3));
    postStimFFT = squeeze(nanmean(allPowerFFT(:,:,postStimTime,:),3));
%     preStimMT = squeeze(nanmean(allPowerMT(:,:,preStimTime,:),3));
%     postStimMT = squeeze(nanmean(allPowerMT(:,:,postStimTime,:),3));
    
    %% Calculating mean and CIs
   for i = 1:length(MFE)
    meanPreStimFFT = squeeze(nanmean(preStimFFT,2));
     ub_preFFT(i,:) =  squeeze(quantile(preStimFFT(i,:,:), 0.95));
     lb_preFFT(i,:) = squeeze(quantile(preStimFFT(i,:,:), 0.05));
%     stdPreStimFFT = squeeze(nanstd(preStimFFT,0,2));%/sqrt(numSets);
%     ub_preFFT(i,:) =  squeeze(meanPreStimFFT(i,:))+ squeeze(stdPreStimFFT(i,:))*2;
%     lb_preFFT(i,:) = squeeze(meanPreStimFFT(i,:))- squeeze(stdPreStimFFT(i,:))*2;
    
    meanPostStimFFT = squeeze(nanmean(postStimFFT,2));
     ub_postFFT(i,:) =  squeeze(quantile(postStimFFT(i,:,:), 0.95));
     lb_postFFT(i,:) = squeeze(quantile(postStimFFT(i,:,:), 0.05));
%     stdPostStimFFT = squeeze(nanstd(postStimFFT,0,2));%/sqrt(numSets);
%     ub_postFFT(i,:) =  squeeze(meanPostStimFFT(i,:))+ squeeze(stdPostStimFFT(i,:))*2;
%     lb_postFFT(i,:) = squeeze(meanPostStimFFT(i,:))- squeeze(stdPostStimFFT(i,:))*2;
%     
%     meanPreStimMT = squeeze(nanmean(preStimMT,2));
%     stdPreStimMT = squeeze(nanstd(preStimMT,0,2))/sqrt(numSets);
%     ub_preMT(i,:) =  squeeze(meanPreStimMT(i,:))+ squeeze(stdPreStimMT(i,:))*2;
%     lb_preMT(i,:) = squeeze(meanPreStimMT(i,:))- squeeze(stdPreStimMT(i,:))*2;
%     
%     meanPostStimMT = squeeze(nanmean(postStimMT,2));
%     stdPostStimMT = squeeze(nanstd(postStimMT,0,2))/sqrt(numSets);
%     ub_postMT(i,:) =  squeeze(meanPostStimMT(i,:))+ squeeze(stdPostStimMT(i,:))*2;
%     lb_postMT(i,:) = squeeze(meanPostStimMT(i,:))- squeeze(stdPostStimMT(i,:))*2;
   end
    
    %% making figure
    ff= figure;
    ff.Position = [680,44,1239,934];
    ff.Color = 'White';
    
    subplot(2,1,1)
    for i = 1:4
        if isnan(meanPreStimFFT(i,1))
            continue
        end
        hold on
        plot(FFT2DcondFreqVect, squeeze(meanPreStimFFT(i,:)), colorsPlot{i}) 
        ciplot(squeeze(lb_preFFT(i,:)), squeeze(ub_preFFT(i,:)), FFT2DcondFreqVect, colorsPlot{i})
    end
    xlabel('Frequency')
    ylabel('Power')
    legend(expTypeTracker)
    title(['PreStim FFT'])
    
    subplot(2,1,2)
    for i = 1:4
        if isnan(meanPostStimFFT(i,1))
            continue
        end
        hold on
        plot(FFT2DcondFreqVect, squeeze(meanPostStimFFT(i,:)), colorsPlot{i})
        ciplot(squeeze(lb_postFFT(i,:)), squeeze(ub_postFFT(i,:)), FFT2DcondFreqVect, colorsPlot{i})
    end
    xlabel('Frequency')
    ylabel('Power')
    legend(expTypeTracker)
    title(['PostStim FFT'])
    
    
%     subplot(4,1,3)
%     for i = 1:4
%         if isnan(meanPreStimMT(i,1))
%             continue
%         end
%         hold on
%         plot(MTcondFreqVect, squeeze(meanPreStimMT(i,:)), colorsPlot{i})
%         ciplot(squeeze(lb_preMT(i,:)), squeeze(ub_preMT(i,:)), MTcondFreqVect, colorsPlot{i})
%     end
%     xlabel('Frequency')
%     ylabel('Power')
%     legend(expTypeTracker)
%     title(['PreStim 2DMT'])
%     
%     subplot(4,1,4)
%     for i = 1:4
%         if isnan(meanPostStimMT(i,1))
%             continue
%         end
%         hold on
%         plot(MTcondFreqVect, squeeze(meanPostStimMT(i,:)), colorsPlot{i})
%         ciplot(squeeze(lb_postMT(i,:)), squeeze(ub_postMT(i,:)), MTcondFreqVect, colorsPlot{i})
%     end
%     xlabel('Frequency')
%     ylabel('Power')
%     legend(expTypeTracker)
%     title(['PostStim 2DMT'])
    
    
    sgtitle(['Mouse ID: ' num2str(allMice(mouseID)), ', not tot power norm'])
    saveas(ff, [dirPic, 'Int50_SpFp_notTPnorm_GL', num2str(allMice(mouseID)), '.png'])
    
end
