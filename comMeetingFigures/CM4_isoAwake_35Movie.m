%% Making movie heat plot of ITPC MutliStim Data

% 8/13/18 Editted for multistim  and multiple anesthetics experiments
% 1/15/19 Editted for larger fonts and new dropbox location
%% Make movie of mean signal at 30-40 Hz for all experiments
clc
clear
close all

dirIn = '/synology/adeeti/ecog/iso_awake_VEPs/GL7/'; %'Z:\adeeti\ecog\iso_awake_VEPs\GL_early\';
dirFILT = '/synology/adeeti/ecog/iso_awake_VEPs/GL7/FiltData/'; %'Z:\adeeti\ecog\iso_awake_VEPs\GL_early\Wavelets\FiltData\';
dirCoh35Movies = '/synology/adeeti/ecog/images/Iso_Awake_VEPs/GL7/coher35MoviesOutlines/'; %'Z:\adeeti\ecog\images\Iso_Awake_VEPs\GL_early\coher35MoviesOutlines\';
dropboxLocation = '/home/adeeti/Dropbox/ProektLab_code/Adeeti_code/'; %'C:\Users\adeeti\Dropbox\KelzLab\';
identifier = '2019*.mat';

COMPARE_ANES =1;

%trial = 50;
fr = 35;
start = 900; %time before in ms
endTime = 1300; %time after in ms
screensize=get(groot, 'Screensize');
movieOutput = [];
finalSampR = 1000;

use_Polarity = 0; %1 if using polarity, 0 if not

darknessOutline = 80; %0 = no outline, 255 is max for black outlines, 80 is good middle ground

stimIndex = [0, Inf]; %if want all, stimIndex = matStimIndex; % if want
%all uniStimIndexes/multiStimIndexes, use [uniStimIndex, multiStimIndex] =
%findUniMutliStimIndex(matStimIndex), [stimIndex, ~] = findUniMutliStimIndex(matStimIndex)


conStrings = {'Low Dose'; 'High Dose'};


%% setting up directories and outline parameters
cd(dirIn)
load('dataMatrixFlashes.mat')

cd(dirFILT)
mkdir(dirCoh35Movies);
allData = dir(identifier);

%% finding experiments with the same characteristics

mouseID = 7;
stim = [0 inf];
expID = [2, 4];

for i = 1:length(expID)
    temp = dataMatrixFlashes(expID(i)).expName;
    compAnes{i} = [temp(length(temp)-22:end-4), 'wave.mat'];
end


%[myFavoriteExp] = findMyExpMulti(dataMatrixFlashes, exp, drugType, conc, stimIndex)

%% Making movies with Coherent bands
% to make an average of signal at coherent bands

close all;
clear filtSig sig
plotIndex = 0;
numExp = size(compAnes, 2);

for anes = 1:numExp
    plotIndex = plotIndex+1;
    load(compAnes{anes}, ['filtSig', num2str(fr)], 'info', 'uniqueSeries', 'indexSeries')
    
    bregmaOffsetX = info.bregmaOffsetX;
    bregmaOffsetY = info.bregmaOffsetY;
    gridIndicies = info.gridIndicies;
    
    % Making sure to only grab  indexes that you are looking
    % for in the mix of trials
    [indices] = getStimIndices(stimIndex, indexSeries, uniqueSeries);
    eval(['sig = filtSig', num2str(fr), '(:, :,indices);']);
    
    %average signal at 35 Hz
    sig = squeeze(mean(sig,3));
    
    %normalize signal to baseline
    m = mean(sig(1:1000,:),1);
    s = std(sig(1:1000,:),1);
    ztransform=(m-sig)./s;
    filtSig(anes,:,:) = ztransform;
    
    %create labels
    plotTitles{anes} = [info.AnesType, ', dose: ', num2str(info.AnesLevel)];
    if isfield(info, 'polarity')
        plotTitles{anes} = [info.AnesType, ', dose: ', num2str(info.AnesLevel), ', polarity: ', info.polarity];
    end
end
superTitle = ['Comparing Iso to Awake'];
colorTitle = ['z threshold voltages from baseline'];

[movieOutput] = makeMoviesWithOutlinesFunc(filtSig, start, endTime, bregmaOffsetX, bregmaOffsetY, gridIndicies, plotTitles, superTitle, colorTitle, [], darknessOutline, dropboxLocation);

v = VideoWriter([dirCoh35Movies, 'M', num2str(mouseID), 'Iso_Awake.avi']);
open(v)
writeVideo(v,movieOutput)
close(v)
close all


