if isunix
    dirIn = '/synology/adeeti/spatialParamWaves/Awake/';
    dirPic = '/synology/adeeti/spatialParamWaves/images/2DFFTMovies/Awake/';
elseif ispc
    dirIn = 'Z:/adeeti/spatialParamWaves/Awake/';
    dirPic = 'Z:\adeeti\spatialParamWaves\images\2DFFTMovies\Awake\';
end

mkdir(dirPic)

cd(dirIn)
allData = dir('gab*.mat');
load('dataMatrixFlashes.mat')

%%
allMice = [6, 9, 13];

interpBy = 3;
gridSpacing = 500;
samplingFreq = 1;
plotTime =50:350;
tapers = 9;
inDims = [5000, 2750];

for mouseID = 1:length(allMice)
    [isoHighExp, isoLowExp, emergExp, awaExp1, awaLastExp, ketExp] = ...
        findAnesArchatypeExp(dataMatrixFlashes, allMice(mouseID));
    
    MFE = [isoHighExp, isoLowExp, awaLastExp, ketExp];
    titleString = {'High Isoflurane', 'Low Isoflurane', 'Awake', 'Ketamine'};
    
    %% load each mouse and compute MTSpectrum
    for expInd = 1:length(MFE)
        clearvars interpFiltDataTimes xFreq yFreq ompMTSpec allSpecShift ...
            fullFFTXscale fullFFTYscale validIndX validIndY info
        
        load(allData(MFE(expInd)).name, 'interpFiltDataTimes', 'xFreq', ...
            'yFreq', 'compMTSpec', 'allSpecShift','fullFFTXscale', 'fullFFTYscale', ...
            'validIndX', 'validIndY', 'info')
        
        disp(allData(MFE(expInd)).name)
        movieToFit = interpFiltDataTimes;
        compImage(expInd,:,:,:) = movieToFit(plotTime,:,:);
        
        
        %% vectorize the MTP sepc
        [condFreqVect_MTEXP, powerAtCondFreq_MTEXP, freqGrid]= ... 
            spectrumSub2FreqDistance(squeeze(compMTSpec(expInd,:,:,:)),xFreq, yFreq);
%         figure
%         plot(condFreqVect_MTEXP, powerAtCondFreq_MTEXP)
        
        MTcondFreqVect = condFreqVect_MTEXP;
        MTPowerAtFreq(expInd,:,:) = powerAtCondFreq_MTEXP;
        
        %% vectorize the 2DFFT sepc
        [condFreqVect_2DFFTEXP, powerVect_2DFFTEXP, ~]= ...
            spectrumSub2FreqDistance(squeeze(allSpecShift), fullFFTXscale(validIndX), fullFFTYscale(validIndY));
%         figure
%         plot(condFreqVect_2DFFTEXP, powerVect_2DFFTEXP)
        
        FFT2DcondFreqVect = condFreqVect_2DFFTEXP;
        FFT2PowerAtFreq(expInd,:,:) = powerVect_2DFFTEXP;
        
        %%
    end

    %% make movie
    f = figure; clf
    f.Position = [292 388 1557 595];
    
    clear movieOutput
    
    for TP2comp = 1:size(compImage,2)
        for expInd = 1:length(MFE)
            subplot(2,1,1)
            plot(FFT2DcondFreqVect, squeeze(FFT2PowerAtFreq(:,TP2comp,:)))
            xlabel('Frequency')
            ylabel('Power')
            legend('High Iso', 'Low Iso', 'Awake', 'Ketamine')
            title(['2DFFT'])
            
            
            subplot(2,1,2)
            plot(MTcondFreqVect, squeeze(MTPowerAtFreq(:,TP2comp,:)))
            xlabel('Frequency')
            ylabel('Power')
            legend('High Iso', 'Low Iso', 'Awake', 'Ketamine')
            title(['Multitaper'])
                 
        end
        sgtitle(['Spatial Freq Inpter by 3, GL', num2str(allMice(mouseID)), ' Timepoint: ', num2str(TP2comp-50)])
        drawnow
        pause(0.25);
        movieOutput(TP2comp) = getframe(gcf);
    end
    v = VideoWriter([dirPic, 'Int3_compGL' num2str(allMice(mouseID)), '_rawSFDist.avi']);
    
    open(v)
    if sum(size(movieOutput(1).cdata) == size(movieOutput(2).cdata)) ==3
        writeVideo(v,movieOutput(2:end))
    else
        writeVideo(v,movieOutput)
    end
    close(v)
    
                %%
                close all
            ff= figure
             subplot(2,2,1)
            plot(FFT2DcondFreqVect, squeeze(sum(FFT2PowerAtFreq(:,1:50,:),2)))
            xlabel('Frequency')
            ylabel('Power')
            legend('High Iso', 'Low Iso', 'Awake', 'Ketamine')
            title(['2DFFT baseline'])
            
            subplot(2,2,2)
            plot(FFT2DcondFreqVect, squeeze(sum(FFT2PowerAtFreq(:,51:end,:),2)))
            xlabel('Frequency')
            ylabel('Power')
            legend('High Iso', 'Low Iso', 'Awake', 'Ketamine')
            title(['2DFFT post stim'])
            
            
            subplot(2,2,3)
            plot(MTcondFreqVect, squeeze(sum(MTPowerAtFreq(:,1:50,:),2)))
            xlabel('Frequency')
            ylabel('Power')
            legend('High Iso', 'Low Iso', 'Awake', 'Ketamine')
            title(['Multitaper baseline'])
             sgtitle(['Spatial Freq, GL', num2str(allMice(mouseID)), ' Timepoint: ', num2str(TP2comp-50)])
             
            subplot(2,2,4)
            plot(MTcondFreqVect, squeeze(sum(MTPowerAtFreq(:,51:end,:),2)))
            xlabel('Frequency')
            ylabel('Power')
            legend('High Iso', 'Low Iso', 'Awake', 'Ketamine')
            title(['Multitaper post stim'])
             sgtitle(['Spatial Freq Inpter by 3, GL', num2str(allMice(mouseID))])

            saveas(ff, [dirPic, 'Int3_SpatFreq_GL', num2str(allMice(mouseID)), '.png'])
    close all
end
