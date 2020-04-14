vidHeight = 80; 
vidWidth = 100; 
% These are the wavevectors I want to find
k1 = 0.1;
k2 = 0.6; 
k3 = -0.8;
k4 = 0.7;
generatedOscillation = zeros(vidHeight, vidWidth);
for x = 1:vidWidth
    for y = 1:vidHeight
        % here i add a zero frequency component, which I get rid of by
        % subtracting the average value of the image
        generatedOscillation(y,x) = generatedOscillation(y,x) + 1.2;
          % add one oscillation
          generatedOscillation(y,x) = generatedOscillation(y,x) + sin(k1*x);% + k2*y);
          % add another oscillation
          %generatedOscillation(y,x) = generatedOscillation(y,x) + sin(k3*x + k4*y);
      end
  end
% show resulting image
imagesc(generatedOscillation)


% dft 2d
NFFTY = 2^nextpow2(vidHeight);
NFFTX = 2^nextpow2(vidWidth);
% 'detrend' data to eliminate zero frequency component
av = sum(generatedOscillation(:)) / length(generatedOscillation(:));
generatedOscillation = generatedOscillation - av;
% this section I'm not too sure about, I pretty much copied the example
% from the matlab 1D fft and adapted it slightly for 2D
samplingFreq = 1;
spatialFreqsX = samplingFreq/2*linspace(0,1,NFFTX/2+1);
spatialFreqsY = samplingFreq/2*linspace(0,1,NFFTY/2+1);
spectrum2D = fft2(generatedOscillation, NFFTY,NFFTX);
% shift the 2D spectrum. I'm not entirely sure why, but all the examples
% I've found seem to do it.
spectrum2D = fftshift(spectrum2D);
imagesc(abs(spectrum2D))



%%

twoD_FT= fft2(generatedOscillation);
figure

imagesc(abs(fftshift(twoD_FT)))


% 'detrend' data to eliminate zero frequency component
av = sum(generatedOscillation(:)) / length(generatedOscillation(:));
generatedOscillation = generatedOscillation - av;

twoD_FT= fft2(generatedOscillation);
figure

imagesc(abs(fftshift(twoD_FT)))

%%
vidHeight = 80; 
vidWidth = 100; 
% These are the wavevectors I want to find
k1 = 2*pi*0.1;
k2 = 2*pi*0.1; 
k3 = 2*pi*0.2;
k4 = 2*pi*0.2;
k5= 2*pi*0.1;

generatedOscillation = zeros(vidHeight, vidWidth);
for x = 1:vidWidth
    for y = 1:vidHeight
        % here i add a zero frequency component, which I later get rid of by
        % subtracting the average value of the image
        generatedOscillation(y,x) = generatedOscillation(y,x) + 1.2;
          % add one oscillation
          generatedOscillation(y,x) = generatedOscillation(y,x) + sin(k1*x + k2*y);
          % add another oscillation
        % generatedOscillation(y,x) = generatedOscillation(y,x) + sin(k3*x + k4*y);
         %generatedOscillation(y,x) = generatedOscillation(y,x) + sin(k5*x);

      end
  end
% show resulting image
figure
subplot(1,3,1)
imagesc(generatedOscillation)
% dft 2d
NFFTY = 2^nextpow2(vidHeight);
NFFTX = 2^nextpow2(vidWidth);
% 'detrend' data to eliminate zero frequency component
av = sum(generatedOscillation(:)) / length(generatedOscillation(:));
generatedOscillation = generatedOscillation - av;
% Find X and Y frequency spaces, assuming sampling rate of 1
samplingFreq = 1;
spatialFreqsX = samplingFreq/2*linspace(0,1,NFFTX/2+1);
spatialFreqsY = samplingFreq/2*linspace(0,1,NFFTY/2+1);
spectrum2D = fft2(generatedOscillation, NFFTY,NFFTX);
subplot(1,3,2)
contourf(spatialFreqsX, spatialFreqsY, abs(spectrum2D(1:NFFTY/2+1, 1:NFFTX/2+1)))
subplot(1,3,3)
imagesc(samplingFreq/2*linspace(-1,1,NFFTX), samplingFreq/2*linspace(-1,1,NFFTY), abs(fftshift(spectrum2D)))


BW = imregionalmax(abs(fftshift(spectrum2D))');

figure
imagesc(BW)



%%



test = abs(fftshift(spectrum2D)); %perlin2D(200);
BW = imregionalmax(test');
[xs, ys] = ind2sub(size(BW), find(BW==1));
heights = [];
for i = 1:length(xs)
    heights(i) = test(ys(i), xs(i));
end
figure(1);
clf;
surf(test);
hold on;
scatter3(xs, ys, heights, 'rx');





