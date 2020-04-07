%% Making movie heat plot of ITPC Fork Data - ECOG only
% 11/19/2019 AA gratings movie

%% Make movie of mean signal at 30-40 Hz for all experiments
clc
clear
close all

dirIn1 = '/synology/adeeti/ecog/matGratingTesting/GT2/';
dirIn2 = [dirIn1, 'Wavelets/FiltData/'];
dirOut = '/synology/adeeti/ecog/images/gratingTesting/GT2/coher35MoviesOutlines/';

dropboxLocation = '/home/adeeti/Dropbox/KelzLab/';
identifier = '2019*.mat';

%trial = 50;
fr = 35;
start = 900; %time before in ms
endTime = 1500; %time after in ms
screensize=get(groot, 'Screensize');
movieOutput = [];
finalSampR = 1000;

use_Polarity = 0; %1 if using polarity, 0 if not

darknessOutline = 80; %0 = no outline, 255 is max for black outlines, 80 is good middle ground

stimIndexFS = [0, Inf, Inf Inf]; %if want all, stimIndex = matStimIndex; % if want
%all uniStimIndexes/multiStimIndexes, use [uniStimIndex, multiStimIndex] =
%findUniMutliStimIndex(matStimIndex), [stimIndex, ~] = findUniMutliStimIndex(matStimIndex)

typeTrial = {'FS', 'Q'};

%% setting up directories and outline parameters

cd(dirIn1)
load('dataMatrixFlashes.mat')
load('matStimIndex.mat')

cd(dirIn2)
mkdir(dirOut);
allData = dir(identifier);

%% finding experiments with the same characteristics

%[myFavoriteExp] = findMyExpMulti(dataMatrixFlashes, exp, drugType, conc, stimIndex,  numStim, typeTrial, forkPos)

%% Making movies with Coherent bands
% to make an average of signal at coherent bands

for experiment = 7:length(dataMatrixFlashes)
    clear movieOutput
    close all;
    clear filtSig sig
    disp(['Exp: ', num2str(experiment)]);
    plotIndex = 0;
    
    plotIndex = plotIndex+1;
    load([dataMatrixFlashes(experiment).expName(end-22:end-4),'wave.mat'], ['filtSig', num2str(fr)], 'info', 'uniqueSeries', 'indexSeries')
    
    bregmaOffsetX = info.bregmaOffsetX;
    bregmaOffsetY = info.bregmaOffsetY;
    gridIndicies = info.gridIndicies;
    
    % Making sure to only grab  indexes that you are looking
    % for in the mix of trials
    if contains(dataMatrixFlashes(experiment).TypeOfTrial, 'Q')
        for st = 1:size(matStimIndex,1)
            [indices] = getStimIndices(matStimIndex(st,:), indexSeries, uniqueSeries);
            eval(['sig = filtSig', num2str(fr), '(:, info.ecogChannels,indices);']);
            
            %average signal at 35 Hz
            sig = squeeze(mean(sig,3));
            
            %normalize signal to baseline
            m = mean(sig(1:1000,:),1);
            s = std(sig(1:1000,:),1);
            ztransform=(m-sig)./s;
            filtSig(st,:,:) = ztransform;
            
            %create labels
            plotTitles{st} = ['Quadrant: ', num2str(st)];
            if isfield(info, 'polarity')
                plotTitles{dose} = [info.AnesType, ', dose: ', num2str(info.AnesLevel), ', polarity: ', info.polarity];
            end
        end
    elseif contains(dataMatrixFlashes(experiment).TypeOfTrial, 'FS')
        eval(['sig = filtSig', num2str(fr), '(:, info.ecogChannels,:);']);
        %average signal at 35 Hz
        sig = squeeze(mean(sig,3));
        
        %normalize signal to baseline
        m = mean(sig(1:1000,:),1);
        s = std(sig(1:1000,:),1);
        ztransform=(m-sig)./s;
        filtSig(1,:,:) = ztransform;
        
        %create labels
        plotTitles{1} = 'Full Screen Stim';
        if isfield(info, 'polarity')
            plotTitles{dose} = [info.AnesType, ', dose: ', num2str(info.AnesLevel), ', polarity: ', info.polarity];
        end
    end
    
    superTitle = [info.AnesType(1:3), ': ', num2str(info.AnesLevel), '% ', info.TypeOfTrial, ' Exp ', num2str(info.exp)];
    
    colorTitle = ['z threshold voltages from baseline'];
    
    [movieOutput] = makeMoviesWithOutlinesFunc(filtSig, start, endTime, bregmaOffsetX, bregmaOffsetY, gridIndicies, plotTitles, superTitle, colorTitle, [], darknessOutline, dropboxLocation);
    
    
    v = VideoWriter([dirOut, num2str(info.expName(1:end-4)), dataMatrixFlashes(experiment).TypeOfTrial, '.avi']);
    open(v)
    if sum(size(movieOutput(1).cdata) == size(movieOutput(2).cdata)) ==3
       writeVideo(v,movieOutput) 
    else
       writeVideo(v,movieOutput(2:end)) 
    end
    close(v)
    close all
end








