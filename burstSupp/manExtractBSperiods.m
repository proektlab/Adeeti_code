%% Manually extract BS data from experiments

%% name directory that data is in and open directory
% directies will be one of the following names
% Iso_flashes
% Iso_whisk
% Prop_flashes
% Prop_whisk

% for each folder, we will run this whole script once

dirInGen = 'Z:\adeeti\JenniferHelen\'; %this folder is yours - it will have
%all of the data that you collect and will analyze

expIdentifier = '20*.mat'; %all the experiemnts are done in the during 2017-2020 and have the .mat ending

dirInExp = 'Iso_flashes\'; % this comes from the list of experiments that we have

dirIn = [dirInGen, dirInExp]; %this created the full path

cd(dirIn);

allData = dir(expIdentifier);

expID =  5;

%% loops through all experiments per condition - do this portion for every experiment in the set

experimentName = allData(expID).name;
load(experimentName, 'meanSubFullTrace', 'info')

% open EEGLAB, load data into EEGLAB, and find BS periods
eeglab % this will open EEGLAB

% now you do all of this part in the gui
% 1) In the blue popup window, go to File --> Import Data --> Using EEGLAB
% functions and plugins --> from ACII/float file or matlab array
% 2) Data file/ array - choose matlab variable and type in
% meanSubFullTrace; Data Samplimng rate (Hz) = 1000; Number of channels
% = 64; everything else can be left as is for right now --> Press Ok
% 3) Name it: Experiment_1 (or whatever number that you are on - it
% actually doesnt matter what you name the experiment, we dont use this
% info) ==> Ok ==> now your EEGLAB window should have the data loaded
% with the new name as the title
% 4) Tools --> Reject contimus data by eye --> Continue
% 5) you will probably need to manually adjust the scale to 150 uV per
% scale so you can see activity - what ever you think is the best way
% to visualize the data; if you want to see more time of data displayed
% then the 5 seconds that is displayed at once then you will need to go
% to settings--> time range to display and change to what you want to
% see (I like 10 personally)
% 6) now you are ready to ID BS areas! So you want to highlight the BS
% areas in teal for us to extract below. To do this, you will drag your
% mouse over the burst suppression time frames with the left mouse click
% down. When you let go of the mouse click, then the assingment of the
% artifact will end. If the burst contines on beyond the data that is
% shown, just let go of the mouse prematurely, and connect the next
% artifact segment to the first - EEGLAB will count all of this as one
% artifact.
% 7) when you are done with idenitfying all of the burst suppression
% windows, click REJECT
% 8) What would you want ot do with the new dataset? Name it:
% Experiment_1_rej --> Ok
% 9) now you are ready to finish the rest of the loop


%%
FILE = ALLEEG(2).event; %FILE should be the ALLEEG.event structure after labelling sections of interest in the visualizer/GUI of EEGlab and hitting REJECT button

temprej=struct2cell(FILE); %insert EEGLab struct to be converted here
temprej=squeeze(temprej);
rej=cell2mat(temprej(2:3,:));
rejsamp=rej; %converting back to original data sample numbers
for i=2:(size(rej,2))
    rejsamp(1,i)=rejsamp(1,i)+sum(rejsamp(2,1:i-1));
end
%now have 2 rows, 1st row original sample location, 2nd event duration
BSTimepoints=rejsamp;
for j=1:size(BSTimepoints,2)
    BSTimepoints(2,j)=BSTimepoints(1,j)+BSTimepoints(2,j);
end
for k=1:size(BSTimepoints,2)
    BSTimepoints(1,k)=floor(BSTimepoints(1,k));
    BSTimepoints(2,k)=ceil(BSTimepoints(2,k));
end

disp('done')
%%
BSTimepoints=BSTimepoints';
BSTimepoints=sortrows(BSTimepoints,1);
BSTimepoints=BSTimepoints';

disp('done')
%%
BSPeriods = {};

for i = 1:size(BSTimepoints, 2)
    BSPeriods{i} = meanSubFullTrace(:, BSTimepoints(1,i):BSTimepoints(2,i));
end

save(experimentName, 'BSTimepoints', 'BSPeriods', '-append')

expID = expID + 1


disp('saved')
%rejstartend now has starting and ending sample for rejected data with
%whole sample numbers, in order, in a 2xn matrix of start samples and end samples for highlighted sections from the visualizer.