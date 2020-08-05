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

load(allData(isoHighExp).name, 'FFT2DcondFreqVect', 'MTcondFreqVect','info')

% MT_size= size(MTcondFreqVect,1);
FFT_size= size(FFT2DcondFreqVect,1);

%% Going through exp
for mouseID = 1:length(allMice)
    [isoHighExp, isoLowExp, emergExp, awaExp1, awaLastExp, ketExp] = ...
        findAnesArchatypeExp(dataMatrixFlashes, allMice(mouseID));
    
    MFE = [isoHighExp, isoLowExp, awaLastExp, ketExp];

    allPowerFFT= nan(length(MFE), numSets, length(plotTime), FFT_size);
    allPowerFFT_normTP= nan(length(MFE), numSets, length(plotTime), FFT_size);

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
                'FFT2PowerAtFreq_normTP', 'info')
            allPowerFFT(expInd,:,:,:) = FFT2PowerAtFreq;
            allPowerFFT_normTP(expInd,:,:,:) = FFT2PowerAtFreq_normTP;

        end
    end
    
    [meanPreStimFFT, stdPreStimFFT, ub_preFFT, lb_preFFT, meanPostStimFFT, stdPostStimFFT, ub_postFFT, lb_postFFT] ...
    = makePlotsFromCondFFT(allPowerFFT, preStimTime, postStimTime);
    
    [meanPreStimFFT_normTP, stdPreStimFFT_normTP, ub_preFFT_normTP, lb_preFFT_normTP,...
        meanPostStimFFT_normTP, stdPostStimFFT_normTP, ub_postFFT_normTP, lb_postFFT_normTP] ...
    = makePlotsFromCondFFT(allPowerFFT_normTP, preStimTime, postStimTime);


    %% making figure
    ff= figure;
    ff.Position = [680,44,1239,934];
    ff.Color = 'White';
    
    subplot(4,1,1)
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
    title(['PreStim FFT not norm'])
    
    subplot(4,1,2)
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
    title(['PostStim FFT not norm'])
    
       subplot(4,1,3)
    for i = 1:4
        if isnan(meanPreStimFFT_normTP(i,1))
            continue
        end
        hold on
        plot(FFT2DcondFreqVect, squeeze(meanPreStimFFT_normTP(i,:)), colorsPlot{i}) 
        ciplot(squeeze(lb_preFFT_normTP(i,:)), squeeze(ub_preFFT_normTP(i,:)), FFT2DcondFreqVect, colorsPlot{i})
    end
    xlabel('Frequency')
    ylabel('Power')
    legend(expTypeTracker)
    title(['PreStim FFT norm to TP'])
    
    subplot(4,1,4)
    for i = 1:4
        if isnan(meanPostStimFFT_normTP(i,1))
            continue
        end
        hold on
        plot(FFT2DcondFreqVect, squeeze(meanPostStimFFT_normTP(i,:)), colorsPlot{i})
        ciplot(squeeze(lb_postFFT_normTP(i,:)), squeeze(ub_postFFT_normTP(i,:)), FFT2DcondFreqVect, colorsPlot{i})
    end
    xlabel('Frequency')
    ylabel('Power')
    legend(expTypeTracker)
    title(['PostStim FFT norm to TP'])

    sgtitle(['Mouse ID: ' num2str(allMice(mouseID))])
    saveas(ff, [dirPic, 'Int50_SpFp_GL', num2str(allMice(mouseID)), '.png'])
    
end
