%% Making movie heat plot of ITPC MutliStim Data

% 8/13/18 Editted for multistim  and multiple anesthetics experiments
% 1/15/19 Editted for larger fonts and new dropbox location
%% Make movie of mean signal at 30-40 Hz for all experiments
% clc
% clear
% close all
%
% dirIn = '/synology/adeeti/ecog/iso_awake_VEPs/GL7/'; %'Z:\adeeti\ecog\iso_awake_VEPs\GL_early\';
% dirFILT = '/synology/adeeti/ecog/iso_awake_VEPs/GL7/FiltData/'; %'Z:\adeeti\ecog\iso_awake_VEPs\GL_early\Wavelets\FiltData\';
% dirCoh35Movies = '/synology/adeeti/ecog/images/Iso_Awake_VEPs/GL7/coher35MoviesOutlines/'; %'Z:\adeeti\ecog\images\Iso_Awake_VEPs\GL_early\coher35MoviesOutlines\';
% dropboxLocation = '/home/adeeti/Dropbox/KelzLab/'; %'C:\Users\adeeti\Dropbox\KelzLab\';
% identifier = '2019*.mat';


%trial = 50;
%fr = 35;
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



%% setting up directories and outline parameters
% outline = imread([dropboxLocation, 'KelzLab/MouseBrainAreas.png']);
%
% mmInGridX = 2.75;
% mmInGridY = 5;
%
% PIXEL_TO_MM = (2254 - 503)/2;
%
% BREGMA_PIXEL_X = 5520;
% BREGMA_PIXEL_Y = 3147;

cd(dirIn)
load('dataMatrixFlashes.mat')

cd(dirFILT)
mkdir(dirMovies);
allData = dir(identifier);

%% finding experiments with the same characteristics


%% Making movies with Coherent bands
% to make an average of signal at coherent bands

for experiment = START_AT:length(allData) %START_AT:length(allData)
    close all;
    clear filtSig sig
    disp(['Experiment: ', num2str(experiment)]);
    plotIndex = 1;
    
    load(allData(experiment).name, ['filtSig', num2str(fr)], 'info', 'uniqueSeries', 'indexSeries')

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
    filtSig(1,:,:) = ztransform;
    
    %create labels
    plotTitles{1} = [info.AnesType, ', dose: ', num2str(info.AnesLevel)];
    if isfield(info, 'polarity')
        plotTitles{1} = [info.AnesType, ', dose: ', num2str(info.AnesLevel), ', polarity: ', info.polarity];
    end
    
    superTitle = [info.expName(1:end-4)];
    colorTitle = ['z threshold voltages from baseline'];
    
   % [movieOutput] = makeMoviesWithOutlinesFunc(filtSig, start, endTime, bregmaOffsetX, bregmaOffsetY, gridIndicies, plotTitles, superTitle, colorTitle, [], darknessOutline, dropboxLocation, interpBy, noiseBlack);
    [movieOutput] = gridMovie_Outln_intrp_noiseBlk(filtSig, info, start, endTime, plotTitles, superTitle, colorTitle, [], darknessOutline, dropboxLocation);
    
    v = VideoWriter([dirMovies,info.AnesType(1:3),info.expName(1:end-4) '.avi']);
    open(v)
    if sum(size(movieOutput(1).cdata) == size(movieOutput(2).cdata)) ==3
        writeVideo(v,movieOutput)
    else
        writeVideo(v,movieOutput(2:end))
    end
    close(v)
    close all
end



