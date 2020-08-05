%% Making movie heat plot of ITPC Fork Data - ECOG only
% 9/10/18 AA Editted for fork data

%% Make movie of mean signal at 30-40 Hz for all experiments
clc
clear
close all

dirIn1 = '/synology/adeeti/ecog/matGratingTesting/GT2/';
dirIn2 = [dirIn1, 'Wavelets/FiltData/'];
dirOut = '/synology/adeeti/ecog/images/gratingTesting/GT2/coher35MoviesOutlines/';

dropboxLocation = '/home/adeeti/Dropbox/';
identifier = '2019*.mat';

%trial = 50;
fr = 35;
start = 900; %time before in ms
endTime = 2300; %time after in ms
screensize=get(groot, 'Screensize');
movieOutput = [];
finalSampR = 1000;

use_Polarity = 0; %1 if using polarity, 0 if not

darknessOutline = 80; %0 = no outline, 255 is max for black outlines, 80 is good middle ground

%stimIndex = [0, Inf]; %if want all, stimIndex = matStimIndex; % if want
%all uniStimIndexes/multiStimIndexes, use [uniStimIndex, multiStimIndex] =
%findUniMutliStimIndex(matStimIndex), [stimIndex, ~] = findUniMutliStimIndex(matStimIndex)


%% setting up directories and outline parameters

cd(dirIn1)
load('dataMatrixFlashes.mat')

cd(dirIn2)
mkdir(dirOut);
allData = dir(identifier);

%% finding experiments with the same characteristics

clear compForkPos

expLabel =unique(vertcat(dataMatrixFlashes(:).exp));
%
% for i=1:size(dataMatrixFlashes,2)
%     allDrugs{i}=dataMatrixFlashes(i).AnesType;
% end
% allDrugs = unique(lower(allDrugs));
% allConc = unique(vertcat(dataMatrixFlashes(:).AnesLevel));
%
% if  exist('stimIndex')  && ~isempty(stimIndex)
%     allStims = stimIndex;
% else
%     allStims = unique(vertcat(dataMatrixFlashes(:).stimIndex), 'rows');
% end

if  exist('forkPos')  && ~isempty(forkPos)
    allForkPos = forkPos;
else
    for i = 1:size(dataMatrixFlashes,2)
        forkPos(i,:)=dataMatrixFlashes(i).forkPosition(1,:);
    end
    allForkPos = unique(forkPos, 'rows');
end

for exp = 1:length(expLabel)
    for f = 1:size(allForkPos, 1)
        myExp = findMyExpMulti(dataMatrixFlashes, expLabel(exp), [],[], [], allForkPos(f,:));
        for t = 1:length(myExp)
            temp = dataMatrixFlashes(myExp(t)).expName;
            compForkPos{exp, f, t} = [temp(47:end-4), 'wave.mat'];
        end
    end
end



%[myFavoriteExp] = findMyExpMulti(dataMatrixFlashes, exp, drugType, conc, stimIndex)

%% Making movies with Coherent bands
% to make an average of signal at coherent bands

for exp = 1:length(expLabel)
    for f = 1:length(allForkPos)
        
        close all;
        clear filtSig sig
        disp(['Exp: ', num2str(expLabel(exp)), ' position: ', num2str(allForkPos(f,:))]);
        plotIndex = 0;
        numExp = size(compForkPos, 5);
        
        if ~exist(compForkPos{exp, f, t})
            continue
        end
        
        plotIndex = plotIndex+1;
        load(compForkPos{exp, st, a, dose, f}, ['filtSig', num2str(fr)], 'info', 'uniqueSeries', 'indexSeries')
        
        bregmaOffsetX = info.bregmaOffsetX;
        bregmaOffsetY = info.bregmaOffsetY;
        gridIndicies = info.gridIndicies;
        
        % Making sure to only grab  indexes that you are looking
        % for in the mix of trials
        [indices] = getStimIndices(allStims(st,:), indexSeries, uniqueSeries);
        eval(['sig = filtSig', num2str(fr), '(:, info.ecogChannels,indices);']);
        
        %average signal at 35 Hz
        sig = squeeze(mean(sig,3));
        
        %normalize signal to baseline
        m = mean(sig(1:1000,:),1);
        s = std(sig(1:1000,:),1);
        ztransform=(m-sig)./s;
        filtSig(f,:,:) = ztransform;
        
        %create labels
        plotTitles{f} = [info.AnesType, ', dose: ', num2str(info.AnesLevel), ' Position ', num2str(info.forkPosition(1,:))];
        if isfield(info, 'polarity')
            plotTitles{dose} = [info.AnesType, ', dose: ', num2str(info.AnesLevel), ', polarity: ', info.polarity];
        end
    end
    superTitle = ['Comparing Concentrations ', allDrugs{a}, ', Exp: ', num2str(expLabel(exp)), ', Stim: ', strrep(stimIndexSeriesString, '_', '\_')];
    colorTitle = ['z threshold voltages from baseline'];
    
    [movieOutput] = makeMoviesWithOutlinesFunc(filtSig, start, endTime, bregmaOffsetX, bregmaOffsetY, gridIndicies, plotTitles, superTitle, colorTitle, darknessOutline, dropboxLocation);
    
    v = VideoWriter([dirOut, 'Exp', num2str(expLabel(exp)), 'Pos', num2str(f), '.avi']);
    open(v)
    writeVideo(v,movieOutput)
    close(v)
    close all
end








