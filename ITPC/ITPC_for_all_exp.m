%% ITPC for channels around V1 for all exp
% 8/9/18 AA editted for multistim delivery

% clear
% close all
% 
% dirIn = '/synology/adeeti/ecog/matGratingTesting/GT4/';
% dirPicITPC = '/synology/adeeti/ecog/images/gratingTesting/GT4/localITPC/';
% 
% useStimIndex = 0;
% useNumStim = 1;
% 
% lowestLatVariable = 'lowLat';
% stimIndex = [0, Inf, Inf, Inf];
% %stimIndex = [0, Inf]; %if want all, stimIndex = matStimIndex; % if want
% %all uniStimIndexes/multiStimIndexes, use [uniStimIndex, multiStimIndex] =
% %findUniMutliStimIndex(matStimIndex), [stimIndex, ~] = findUniMutliStimIndex(matStimIndex)
% 
% numStim = 1;

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
end

mkdir(dirPicITPC);
screensize=get(groot, 'Screensize');

%%

ITPCCatchTrials = [];

for a = 1:length(allExp)
    for b = 1:length(allExp{a})
        experiment = allExp{a}(b);
        load(dataMatrixFlashes(experiment).expName, 'info', 'meanSubData', 'uniqueSeries', 'indexSeries', 'meanSubFullTrace')
        if ~isfield(info, lowestLatVariable)
            disp(['No variable info.' lowestLatVariable, ' . Trying next experiment.']);
            ITPCCatchTrials = [ITPCCatchTrials; info.expName];
            continue
        end
        
        [indices] = getStimIndices(stimIndex, indexSeries, uniqueSeries);
        useMeanSubData = meanSubData(info.ecogChannels, indices,:);
        
        smallSnippitSize = 2001;
        
        useSmallSnippits = meanSubData(info.ecogChannels, indices,1:smallSnippitSize);
        
        %% finding V1 for each experiment based on mode
        [adjVector] = findAdjacentChan(info);
        eval(['lowLat = info.', lowestLatVariable, ';'])
        
        %% Parameters for Stats
        totTrialsPerExp = size(useMeanSubData, 2);
        trialsPerSamp = totTrialsPerExp;
        totSamp = 100;
        
        %% Making fake data flashes onsets (rand time of starts)
        [fakeSnippits] = makeFakeSnippitsFullTrace(meanSubFullTrace(info.ecogChannels,:), info, length(indices), smallSnippitSize);
        
        %% Run wavelet on fake data
        disp('Wavelet on Fake Data')
        fakeWAVE=zeros(40, 2001, size(fakeSnippits,1), size(fakeSnippits,2));
        for i=1:size(fakeWAVE,3)
            disp(i);
            for j = 1:size(fakeSnippits,2)
                sig=detrend(squeeze(fakeSnippits(i, j,:)));
                % [temp,PERIOD,SCALE,COI,DJ, PARAMOUT, K] = contwt(sig,1/1000,1, 0.1);
                [temp,PERIOD,SCALE,COI,DJ, PARAMOUT, K] = contwt(sig,1/1000,1, 0.25);
                fakeWAVE(:,:,i, j)=temp; %WAVE is in freq by time by channels by trials
                Freq=1./PERIOD;
            end
        end
        
        %% Run wavelet on real data
        disp('Wavelet on Real Data')
        WAVE=zeros(40, 2001, size(useSmallSnippits,1), size(useSmallSnippits,2));
        for i=1:size(WAVE,3)
            disp(i);
            for j = 1:size(useSmallSnippits,2)
                sig=detrend(squeeze(useSmallSnippits(i, j,:)));
                % [temp,PERIOD,SCALE,COI,DJ, PARAMOUT, K] = contwt(sig,1/1000,1, 0.1);
                [temp,PERIOD,SCALE,COI,DJ, PARAMOUT, K] = contwt(sig,1/1000,1, 0.25);
                WAVE(:,:,i, j)=temp; %WAVE is in freq by time by channels by trials
                Freq=1./PERIOD;
            end
        end
        
        %% For intertrial phase coherence
        
        disp('Running ITPC iterations')
        
        myChannels = adjVector(lowLat,:);
        statsFakeITPC = nan(totSamp, length(myChannels), size(WAVE, 1), size(WAVE, 2));
        statsRealITPC = nan(totSamp, length(myChannels), size(WAVE, 1), size(WAVE, 2));
        
        clear exp
        for i = 1:totSamp
            tic
            trials = randsample(totTrialsPerExp, trialsPerSamp, 'true'); %with replacement
            %     useWAVE = fakeWAVE(:, :, : , trials);
            [ITPCmeasures] = ITPC_AA(fakeWAVE, myChannels, trials);
            statsFakeITPC(i, :, :, :) = ITPCmeasures;
            disp(['Calculating ', num2str(i), ' out of ', num2str(totSamp) ' time taken ' num2str(round(toc*1000)) 'ms'])
        end
        stErrorFakeITPC = squeeze(std(statsFakeITPC, [], 1));
        meanFakeITPC = squeeze(mean(statsFakeITPC, 1));
        
        clear exp
        for i = 1:totSamp
            tic
            trials = randsample(totTrialsPerExp, trialsPerSamp, 'true');
            %     useWAVE = fakeWAVE(:, :, : , trials);
            [ITPCmeasures] = ITPC_AA(WAVE, myChannels, trials);
            statsRealITPC(i, :, :, :) = ITPCmeasures;
            disp(['Calculating ', num2str(i), ' out of ', num2str(totSamp) ' time taken ' num2str(round(toc*1000)) 'ms'])
        end
        trueITPC = ITPC_AA(WAVE);
        stErrorRealITPC = squeeze(std(statsRealITPC, [], 1));
        meanRealITPC = squeeze(mean(statsRealITPC, 1));
        
        %% T test to compare how real data compares with fake data
        % Welch's t test- equal sample size, unequal variances
        tVals = (meanRealITPC- meanFakeITPC)./sqrt((stErrorFakeITPC.^2+stErrorRealITPC.^2));
        pVals = tcdf(tVals,trialsPerSamp-1);
        
        use_p_value = 1; % 1 for p value, 0 for t Value, any other number for true ITPC
        currentFig = figure('Position', [1146 -63 1423 1333]); clf;
        
        for ch = 1:length(myChannels)
            channel = myChannels(ch);
            if isnan(channel)
                continue
            end
            
            % plot results- average trace on top and p values of ITPC on the
            % bottom
            h1= subplot(6,3,floor((ch-1)/3)*6 + mod(ch-1,3) + 1);
            plot(squeeze(nanmean(useSmallSnippits(channel,:,:),2)));
            title(['Average trace channel ', num2str(channel)])
            colorbar
            
            h2= subplot(6, 3, floor((ch-1)/3)*6 + mod(ch-1,3)+4);
            if use_p_value == 1
                pcolor(1:size(useSmallSnippits,3), Freq, log10(squeeze(1-squeeze(pVals(ch,:,:))))); shading 'flat';
                set(gca, 'yscale', 'log')
                colorbar
                title(['P-Value ITPC channel ', num2str(channel)])
                set(gca,'clim',[-8 0])
                set(gca, 'YTick', [1, 10, 30, 50, 100])
            elseif use_p_value == 0
                pcolor(1:size(useSmallSnippits,3), Freq, squeeze(tVals(ch,:,:))); shading 'flat';
                set(gca, 'yscale', 'log')
                colorbar
                set(gca, 'YTick', [1, 10, 30, 50, 100])
                title(['t-Value ITPC channel ', num2str(channel)])
            else
                pcolor(1:size(useSmallSnippits,3), Freq, squeeze(trueITPC(channels,:,:))); shading 'flat';
                set(gca, 'yscale', 'log')
                colorbar
                set(gca, 'YTick', [1, 10, 30, 50, 100])
                title(['True ITPC channel ', num2str(channel)])
            end
            
            linkaxes([h1 h2], 'x')
            set(gca, 'xlim', [0, 2001])
        end
        
        suptitle(['ITPC for channels around V1 of ', strrep(info.expName(1:end-4), '_', '\_'), ' drug: ', info.AnesType, ' conc: ' num2str(info.AnesLevel)])
        
        
        saveas(currentFig, [dirPicITPC, info.expName(1:end-4), 'localITPC.png'])
        close all;
        
    end
end

save([dirIn, 'ITPCCatchTrials.mat'], 'ITPCCatchTrials')
