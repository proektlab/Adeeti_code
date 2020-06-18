%clear
close all
clc

if isunix
    dirIn = '/synology/adeeti/spatialParamWaves/Awake/';
    dirPic = '/synology/adeeti/spatialParamWaves/images/SVD/';
elseif ispc
    dirIn = 'Z:/adeeti/spatialParamWaves/Awake/';
    dirPic = 'Z:\adeeti\spatialParamWaves\images\SVD\';
end

fs = 1000;
testTime = 350;
baselineStart = 100;
epStart = 500;
allMice = [6, 9, 13];

%%
anesString = {'High Isoflurane', 'Low Isoflurane', 'Awake', 'Ketamine'};
shortAnesString = {'HIso', 'LIso', 'Awa', 'Ket'};

baselineTime= baselineStart:baselineStart+testTime;
epTime = epStart:epStart+testTime;

mkdir(dirPic)

cd(dirIn)
allData = dir('gab*.mat');
load('dataMatrixFlashes.mat')
spModes = [];
%%
for mouseID = 1:length(allMice) %1=GL6, 2=GL9, 3=GL13
    %a = 2; %1 = high iso, 2 = low iso, 3 = awake, 4 = ket
    
    [isoHighExp, isoLowExp, emergExp, awaExp1, awaLastExp, ketExp] = ...
        findAnesArchatypeExp(dataMatrixFlashes, allMice(mouseID));
    
    MFE = [isoHighExp, isoLowExp, awaLastExp, ketExp]

    
    %% load data and rearranage for SVD on interpolated data
    for experiment = 1:length(MFE)
        if isnan(MFE(experiment))
            disp(['No experiment for', anesString{experiment}]);
            continue
        end
        
        load(allData(MFE(experiment)).name)
        
        interpBy = 3;
        [concatChanTimeData, interpGridInd, interpNoiseInd, interpNoiseGrid] = ...
            makeInterpGridInd(interp3Coh35, interpBy, info);
        
        epDataAvg = concatChanTimeData(:,epTime);
        baselineDataAvg = concatChanTimeData(:,baselineTime);
        
        %% finding SVD of interpolated ata
        
        rearrange2Gr =1;
        N = 20;
        badChan = interpNoiseInd; %becuase interp
        numChan = size(concatChanTimeData, 1);
        
        
        [SVDout, SpatialAmp, SpatialPhase, TemporalAmp, TemporalPhase,GridOut ] = ...
            WaveSVD(epDataAvg, N, rearrange2Gr, interpGridInd, badChan, numChan);
        
        U = SVDout.U;
        S = SVDout.S;
        V = SVDout.V;
        
        comVar = 100*(diag(S)./sum(diag(S)));
        expVar = cumsum(comVar);
        allExpVar(mouseID, experiment,:) = expVar;
        numModesExplain(mouseID, experiment) = find(expVar>95, 1, 'first');
        
        reconModes = [];        
        %% loooking at spatial modes
%         useModesNum = 3;
%         
%         modInd = 1:useModesNum;
%         allEPSpAmp = GridOut.SpatialAmp(:,:,modInd);
        
%         ff = figure('Position', [1, 79,1912,737] , 'Color', 'w'); clf;
%         for m = 1:length(modInd)
%             subplot(1, length(modInd), m)
%             useSpatialData = squeeze(allEPSpAmp(:,:,m));
%             imagesc(useSpatialData)
%             set(gca, 'clim', [min(useSpatialData(:)), max(useSpatialData(:))])
%             colorbar
%             title(['Mode ', num2str(m), ': ', num2str(comVar(m)), '%'])
%         end
%         sgtitle(['GL', num2str(allMice(mouseID)), ': ',  anesString{experiment}, 'Spatial Modes '])
%         saveas(ff, [dirPic, 'GL', num2str(allMice(mouseID)),'_',  shortAnesString{experiment}, 'spatSVDmodes', '.png'])
%         close all
        
        
%         %% recostructing SVD of top modes individually
%         for m = 1:useModesNum
%             useMode = modInd(m);
%             useS = S;
%             if useMode ==1
%                 useS(:,useMode+1:end) = 0;
%             else
%                 notMode = [1:useMode-1, useMode+1:size(S,2)];
%                 useS(:,notMode) = 0;
%             end
%             
%             reconstData = U*useS*V';
%             [tempRec] = hilbert2filtsig(reconstData);
%             reconModes(m,:,:) = tempRec;
%         end
%         
%         
%         % put SVD projected data back into grid space
%         reconModeGrid = [];
%         for m = 1:size(reconModes,1)
%             inputData = squeeze(reconModes(m,:,:));
%             [tempGrid] = plotOnECoG_interpCon(inputData, interpGridInd);
%             reconModeGrid(m,:,:,:) = tempGrid;
%         end
%         
% 
%       %% reconstucting data with the top few SVD modes (effectively decreasing noise)
%         useModesNumRecon = 5;
%         useS = zeros(size(S));
%         useS(1:useModesNumRecon,:) = S(1:useModesNumRecon,:);
%         
%         reconstData = U*useS*V';
%         reconTogetModes = hilbert2filtsig(reconstData);
%         
%         reconTogetModeGrid = plotOnECoG_interpCon(reconTogetModes, interpGridInd);
%         comVarToget = sum(comVar(1:useModesNumRecon));
%         
        %% make movie of recons Data with SVD modes 
        
%         clear movieOutput
%         ff = figure('Position', [1, 79,1912,737] , 'Color', 'w'); clf;
%         for i = 1:size(reconModeGrid,4)
%             subplot(1, size(reconModeGrid,1)+2, 1)
%             imagesc(squeeze(interp3Coh35(i,:,:)))
%             colorbar
%             set(gca, 'clim', [min(epDataAvg(:)),max(epDataAvg(:))])
%             title('OG data')
%             
%             subplot(1, size(reconModeGrid,1)+2, 2)
%             imagesc(squeeze(reconTogetModeGrid(:,:,i)))
%             colorbar
%             set(gca, 'clim', [min(reconTogetModeGrid(:)),max(reconTogetModeGrid(:))])
%             title(['SVD recon of 1st 5 modes', ': ', num2str(comVarToget), '%'])
%             
%             for m = 1:size(reconModeGrid+2,1)
%                 subplot(1, size(reconModeGrid,1)+2, m+2)
%                 imagesc(squeeze(reconModeGrid(m,:,:,i)))
%                 set(gca, 'clim', [min(min(min(reconModeGrid(m,:,:,:)))), max(max(max(reconModeGrid(m,:,:,:))))])
%                 colorbar
%                 title(['Mode ', num2str(m), ': ', num2str(comVar(m)), '%'])
%             end
%            sgtitle(['GL', num2str(allMice(mouseID)), ': ',  anesString{experiment} ' Time t = :', num2str(i)])
%            drawnow
%            pause(0.15);
%            movieOutput(i) = getframe(gcf);
%         
%         end
%          
%         v = VideoWriter([dirPic, 'GL', num2str(allMice(mouseID)), shortAnesString{experiment}, 'SVD_rcn_Int3.avi']);
%         
%         open(v)
%         if sum(size(movieOutput(1).cdata) == size(movieOutput(2).cdata)) ==3
%             writeVideo(v,movieOutput(2:end))
%         else
%             writeVideo(v,movieOutput)
%         end
%         close(v)
        
    end
end

%%

plotColors = {'k', 'b', 'r', 'g'};
shortAnesString = {'HIso', 'LIso', 'Awa', 'Ket'};
counter = 0
figure
for mouseID = 1:length(allMice) 
    for experiment = 1:length(shortAnesString)
        counter = counter +1;
        plot(squeeze(allExpVar(mouseID,experiment,1:10))', plotColors{experiment});
        hold on
    end
end

xlabel('SVD mode')
ylabel('% variance explained')
legend(shortAnesString)
title('SVD modes explained of average')