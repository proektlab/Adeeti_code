%% Comparing ITPC for propofol vs iso for committee meeting figure 
% 09/26/18 AA

clc
clear
close all

dirIn = '/data/adeeti/ecog/matIsoPropMultiStim/';
%dirDropbox = '/data/adeeti/Dropbox/';

cd(dirIn)
load('dataMatrixFlashes.mat')
load('matStimIndex.mat')

lowestLatVariable = 'lowLat';

USE_SINGLE_EXP = 0; %1 if want to specifically write in experiments, 0 if want to loop through
experiment = [];

%expID = 5;

stimIndex = [0, Inf]; %if want all, stimIndex = matStimIndex; % if want
%all uniStimIndexes/multiStimIndexes, use [uniStimIndex, multiStimIndex] =
%findUniMutliStimIndex(matStimIndex), [stimIndex, ~] = findUniMutliStimIndex(matStimIndex)

%drug = 'prop';

%channels = 31; % channels = [];
%% Setting up parameters

allExp = nan(6, 6);
if exist('stimIndex')  && ~isempty(stimIndex)
    for i = 1:size(stimIndex,1)
        for mouseID = 1:6
        [MFE] = findMyExpMulti(dataMatrixFlashes, mouseID, [], [], stimIndex(i,:));
        allExp(mouseID,:) = MFE;
        end
    end
else
    [MFE] = 1:length(dataMatrixFlashes);
end

%% parameters for bootstrapping

trueITPC = nan(length(allExp), 40, 2001);
aveTrace = nan(length(allExp), 2001);
%drug = nan(length(allExp), 1);
conc = nan(length(allExp), 1);

for experiment = 1:length(allExp)
    load(dataMatrixFlashes(allExp(experiment)).expName, 'info', 'uniqueSeries', 'indexSeries', 'meanSubData', 'smallSnippits')
    
    [indices] = getStimIndices(stimIndex, indexSeries, uniqueSeries);
    useMeanSubData = meanSubData(:, indices,:);
    useSmallSnippits = smallSnippits(:, indices,:);
    
    totTrialsPerExp = size(useMeanSubData, 2);
    trialsPerSamp = totTrialsPerExp;
    totSamp = 1000;
    
    if isempty(channels)
    channels = info.lowLat;
    end
    
%     %% Making fake data flashes onsets (rand time of starts)
%     
%     [fakeSnippits] = makeFakeSnippits(useMeanSubData, useSmallSnippits);
%     
%     %% Run wavelet on fake data
%     fakeWAVE=zeros(40, 2001, size(fakeSnippits,1), size(fakeSnippits,2));
%     for i=channels
%         disp(i);
%         for j = 1:size(fakeSnippits,2)
%             sig=detrend(squeeze(fakeSnippits(i, j,:)));
%             % [temp,PERIOD,SCALE,COI,DJ, PARAMOUT, K] = contwt(sig,1/1000,1, 0.1);
%             [temp,PERIOD,SCALE,COI,DJ, PARAMOUT, K] = contwt(sig,1/1000,1, 0.25);
%             fakeWAVE(:,:,i, j)=temp; %WAVE is in freq by time by channels by trials
%             Freq=1./PERIOD;
%         end
%     end
%     
    %% Run wavelet on real data
    WAVE=zeros(40, 2001, size(useSmallSnippits,1), size(useSmallSnippits,2));
    for i=channels
        disp(i);
        for j = 1:size(useSmallSnippits,2)
            sig=detrend(squeeze(useSmallSnippits(i, j,:)));
            % [temp,PERIOD,SCALE,COI,DJ, PARAMOUT, K] = contwt(sig,1/1000,1, 0.1);
            [temp,PERIOD,SCALE,COI,DJ, PARAMOUT, K] = contwt(sig,1/1000,1, 0.25);
            WAVE(:,:,i, j)=temp; %WAVE is in freq by time by channels by trials
            Freq=1./PERIOD;
        end
    end
    
%     %% Run ITPC on fake data
%     clear exp
%     
%     statsFakeITPC = nan(totSamp, length(channels), size(WAVE, 1), size(WAVE, 2));
%     
%     for i = 1:totSamp
%         trials = randsample(totTrialsPerExp, trialsPerSamp, 'true');
%         %     useWAVE = fakeWAVE(:, :, : , trials);
%         [ITPCmeasures] = ITPC_AA(fakeWAVE, channels, trials);
%         statsFakeITPC(i, :, :, :) = ITPCmeasures;
%         disp(['Calculating ', num2str(i), ' out of ', num2str(totSamp)])
%     end
%     
%     % fakeITPC = ITPC_AA(fakeWAVE);
%     
%     stErrorFakeITPC = squeeze(std(statsFakeITPC, [], 1));
%     meanFakeITPC = squeeze(mean(statsFakeITPC, 1));
%     
%     %% Run ITPC on real data
%     clear exp
%     
%     statsRealITPC = nan(totSamp, length(channels), size(WAVE, 1), size(WAVE, 2));
%     
%     for i = 1:totSamp
%         trials = randsample(totTrialsPerExp, trialsPerSamp, 'true');
%         %     useWAVE = fakeWAVE(:, :, : , trials);
%         [ITPCmeasures] = ITPC_AA(WAVE, channels, trials);
%         statsRealITPC(i, :, :, :) = ITPCmeasures;
%         disp(['Calculating ', num2str(i), ' out of ', num2str(totSamp)])
%     end
%     
    trueITPC(experiment,:,:) = ITPC_AA(WAVE, channels, []);
    aveTrace(experiment,:) = squeeze(mean(useSmallSnippits(channels,:,:),2));
    drug{experiment} = info.AnesType;
    conc(experiment) = info.AnesLevel;
    
end

%     
%     stErrorRealITPC = squeeze(std(statsRealITPC, [], 1));
%     meanRealITPC = squeeze(mean(statsRealITPC, 1));
%     
    %ztrueITPC = (squeeze(trueITPC(15,:,:)) - meanFakeITPC) ./ stErrorFakeITPC; %zcores for the real data
    
    %% T test to compare how real data compares with fake data
    % Welch's t test- equal sample size, unequal variances
%     
%     tVals = (meanRealITPC- meanFakeITPC)./sqrt((stErrorFakeITPC.^2+stErrorRealITPC.^2));
%     pVals = tcdf(tVals,trialsPerSamp-1);
    
    %% plotting and shit
    % plot results
    screensize=get(groot, 'Screensize');
    ff = figure('Position', screensize, 'color', 'w'); clf;
    ff.Renderer='Painters';
    % ff.Renderer='Painters';
    clf
    %use_p_value = 1;
    %plotIndex = 1;
    
    for experiment = 1:length(allExp)
        
            h1= subplot(2,length(allExp),experiment)
            plot(squeeze(aveTrace(experiment,:)));
            set(gca, 'ylim', [min(aveTrace(:)), max(aveTrace(:))])
            set(gca, 'xlim', [0, 2001])
            colorbar
            if conc(experiment)<3
            title({[drug{experiment}, ', dose ', num2str(conc(experiment)), '%']; 'Average Trace'})
            else 
            title({[drug{experiment}, ', dose ', num2str(conc(experiment)), '\mug/g']; 'Average Trace'})
            end
            axis off
           if experiment == 6
               hold on 
               line([200 200], [200 300], 'LineWidth', 2, 'Color', 'k');
               line([200 700], [200 200], 'LineWidth', 2, 'Color', 'k');
    
                tt=text(70, 250, '100 \muV', 'FontName', 'Arial', 'FontSize', 12)
                tt2=text(220, 150, '500 ms', 'FontName', 'Arial', 'FontSize', 12)
           end
            %xlabel('Time (ms)')
            %ylabel('Voltage (\muV)')
         

            h2 = subplot(2, length(allExp), experiment+6)
            pcolor(1:size(aveTrace,2), Freq, squeeze(trueITPC(experiment,:,:))); shading 'flat';
            set(gca, 'yscale', 'log')
            set(gca, 'xlim', [0, 2001])
            set(gca,'clim',[0, max(trueITPC(:))])
            colorbar
            title('ITPC')
            xlabel('Time (ms)')
            ylabel('Freq (Hz)')
        
        %     h3=  subplot(3, 1, 3)
        %     if use_p_value == 1;
        %         pcolor(1:size(useSmallSnippits,3), Freq, log10(squeeze(1-pVals))); shading 'flat';
        %         set(gca, 'yscale', 'log')
        %         colorbar
        %         title('P-Value ITPC')
        %         set(gca,'clim',[-8 0])
        %     else
        %         pcolor(1:size(useSmallSnippits,3), Freq, squeeze(tVals)); shading 'flat';
        %         set(gca, 'yscale', 'log')
        %         colorbar
        %         title('t-Value ITPC')
        %     end
        %     suptitle(['ITPC for channel ', num2str(channels)])
        %
        
        set(gca, 'xlim', [0, 2001])
        linkaxes
        
        
    end

    suptitle('Comparing Isoflurane and Propofol Intertrial Phase Coherence')
    %saveas(ff, [dirOut1, 'ITPCsingleTrialOnlyGamma', info.expName, '.png'])
    
   saveas(ff, [dirDropbox, 'compITPCcomMeeting', '.pdf'])
