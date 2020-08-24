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

cd(genDir)

allDir = [dir('*GL9')];

ident1 = '2019*';
ident2 = '2020*';

stimIndex = [0, Inf];
START_AT = 1;
finalSampR = 1000;
use_Polarity = 0; %1 if using polarity, 0 if not
darknessOutline = 80; %0 = no outline, 255 is max for black outlines, 80 is good middle ground
stimIndex = [0, Inf]; %if want all, stimIndex = matStimIndex; % if want
%all uniStimIndexes/multiStimIndexes, use [uniStimIndex, multiStimIndex] =
%findUniMutliStimIndex(matStimIndex), [stimIndex, ~] = findUniMutliStimIndex(matStimIndex)
fr = [5, 35];
start = 900; %time before in ms
endTime = 1300; %time after in ms
screensize=get(groot, 'Screensize');

%%
for d = 1:length(allDir)
    disp(allDir(d).name)
    cd([genDir, allDir(d).name])
    mouseID = allDir(d).name;
    genPicsDir =  [picsDir, mouseID, '/'];
    dirIn = [genDir, mouseID, '/'];
    dirFILT = [dirIn, 'FiltData/'];
    cd(dirFILT)
    
    allData = dir(ident1);
    identifier = ident1;
    
    if isempty(allData)
        allData = dir(ident2);
        identifier = ident2;
    end

    %% Finding correct experiments
    cd(dirIn)
    load('dataMatrixFlashes.mat')
    compExp=[];
    
    if contains(mouseID, 'GL')
        expIDNum = str2num(mouseID(3:end))
    elseif contains(mouseID, 'CB')
        expIDNum = str2num(mouseID(3:end))
        expIDNum = -expIDNum;
    elseif contains(mouseID, 'IP')
        expIDNum = 0;
    end
    
    [isoHighExp, isoLowExp, emergExp, awaExp1, awaLastExp, ketExp] = ...
        findAnesArchatypeExp(dataMatrixFlashes, expIDNum);

    MFE = [isoHighExp, isoLowExp, awaLastExp, ketExp];
    
    %% setting up directories
    cd(dirFILT)
    allData = dir(identifier);
    movieOutput = [];
    
    %% Making movies with Coherent bands
    % to make an average of signal at coherent bands
    
    for f = 1:length(fr)
        useFreq = fr(f);
        clear filtSig
        for expID = 1:length(compExp)
            
            close all;
            clear sig
            disp(['Exp: ', num2str(compExp(expID))]);
            plotIndex = 0;
            numExp = length(compExp);
            
            plotIndex = plotIndex+1;
            load(allData(compExp(expID)).name, ['filtSig', num2str(useFreq)], 'info', 'uniqueSeries', 'indexSeries')
            
            bregmaOffsetX = info.bregmaOffsetX;
            bregmaOffsetY = info.bregmaOffsetY;
            gridIndicies = info.gridIndicies;
            
            % Making sure to only grab  indexes that you are looking
            % for in the mix of trials
            [indices] = getStimIndices(stimIndex, indexSeries, uniqueSeries);
            eval(['sig = filtSig', num2str(useFreq), '(:, :,indices);']);
            
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
        

        superTitle = ['Comparing conditions, ' num2str(useFreq), 'Hz, Exp: ', mouseID];

        colorTitle = ['z threshold voltages from baseline'];
        
        [movieOutput] = makeMoviesWithOutlinesFunc(filtSig, start, endTime, bregmaOffsetX, bregmaOffsetY, gridIndicies, plotTitles, superTitle, colorTitle, [], darknessOutline, dropboxLocation);
        
        v = VideoWriter([genPicsDir, mouseID, num2str(useFreq), 'compCond.avi']);
        open(v)
        writeVideo(v,movieOutput)
        close(v)
        close all
    end
end
