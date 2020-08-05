% This code splices a BS period into two or more shorter ones
% 6/4/20 JL 

%% Variables

%sections that need to linked together
replacement = 1000.*[0, 62.25, 80, 92.8; 57.7, 75, 83.2, 98];

%replacement location. ideally, you should work from highest column to
%lowest column
repLoc = 1;

%file location
dirInExp = 'Iso_flashes\'; %folder name
expID =5; %experiment number

%% Navigate to correct file, get experiment name and BSTimepoints
dirInGen = 'Z:\adeeti\JenniferHelen\';

expIdentifier = '20*.mat'; %all the experiemnts are done in the during 2017-2020 and have the .mat ending

dirIn = [dirInGen, dirInExp]; %this created the full path

cd(dirIn);

allData = dir(expIdentifier);

experimentName = allData(expID).name;
load(experimentName, 'BSTimepoints')

%% splice

newBSTimepoints = [BSTimepoints(:, 1:repLoc - 1), replacement, BSTimepoints(:, repLoc +1:end)];

%% save

BSTimepoints = newBSTimepoints;

BSPeriods = {};

for i = 1:size(newBSTimepoints, 2)
    BSPeriods{i} = meanSubFullTrace(:, newBSTimepoints(1,i): newBSTimepoints(2,i));
end

save(experimentName, 'BSTimepoints', 'BSPeriods', '-append')