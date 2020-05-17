clear 
clc
close all

%%
if isunix
    dirIn = '/synology/adeeti/spatialParamWaves/Awake/';
    dirPic = '/synology/adeeti/spatialParamWaves/images/2DFFTMovies/Awake/';
elseif ispc
    dirIn = 'Z:/adeeti/spatialParamWaves/Awake/';
    dirPic = 'Z:\adeeti\spatialParamWaves\images\2DFFTMovies\Awake\';
end

mkdir(dirPic)

cd(dirIn)
load('dataMatrixFlashes.mat')
allData = dir('gab*');
%%
allMice = [6, 9, 13];

%%
for mouseID = 1:length(allMice)
    [isoHighExp, isoLowExp, emergExp, awaExp1, awaLastExp, ketExp] = findAnesArchatypeExp(dataMatrixFlashes, allMice(mouseID));
    
    MFE = [isoHighExp, isoLowExp, awaLastExp, ketExp];
    titleString = {'High Isoflurane', 'Low Isoflurane', 'Awake', 'Ketamine'};
    
    for expInd = 1:length(MFE)
%         load(allData(MFE(expInd)).name, 'interp100FiltDataTimes', 'info')
        load(allData(MFE(expInd)).name, 'interpFiltDataTimes', 'info')

        disp(allData(MFE(expInd)).name)
%         movieToFit = interp100FiltDataTimes;
%         interpBy = 100;
        
        movieToFit = interpFiltDataTimes;
        interpBy = 3;
        
        gridSpacing = 500;
        samplingFreq = 1;
        
        plotTime =50:350;
        
        %     clear movieOutput
        %     f = figure; clf
        %     f.Position = [292 388 1557 595];
        
        allSpecShift = [];
%         allBWs = [];
%         allheights=  {};
%         allYs =  {};
%         allXs= {};
        for i =1:length(plotTime)
            testImage = squeeze(movieToFit(plotTime(i),:,:));
            
            [spectrum2D, NFFTX, NFFTY] = twoDFFT4gridMovies(testImage);
            shiftSpec2D = abs(fftshift(spectrum2D));
            if i ==1
                % Find X and Y frequency spaces, assuming sampling rate of 1
                samplingFreq = gridSpacing/interpBy; %5;
                %             if interpBy ==100
                %                 plotUB =  10^-4;%=1/interBy;
                %             elseif interpBy ==3
                %                 plotUB =  10^-1;%=1/interBy;
                %             end
                plotUB = 1/gridSpacing*2; %samplingFreq/interpBy*2;
                plotLB = -plotUB;
                
                %fullFFTXscale = samplingFreq/2*linspace(-1,1,NFFTX);
                %fullFFTYscale = samplingFreq/2*linspace(-1,1,NFFTY);
                
                fullFFTXscale = 1/samplingFreq*2*linspace(-1,1,NFFTX);
                fullFFTYscale = 1/samplingFreq*2*linspace(-1,1,NFFTY);
                
                halfIndX = find(fullFFTXscale<=plotUB & fullFFTXscale>=0);
                halfIndY = find(fullFFTYscale<=plotUB & fullFFTYscale>=0);
                
                validIndX = find(fullFFTXscale<=plotUB & fullFFTXscale >=plotLB);
                validIndY = find(fullFFTYscale<=plotUB & fullFFTYscale >=plotLB);
            end
            allSpecShift(i,:,:) = shiftSpec2D(validIndY,validIndX);
%             [BW, heights, xs, ys] = find2DPeaksImage(squeeze(allSpecShift(i,:,:)), [], []);
%             
%             
%             allXs{i} = xs;
%             allYs{i} = ys;
%             allheights{i} = heights;
%             allBWs(i,:,:)= BW;
%             
            %         subplot(1,4,1)
            %         imagesc(testImage)
            %         colormap(parula)
            %         set(gca, 'clim', [-15, 15]);
            %         colorbar
            %
            %         subplot(1,4,2)
            %         pcolor(fullFFTXscale(halfIndX), fullFFTYscale(halfIndY), abs(spectrum2D(1:numel(halfIndY), 1:numel(halfIndX))));
            %         shading 'flat';
            % %         set(gca, 'clim', [0, 10^12]);
            %         colorbar
            %
            %         subplot(1,4,3)
            %         imagesc(fullFFTXscale(validIndX), fullFFTYscale(validIndY), shiftSpec2D(validIndY,validIndX))
            %        % set(gca, 'clim', [0, 10^12]);
            %         colorbar
            %
            %         subplot(1,4,4)
            %         surf(shiftSpec2D(validIndY,validIndX));
            %         hold on;
            %         scatter3(xs, ys, heights, 'rx');
            %        % set(gca, 'zlim', [0, 10^12]);
            %
            %         suptitle([info.AnesType, ' Time = ', num2str(plotTime(i)-100)]);
            %         %     set(H, 'clim', [-15, 15]);
            %         drawnow
            %         pause(0.15);
            %         movieOutput(i) = getframe(gcf);
        end
        
        save(allData(MFE(expInd)).name, 'allSpecShift', 'fullFFTXscale', ...
            'fullFFTYscale', 'validIndX', 'validIndY', '-append')
        
%         save(allData(MFE(expInd)).name, 'allSpecShift', 'allXs', 'allYs', ...
%             'allheights', 'allBWs', 'fullFFTXscale', 'fullFFTYscale', 'validIndX', ...
%             'validIndY', '-append')
        %     v = VideoWriter([dirPic, info.AnesType(1:3) 'exp', num2str(expInd), 'Interp100.avi']);
        %
        %     open(v)
        %     if sum(size(movieOutput(1).cdata) == size(movieOutput(2).cdata)) ==3
        %         writeVideo(v,movieOutput(2:end))
        %     else
        %         writeVideo(v,movieOutput)
        %     end
        %     close(v)
    end
end
