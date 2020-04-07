%% finding max ITPC for each exeperiment

% clear
% close all
% 
% dirIn = '/synology/adeeti/ecog/iso_awake_VEPs/GL7/';
% dirPicITPC = '/synology/adeeti/ecog/images/Iso_Awake_VEPs/GL7/V1_ITPC/';
% 
% useStimIndex = 0;
% useNumStim = 1;
% 
% lowestLatVariable = 'lowLat';
% stimIndex = [0, Inf];%, Inf, Inf];
% %stimIndex = [0, Inf]; %if want all, stimIndex = matStimIndex; % if want
% %all uniStimIndexes/multiStimIndexes, use [uniStimIndex, multiStimIndex] =
% %findUniMutliStimIndex(matStimIndex), [stimIndex, ~] = findUniMutliStimIndex(matStimIndex)
% 
% numStim = 1;

freqBound = [1, 120];
useTime = [950:1300];
use_p_value = 1;

%%
cd(dirIn)
load('dataMatrixFlashes.mat')
%load('matStimIndex.mat')

%% Setting up parameters

allExp = {};
if useStimIndex ==1
    if exist('stimIndex')  && ~isempty(stimIndex)
        for i = 1:size(stimIndex,1)
            [MFE] = findMyExpMulti(dataMatrixFlashes, [], [], [], stimIndex(i,:));
            allExp{i} = MFE;
        end
    end
elseif useNumStim ==1
    if exist('numStim')  && ~isempty(numStim)
        for i = 1:size(stimIndex,1)
            [MFE] = findMyExpMulti(dataMatrixFlashes, [], [], [], [], numStim);
            allExp{i} = MFE;
        end
    end
else
    [MFE] = 1:length(dataMatrixFlashes);
    allExp{i} = MFE;
end

mkdir(dirPicITPC);
%%
ITPCCatchTrials = [];

for a = 1:length(allExp)
    for b = 1:length(allExp{a})
        experiment = allExp{a}(b);
        load(dataMatrixFlashes(experiment).expName(end-22:end-4), 'info', 'meanSubData', 'uniqueSeries', 'indexSeries', 'meanSubFullTrace')
        if ~isfield(info, lowestLatVariable)
            disp(['No variable info.' lowestLatVariable, ' . Trying next experiment.']);
            ITPCCatchTrials = [ITPCCatchTrials; info.expName];
            continue
        end
        
        [indices] = getStimIndices(stimIndex, indexSeries, uniqueSeries);
        useMeanSubData = meanSubData(:, indices,:);
        useSmallSnippits = useMeanSubData;
        
        totTrialsPerExp = size(useMeanSubData, 2);
        trialsPerSamp = totTrialsPerExp;
        totSamp = 1000;
        
        channels = info.lowLat;
        
        %% Run wavelet on real data, ITPC
        WAVE=zeros(43, size(useSmallSnippits,3), 1, size(useSmallSnippits,2));
        for i= info.lowLat %i=1:size(WAVE,3)
            disp(i);
            for j = 1:size(useSmallSnippits,2)
                sig=detrend(squeeze(useSmallSnippits(i, j,:)));
                % [temp,PERIOD,SCALE,COI,DJ, PARAMOUT, K] = contwt(sig,1/1000,1, 0.1);
                [temp,PERIOD,SCALE,COI,DJ, PARAMOUT, K] = contwt(sig,1/1000,1, 0.25);
                WAVE(:,:,1, j)=temp; %WAVE is in freq by time by channels by trials
                Freq=1./PERIOD;
            end
        end
        trueITPC = ITPC_AA(WAVE);
        
        freqInd = find(Freq>freqBound(1) & Freq<freqBound(2));
        useFreq = Freq(freqInd);
        
        %% plotting and shit
        % plot results
        ff = figure('Position',[1347,-12,792,1333]);
        % ff.Renderer='Painters';
        clf
        
        
        h1= subplot(3,1,1);
        plot(useTime,squeeze(mean(useSmallSnippits(channels,:,useTime),2)));
        colorbar
        title('Average trace')
        
        
        h2 = subplot(3, 1, [2, 3]);
        pcolor(useTime, useFreq, squeeze(trueITPC(1,freqInd,useTime))); shading 'flat';
        %set(gca, 'yscale', 'log')
        set(gca, 'YTick', [1, 10, 20, 30, 40, 50, 60, 70, 80, 90, 100])
        colorbar
        title('True ITPC')
       
        suptitle(['ITPC for V1 of ', strrep(info.expName(1:end-4), '_', '\_'), ' drug: ', info.AnesType, ' conc: ' num2str(info.AnesLevel)])
        %suptitle(['ITPC for channel ', num2str(channels)])
        
        linkaxes([h1 h2], 'x')
 
        saveas(ff, [dirPicITPC, info.expName(end-22:end-4), 'ITPC_V1z', '.png'])
        close all
    end
end






