%% Making movie heat plot of ITPC MutliStim Data

% 8/13/18 Editted for multistim  and multiple anesthetics experiments
% 1/15/19 Editted for larger fonts and new dropbox location
%% Make movie of mean signal at 30-40 Hz for all experiments
clc
clear
close all

if isunix
    genDir = '/synology/adeeti/ecog/iso_awake_VEPs/';
    picsDir =  '/synology/adeeti/ecog/images/Iso_Awake_VEPs/';
    dropboxLocation = '/home/adeeti/Dropbox/ProektLab_code/Adeeti_code/'; %'C:\Users\adeeti\Dropbox\KelzLab\';
elseif ispc
    genDir = 'Z:\adeeti\ecog\iso_awake_VEPs\';
    picsDir =  'Z:\adeeti\ecog\images\Iso_Awake_VEPs\';
    dropboxLocation = 'C:\Users\adeeti\Dropbox\ProektLab_code\Adeeti_code\';
end

mouse = 'GL9';
compExp = [4, 6, 8];
compString = {'Isoflurane'; 'Awake'; 'Ketamine'};

identifier = '2020*';
stimIndex = [0, Inf];

%trial = 50;
fr = [5, 35];
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


%% setting up directories
dirIn = [genDir, mouse, '/'];
dirFILT = [dirIn, 'FiltData/'];

cd(dirIn)
load('dataMatrixFlashes.mat')

cd(dirFILT)
mkdir(picsDir);
allData = dir(identifier);

%% Making movies with Coherent bands
% to make an average of signal at coherent bands

for expID = 1:length(compExp)
    
    close all;
    clear sig
    disp(['Exp: ', num2str(compExp(expID))]);
    plotIndex = 0;
    numExp = length(compExp);

    plotIndex = plotIndex+1;
    load(allData(compExp(expID)).name, ['filtSig', num2str(fr)], 'info', 'uniqueSeries', 'indexSeries')
    
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
    filtSig(expID,:,:) = ztransform;
    
    %create labels
    plotTitles{expID} = [info.AnesType, ', dose: ', num2str(info.AnesLevel)];
    if isfield(info, 'polarity')
        plotTitles{expID} = [info.AnesType, ', dose: ', num2str(info.AnesLevel), ', polarity: ', info.polarity];
    end
end

superTitle = ['Comparing Anesthetics, Exp: ', mouse];
colorTitle = ['z threshold voltages from baseline'];

[movieOutput] = makeMoviesWithOutlinesFunc(filtSig, start, endTime, bregmaOffsetX, bregmaOffsetY, gridIndicies, plotTitles, superTitle, colorTitle, [], darknessOutline, dropboxLocation);

v = VideoWriter([picsDir, 'GL9_compDelta.avi']);
open(v)
writeVideo(v,movieOutput)
close(v)
close all

