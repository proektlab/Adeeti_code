%% Trying twoD multitaper to see if there are cleaner results 
if isunix
    dirIn = '/synology/adeeti/GaborTests/IsoProp/';
    dirPic = 'synology/adeeti/GaborTests/images/mulitTaper2D/IsoProp/';
elseif ispc
    dirIn = 'Z:/adeeti/GaborTests/IsoProp/';
    dirPic = 'Z:\adeeti\GaborTests\images\mulitTaper2D\IsoProp';
end

cd(dirIn)
mkdir(dirPic)

load('gaborCoh2018-07-07_16-28-49.mat')

movieToFit = interp100FiltDataTimes;
interpBy = 100;
% 
% movieToFit = interpFiltDataTimes;
% interpBy = 3;

gridSpacing = 1;

i = 104;
testImage = squeeze(movieToFit(i,:,:));

%% for comp to 2D FFT

[spectrum2D, NFFTX, NFFTY] = twoDFFT4gridMovies(testImage);
shiftSpec2D = abs(fftshift(spectrum2D));

% Find X and Y frequency spaces, assuming sampling rate of 1
samplingFreq = gridSpacing/interpBy; %5;
plotUB =  10^-4;%=1/interBy;
%plotUB = samplingFreq/interpBy*2;
 plotLB = -plotUB;

 fullFFTXscale = samplingFreq/2*linspace(-1,1,NFFTX);
 fullFFTYscale = samplingFreq/2*linspace(-1,1,NFFTY);

%fullFFTXscale = 1/samplingFreq*2*linspace(-1,1,NFFTX);
%fullFFTYscale = 1/samplingFreq*2*linspace(-1,1,NFFTY);

halfIndX = find(fullFFTXscale<plotUB & fullFFTXscale>=0);
halfIndY = find(fullFFTYscale<plotUB & fullFFTYscale>=0);



%% trying out multitaper
tapers = [3 5 10 20 40];
inDims = [5000, 2750];

figure
subplot(1, numel(tapers)+2, 1)
imagesc(testImage)
title('True image')

subplot(1, numel(tapers)+2, 2)
pcolor(fullFFTXscale(halfIndX), fullFFTYscale(halfIndY), abs(spectrum2D(1:numel(halfIndY), 1:numel(halfIndX)))); 
shading 'flat';
title('2DFFT')

for i = 1:length(tapers)
[Out] = mtImageFFT(testImage,tapers(i), inDims);

subplot(1, numel(tapers)+2, i+2)
imagesc(abs(Out.spectrum))
title(['tapers = ', num2str(tapers(i))])

end
















%%
[spectrum2D, NFFTX, NFFTY] = twoDFFT4gridMovies(testImage);
shiftSpec2D = abs(fftshift(spectrum2D));

% Find X and Y frequency spaces, assuming sampling rate of 1
samplingFreq = gridSpacing/interpBy; %5;
plotUB =  10^-4;%=1/interBy;
%plotUB = samplingFreq/interpBy*2;
 plotLB = -plotUB;

 fullFFTXscale = samplingFreq/2*linspace(-1,1,NFFTX);
 fullFFTYscale = samplingFreq/2*linspace(-1,1,NFFTY);

%fullFFTXscale = 1/samplingFreq*2*linspace(-1,1,NFFTX);
%fullFFTYscale = 1/samplingFreq*2*linspace(-1,1,NFFTY);

halfIndX = find(fullFFTXscale<plotUB & fullFFTXscale>=0);
halfIndY = find(fullFFTYscale<plotUB & fullFFTYscale>=0);

validIndX = find(fullFFTXscale<plotUB & fullFFTXscale >plotLB);
validIndY = find(fullFFTYscale<plotUB & fullFFTYscale >plotLB);

[BW, heights, xs, ys] = find2DPeaksImage(shiftSpec2D,validIndX,validIndY);

figure
subplot(1,4,1)
imagesc(testImage)
subplot(1,4,2)
pcolor(fullFFTXscale(halfIndX), fullFFTYscale(halfIndY), abs(spectrum2D(1:numel(halfIndY), 1:numel(halfIndX)))); 
shading 'flat';
subplot(1,4,3)
imagesc(fullFFTXscale(validIndX), fullFFTYscale(validIndY), shiftSpec2D(validIndY,validIndX))
subplot(1,4,4)
surf(shiftSpec2D(validIndY,validIndX));
hold on;
scatter3(xs, ys, heights, 'rx');
%set(gca, 'xlim', [validIndX(1), validIndX(end)]);
%set(gca, 'ylim', [validIndY(1), validIndY(end)]);

%%

movieToFit = interpFiltDataTimes;
interpBy = 3;

% movieToFit = interp100FiltDataTimes;
% interpBy = 100;

gridSpacing = 1;
samplingFreq = 1;

plotTime =50:350;

clear movieOutput
f = figure; clf
f.Position = [292 388 1557 595];
% for i = 1:size(movieToFit,1)
allSpec = [];
for i =1:length(plotTime)
    testImage = squeeze(movieToFit(plotTime(i),:,:));
    
    [spectrum2D, NFFTX, NFFTY] = twoDFFT4gridMovies(testImage);
    shiftSpec2D = abs(fftshift(spectrum2D));
    if i ==1
    % Find X and Y frequency spaces, assuming sampling rate of 1
    samplingFreq = gridSpacing/interpBy; %5;
    if interpBy ==100
        plotUB =  10^-4;%=1/interBy;
    elseif interpBy ==3
        plotUB =  10^-1;%=1/interBy;
    end
    %plotUB = samplingFreq/interpBy*2;
    plotLB = -plotUB;
    
    fullFFTXscale = samplingFreq/2*linspace(-1,1,NFFTX);
    fullFFTYscale = samplingFreq/2*linspace(-1,1,NFFTY);
    
    %fullFFTXscale = 1/samplingFreq*2*linspace(-1,1,NFFTX);
    %fullFFTYscale = 1/samplingFreq*2*linspace(-1,1,NFFTY);
    
    halfIndX = find(fullFFTXscale<plotUB & fullFFTXscale>=0);
    halfIndY = find(fullFFTYscale<plotUB & fullFFTYscale>=0);
    
    validIndX = find(fullFFTXscale<plotUB & fullFFTXscale >plotLB);
    validIndY = find(fullFFTYscale<plotUB & fullFFTYscale >plotLB);
    end
    [BW, heights, xs, ys] = find2DPeaksImage(spectrum2D,validIndX,validIndY);
    
    allXs(i,:) = xs;
    allYs(i,:) = ys;
    allheights(i,:) = heights; 
    
    
    subplot(1,4,1)
    imagesc(testImage)
    colormap(parula)
    set(gca, 'clim', [-15, 15]);
    colorbar
    subplot(1,4,2)
    pcolor(fullFFTXscale(halfIndX), fullFFTYscale(halfIndY), abs(spectrum2D(1:numel(halfIndY), 1:numel(halfIndX))));
    shading 'flat';
    subplot(1,4,3)
    imagesc(fullFFTXscale(validIndX), fullFFTYscale(validIndY), shiftSpec2D(validIndY,validIndX))
    subplot(1,4,4)
    surf(shiftSpec2D(validIndY,validIndX));
    hold on;
    scatter3(xs, ys, heights, 'rx');
  
   suptitle(['Time = ', num2str(plotTime(i)-100)]);
%     set(H, 'clim', [-15, 15]);
    drawnow
    pause(0.15);
    movieOutput(i) = getframe(gcf);
end

save(allData(expID), 'allXs', 'allYs', 'allheights', 'fullFFTXscale', 'fullFFTYscale', 'validIndX', 'validIndY')
v = VideoWriter(['Z:\adeeti\GaborTests\IsoProp', 'Interp3Exp1.avi']);

open(v)
if sum(size(movieOutput(1).cdata) == size(movieOutput(2).cdata)) ==3
    writeVideo(v,movieOutput(2:end))
else
    writeVideo(v,movieOutput)
end
close(v)

 