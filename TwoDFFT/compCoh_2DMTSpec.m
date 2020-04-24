
if isunix
    dirIn = '/synology/adeeti/GaborTests/Awake/';
    dirPic = '/synology/adeeti/GaborTests/images/2DFFTMovies/Awake/';
elseif ispc
    dirIn = 'Z:/adeeti/GaborTests/Awake/';
    dirPic = 'Z:\adeeti\GaborTests\images\2DFFTMovies\Awake\';
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

for mouseID = 2:length(allMice)
    [isoHighExp, isoLowExp, emergExp, awaExp1, awaLastExp, ketExp] = findAnesArchatypeExp(dataMatrixFlashes, allMice(mouseID));
    
    MFE = [isoHighExp, isoLowExp, awaLastExp, ketExp];
    titleString = {'High Isoflurane', 'Low Isoflurane', 'Awake', 'Ketamine'};
    
    %% load each mouse and compute MTSpectrum
    for expInd = 1:length(MFE)
        load(allData(MFE(expInd)).name, 'interp100FiltDataTimes', 'info')
        disp(allData(MFE(expInd)).name)
        movieToFit = interp100FiltDataTimes;
        compImage(expInd,:,:,:) = movieToFit(plotTime,:,:);
        
        for TP2comp = 1:length(plotTime)
            testImage = squeeze(compImage(expInd,TP2comp,:,:));
            av = nansum(testImage(:)) / length(testImage(:));
            dcRem_testImage = testImage - av;
            
            [Out] = mtImageFFT_AA(dcRem_testImage,tapers, inDims, [], []);
            
            if TP2comp ==1
                xFreq = Out.freq1(find(Out.freq1<0.004));
                yFreq = Out.freq2(find(Out.freq2<0.004));
            end
            allMTSpec = abs(Out.spectrum((find(Out.freq2<0.004)),(find(Out.freq1<0.004))))';
            compMTSpec(expInd,TP2comp,:,:) =allMTSpec;
        end
        save(allData(MFE(expInd)).name, 'xFreq', 'yFreq', 'compMTSpec', 'info', '-append')
    end
    %% make movie
%     f = figure; clf
%     f.Position = [292 388 1557 595];
%     
%     clear movieOutput
%     
%     for TP2comp = 1:size(compImage,2)
%         for expInd = 1:length(MFE)
%             
%             testImage = squeeze(compImage(expInd,TP2comp,:,:));
%             plotSpecMT = squeeze(compMTSpec(expInd, TP2comp,:,:));
%             
%             subplot(2,4,expInd)
%             imagesc(testImage)
%             colormap(parula)
%             set(gca, 'clim', [-15, 15]);
%             colorbar
%             title([titleString{expInd}, ' Movie Still'])
%             
%             
%             subplot(2,4,expInd+4)
%             pcolor(xFreq, yFreq, squeeze(plotSpecMT));
%             %pcolor(xFreq, yFreq, squeeze(plotSpecMT)'); shading 'flat'
%             colorbar
%             hold on
%             % scatter(compXs{expInd}, compY{expInd}, 'rx');
%             % set(gca, 'clim', [0, 10^12]);
%             colorbar
%             title([titleString{expInd}, 'MT Spectrum'])
%             
%         end
%         suptitle(['MTspec of mouse GL' num2str(allMice(mouseID)), ' Timepoint: ', num2str(TP2comp)])
%         drawnow
%         pause(0.25);
%         movieOutput(TP2comp) = getframe(gcf);
%     end
%     v = VideoWriter([dirPic, 'compGL' num2str(allMice(mouseID)), '_MTSpec.avi']);
%     
%     open(v)
%     if sum(size(movieOutput(1).cdata) == size(movieOutput(2).cdata)) ==3
%         writeVideo(v,movieOutput(2:end))
%     else
%         writeVideo(v,movieOutput)
%     end
%     close(v)
    
end
