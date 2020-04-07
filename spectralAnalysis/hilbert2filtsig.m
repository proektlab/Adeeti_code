function [filtSig] = hilbert2filtsig(H)
% [filtSig] = hilbert2filtsig(H)
% Converts analytic signal in hilbert back to filtered singal in time
% domain
amp = abs(H);
theta = angle(H);
filtSig = amp.*cos(theta);