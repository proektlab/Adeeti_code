function [spectrum2D, NFFTX, NFFTY] = twoDFFT4gridMovies(movieImage, samplingFreq)
if nargin<2
samplingFreq = 1;    
end

vidHeight = size(movieImage,1);
vidWidth = size(movieImage,2);
 
NFFTY = 2^nextpow2(vidHeight);
NFFTX = 2^nextpow2(vidWidth);
% 'detrend' data to eliminate zero frequency component
av = sum(movieImage(:)) / length(movieImage(:));
movieImage = movieImage - av;
% Find X and Y frequency spaces, assuming sampling rate of 1

spatialFreqsX = samplingFreq/2*linspace(0,1,NFFTX/2+1);
spatialFreqsY = samplingFreq/2*linspace(0,1,NFFTY/2+1);
spectrum2D = fft2(movieImage, NFFTY,NFFTX);



