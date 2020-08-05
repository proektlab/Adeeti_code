
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

%[MFE] = findMyExpMulti(dataMatrixFlashes, 9, [], [], [],  [], []);

[isoHighExp, isoLowExp, emergExp, awaExp1, awaLastExp, ketExp] = findAnesArchatypeExp(dataMatrixFlashes, 6);

MFE = [isoHighExp, isoLowExp, awaLastExp, ketExp];
titleString = {'High Isoflurane', 'Low Isoflurane', 'Awake', 'Ketamine'};

%[allIso] = findMyExpMulti(dataMatrixFlashes, [], 'iso', [], [],  [], []);

%%
compImage = [];
compSpec = [];
compXs = [];
compYs = [];

%TP2comp = 100+50;
  plotTime =50:350;
for expInd = 1:length(MFE)
    load(allData(MFE(expInd)).name, 'interp100FiltDataTimes', 'allSpecShift', ...
        'fullFFTXscale', 'fullFFTYscale', 'validIndX', 'validIndY', 'allXs', 'allYs', 'info')
    disp(allData(MFE(expInd)).name)
    movieToFit = interp100FiltDataTimes;
    interpBy = 100;
    
    compImage(expInd,:,:,:) = movieToFit(plotTime,:,:);
    compSpec(expInd,:, :,:) = allSpecShift;
    %     compXs{expInd} = plotX;
    %     compY{expInd} = plotY;
end
%%

f = figure; clf
f.Position = [292 388 1557 595];

clear movieOutput

for TP2comp = 1:size(compImage,2)
    for expInd = 1:length(MFE)
        
        testImage = squeeze(compImage(expInd,TP2comp,:,:));
        plotSpec = squeeze(compSpec(expInd, TP2comp,:,:));
        
        subplot(2,4,expInd)
        imagesc(testImage)
        colormap(parula)
        set(gca, 'clim', [-15, 15]);
        colorbar
        title([titleString{expInd}, ' Movie Still'])
        
        
        subplot(2,4,expInd+4)
        imagesc(fullFFTXscale(validIndX), fullFFTYscale(validIndY), squeeze(plotSpec))
        colorbar
        hold on
        % scatter(compXs{expInd}, compY{expInd}, 'rx');
        % set(gca, 'clim', [0, 10^12]);
        colorbar
        title([titleString{expInd}, ' Spectrum'])
        
    end
    suptitle(['Timepoint: ', num2str(TP2comp)])
    drawnow
    pause(0.25);
    movieOutput(TP2comp) = getframe(gcf);
end
v = VideoWriter([dirPic, 'compGL6_2DFFT.avi']);

open(v)
if sum(size(movieOutput(1).cdata) == size(movieOutput(2).cdata)) ==3
    writeVideo(v,movieOutput(2:end))
else
    writeVideo(v,movieOutput)
end
close(v)

