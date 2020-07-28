% This code links together two segments, making everything between the two
% segments also considered 'BS'
% 6/4/20 JL added code in beginning to navigate to experiment, fixed problem
% with deletions shifting array indexes
%% Variables

%sections that need to linked together
BStime2Link = [15, 16];

%file location
dirInExp = 'Iso_flashes\'; %folder name
expID =2; %experiment number

%% Navigate to correct file, get experiment name and BSTimepoints
dirInGen = 'Z:\adeeti\JenniferHelen\';

expIdentifier = '20*.mat'; %all the experiemnts are done in the during 2017-2020 and have the .mat ending

dirIn = [dirInGen, dirInExp]; %this created the full path

cd(dirIn);

allData = dir(expIdentifier);

experimentName = allData(expID).name;
load(experimentName, 'BSTimepoints')
load(experimentName, 'meanSubFullTrace')
%% Linking together sections 
%put rows in descending order to prevent problems with elements shifting
%left after column deletion
BStime2Link = sort(BStime2Link);
BStime2Link = flip(BStime2Link);  

%loops through BStime2Link and links those column together
for i = 1:size(BStime2Link,1)
    BSTimepoints;(2,BStime2Link(i, 1)) = BSTimepoints;(2,BStime2Link(i, 2));
    BSTimepoints;(:,BStime2Link(i, 1)+1:BStime2Link(i, 2)) = [];
end

%% rerun BS periods 
BSPeriods = {};

for i = 1:size(BSTimepointsTest, 2)
    BSPeriods{i} = meanSubFullTrace(:, BSTimepointsTest(1,i):BSTimepointsTest(2,i));
end

BSTimepoints = BSTimepointsTest;
save(experimentName, 'BSTimepoints', 'BSPeriods', '-append')