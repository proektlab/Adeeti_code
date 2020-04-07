function [filterweights] = buildBandPassFiltFunc_AA(finalSampR, filtbound, trans_width, filt_order)
% [filterweights] = buildBandPassFiltFunc_AA(finalSampR, filtbound, trans_width, filt_order)
% band pass filter generation using firls function in matlab 
% default is set for filter for 35 Hz
% 09/20/18 AA

if nargin <1
    finalSampR = 1000;
end
if nargin <2
    filtbound = [30 40]; % Hz
end
if nargin <3
    trans_width = 0.2; % fraction of 1, thus 20%
end
if nargin < 4
    filt_order = 50; %filt_order = round(3*(EEG.srate/filtbound(1)));
end
% setting up for low pass FIR filtering
nyquist = finalSampR/2;
ffrequencies = [ 0 (1-trans_width)*filtbound(1) filtbound (1+trans_width)*filtbound(2) nyquist ]/nyquist;
idealresponse = [0 0 1 1 0 0];
filterweights= firls(filt_order,ffrequencies,idealresponse);
