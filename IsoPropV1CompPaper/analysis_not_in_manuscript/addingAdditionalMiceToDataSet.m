
dirIn = '/data/adeeti/ecog/z_brainDeadMice_VEPs/';

identifier = '20*.mat';
allData = dir(identifier);

for i = 1:length(allData)
    load(allData(i).name, 'info')
    if contains(allData(i).name(1:4),'2018')
        info.exp = 1;
    elseif contains(allData(i).name(1:4),'2019')
        if str2num(allData(i).name(12:13)) < 17
            info.exp= 2;
        else
            info.exp = 3;
        end
    end
    save(allData(i).name, 'info', '-append')
end

%% Creating big ass matrix

cd(dirIn)
allData = dir('2*.mat');
electStim = 0; %0 if sensory, 1 if electrical

creatingBigAssMatrix

%% Adding unique series id to info files and big ass matrix

cd(dirIn)
allData = dir('2019*.mat');
load('dataMatrixFlashes.mat');

for experiment = 1:length(allData)
    load(allData(experiment).name, 'info', 'uniqueSeries', 'indexSeries')
    y =  mode(indexSeries);
    info.stimIndex = uniqueSeries(y,:);
    dataMatrixFlashes(experiment).stimIndex = info.stimIndex;
    save(allData(experiment).name, 'info', '-append')
end

save('dataMatrixFlashes.mat', 'dataMatrixFlashes')

%% Creating stimIndexMatrix

cd(dirIn)

load('dataMatrixFlashes.mat')

if isfield(dataMatrixFlashes, 'numberStim')
    numStim = unique([dataMatrixFlashes.numberStim]);
    if numel(numStim) > 1
        disp('There is at least one file that does not have the same stimulation paradigm as the others. This may be a mistake in info file and dataMatrixFlashes generation');
    elseif numel(numStim) == 0
        disp('You have recorded that there are no stimuli in this file; will treat as baseline measurement.');
    else
        if numStim ==1
            numStim = 2;
        end
        matStimIndex = (reshape([dataMatrixFlashes.stimIndex], [numStim, size(dataMatrixFlashes,2)]))';
        matStimIndex = unique(matStimIndex, 'rows');
    end
else 
    disp('You have recorded that there are no stimuli in this file; will treat as baseline measurement.');
end

if exist('matStimIndex')
    save([dirIn, 'matStimIndex.mat'], 'matStimIndex')
end

%% adding to dataFlashesMatrix when adding mice to fill processing data set 

load('dataMatrixFlashesVIS_ONLY.mat')

for i = 1:length(allData)
    load([dirOut, allData(i).name], 'info')
    dataMatrixFlashesVIS_ONLY(i+32).expName = [allData(i).name];
    dataMatrixFlashesVIS_ONLY(i+32).exp = info.exp;
    dataMatrixFlashesVIS_ONLY(i+32).AnesType = info.AnesType;
    dataMatrixFlashesVIS_ONLY(i+32).AnesLevel = info.AnesLevel;
    dataMatrixFlashesVIS_ONLY(i+32).TypeOfTrial = info.TypeOfTrial;
    dataMatrixFlashesVIS_ONLY(i+32).date = info.date;
    dataMatrixFlashesVIS_ONLY(i+32).channels = info.channels;
    dataMatrixFlashesVIS_ONLY(i+32).notes = info.notes;
    dataMatrixFlashesVIS_ONLY(i+32).noiseChannels = info.noiseChannels;
    dataMatrixFlashesVIS_ONLY(i+32).interPulseInterval = info.interPulseInterval;
    dataMatrixFlashesVIS_ONLY(i+32).interStimInterval = info.interStimInterval;
    dataMatrixFlashesVIS_ONLY(i+32).numberStim = info.numberStim;
    dataMatrixFlashesVIS_ONLY(i+32).gridIndicies = info.gridIndicies;
    dataMatrixFlashesVIS_ONLY(i+32).Stim1 = info.Stim1;
    dataMatrixFlashesVIS_ONLY(i+32).Stim1ID = info.Stim1ID;
    dataMatrixFlashesVIS_ONLY(i+32).LengthStim1 = info.LengthStim1;
    dataMatrixFlashesVIS_ONLY(i+32).IntensityStim1 = info.IntensityStim1;
    dataMatrixFlashesVIS_ONLY(i+32).Stim2 = nan;
    dataMatrixFlashesVIS_ONLY(i+32).Stim2ID = nan;
    dataMatrixFlashesVIS_ONLY(i+32).LengthStim2 = nan;
    dataMatrixFlashesVIS_ONLY(i+32).IntensityStim2 = nan;
    dataMatrixFlashesVIS_ONLY(i+32).stimIndex = info.stimIndex;
    dataMatrixFlashesVIS_ONLY(i+32).lowLat = info.lowLat;
end

save('dataMatrixFlashesVIS_ONLY.mat', 'dataMatrixFlashesVIS_ONLY')


