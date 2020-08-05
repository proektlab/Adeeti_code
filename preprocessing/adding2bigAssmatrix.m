function [dataMatrixFlashes] = adding2bigAssmatrix(dirMat, dataMatrixFlashes, info)
%[dataMatrixFlashes] = adding2bigAssmatrix(dirIn, dataMatrixFlashes, info)
%%
temp = [];
temp.expName = info.expName;

temp.exp = info.exp;
temp.AnesType = info.AnesType;
temp.AnesLevel= info.AnesLevel;
temp.TypeOfTrial = info.TypeOfTrial;
temp.date= info.date;
temp.channels= info.channels;
temp.noiseChannels = info.noiseChannels;
temp.gridIndicies= info.gridIndicies;
temp.bregmaOffsetX = info.bregmaOffsetX;
temp.bregmaOffsetY = info.bregmaOffsetY;

if isfield(dataMatrixFlashes, 'notes')
    if isfield(info, 'notes')
        temp.notes= info.notes;
    else
        temp.notes= nan;
    end
end

if isfield(dataMatrixFlashes, 'interPulseInterval')
    if isfield(info,'interPulseInterval')
        temp.interPulseInterval= info.interPulseInterval;
    else
        temp.interPulseInterval= nan;
    end
end

if isfield(dataMatrixFlashes, 'interStimInterval')
    if isfield(info, 'interStimInterval')
        temp.interStimInterval= info.interStimInterval;
    else
        temp.interStimInterval= nan;
    end
end

if isfield(dataMatrixFlashes, 'numberStim')
    if isfield(info, 'numberStim')
        temp.numberStim= info.numberStim;
    else
        temp.numberStim= nan;
    end
end


if isfield(dataMatrixFlashes, 'Stim1')
    if isfield(info, 'Stim1')
        temp.Stim1= info.Stim1;
        temp.Stim1ID = info.Stim1ID;
        temp.LengthStim1= info.LengthStim1;
        temp.IntensityStim1= info.IntensityStim1;
    else
        temp.Stim2= nan;
        temp.Stim2ID= nan;
        temp.LengthStim2= nan;
        temp.IntensityStim2= nan;
    end
end

if isfield(dataMatrixFlashes, 'Stim2')
    if isfield(info, 'Stim2')
        temp.Stim2= info.Stim2;
        temp.Stim2ID= info.Stim2ID;
        temp.LengthStim2= info.LengthStim2;
        temp.IntensityStim2= info.IntensityStim2;
    else
        temp.Stim2= nan;
        temp.Stim2ID= nan;
        temp.LengthStim2= nan;
        temp.IntensityStim2= nan;
    end
end

if isfield(dataMatrixFlashes, 'Stim3')
    if isfield(info, 'Stim3')
        temp.Stim3= info.Stim3;
        temp.Stim3ID= info.Stim3ID;
        temp.LengthStim3= info.LengthStim3;
        temp.IntensityStim3= info.IntensityStim3;
    else
        temp.Stim3= nan;
        temp.Stim3ID= nan;
        temp.LengthStim3= nan;
        temp.IntensityStim3= nan;
    end
end

if isfield(dataMatrixFlashes, 'Stim4')
    if isfield(info, 'Stim4')
        temp.Stim4= info.Stim4;
        temp.Stim4ID= info.Stim4ID;
        temp.LengthStim4= info.LengthStim4;
        temp.IntensityStim4= info.IntensityStim4;
    else
        temp.Stim4= nan;
        temp.Stim4ID= nan;
        temp.LengthStim4= nan;
        temp.IntensityStim4= nan;
    end
end

if isfield(dataMatrixFlashes, 'polarity')
    if isfield(info, 'polarity')
        temp.polarity = info.polarity;
    else
        temp.polarity = nan;
    end
end

%     if isfield(dataMatrixFlashes, 'V1')
%         temp.V1 = info.V1;
%     end

%     if isfield(dataMatrixFlashes, 'lowLat')
%         temp.lowLat = info.lowLat;
%     end

if isfield(dataMatrixFlashes, 'ecogChannels')
    if isfield(info, 'ecogChannels')
        temp.ecogChannels = info.ecogChannels;
        temp.ecogGridName = info.ecogGridName;
    else
        temp.ecogChannels = nan;
        temp.ecogGridName = nan;
    end
end

if isfield(dataMatrixFlashes, 'forkChannels')
    if isfield(info, 'forkChannels')
        temp.forkChannels = info.forkChannels;
        temp.forkPosition = info.forkPosition;
        temp.forkName= info.forkName;
    else
        temp.forkChannels = nan;
        temp.forkPosition = nan;
        temp.forkName= nan;
    end
end

if isfield(dataMatrixFlashes, 'stimIndex')
    if isfield(info, 'stimIndex')
        temp.stimIndex = info.stimIndex;
    else
        temp.stimIndex = nan;
    end
end

dataMatrixFlashes = [dataMatrixFlashes, temp];


% for i = 1:length(dataMatrixFlashes)
%     s = dataMatrixFlashes(i).date;
%
%     if contains(s, '01-18')
%         dataMatrixFlashes(i).exp = 10;
%         info.exp = 10;
%     elseif contains(s, '01-22')
%         dataMatrixFlashes(i).exp = 11;
%         info.exp = 11;
%     elseif contains(s, '02-05')
%         dataMatrixFlashes(i).exp = 12;
%         info.exp = 12;
%     end
% end

save([dirMat, 'dataMatrixFlashes.mat'], 'dataMatrixFlashes')

