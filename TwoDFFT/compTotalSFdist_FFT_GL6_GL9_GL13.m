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

interpBy = 100;
gridSpacing = 500;
samplingFreq = 1;
plotTime =50:350;
tapers = 9;
inDims = [5000, 2750];
norm2TotPower =1;

for mouseID = 1:length(allMice)
    [isoHighExp, isoLowExp, emergExp, awaExp1, awaLastExp, ketExp] = ...
        findAnesArchatypeExp(dataMatrixFlashes, allMice(mouseID));
    
    MFE = [isoHighExp, isoLowExp, awaLastExp, ketExp];
    titleString = {'High Isoflurane', 'Low Isoflurane', 'Awake', 'Ketamine'};
    
    %% load each mouse and compute MTSpectrum
    for expInd = 1:length(MFE)
        clearvars allSpecShift fullFFTXscale fullFFTYscale validIndX validIndY info
        
        load(allData(MFE(expInd)).name, 'allSpecShift', 'fullFFTXscale', ...
            'fullFFTYscale', 'validIndX', 'validIndY', 'info')
        
        disp(allData(MFE(expInd)).name)
        %movieToFit = interp100FiltDataTimes;
        %compImage(expInd,:,:,:) = movieToFit(plotTime,:,:);
        
        
        %% vectorize the 2DFFT sepc
        [condFreqVect_2DFFTEXP, powerVect_2DFFTEXP, ~]= ...
            spectrumSub2FreqDistance(squeeze(allSpecShift), fullFFTXscale(validIndX), ...
            fullFFTYscale(validIndY), norm2TotPower);
%         figure
%         plot(condFreqVect_2DFFTEXP, powerVect_2DFFTEXP)
        
        FFT2DcondFreqVect = condFreqVect_2DFFTEXP;
        FFT2PowerAtFreq(expInd,:,:) = powerVect_2DFFTEXP;
        
        %%
    end

    %% make movie
%     f = figure; clf
%     f.Position = [292 388 1557 595];
%     
%     clear movieOutput
%     
%     for TP2comp = 1:size(compImage,2)
%         for expInd = 1:length(MFE)
%             plot(FFT2DcondFreqVect, squeeze(FFT2PowerAtFreq(:,TP2comp,:)))
%             xlabel('Frequency')
%             ylabel('Power')
%             legend('High Iso', 'Low Iso', 'Awake', 'Ketamine')
%             title(['2DFFT'])
%                  
%         end
%         sgtitle(['Spatial Freq Inpter by 3, GL', num2str(allMice(mouseID)), ' Timepoint: ', num2str(TP2comp-50)])
%         drawnow
%         pause(0.25);
%         movieOutput(TP2comp) = getframe(gcf);
%     end
%     v = VideoWriter([dirPic, 'Int100_compGL' num2str(allMice(mouseID)), '_rawSF_FFT_Dist.avi']);
%     
%     open(v)
%     if sum(size(movieOutput(1).cdata) == size(movieOutput(2).cdata)) ==3
%         writeVideo(v,movieOutput(2:end))
%     else
%         writeVideo(v,movieOutput)
%     end
%     close(v)
%     
                %%
                close all
                
                meanBaseline = squeeze(mean(FFT2PowerAtFreq(:,1:25,:),2));
                stdBaseline = squeeze(std(FFT2PowerAtFreq(:,1:25,:),0,2));
                meanPostStim = squeeze(mean(FFT2PowerAtFreq(:,51:150,:),2));
                baseNormPostStim = meanPostStim./meanBaseline;
                zPostStim = (meanPostStim-meanBaseline)./stdBaseline;
                
                
            ff= figure
            ff.Position = [680,44,1239,934];
            ff.Color = 'White'
             subplot(4,1,1)
            plot(FFT2DcondFreqVect, meanBaseline)
            xlabel('Frequency')
            ylabel('Power')
            legend('High Iso', 'Low Iso', 'Awake', 'Ketamine')
            title(['2DFFT baseline'])
            
%             ff= figure
%              subplot(3,1,1)
%             plot(FFT2DcondFreqVect, squeeze(mean(FFT2PowerAtFreq(:,1:25,:),2)))
%             xlabel('Frequency')
%             ylabel('Power')
%             legend('High Iso', 'Low Iso', 'Awake', 'Ketamine')
%             title(['2DFFT baseline'])
            
            subplot(4,1,2)
            plot(FFT2DcondFreqVect, meanPostStim)
            xlabel('Frequency')
            ylabel('Power')
            legend('High Iso', 'Low Iso', 'Awake', 'Ketamine')
            title(['2DFFT post stim 100 ms'])
            
             subplot(4,1,3)
            plot(FFT2DcondFreqVect, baseNormPostStim)
            xlabel('Frequency')
            ylabel('Power')
            legend('High Iso', 'Low Iso', 'Awake', 'Ketamine')
            title(['2DFFT poststim/prestim'])
            
             subplot(4,1,4)
            plot(FFT2DcondFreqVect, zPostStim)
            xlabel('Frequency')
            ylabel('Power')
            legend('High Iso', 'Low Iso', 'Awake', 'Ketamine')
            title(['2DFFT zpostStim'])
           
           
           saveas(ff, [dirPic, 'Int3_SpatFreq_FFT_first100ms_bsNorm_GL', num2str(allMice(mouseID)), '.png'])
   %close all
end
