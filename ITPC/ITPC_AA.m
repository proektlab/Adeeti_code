function [ITPC] = ITPC_AA(WAVE, channels, trials)

if ~exist('trials') || isempty(trials)
    trials = 1:size(WAVE, 4);
end
if ~exist('channels') || isempty(channels)
    channels = 1:size(WAVE, 3);
end

ITPC = nan(length(channels), size(WAVE, 1), size(WAVE, 2));
for chIndex = 1:length(channels)
    ch = channels(chIndex);
    for fr = 1:size(WAVE, 1)
        if isnan(ch)
            ITPC(chIndex, fr,:) = NaN;
        else
        waveDecop = squeeze(WAVE(fr, :, ch, trials));
        ITPC(chIndex, fr,:) = abs(nanmean(exp(1i*angle(waveDecop)),2)); %absolute value of the mean of the euler's formula of the
        %     phase angles from the wavlet transform
        end
    end
end


