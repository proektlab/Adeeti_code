function [residual,f0,fspectrum,cs,freq_grid,taper] = spectralLineFilter(data,sampleFreq,Ktapers,freqsOfInterest,pad,taper,sigThresh)
% function [residual,f0,fspectrum,cs,freq_grid] = spectralLineFilter(data,sampleFreq,Ktapers,freqsOfInterest,pad,taper,sigThresh)
%
% This function follows Jarvis and Mitra in approach to remove the most
% significant of any clear linespectra from locally white noise.
%
% INPUTS: 
%       data, a maxtrix [ntrials nsamples] of data to check for significant
%               linespectra; if present, they will be removed
%       sampleFreq, a scalar, specifying the frequency at which the data
%           were sampled; defaults to 1KHz.
%       Ktapers, a scalar, specifying the number of tapers to use in the
%           spectral estimate; defaults to the most tapers that can be used 
%           to acheive a 1Hz bandwith on the frequency content
%       freqsOfInterest, a scalar or 2 element vector, specifying the 
%           frequency range to examine for lines.  If one entry is provided,
%           the lower limit is assumed to be 0. Defaults to include all
%           frequencies below the Nyquist limit.
%       pad, a scalar, specifying the padding to do for the fft.
%       taper, a matrix [nsamples Ktapers], containing the slepian sequences 
%           to use as tapers for the spectral estimate.  Useful for
%           saving computational overhead when including this function in a
%           loop.
%       sigThresh, a scalar, value for which if 1-p<sigThresh, a line
%           element would be considered significant.  Defaults to
%           1/Nsamples.
%
% OUTPUTS:
%       residual, a matrix containing the data with the lines removed on a
%           trial-by-trial basis
%       f0, the frequency of the removed line element
%       fspectrum, the fstatistics of the spectrum.  Asymptotically
%           distributed as F_2_,_2(K-1).
%       cs, the complex spectrum; can be used to reconstruct the line
%           elements
%       freq_grid, a vector of the frequencies contained in the spectral
%           quantities
%
% Written 5/27/2004 by Andrew Hudson, based upon an algorithm by Bijan
% Pesaren.  Last Updated 5/27/2004.

[trials,Nsamples] = size(data);

if nargin<2 sampleFreq = []; end;
if nargin<3 Ktapers = []; end;
if nargin<4 freqsOfInterest = []; end;
if nargin<5 pad = []; end;
if nargin<6 taper = [];end;
if nargin<7 sigThresh = []; end;

if isempty(sampleFreq) sampleFreq = 1000; end;
if isempty(Ktapers)  Ktapers = 2*ceil(Nsamples/sampleFreq) - 1; end
if isempty(pad)  pad = 2.^max((nextpow2(Nsamples)+6),12); end
NW = Ktapers+1;
if isempty(taper); taper=dpss(Nsamples,NW); taper=taper(:,1:Ktapers); end;
if isempty(freqsOfInterest) freqsOfInterest = [0 sampleFreq/2];
elseif length(freqsOfInterest)==1 freqsOfInterest = [0 freqsOfInterest]; end;
if isempty(sigThresh) sigThresh = 1./Nsamples; end;
freqsOfInterest = sort(freqsOfInterest);
pad_freqs = sampleFreq*(1:pad)/pad;
keep = find(pad_freqs>freqsOfInterest(1)&pad_freqs<freqsOfInterest(2));
[fspectrum, cs, freq_grid] = spectralFtest(data,1./sampleFreq,Ktapers,pad,freqsOfInterest,taper);

if trials>10
    w = waitbar(0,'Fitting line spectra');
end
for t=1:trials
    if trials>10  waitbar(t/trials,w); end;
    [f_val,ind] = max(fspectrum(t,:)); % find the most significant line element in each channel and remove it
    f0(t) = freq_grid(ind);
    p(t) = fcdf(f_val,2,2*(Ktapers-1)); % Percival and Walden
    sig = (1-p(t)<sigThresh);
    best_fit(t,1:Nsamples) = sig.*2.*real(repmat(cs(t,ind),[1,Nsamples]).*exp(-2*pi*complex(0,1).*repmat(f0(t)',[1,Nsamples]).*(0:Nsamples-1)./sampleFreq));
end;

residual = data-best_fit;
if trials>10  
    close(w); 
end;