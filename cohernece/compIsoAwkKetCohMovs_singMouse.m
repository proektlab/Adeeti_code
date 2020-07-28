%% Making movie heat plot of ITPC MutliStim Data

% 8/13/18 Editted for multistim  and multiple anesthetics experiments
% 1/15/19 Editted for larger fonts and new dropbox location
%% Make movie of mean signal at 30-40 Hz for all experiments

% if isunix
%     genDir = '/synology/adeeti/ecog/iso_awake_VEPs/';
%     picsDir =  '/synology/adeeti/ecog/images/Iso_Awake_VEPs/';
%     dropboxLocation = '/home/adeeti/Dropbox/ProektLab_code/Adeeti_code/'; %'C:\Users\adeeti\Dropbox\KelzLab\';
% elseif ispc
%     genDir = 'Z:\adeeti\ecog\iso_awake_VEPs\';
%     picsDir =  'Z:\adeeti\ecog\images\Iso_Awake_VEPs\';
%     dropboxLocation = 'C:\Users\adeeti\Dropbox\ProektLab_code\Adeeti_code\';
% end
% 
% cd(genDir)

stimIndex = [0, Inf];
START_AT = 1;
finalSampR = 1000;
use_Polarity = 0; %1 if using polarity, 0 if not
darknessOutline = 80; %0 = no outline, 255 is max for black outlines, 80 is good middle ground
%fr = [5, 35];
start = 900; %time before in ms
endTime = 1300; %time after in ms
screensize=get(groot, 'Screensize');

%% Finding correct experiments
cd(dirIn)
load('dataMatrixFlashes.mat')
compExp=[];

[isoHighExp, isoLowExp, emergExp, awaExp1, awaLastExp, ketExp] = ...
    findAnesArchatypeExp(dataMatrixFlashes);

compExp = [isoHighExp, isoLowExp, emergExp, awaLastExp, ketExp]

%% setting up directories
cd(dirFILT)
allData = dir(identifier);
movieOutput = [];

%% Making movies with Coherent bands
% to make an average of signal at coherent bands

for f = 1:length(fr)
    useFreq = fr(f);
    clear filtSig
    plotIndex = 0;
    for expID = 1:length(compExp)
        if isnan(compExp(expID))
            continue
        end
        
        close all;
        clear sig
        disp(['Exp: ', num2str(compExp(expID))]);
        
        numExp = sum(~isnan(compExp));
        
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
        filtSig(plotIndex,:,:) = ztransform;
        
        %create labels
        plotTitles{plotIndex} = [info.AnesType, ', dose: ', num2str(info.AnesLevel)];
        if isfield(info, 'polarity')
            plotTitles{plotIndex} = [info.AnesType, ', dose: ', num2str(info.AnesLevel), ', polarity: ', info.polarity];
        end
    end
    
    if iscell(mouseID)
        superTitle = ['Comparing conditions, ' num2str(useFreq), 'Hz, Exp: ', cell2mat(mouseID)];
    else
        superTitle = ['Comparing conditions, ' num2str(useFreq), 'Hz, Exp: ', mouseID];
    end
    
    colorTitle = ['z threshold voltages from baseline'];
    
    [movieOutput] = makeMoviesWithOutlinesFunc(filtSig, start, endTime, bregmaOffsetX, bregmaOffsetY, gridIndicies, plotTitles, superTitle, colorTitle, [], darknessOutline, dropboxLocation);
    
    if iscell(mouseID)
        v = VideoWriter([genPicsDir, cell2mat(mouseID), num2str(useFreq), 'compCond.avi']);
    else
        v = VideoWriter([genPicsDir, mouseID, num2str(useFreq), 'compCond.avi']);
    end
    
    open(v)
    writeVideo(v,movieOutput)
    close(v)
    close all
end

