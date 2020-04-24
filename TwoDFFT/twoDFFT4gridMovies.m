function [spectrum2D, NFFTX, NFFTY] = twoDFFT4gridMovies(movieImage)

vidHeight = size(movieImage,1);
vidWidth = size(movieImage,2);
 
NFFTY = 2^nextpow2(vidHeight);
NFFTX = 2^nextpow2(vidWidth);
% 'detrend' data to eliminate zero frequency component
av = nansum(movieImage(:)) / length(movieImage(:));
movieImage = movieImage - av;
spectrum2D = fft2(movieImage, NFFTY,NFFTX);



