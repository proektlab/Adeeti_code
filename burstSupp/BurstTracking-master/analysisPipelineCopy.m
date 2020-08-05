% This allows for analysis of periods of burst suppression
% created by Jared, edited by JL 7/9/20

%% Load dataset
%
% Load dataset from wherever it is- if it has "meanSubFullTrace" and
% "info", you're set. If it just has the LFP data (usually called
% "dataSnippits" or something like "LFPData", make sure to create the
% meanSubFullTrace by subtracting the average LFP across channels at each
% time point.

%directory navigation
loadDir = 'Z:\adeeti\JenniferHelen\rats_BS_grid_iso';
saveDir = loadDir;
dataset = 'meanSub_2019-09-10_12-04-00.mat';

%go to directory
cd(loadDir);
ogRecording = load(dataset);

%get meanSubFullTrace
meanSubFullTrace = ogRecording.meanSubFullTrace;
chGrid = ogRecording.info.gridIndicies;

disp('loaded')

%I think this creates meanSubFullTrace if it doesn't already exist
% meanSubFullTrace = bsxfun(@minus,___,nanmean(___)); 

%% Test or full send?
%
% I'd recommend setting test to one first, then running the next sections
% individually. When test = 1, the smoothing is done with a large step
% size, only the first 10 seconds (~1 burst) is analyzed, and only the
% first n channels are used, where n is the number of active parallel
% clusters.

test = 0;

%% Find channels with NA and ignore them

sTest=sum(meanSubFullTrace,2); %adds up every channel
bad = find(isnan(sTest)); %find which channels have NaNs
chidx = setdiff(1:64,bad); %return channels without NaNs

%converts chidx, which gives  the numbers non-noise channels, to noiseChan 
%which is the index of noise channels on the grid.
noiseChan = find(isnan(mapChGrid(zeros(size(chidx)),chGrid,chidx)));

clear sTest bad

disp('done');

%% Create smoothed trace by sliding window over each channel
%
% Here, you have a few choices. I would recommend running this with 700 ms
% windowSize to begin with, and, if it looks like the test is even
% reasonable, check out the file: 'determiningOptimalWindowSize.m'. That
% process will help ensure your choice of window size doesn't worsen the
% classification significantly.

pp = gcp; %set up parallel pool

BSPeriods = ogRecording.BSPeriods;

%set up cell arrays
smoothedTrace = cell(size(BSPeriods));
postBurstProb = cell(size(BSPeriods));
corStruct = cell(size(BSPeriods));
periodLengths =cell(size(BSPeriods));


%% for each BS Period
for i = 1:numel(BSPeriods) %for each burst period
    tidx = 1:length(BSPeriods{i});
    stepSize = 1; %ms
    windowSize = 600; %ms
    chidxT = chidx;

    if test == 1 %if test is 1, limit computing to first 10 seconds
        stepSize = 10;
        chidxT = chidxT(1:(2*pp.NumWorkers));
        tidx = tidx(1:20000);
    end
%Transforming bsperiods

% Currently without padding, so will lose windowSize/2 on each end of trace

smoothedTrace{i} = applySmoothingFN(...
    BSPeriods{i}(chidxT,tidx),...
    stepSize,...
    windowSize...
    );

% test success:
%figure(1); imagesc(smoothedFullTrace);

% For each channel, fit a gaussian mixture model to classify bursts and suppressions

[postBurstProb{i},fitInfo] = mixModel(smoothedTrace{i});

fitInfo.windowSize = windowSize;
fitInfo.stepSize = stepSize;

clear windowSize stepSize

% test success:
%figure(2); imagesc(postBurstProb)

%add padding to match smoothed trace and model to actual trace
smoothedTrace{i} = [zeros(size(smoothedTrace{i}, 1), fitInfo.windowSize/2), smoothedTrace{i}];
postBurstProb{i} = [zeros(size(postBurstProb{i}, 1), fitInfo.windowSize/2), postBurstProb{i}];

% Using the fit results, find points of transition from burst to suppression
[periodLengths{i}.burstIndex, periodLengths{i}.burst, periodLengths{i}.sup, fitInfo.weirdIndex]...
    = findBurstIndexCopy(postBurstProb{i});

datToCor = 1:size(postBurstProb{i},2); % Here, run correlation across all time points

maxLag = 1000;

corStruct{i} = getCorStruct(...
    postBurstProb{i},...
    datToCor,...
    maxLag...
    );

clear idx maxLag
%

fitInfo.chGrid = chGrid;
fitInfo.chidx = chidx;

periodLengths{i}.bsSegment = size(BSPeriods{i}, 2);
end %end of for loop
disp('analysis done')

%% Save your data

if(test==0)
    cd(saveDir);
    save(dataset,...
        'smoothedTrace',...
        'postBurstProb',...
        'fitInfo',... %don't make this a cell
        'corStruct',... 
        'periodLengths', '-append');
end


%% Functions

function [smoothedFullTrace,smoothTime] = applySmoothingFN(data,stepSize,windowSize)
smoothedFullTrace = zeros(size(data,1),size(data,2)-windowSize);
smoothStart = tic; %foor timing
parfor ii = 1:size(data,1) %for every channel, using some fancy parallel computing stuff
    msd = data(ii,:)-mean(data(ii,:)); %subtract mean from the channel
    smoothedFullTrace(ii,:) = bsWindow(...
        msd,...
        'windowSize',windowSize,...
        'step',stepSize,...
        'padding','none',...
        'type','dev');
end
smoothTime = toc(smoothStart);
end
