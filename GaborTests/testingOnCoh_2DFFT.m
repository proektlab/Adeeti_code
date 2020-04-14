
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

movieToFit = rawFiltDataTimes;
interpBy = 1;


gridSpacing = 500;

 
 i = 104;
testImage = squeeze(movieToFit(i,:,:));
vidHeight = size(testImage,1);
vidWidth = size(testImage,2);
 
NFFTY = 2^nextpow2(vidHeight);
NFFTX = 2^nextpow2(vidWidth);
% 'detrend' data to eliminate zero frequency component
av = sum(testImage(:)) / length(testImage(:));
testImage = testImage - av;
% Find X and Y frequency spaces, assuming sampling rate of 1
samplingFreq = gridSpacing/interpBy; %5;
spatialFreqsX = samplingFreq/2*linspace(0,1,NFFTX/2+1);
spatialFreqsY = samplingFreq/2*linspace(0,1,NFFTY/2+1);
spectrum2D = fft2(testImage, NFFTY,NFFTX);

test = abs(fftshift(spectrum2D)); %perlin2D(200);
BW = imregionalmax(test');
[xs, ys] = ind2sub(size(BW), find(BW==1));
heights = [];
for i = 1:length(xs)
    heights(i) = test(ys(i), xs(i));
end


plotLB = -samplingFreq/interpBy;
plotUB = samplingFreq/interpBy;
plotXscale = spatialFreqsX(find(spatialFreqsX<plotUB));
plotYscale = spatialFreqsY(find(spatialFreqsY<plotUB));

figure
subplot(1,4,1)
imagesc(testImage)
subplot(1,4,2)
imagesc(spatialFreqsX, flipud(spatialFreqsY), abs(spectrum2D(1:NFFTY/2+1, 1:NFFTX/2+1)))
subplot(1,4,3)
imagesc(samplingFreq/2*linspace(-1,1,NFFTX), samplingFreq/2*linspace(-1,1,NFFTY), abs(fftshift(spectrum2D)))



subplot(1,4,4)
surf(test);
hold on;
scatter3(xs, ys, heights, 'rx');



%%

 i = 54;
testImage = squeeze(movieToFit(i,:,:));


vidHeight = size(testImage,1);
vidWidth = size(testImage,2);



 
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
 
 
 
 
 
 
 
 
 
 
 
 