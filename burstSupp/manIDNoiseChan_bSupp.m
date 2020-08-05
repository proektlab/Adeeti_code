%% adding noise channels to recordings

%% name directory that data is in and open directory
% directies will be one of the following names
% Iso_flashes
% Iso_whisk
% iso_longBaseline
% Prop_flashes
% Prop_whisk
% prop_longBaseline


% for each folder, we will run this whole script once
if ispc
    dirInGen = 'Z:\adeeti\JenniferHelen\'; %this folder is yours - it will have
    %all of the data that you collect and will analyze
elseif isunix
    dirInGen = '/synology/adeeti/JenniferHelen/';
end


expIdentifier = '20*.mat'; %all the experiemnts are done in the during 2017-2020 and have the .mat ending

dirInExp = 'iso_longBaseline/'; % this comes from the list of experiments that we have

dirIn = [dirInGen, dirInExp]; %this created the full path

cd(dirIn);

allData = dir(expIdentifier);

expID =  1;

%% loops through all experiments per condition - do this portion for every experiment in the set

warning('') % Clear last warning message

experimentName = allData(expID).name;

load(experimentName, 'LFPData', 'meanSubFullTrace', 'info')
[warnMsg, warnId] = lastwarn;
if contains(warnMsg, 'not found') && contains(warnMsg, 'LFPData')
    load(experimentName, 'fullTrace')
    LFPData = fullTrace;
end


% open EEGLAB, load data into EEGLAB, and find BS periods
eegplot(meanSubFullTrace, 'srate', 1000) % this will open EEGLAB

% now your goal is to look through and see if there are any additional
% noise channels that need to be removed - these are channels that have
% 60Hz noise or channels that have very large deflections - these channels
% are probably not on the brain

prompt = ['NoiseChannels =', mat2str(info.noiseChannels), ' Enter other bad channels, if there are none, put []'];
exNoise = input(prompt); %enter in the extra cahnnels
noiseChannels = sort([info.noiseChannels, exNoise]);

info.noiseChannels = noiseChannels;

save(experimentName, 'info', 'LFPData', '-append')

before = 1;
after = 2;

[meanSubData, meanSubFullTrace] = meanSubAndAvgTrace(experimentName, before, after);

if exist('BSTimepoints')
    BSPeriods = {};
    for i = 1:size(BSTimepoints, 2)
        BSPeriods{i} = meanSubFullTrace(:, BSTimepoints(1,i):BSTimepoints(2,i));
    end
    save(experimentName, 'BSPeriods', '-append')
end


expID = expID +1;

clearvars  info LFPData meanSubFullTrace BSTimepoints BSPeriods

