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

preStimTime = 1:25;
postStimTime = 60:150;

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

load(allData(isoHighExp).name, 'FFT2DcondFreqVect','info')
FFT_size= size(FFT2DcondFreqVect,1);

%% Going through exp
for mouseID = 1:length(allMice)
    [isoHighExp, isoLowExp, emergExp, awaExp1, awaLastExp, ketExp] = ...
        findAnesArchatypeExp(dataMatrixFlashes, allMice(mouseID));
    
    MFE = [isoHighExp, isoLowExp, awaLastExp, ketExp];

    allPowerFFT= nan(length(MFE), numSets, length(plotTime), FFT_size);
    allPowerFFT_normTP= nan(length(MFE), numSets, length(plotTime), FFT_size);
    
    allPostStimOverPreStim= nan(length(MFE), numSets, FFT_size);

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
                'FFT2PowerAtFreq_normTP')
            allPowerFFT(expInd,:,:,:) = FFT2PowerAtFreq;
           % allPowerFFT_normTP(expInd,:,:,:) = FFT2PowerAtFreq_normTP;
           
           allPostStimOverPreStim(expInd,n,:) = squeeze(nanmean(allPowerFFT(expInd,n,postStimTime,:),3))...
               ./squeeze(nanmean(allPowerFFT(expInd,n,preStimTime,:),3));
        end
    end
    
    baselineNormPost= nan(length(MFE),size(allPowerFFT,4));
    ub_baseNormPost = nan(size(baselineNormPost));
    lb_baseNormPost = nan(size(baselineNormPost));
    
    for i = 1:length(MFE)
        baselineNormPost = nanmean(allPostStimOverPreStim,2);
        
        % ub_baseNormPost(i,:) = squeeze(baselineNormPost(i,:))+ squeeze(stdPostStimFFT(i,:))*0.95;
        % lb_baseNormPost(i,:) = squeeze(baselineNormPost(i,:))- squeeze(stdPostStimFFT(i,:))*0.95;
        
        ub_baseNormPost(i,:) =  squeeze(quantile(allPostStimOverPreStim(i,:,:), 0.95));
        lb_baseNormPost(i,:) = squeeze(quantile(allPostStimOverPreStim(i,:,:), 0.05));
    end
%     [meanPreStimFFT, stdPreStimFFT, ub_preFFT, lb_preFFT, meanPostStimFFT, stdPostStimFFT, ub_postFFT, lb_postFFT] ...
%     = makePlotsFromCondFFT(allPowerFFT, preStimTime, postStimTime);

%     [meanPreStimFFT_normTP, stdPreStimFFT_normTP, ub_preFFT_normTP, lb_preFFT_normTP,...
%         meanPostStimFFT_normTP, stdPostStimFFT_normTP, ub_postFFT_normTP, lb_postFFT_normTP] ...
%     = makePlotsFromCondFFT(allPowerFFT_normTP, preStimTime, postStimTime);


    %% making figure
    ff= figure;
    ff.Position = [680,44,1239,934];
    ff.Color = 'White';
    
    for i = 1:4
        if isnan(baselineNormPost(i,1))
            continue
        end
        hold on
        plot(FFT2DcondFreqVect, squeeze(baselineNormPost(i,:)), colorsPlot{i})
        ciplot(squeeze(lb_baseNormPost(i,:)), squeeze(ub_baseNormPost(i,:)), FFT2DcondFreqVect, colorsPlot{i})
    end
    xlabel('Frequency')
    ylabel('Power')
    legend(expTypeTracker)
    title(['PostStim FFT norm to baseline'])
    
    sgtitle(['Mouse ID: ' num2str(allMice(mouseID))])
    saveas(ff, [dirPic, 'baseNorm_SpFp_GL', num2str(allMice(mouseID)), '.png'])
    
end
