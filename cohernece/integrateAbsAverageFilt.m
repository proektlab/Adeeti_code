%% Making movie heat plot of ITPC MutliStim Data

% 8/13/18 Editted for multistim  and multiple anesthetics experiments
% 1/15/19 Editted for larger fonts and new dropbox location
%% Make movie of mean signal at 30-40 Hz for all experiments
clc
clear
close all

dirIn1 = '/data/adeeti/ecog/matIsoPropMultiStim/';
dirIn2 = '/data/adeeti/ecog/matIsoPropMultiStim/Wavelets/FiltData/';
dirOut = '/data/adeeti/ecog/images/IsoPropMultiStim/coher35MoviesOutlines/';
dropboxLocation = '/home/adeeti/Dropbox/KelzLab/';
identifier = '2018*.mat';

COMPARE_ANES =1;

COMPARE_CONC =1;

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

lowConc = [0.6, 20, 25]; %use these if want to split between low and high concentrations
highConc = [1.2, 35];

allConc = {lowConc; highConc};
conStrings = {'Low Dose'; 'High Dose'};


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

cd(dirIn1)
load('dataMatrixFlashes.mat')

cd(dirIn2)
mkdir(dirOut);
allData = dir(identifier);

%% finding experiments with the same characteristics

clear compCon compAnes

expLabel =unique(vertcat(dataMatrixFlashes(:).exp));

for i=1:size(dataMatrixFlashes,2)
    allDrugs{i}=dataMatrixFlashes(i).AnesType;
end
allDrugs = unique(lower(allDrugs));

if  exist('allConc')  && ~isempty(allConc)
    allConc = allConc;
else
    allConc = unique(vertcat(dataMatrixFlashes(:).AnesLevel));
end

if  exist('stimIndex')  && ~isempty(stimIndex)
    allStims = stimIndex;
else
    allStims = unique(vertcat(dataMatrixFlashes(:).stimIndex), 'rows');
end

for exp = 1:length(expLabel)
    for st = 1:size(allStims, 1)
        if COMPARE_ANES ==1
            for c= 1:size(allConc,1)
                myExp = findMyExpMulti(dataMatrixFlashes, expLabel(exp), [], allConc{c}, allStims(st,:));
                for t = 1:length(myExp)
                    temp = dataMatrixFlashes(myExp(t)).expName;
                    compAnes{exp, st, c, t} = [temp(length(temp)-22:end-4), 'wave.mat'];
                end
            end
        end
    end
end



%[myFavoriteExp] = findMyExpMulti(dataMatrixFlashes, exp, drugType, conc, stimIndex)

%% Making movies with Coherent bands
% to make an average of signal at coherent bands

for exp = 1%:length(expLabel)
    for st = 1:size(allStims, 1)
        [stimIndexSeriesString] = stimIndex2string4saving(allStims(st,:), finalSampR);
        
        if COMPARE_ANES ==1
            for c = 1%:size(allConc,1)
                close all;
                clear filtSig sig absSig intSig
                disp(['Exp: ', num2str(expLabel(exp)), ' stim: ', num2str(allStims(st,:)), ' conc: ', num2str(allConc{c})]);
                plotIndex = 0;
                numExp = size(compAnes, 4);
                
                for anes = 1:numExp
                    if ~exist(compAnes{exp, st, c, anes})
                        continue
                    end
                    
                    plotIndex = plotIndex+1;
                    load(compAnes{exp, st, c, anes}, ['filtSig', num2str(fr)], 'info', 'uniqueSeries', 'indexSeries')
                    
                    bregmaOffsetX = info.bregmaOffsetX;
                    bregmaOffsetY = info.bregmaOffsetY;
                    gridIndicies = info.gridIndicies;
                    
                    % Making sure to only grab  indexes that you are looking
                    % for in the mix of trials
                    [indices] = getStimIndices(allStims(st,:), indexSeries, uniqueSeries);
                    eval(['sig = filtSig', num2str(fr), '(:, :,indices);']);
                    
                    %average signal at 35 Hz
                    sig = squeeze(mean(sig,3));
                    
                    %normalize signal to baseline
                    m = mean(sig(1:1000,:),1);
                    s = std(sig(1:1000,:),1);
                    ztransform=(m-sig)./s;
                    filtSig(anes,:,:) = ztransform;
                    absSig = abs(ztransform);
                    intSig(anes,:) = nansum(absSig(100:1350,:),1);
                    
                    %create labels
                    plotTitles{anes} = [info.AnesType, ', dose: ', num2str(info.AnesLevel)];
                    if isfield(info, 'polarity')
                        plotTitles{anes} = [info.AnesType, ', dose: ', num2str(info.AnesLevel), ', polarity: ', info.polarity];
                    end
                end
                intSig = permute(intSig, [1 3 2]);
                
                superTitle = ['Comparing Anesthetics ', conStrings{c}, ', Exp: ', num2str(expLabel(exp))];
                colorTitle = ['z threshold voltages from baseline'];
                
                [movieOutput] = makeMoviesWithOutlinesFunc(intSig, 1, 1, bregmaOffsetX, bregmaOffsetY, gridIndicies, plotTitles, superTitle, colorTitle, [], darknessOutline, dropboxLocation);
                
                %v = saveas([dropboxLocation, 'IntFilt_Exp', num2str(expLabel(exp)), stimIndexSeriesString, strrep(conStrings{c}, ' ', '_') '.pdf']);
                %open(v)
                %writeVideo(v,movieOutput)
                %close(v)
                %close all
            end
        end
    end
end



