%% Makes movies of EEG stuffs

% 01/15/19 AA utilizes makeMoviesWithOutlinesFun.m function 
%%
clear
clc
close all

onAlexsWorkStation = 2;
if onAlexsWorkStation ==1
    dirIn = '/data/adeeti/ecog/matIsoPropMultiStim/';
    dirOut1 = '/data/adeeti/ecog/images/IsoPropMultiStim/bigFontMovies/';
    outlineLocation = '/home/adeeti/Dropbox/KelzLab/';
    %dirOut2 = '/data/adeeti/ecog/images/2018Stim/averageMovies/';
    cd(dirIn)
    load('dataMatrixFlashes.mat')
    load('matStimIndex.mat')
elseif onAlexsWorkStation ==0
    % Adeeti's Desktop
    dirIn = '/Users/adeeti/Desktop/data/VIS_Only_Iso_prop_2018/baseline/';
    dirOut1 = '/Users/adeeti/Google Drive/TNI/IsoPropCompV1Paper/';
    cd(dirIn)
    load('dataMatrixFlashesVIS_ONLY.mat')
    outlineLocation = '/Users/adeeti/Dropbox/KelzLab/';
    dataMatrixFlashes = dataMatrixFlashesVIS_ONLY;
elseif onAlexsWorkStation ==2
    % Adeeti's Desktop
    dirIn = '/Users/adeetiaggarwal/Google Drive/data/VIS_Only_Iso_prop_2018/flashTrials/';
    dirOut1 = '/Users/adeetiaggarwal/Google Drive/';
    cd(dirIn)
    load('dataMatrixFlashesVIS_ONLY.mat')
    outlineLocation = '/Users/adeetiaggarwal/Dropbox/KelzLab/';
    dataMatrixFlashes = dataMatrixFlashesVIS_ONLY;
end

% lowestLatVariable = 'lowLat';
% stimIndex = [0, Inf]; %if want all, stimIndex = matStimIndex; % if want
% %all uniStimIndexes/multiStimIndexes, use [uniStimIndex, multiStimIndex] =
% %findUniMutliStimIndex(matStimIndex), [stimIndex, ~] = findUniMutliStimIndex(matStimIndex)
% 
% % Setting up new data set for just visual only stim
% expLabel =unique(vertcat(dataMatrixFlashes(:).exp));
% allExp = {};
% if exist('stimIndex')  && ~isempty(stimIndex)
%     for i = 1:length(expLabel)
%         for j = 1:size(stimIndex,1)
%             [MFE] = findMyExpMulti(dataMatrixFlashes, expLabel(i), [], [], stimIndex(j,:));
%             allExp{i}(:) = MFE;
%         end
%     end
% else
%     [MFE] = 1:length(dataMatrixFlashes);
% end
% 
% numSubjects = size(allExp,2);
% maxExposuresPerSubject = max(cellfun(@length, allExp));
% fs = 1000;

%%
expNum = 1;
conc = 0.6;
stimIndex = [0 Inf];

[myFavoriteExp] = findMyExp(dataMatrixFlashes, expNum, conc, [], []);

makeSingleTrailsMoivies = 0;
makeAverageMovies = 0;
makeCoherenceMovie =1;

trial = 15;
start = 900; %time before in ms
cutTime = 1300; %time after in ms

darknessOutline = 80; %in 1 to 255, 1 being lightest, 255 being darkest


%% making movies

if length(myFavoriteExp) >3
    myFavoriteExp(1) = [];
end

for e = 1%:length(myFavoriteExp)
    close all;
    clear data
    plotIndex = 1;
    
    load(dataMatrixFlashes(myFavoriteExp(e)).expName, 'info', 'indexSeries', 'uniqueSeries', 'meanSubData', 'finalSampR')
    [indices] = getStimIndices(stimIndex, indexSeries, uniqueSeries);
    useMeanSubData = meanSubData(:, indices,:);
    if makeSingleTrailsMoivies ==1
        data = useMeanSubData(:,trial,:);
        data = permute(data, [2 3 1]); % data has to be in number of data plots x time x channel
    end
    if makeAverageMovies ==1
        data = nanmean(useMeanSubData,2);
        data = permute(data, [2 3 1]); % data has to be in number of data plots x time x channel
    end
    if makeCoherenceMovie ==1
        filtbound = [30 40]; % Hz
        trans_width = 0.2; % fraction of 1, thus 20%
        filt_order = 50; %filt_order = round(3*(EEG.srate/filtbound(1)));
        
        [filterweights] = buildBandPassFiltFunc_AA(finalSampR, filtbound, trans_width, filt_order);
        
        filtered_data = zeros(size(useMeanSubData));
        for ch=1:size(useMeanSubData, 1)
            for tr = 1:size(useMeanSubData,2)
                filtered_data(ch,tr,:) = filtfilt(filterweights,1,squeeze(double(useMeanSubData(ch,tr,:))));
            end
        end
        filtered_data = permute(filtered_data(:,:,1:2001), [3 1 2]);
        data = filtered_data;
    end
    
    bregmaOffsetX = info.bregmaOffsetX;
    bregmaOffsetY = info.bregmaOffsetY;
    gridIndicies = info.gridIndicies;
    
    % Making sure to only grab  indexes that you are looking
    % for in the mix of trials
    
    %create labels
    superTitle = [];%[num2str(info.AnesLevel), '% Isoflurane '];
    plotTitles = [];
    colorTitle = ['Voltage in \muV'];
    
    if makeSingleTrailsMoivies ==1
         [movieOutput] = makeMoviesWithOutlinesFunc(data, start, cutTime, bregmaOffsetX, bregmaOffsetY, gridIndicies, plotTitles, superTitle, colorTitle, [], darknessOutline, outlineLocation);
        v = VideoWriter([dirOut1, dataMatrixFlashes(myFavoriteExp(e)).date, 'iso', num2str(info.AnesLevel), 'SingleTrial.avi']);
    end
    if makeAverageMovies ==1
         [movieOutput] = makeMoviesWithOutlinesFunc(data, start, cutTime, bregmaOffsetX, bregmaOffsetY, gridIndicies, plotTitles, superTitle, colorTitle, [], darknessOutline, outlineLocation);
        v = VideoWriter([dirOut1, dataMatrixFlashes(myFavoriteExp(e)).date, 'iso', num2str(info.AnesLevel), 'averageEP.avi']);
    end
    if makeCoherenceMovie ==1
        [movieOutput, filtSigFr] = singleMovieCoherenceFromWAVE(info, data, outlineLocation, start, cutTime);
        v = VideoWriter([dirOut1, dataMatrixFlashes(myFavoriteExp(e)).date, 'iso', num2str(info.AnesLevel), 'gammaCohEP.avi']);
    end
    open(v)
    writeVideo(v,movieOutput)
    close(v)
    close all
end


