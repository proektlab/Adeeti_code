
%%
%load([dirIn, allData(expID).name]);
movieToFit = squeeze(interpFiltDataTimes(50:350,:,:));

imageToFit = squeeze(movieToFit(1,:,:));
[gridX, gridY] = meshgrid(1:size(imageToFit,2), 1:size(imageToFit,1));
gridX(isnan(imageToFit)) = nan;
gridY(isnan(imageToFit)) = nan;

plotTime =1:301;

 for i = plotTime
        imagesc(squeeze(movieToFit(i,:,:)))
        title('True Image')
       
        suptitle(['Time: ' num2str(i) 'ms']);
        colormap(parula)
        set(gca, 'clim', [-15, 15]);
        colorbar
        drawnow
        pause(0.15);
       % movieOutput(i) = getframe(gcf);
 end
    
 %%
% movieToFit = interp100FiltDataTimes;
% interpBy = 100;
% 
% movieToFit = interpFiltDataTimes;
% interpBy = 3;

gridSpacing = 500;

i = 104;
testImage = squeeze(movieToFit(i,:,:));

[spectrum2D, NFFTX, NFFTY] = twoDFFT4gridMovies(testImage);
shiftSpec2D = abs(fftshift(spectrum2D));

% Find X and Y frequency spaces, assuming sampling rate of 1
samplingFreq = gridSpacing/interpBy; %5;
plotUB =10000
%plotUB = samplingFreq/interpBy*2;
% plotLB = -plotUB;

% fullFFTXscale = samplingFreq/2*linspace(-1,1,NFFTX);
% fullFFTYscale = samplingFreq/2*linspace(-1,1,NFFTY);

fullFFTXscale = 1/samplingFreq*2*linspace(-1,1,NFFTX);
fullFFTYscale = 1/samplingFreq*2*linspace(-1,1,NFFTY);

halfIndX = find(fullFFTXscale<plotUB & fullFFTXscale>=0);
halfIndY = find(fullFFTYscale<plotUB & fullFFTYscale>=0);

validIndX = find(fullFFTXscale<plotUB & fullFFTXscale >plotLB);
validIndY = find(fullFFTYscale<plotUB & fullFFTYscale >plotLB);

[BW, heights, xs, ys] = find2DPeaksImage(shiftSpec2D);

figure
subplot(1,4,1)
imagesc(testImage)
subplot(1,4,2)
pcolor(fullFFTXscale(halfIndX), fullFFTYscale(halfIndY), abs(spectrum2D(1:numel(halfIndY), 1:numel(halfIndX)))); shading 'flat';
subplot(1,4,3)
imagesc(fullFFTXscale(validIndX), fullFFTYscale(validIndY), shiftSpec2D(validIndY,validIndX))
% subplot(1,4,4)
% surf(shiftSpec2D(validIndY,validIndX));
% hold on;
% scatter3(xs(validIndX), ys(validIndY), heights(validIndY, validIndX), 'rx');


%%

movieToFit = interpFiltDataTimes;

samplingFreq = 1;

plotTime =1:301;

clear movieOutput
f = figure; clf
f.Position = [292 388 1557 595];
% for i = 1:size(movieToFit,1)
allSpec = [];
for i =1% plotTime
    movieImage = squeeze(movieToFit(i,:,:));
    [spectrum2D, NFFTX, NFFTY] = twoDFFT4gridMovies(movieImage, samplingFreq);
    allSpec(i,:,:) = spectrum2D;
    
    [BW, heights] = find2DPeaksImage(movieImage);
    
    H(1) = subplot(1,3,1);
    imagesc(movieImage)
    colormap(parula)
    set(gca, 'clim', [-15, 15]);
    colorbar
    
    H(2) = subplot(1,3,2);
    imagesc(spatialFreqsX, flipud(spatialFreqsY), abs(spectrum2D(1:NFFTY/2+1, 1:NFFTX/2+1)))
    %set(gca, 'clim', [0 , 600])
    colorbar
    
    H(3) = subplot(1,3,3);
    imagesc(samplingFreq/2*linspace(-1,1,NFFTX), samplingFreq/2*linspace(-1,1,NFFTY), abs(fftshift(spectrum2D)))
    %set(gca, 'clim', [0 , 600])
    colorbar
%    H(4) = subplot(1,4,4);
%     imagesc(samplingFreq/2*linspace(-1,1,NFFTX), samplingFreq/2*linspace(-1,1,NFFTY), abs(fftshift(spectrum2D)))
    
    
   suptitle(['Time = ', num2str(i)]);
%     set(H, 'clim', [-15, 15]);
    drawnow
    pause(0.15);
    movieOutput(i) = getframe(gcf);
end

v = VideoWriter(['Z:\adeeti\GaborTests\IsoProp', 'test.avi']);

open(v)
if sum(size(movieOutput(1).cdata) == size(movieOutput(2).cdata)) ==3
    writeVideo(v,movieOutput(2:end))
else
    writeVideo(v,movieOutput)
end
close(v)




%%

 
  i = 54;
testImage = squeeze(movieToFit(i,:,:));
vidHeight = size(testImage,1);
vidWidth = size(testImage,2);
 
NFFTY = 2^nextpow2(vidHeight);
NFFTX = 2^nextpow2(vidWidth);
% 'detrend' data to eliminate zero frequency component
av = sum(testImage(:)) / length(testImage(:));
testImage = testImage - av;
% Find X and Y frequency spaces, assuming sampling rate of 1
samplingFreq = 1;
spatialFreqsX = samplingFreq/2*linspace(0,1,NFFTX/2+1);
spatialFreqsY = samplingFreq/2*linspace(0,1,NFFTY/2+1);
spectrum2D = fft2(testImage, NFFTY,NFFTX);
figure
subplot(1,2,1)
 imagesc(testImage)
 subplot(1,2,2)
contourf(spatialFreqsX, spatialFreqsY, abs(spectrum2D(1:NFFTY/2+1, 1:NFFTX/2+1)))
 
 
 
 
 
 
 
 
 
 
 
 