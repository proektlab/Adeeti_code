%% Load and organize the isoflurane induction/emergence data for further analyses
% The data are ECoG files recorded from mice undergoing induction and
% emergence from isoflurane anesthesia.

% The data live on the Proekt lab server (192.168.1.237:5001) in the
% folder:
%       /mouseData/compiled/

% Within each file:
%       EMG - data collected during emergence
%       IND - data collected during induction
%           portC# - the software used to collect this data crashed
%           sometimes so these are "trials" they need to be concatenated in
%           time

% Written by Brenna Shortal using code adapted from RMM and DH
%   /home/rachel/scripts/avg_spectrogram/

%%
addpath(genpath('/Users/Brenna/Dropbox/ProektLab/PropStates/'))
addpath(genpath('/Users/Brenna/Documents/AndiData/'))
%% Load color map

clear all
clc

% Brenna is very particular about colors and all plotting functions require
% this color map
colormapLocation = '/data/adeeti/ecog/'
load(['/data/adeeti/ecog/BrennaColorMap2.mat'])
cidx = 1:6:60; % use this to index cmap
id = cidx(1,randperm(10));
cmap = mycmap;
cmap = cmap(cidx,:); % this gives a set of 10 random, but equally spaced colors
clear cidx id

cmap = cmap([2,5,6,8,10],:);

%% Information

% Subjects to look at. Will accept single values or vectors
% subs = [1,3,4];
subs = 4;

% Sex of subjects
subject{1} = 'M10';
subject{2} = 'M11';
subject{3} = 'M12';
subject{4} = 'M13';
subject{5} = 'M15';
subject{6} = 'M16';
subject{7} = 'M17';
subject{8} = 'M18';
subject{9} = 'M21';
subject{10} = 'M22';
subject{11} = 'M23';
subject{12} = 'M24';
subject{13} = 'M25';

notes = ['Here is hoping this works'];

% Choose one channel to analyze. Will accept single values or vectors
choicechan = 14; 

% indir = '/data/adeeti/ecog/matPropStates2018/'; % Alex's rig computer
indir = '/Users/Brenna/Documents/AndiData/'; % Brenna's desk computer
%indir = '/data/adeeti/ecog/Andrew_Andi_Brick_Awake/';

INDorEMG = 'EMG';

%% Set up a director for saving things.
% outdir = ['/data/brenna/PropStates/', expdate(subs,:), '/']; % Alex's rig computer
outdir = '/Users/Brenna/Documents/AndiData/SpecRes/'; % Brenna's desk computer
outdir = ['/data/adeeti/ecog/Andrew_Andi_Brick_Awake/', '/images'];

if ~exist(outdir,'dir')
    mkdir(outdir)
end

%% Options
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Removing outliers and mean subtracting
% Cut off whatever percentage from the high and low ends of the data
% distribution
cutoffs=[0.01, 0.99];
% The number of standard deviations beyond which you want to call data an
% outlier in amplitude
ampCutoff = 2; % units of standard deviation

freqCutoff = 50;

% PCA
win = 30; % size of window (secs)
win_step = 5; % size of window step (secs)
ktapers = 20;
NW = 39;

% Plotting spectrogram
% How often you want a tick on the x axis, give 1 or 10;
t = 10;

% kmeans clustering
clustnum = 3;

options.outlierCutoffs = cutoffs;
options.ampCutoff = ampCutoff;
options.freqCutoff = freqCutoff;
options.PCAwinsize = win;
options.PCAwinoverlap = win_step;
options.PCAtapers = ktapers;
options.PCAnw = NW;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Save information about analysis
% Load the information file associated with the file and save it in the
% output folder along with some more variables about the analyses run.

% [info] = InfoSaver_PropStates(subs,choicechan,expdate,indir,outdir,sex,prop,notes);

%% Find sampling rate
% The sampling rate is the same for all recordings and saved as a variable

fs = 250;

%% Pull out data for selected channel
% Create index vector for each subject that tells you which indices of the
% total data length belong to which subject.

[databyconc, concdur] = RecordingSelector_BComp(subs, subject, INDorEMG, choicechan, indir); % Brenna's desk computer

% Now we have:
%       databyconc -- a double cell array. First order cells are the
%       different subjects, if you are looking at more than one. Second
%       order cells are the concentration steps for the subject.
%       expdate -- strings that give the date the experiment/subject names
%       concdur -- a cell array that, for each subject selected, gives the
%       duration of each concentration in units of data points

%% Create indexing arrays
% Later on, it will be nice to be able to index the data by subject and
% concentration. Create vectors that are the length of the total data
% vector with all zeros, except for where a particular subject or
% concentration happens.

[conc_tidx, sub_tidx, finbin] = MakeIndexingArrays(databyconc,concdur);

% Now we have:
%       sub_tidx -- subject time indices. A cell array with a cell per
%       subject. Each cell is a 1 x total duration vector of ones and
%       zeros. Ones when that subjects data appears in the concatenated
%       dataset.
%       conc_tidx -- concentration time indices. A cell array like sub_tidx
%       excecpt that each cell has a matrix of dimensions concentration x
%       duration of that subject's recording
%       finbin -- a useful matrix for indexing later. It is the final data
%       point of each concentration recording with a zero on the top.

%% Rearrange the conc steps to be a single, horizontally concatenated matrix of steps
% If looking at more than one subject, there is some extra rearranging that needs to be done

[alldata] = RearrangeCellArrays_PropStates(databyconc,subs);

% finbin will also need to be made into a single vector
fb{1,1} = finbin{1,1};
temp = finbin{1,1}(end,1);
if size(subs,2) > 1
    for s = 2:size(subs,2)
        fb{s,1} = finbin{s,1}(2:end,1) + temp;
        temp = fb{s,1}(end,1);
    end
    finbin = [];
    for s = 1:size(subs,2)
        finbin = vertcat(finbin,fb{s,1});
    end
else
    finbin = finbin{1,1};
end

clear temp fb

% Now we have:
%       alldata -- a single matrix that contains all of the data for the
%       selected subjects for all of their concentration steps. Organized
%       as sub1conc1, sub1conc2, ... sub2conc1,sub2conc2, ...
%       finbin -- a single vector of the final data point of each
%       concentration step for all subjects with one zero as the first
%       value

%% Remove amplitude outliers
% This data is full of high amplitude outliers that need to be taken out.

[cleanData,cleanTime_amp] = RemoveAmpOutliers(alldata,ampCutoff);

%% Create spectrogram, remove outliers, and mean subtract

[spectrum, out] = CreateSpectrogram(cleanData,fs,ktapers,win,win_step,NW);

[cleanSpec,cleanTime_spc] = RemoveSpcOutliers(spectrum,out,cutoffs,freqCutoff);

[normSpec] = MeanSubSpc(cleanSpec);

% save([outdir,'NormalizedSpectrum_subs',num2str(1),'to',num2str(end),'.mat'],'normSpec');
% save([outdir,'info_subs',num2str(1),'to',num2str(end),'.mat'],'subs','win','win_step','ktapers','NW','cutoffs','freqCutoff','options');

% [meanSubSpc, out] = CreateSpectrogram_MeanSub(DATA,fs,ktapers,win,win_step,NW,outdir,choicechan,fname,t);

%% Plot spectrogram

PlotSpectrogram(normSpec,choicechan,win_step,t);

%% PCA

% addpath('/home/rachel/scripts/pca');

[T,pvar, W, L] = pca_alex(normSpec');

%% K means

[idx,C] = kmeansandplot(T([1,2, 4],:),clustnum,cmap);

set(gca,'xtick',[]);
set(gca,'ytick',[]);
set(gca,'ztick',[]);

xlabel('PC1')
ylabel('PC2')
zlabel('PC3')
set(gca,'fontsize',20)

%% Plot color-coded state assignments across time

PlotClustColor_intime(idx,clustnum,cmap,cleanTime_spc);

%% Plot just sections of LFP to see what it looks like during different
% % portions of spectrogram
% 
% % choose the time points to look at in units of minutes
% minutes = [8, 22, 30, 45, 55];
% 
% % how much time after these time point do you want to see? again, in minutes
% ws = 6;
% 
% if ~exist('choiceConc','var')
%     % Want to see it all?
%     PlotSnips_LFPandSpc(normSpec, alldata,fs,minutes,ws);
% else
%     % Or maybe just one concentration?
%     % PlotSnips_LFPandSpc(normSpec, alldata(:,(finbin(1,1)) + 1:finbin(1 + 1,1)),fs,m,ws);
%     PlotSnips_LFPandSpc(normSpec,alldata,fs,minutes,ws,cleanTime_spc);
% end




