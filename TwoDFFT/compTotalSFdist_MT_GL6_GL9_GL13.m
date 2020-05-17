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

%interpBy = 3;
gridSpacing = 500;
samplingFreq = 1;
plotTime =50:350;
tapers = 9;
inDims = [5000, 2750];
norm2TotPower =1;

for mouseID = 1%:length(allMice)
    [isoHighExp, isoLowExp, emergExp, awaExp1, awaLastExp, ketExp] = ...
        findAnesArchatypeExp(dataMatrixFlashes, allMice(mouseID));
    
    MFE = [isoHighExp, isoLowExp, awaLastExp, ketExp];
    titleString = {'High Isoflurane', 'Low Isoflurane', 'Awake', 'Ketamine'};
    MTPowerAtFreq = [];
    %% load each mouse and compute MTSpectrum
    for expInd = 1:length(MFE)
        clearvars  xFreq yFreq ompMTSpec allSpecShift ...
            fullFFTXscale fullFFTYscale validIndX validIndY info
        
        load(allData(MFE(expInd)).name, 'xFreq', ...
            'yFreq', 'compMTSpec', 'info')
        
        disp(allData(MFE(expInd)).name)
        %movieToFit = interpFiltDataTimes;
        %compImage(expInd,:,:,:) = movieToFit(plotTime,:,:);
        
        
        %% vectorize the MTP sepc
        [condFreqVect_MTEXP, powerAtCondFreq_MTEXP, freqGrid]= ... 
            spectrumSub2FreqDistance(squeeze(compMTSpec),xFreq, yFreq, norm2TotPower);
%         figure
%         plot(condFreqVect_MTEXP, powerAtCondFreq_MTEXP)
        
        MTcondFreqVect = condFreqVect_MTEXP;
        MTPowerAtFreq(expInd,:,:) = powerAtCondFreq_MTEXP;
    end

    %% make movie
%     f = figure; clf
%     f.Position = [292 388 1557 595];
%     
%     clear movieOutput
%     
%     for TP2comp = 1:size(compImage,2)
%         for expInd = 1:length(MFE)
%             plot(MTcondFreqVect, squeeze(MTPowerAtFreq(:,TP2comp,:)))
%             xlabel('Frequency')
%             ylabel('Power')
%             legend('High Iso', 'Low Iso', 'Awake', 'Ketamine')
%             title(['Multitaper'])
%                  
%         end
%         sgtitle(['Spatial Freq Inpter by 100, GL', num2str(allMice(mouseID)), ' Timepoint: ', num2str(TP2comp-50)])
%         drawnow
%         pause(0.25);
%         movieOutput(TP2comp) = getframe(gcf);
%     end
%     v = VideoWriter([dirPic, 'Int100_compGL' num2str(allMice(mouseID)), '_rawSFDist.avi']);
%     
%     open(v)
%     if sum(size(movieOutput(1).cdata) == size(movieOutput(2).cdata)) ==3
%         writeVideo(v,movieOutput(2:end))
%     else
%         writeVideo(v,movieOutput)
%     end
%     close(v)
    
                %%
            close all
                
                meanBaseline = squeeze(sum(MTPowerAtFreq(:,1:25,:),2));
                stdBaseline = squeeze(std(MTPowerAtFreq(:,1:25,:),0,2));
                meanPostStim = squeeze(mean(MTPowerAtFreq(:,51:150,:),2));
                baseNormPostStim = meanPostStim./meanBaseline;
                zPostStim = (meanPostStim-meanBaseline)./stdBaseline;
                
                
            ff= figure
            ff.Position = [680,44,1239,934];
            ff.Color = 'White';
             subplot(4,1,1)
            plot(MTcondFreqVect, meanBaseline)
            xlabel('Frequency')
            ylabel('Power')
            legend('High Iso', 'Low Iso', 'Awake', 'Ketamine')
            title(['2DMT baseline'])
            
%             ff= figure
%              subplot(3,1,1)
%             plot(FFT2DcondFreqVect, squeeze(mean(FFT2PowerAtFreq(:,1:25,:),2)))
%             xlabel('Frequency')
%             ylabel('Power')
%             legend('High Iso', 'Low Iso', 'Awake', 'Ketamine')
%             title(['2DFFT baseline'])
            
            subplot(4,1,2)
            plot(MTcondFreqVect, meanPostStim)
            xlabel('Frequency')
            ylabel('Power')
            legend('High Iso', 'Low Iso', 'Awake', 'Ketamine')
            title(['2MT post stim 100 ms'])
            
             subplot(4,1,3)
            plot(MTcondFreqVect, baseNormPostStim)
            xlabel('Frequency')
            ylabel('Power')
            legend('High Iso', 'Low Iso', 'Awake', 'Ketamine')
            title(['2DMT poststim/prestim'])
            
             subplot(4,1,4)
            plot(MTcondFreqVect, zPostStim)
            xlabel('Frequency')
            ylabel('Power')
            legend('High Iso', 'Low Iso', 'Awake', 'Ketamine')
            title(['2DMT zpostStim'])
            
            if norm2TotPower==1
            sgtitle(['GL', num2str(allMice(mouseID)), ' Normalized to total power'])
            else
                 sgtitle(['GL', num2str(allMice(mouseID)), ' not norm to total power'])
            end
            
            
            %saveas(ff, [dirPic, 'Int100_SpFq_MT_bsandTPNorm_GL', num2str(allMice(mouseID)), '.png'])

end
