%clear
close all
clc

if isunix
    dirIn = '/synology/adeeti/spatialParamWaves/Awake/';
    dirPic = '/synology/adeeti/spatialParamWaves/images/NeuroPatt/Awake/';
elseif ispc
    dirIn = 'Z:/adeeti/spatialParamWaves/Awake/';
    dirPic = 'Z:\adeeti\spatialParamWaves\images\NeuroPatt\Awake\';
end

fs = 1000;
testTime = 350;
baselineStart = 100;
epStart = 500;
allMice = [6, 9, 13];

%% set up Neuropath parameters
clearvars params
params = setNeuroPattParams(fs);
params = setNeuroPattParams(params, 'downsampleScale', 1, fs);
params = setNeuroPattParams(params, 'subtractBaseline', 0, fs);
params = setNeuroPattParams(params, 'filterData', 0, fs);
params = setNeuroPattParams(params, 'morletCfreq', 35, fs);
params = setNeuroPattParams(params, 'morletParam', 5, fs);
params = setNeuroPattParams(params, 'hilbFreqLow', 30, fs);
params = setNeuroPattParams(params, 'hilbFreqHigh', 40, fs);

params = setNeuroPattParams(params, 'performSVD', 1, fs);
params = setNeuroPattParams(params, 'useComplexSVD', 1, fs);

params = setNeuroPattParams(params, 'opAlpha', 0.5, fs);
params = setNeuroPattParams(params, 'opBeta', 10, fs);

params = setNeuroPattParams(params, 'planeWaveThreshold', 0.8, fs);
params = setNeuroPattParams(params, 'planeWaveThreshold', 0.8, fs);
params = setNeuroPattParams(params, 'maxDisplacement', 1, fs);
params = setNeuroPattParams(params, 'minCritRadius', 1, fs);
params = setNeuroPattParams(params, 'minEdgeDistance', 1, fs);


%%
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
    anesString = {'High Isoflurane', 'Low Isoflurane', 'Awake', 'Ketamine'};
    
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
        
        % ff = figure('color', 'w', 'position', [440,113,560,685])
        % for t =1:length(epTime)
        %     imagesc(squeeze(epDataAvg(:,:,t)))
        %     colorbar
        %     set(gca, 'clim', [-10,10])
        %     title(['Time = ', num2str(t)])
        %     pause(0.01)
        % end
        
        [SVDout, SpatialAmp, SpatialPhase, TemporalAmp, TemporalPhase,GridOut ] = ...
            WaveSVD(epDataAvg, N, rearrange2Gr, interpGridInd, badChan, numChan);
        
        U = SVDout.U;
        S = SVDout.S;
        V = SVDout.V;
        reconModes = [];
        %% Grabbing spatial modes only
%         modInd = 1:useModesNum;
%         allEPSpAmp = GridOut.SpatialAmp(:,:,modInd);
%         
        
        %% remaking matrix with only a few modes
        useModesNum = 5;
        useS = zeros(size(S));
        useS(1:useModesNum,:) = S(1:useModesNum,:);
        
        reconstData = U*useS*V';
        reconModes = hilbert2filtsig(reconstData);
        
        reconModeGrid = plotOnECoG_interpCon(reconModes, interpGridInd);
        
        
        %% looking at the top three spatial modes
        %         figure
        %         for m = 1:length(modInd)
        %             subplot(1, length(modInd), m)
        %             imagesc(squeeze(allEPSpAmp(:,:,m)))
        %             title(['Mode ', num2str(modInd(m))])
        %         end
        %         sgtitle(['Spatial Modes '])
        %
        
        %% put SVD projected data back into grid space
        
        %         figure
        %         for i = 1:size(reconModeGrid,4)
        %             for m = 1:size(reconModeGrid,1)
        %                 subplot(1, size(reconModeGrid,1), m)
        %                 imagesc(squeeze(reconModeGrid(m,:,:,i)))
        %                 set(gca, 'clim', [min(min(min(reconModeGrid(m,:,:,:)))), max(max(max(reconModeGrid(m,:,:,:))))])
        %                 colorbar
        %                 title(['Mode ', num2str(m)])
        %             end
        %             sgtitle(['Time t = :', num2str(i)])
        %             pause(0.01)
        %         end
        
        %% Now putting into neuropatt format
        %NeuroPattGUI(reconModeGrid, fs)
        
        onlyPatterns = false;
        suppressFigures = false;
        
        %          testAlphas = [0.1, 0.5, 1];
        % %         testBetas = [1, 5, 10, 15];
        %
        testAlphas = [0.5];
        testBetas = [10];
        
        cprintf(-[1 0 1],  ['mouseID = ', num2str(mouseID), '; experiment =  ', ...
            num2str(experiment)])
        
        useMode = squeeze(reconModeGrid(:,:,:));
        for alphaInd = 1:length(testAlphas)
            for betaInd = 1:length(testBetas)
                params = setNeuroPattParams(params, 'opAlpha', testAlphas(alphaInd), fs);
                params = setNeuroPattParams(params, 'opBeta', testBetas(betaInd), fs);
                
                outputs = mainProcessingWithOutput(useMode, fs, params, [], onlyPatterns, suppressFigures);
                
                patternTypes = outputs.patternTypes; %names of patterns
                patternResultColumns = outputs.patternResultColumns; %features of each detected patterns
                
                if length(testAlphas) ~=1 && length(testBetas) ~=1
                    spModes(mouseID,experiment,alphaInd,betaInd).patterns = outputs.patterns;
                    spModes(mouseID,experiment,alphaInd,betaInd).patternLocs = outputs.patternLocs;
                    
                elseif length(testAlphas) ~=1 && length(testBetas) ==1
                    spModes(mouseID,experiment,alphaInd).patterns = outputs.patterns;
                    spModes(mouseID,experiment,alphaInd).patternLocs = outputs.patternLocs;
                    
                elseif length(testAlphas) ==1 && length(testBetas) ~=1
                    spModes(mouseID,experiment,betaInd).patterns = outputs.patterns;
                    spModes(mouseID,experiment,betaInd).patternLocs = outputs.patternLocs;
                    
                else
                    spModes(mouseID,experiment).patterns = outputs.patterns;
                    spModes(mouseID,experiment).patternLocs = outputs.patternLocs;
                end
                
            end
        end
        
    end
end

squeeze(spModes)

%%

figs_compAnes_firstSVD_thenNeuroPatt
