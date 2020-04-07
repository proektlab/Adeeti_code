%movie coherence single trials
clc
clear
close all

% dirIn1 = '/Users/adeetiaggarwal/Google Drive/data/matIsoPropMultiStimVIS_ONLY_/flashTrials/FiltData/'; %'Z:\adeeti\ecog\iso_awake_VEPs\GL_early\';
% dirOut = '/Users/adeetiaggarwal/Google Drive/IsoPropMultiStim//singTr35MoviesOutlines/'; %'Z:\adeeti\ecog\images\Iso_Awake_VEPs\GL_early\coher35MoviesOutlines\';
% dropboxLocation = '/Users/adeetiaggarwal/Dropbox/KelzLab/'; %'C:\Users\adeeti\Dropbox\KelzLab\';


addpath(genpath('home/adeeti/Dropbox/ProektLab_code/Adeeti_code/'))
dirIn1 = '/synology/adeeti/ecog/matIsoPropMultiStim/Wavelets/FiltData/'; %'Z:\adeeti\ecog\iso_awake_VEPs\GL_early\';
dirOut = '/synology/adeeti/ecog/images/IsoPropMultiStim//singTr35MoviesOutlines/'; %'Z:\adeeti\ecog\images\Iso_Awake_VEPs\GL_early\coher35MoviesOutlines\';
dropboxLocation = '/home/adeeti/Dropbox/KelzLab/'; %'C:\Users\adeeti\Dropbox\KelzLab\';
identifier = '2018-07-07_16-28-49*';

%trial = 50;
fr = 35;
start = 900; %time before in ms
endTime = 1300; %time after in ms
screensize=get(groot, 'Screensize');
movieOutput = [];
finalSampR = 1000;

darknessOutline = 80; %0 = no outline, 255 is max for black outlines, 80 is good middle ground

stimIndex = [0, Inf]; %if want all, stimIndex = matStimIndex; % if want
%all uniStimIndexes/multiStimIndexes, use [uniStimIndex, multiStimIndex] =
%findUniMutliStimIndex(matStimIndex), [stimIndex, ~] = findUniMutliStimIndex(matStimIndex)

singTrialInd = [5:5:90];


cd(dirIn1)
mkdir(dirOut);
experiment = dir(identifier);

%% to make an average of signal at coherent bands
numExp = 1;
plotIndex = 1;
load(experiment.name, ['filtSig', num2str(fr)], 'info', 'indexSeries', 'uniqueSeries')
bregmaOffsetX = info.bregmaOffsetX;
bregmaOffsetY = info.bregmaOffsetY;
gridIndicies = info.gridIndicies;
% Making sure to only grab  indexes that you are looking
% for in the mix of trials
[indices] = getStimIndices(stimIndex, indexSeries, uniqueSeries);
singleTrials = indices(singTrialInd);
eval(['filtSig = filtSig', num2str(fr), '(:, :,singleTrials);']);

for i = 1:length(singTrialInd)
    disp(['Trial: ', num2str(i)]);
    close all 
    
    sig = permute(filtSig(:,:,i), [3,1,2]);
    
    %average signal at 35 Hz
    %sig = squeeze(mean(sig,3));
    
    %normalize signal to baseline
    m = mean(sig(:,1:1000,:),2);
    s = std(sig(:,1:1000,:),1, 2);
    ztransform=(repmat(m, [1,2001,1])-sig)./repmat(s, [1,2001,1]);
    
    %create labels
    plotTitles{1} = ['Trial: ', num2str(i)];
    superTitle = [info.AnesType, ', Exp: ', num2str(info.exp)];
    colorTitle = ['z threshold voltages from baseline'];
    
    
    [movieOutput] = makeMoviesWithOutlinesFunc(ztransform, start, endTime, bregmaOffsetX, bregmaOffsetY, gridIndicies, plotTitles, superTitle, colorTitle, [], darknessOutline, dropboxLocation);
    
    v = VideoWriter([dirOut, info.expName(1:end-4), 'Tr', num2str(i), '.avi']);
    open(v)
    if sum(size(movieOutput(1).cdata) == size(movieOutput(2).cdata)) ==3
        writeVideo(v,movieOutput(2:end))
    else
        writeVideo(v,movieOutput)
    end
    close(v)
    close all
end
