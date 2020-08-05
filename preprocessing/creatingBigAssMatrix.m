%% Creating big ass matric for searching parameter space 
% 08/07/18 AA editted to make it compatible with multistim data 

dataMatrixFlashes = [];

for i = 1:length(allData)
    temp = [];
    load(allData(i).name, 'info')
    
    temp.expName = [allData(i).name];
    
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
    
    if isfield(info, 'notes')
    temp.notes= info.notes;
    end
    
    if isfield(info, 'interPulseInterval')
    temp.interPulseInterval= info.interPulseInterval;
    end
    
    if isfield(info, 'interStimInterval')
    temp.interStimInterval= info.interStimInterval;
    end
    
    if isfield(info, 'numberStim')
    temp.numberStim= info.numberStim;
    end

    if isfield(info, 'Stim1')
    temp.Stim1= info.Stim1;
    temp.Stim1ID = info.Stim1ID;
    temp.LengthStim1= info.LengthStim1;
    temp.IntensityStim1= info.IntensityStim1;
    end

    if isfield(info, 'Stim2')
        temp.Stim2= info.Stim2;
        temp.Stim2ID= info.Stim2ID;
        temp.LengthStim2= info.LengthStim2;
        temp.IntensityStim2= info.IntensityStim2;
    end
    
    if isfield(info, 'Stim3')
        temp.Stim3= info.Stim3;
        temp.Stim3ID= info.Stim3ID;
        temp.LengthStim3= info.LengthStim3;
        temp.IntensityStim3= info.IntensityStim3;
    end
    
    if isfield(info, 'Stim4')
        temp.Stim4= info.Stim4;
        temp.Stim4ID= info.Stim4ID;
        temp.LengthStim4= info.LengthStim4;
        temp.IntensityStim4= info.IntensityStim4;
    end

    if exist('electStim', 'var') && electStim ==1
        temp.polarity = info.polarity;
    end

    if isfield(info, 'V1')
        temp.V1 = info.V1;
    end
    
    if isfield(info, 'lowLat')
        temp.lowLat = info.lowLat;
    end
    
    if isfield(info, 'ecogChannels')
        temp.ecogChannels = info.ecogChannels;
        temp.ecogGridName = info.ecogGridName;
    end
    
    if isfield(info, 'forkChannels')
        temp.forkChannels = info.forkChannels;
        temp.forkPosition = info.forkPosition;
        temp.forkName= info.forkName;
    end
    
    if isfield(info, 'stimIndex')
        temp.stimIndex = info.stimIndex;
    end
    
    dataMatrixFlashes = [dataMatrixFlashes, temp];
end

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

save([dirIn, 'dataMatrixFlashes.mat'], 'dataMatrixFlashes')

