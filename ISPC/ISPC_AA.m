function [ISPC, allAngDiff] = ISPC_AA(waveDecop, info)
% [ISPC, angleDiff] = ISPC_AA(waveDecop, info) 
% waveDecop is a wavelet decomp of single trials of time x chan x trials
phaseData = angle(waveDecop);

ISPC = nan(info.channels, info.channels, size(waveDecop,1));

%     phase angles from the wavlet transform
for ch2= 1:size(waveDecop, 2)
    for ch1 = 1:size(waveDecop, 2)
        angleDiff = phaseData(:, ch1 ,:)-phaseData(:, ch2, :);
        allAngDiff(ch1, ch2, :,:) = squeeze(angleDiff);
        ISPC(ch1, ch2, :) = squeeze(mean(exp(1i*(angleDiff)),3));
    end
end