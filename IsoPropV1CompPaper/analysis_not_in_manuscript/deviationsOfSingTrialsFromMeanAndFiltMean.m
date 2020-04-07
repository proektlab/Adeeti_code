%% Distance from aveTrace and filt35Average

% 10/02/18 AA

%%
clc
clear
close all

dirIn = '/data/adeeti/ecog/matIsoPropMultiStim/';
filtStimDir = '/data/adeeti/ecog/matIsoPropMultiStim/Wavelets/FiltData/';
%dirDropbox = '/data/adeeti/Dropbox/';

cd(dirIn)
load('dataMatrixFlashes.mat')
load('matStimIndex.mat')

lowestLatVariable = 'lowLat';
fr = 35;

% rangeBefore = 500 + [21:80];
% rangeAfter = 1000 + [21:80];

rangeBefore = 500 + [20:140];
rangeAfter = 1000 + [20:140];

%expID = 5;

stimIndex = [0, Inf]; %if want all, stimIndex = matStimIndex; % if want
%all uniStimIndexes/multiStimIndexes, use [uniStimIndex, multiStimIndex] =
%findUniMutliStimIndex(matStimIndex), [stimIndex, ~] = findUniMutliStimIndex(matStimIndex)


%% Setting up parameters

allExp = nan(6, 6);
if exist('stimIndex')  && ~isempty(stimIndex)
    for i = 1:size(stimIndex,1)
        for mouseID = 1:6
            [MFE] = findMyExpMulti(dataMatrixFlashes, mouseID, [], [], stimIndex(i,:));
            allExp(mouseID,1:length(MFE)) = MFE;
        end
    end
else
    [MFE] = 1:length(dataMatrixFlashes);
end

%%

for a = 5%1:size(allExp,1)
    for b = 2%1:size(allExp,2)
        if isnan(allExp(a,b))
            continue
        end
        
        load(dataMatrixFlashes(allExp(a,b)).expName, 'meanSubData', 'info', 'aveTrace', 'uniqueSeries', 'indexSeries')
        
        V1 = info.lowLat;
        
        experimentName = info.expName(1:end-4);
        
        load([filtStimDir, experimentName, 'wave.mat'], ['filtSig', num2str(fr)], 'Freq')
        
        [indices] = getStimIndices(stimIndex, indexSeries, uniqueSeries);
        aveTraceIndex = find(ismember(stimIndex, uniqueSeries, 'rows'));
        
        eval(['sig = filtSig', num2str(fr), '(:, :,indices);']);
        
        meanFiltSig = nanmean(sig(:,info.lowLat, indices), 3);
        singTrials = meanSubData(:,indices,:);
        
        % apply filter to data
        [filterweights] = buildBandPassFiltFunc_AA(1000, [25, 60], 0.2, 50);
        
        filtered_data = zeros(size(singTrials));
        for ch=1:size(singTrials, 1)
            for tr = 1:size(singTrials,2)
                filtered_SingleTrials(ch,tr,:) = filtfilt(filterweights,1,double(singTrials(ch,tr,:)));
                an_hilb_singleTrials(ch,tr,:) = hilbert(filtered_SingleTrials(ch,tr,:));
            end
        end
        
        
        phases = angle(an_hilb_singleTrials);
        unwrappedPhase = unwrap(phases);
        
        meanPhase = angle(nanmean(exp(1i*phases),2));
        unwrappedMeanPhase = unwrap(meanPhase);

        dotMeanBefore = [];
        dotMeanAfter = [];
        dotFiltBefore = [];
        dotFiltAfter = [];
        
        for i = 1:size(singTrials,2)
            dotMeanBefore(i) = sum((zscore(squeeze(singTrials(V1, i, rangeBefore)))- zscore(squeeze(aveTrace(aveTraceIndex, V1, rangeAfter)))).^2);
            dotMeanAfter(i) = sum((zscore(squeeze(singTrials(V1, i, rangeAfter)))-zscore(squeeze(aveTrace(aveTraceIndex, V1, rangeAfter)))).^2);
            dotFiltAfter(i) = sum((angdiff(squeeze(phases(V1, i, rangeAfter)), squeeze(meanPhase(V1, :,rangeAfter)))).^2);
            dotFiltBefore(i) = sum((angdiff(squeeze(phases(V1, i, rangeBefore)), squeeze(meanPhase(V1, :,rangeAfter)))).^2);
            
            
%             dotFiltAfter(i) = zscore(squeeze(sig(rangeAfter, V1, i)))'* zscore(squeeze(meanFiltSig(rangeAfter,:)));
%             dotFiltBefore(i) = zscore(squeeze(sig(rangeBefore, V1, i)))'* zscore(squeeze(meanFiltSig(rangeAfter,:)));
        end
        %
        %         for i = 1:size(singTrials,2)
        %             dotMeanBefore(i) = sum((zscore(squeeze(singTrials(V1, i, rangeBefore)))- zscore(squeeze(aveTrace(aveTraceIndex, V1, rangeAfter)))).^2);
        %             dotMeanAfter(i) = sum((zscore(squeeze(singTrials(V1, i, rangeAfter)))-zscore(squeeze(aveTrace(aveTraceIndex, V1, rangeAfter)))).^2);
        %             dotFiltAfter(i) = sum((zscore(squeeze(sig(rangeAfter, V1, i)))- zscore(squeeze(meanFiltSig(rangeAfter,:)))).^2);
        %             dotFiltBefore(i) = sum((zscore(squeeze(sig(rangeBefore, V1, i)))- zscore(squeeze(meanFiltSig(rangeAfter,:)))).^2);
        %         end
        %
        
        figure(1);
        clf
        [~, edges] = histcounts([dotFiltAfter, dotFiltBefore], 20);
        afterCounts = histogram(dotFiltAfter, 'BinEdges', edges);
        hold on
        beforeCounts = histogram(dotFiltBefore, 'BinEdges', edges);
        title('Filtered')
        legend()
        
        afterCounts = afterCounts.Values / sum(afterCounts.Values);
        beforeCounts = beforeCounts.Values / sum(beforeCounts.Values);
        
        filteredKL = beforeCounts .* log(beforeCounts ./ afterCounts);
        filteredKL(isinf(filteredKL)) = 0;
        filteredKL(isnan(filteredKL)) = 0;
        title(['Filtered - KL ' num2str(sum(filteredKL))])
        
        figure(2)
        clf;
        [~, edges] = histcounts([dotMeanAfter, dotMeanBefore], 20);
        afterCounts = histogram(dotMeanAfter, 'BinEdges', edges)
        hold on
        beforeCounts = histogram(dotMeanBefore, 'BinEdges', edges)
        
        legend()
        
        afterCounts = afterCounts.Values / sum(afterCounts.Values);
        beforeCounts = beforeCounts.Values / sum(beforeCounts.Values);
        
        filteredKL = beforeCounts .* log(beforeCounts ./ afterCounts);
        filteredKL(isinf(filteredKL)) = 0;
        filteredKL(isnan(filteredKL)) = 0;
        title(['Mean - KL ' num2str(sum(filteredKL))])
        
        i = [3, 6, 18, 9, 39];
        
        figure(3)
        clf
        subplot(2,1,1)
        plot(zscore(squeeze(aveTrace(aveTraceIndex, V1, rangeAfter))), 'k', 'LineWidth', 3)
        hold on
        plot(zscore(squeeze(singTrials(V1, i, rangeAfter))'))
        title('PostStim')
        subplot(2,1,2)
        plot(zscore(squeeze(aveTrace(aveTraceIndex, V1, rangeAfter))), 'k', 'LineWidth', 3)
        hold on
        plot(zscore(squeeze(singTrials(V1, i, rangeBefore))'))
        title('PreStim')
        
%         figure(4)
%         clf
%         subplot(2,1,1)
%         plot(squeeze(meanFiltSig(rangeAfter,:)), 'k', 'LineWidth', 3)
%         hold on
%         plot(squeeze(sig(rangeAfter, V1, i)))
%         title('PostStim')
        
        figure(4)
        clf
        subplot(2,1,1)
        plot(squeeze(real(exp(1i*meanPhase(V1,:,rangeAfter)))), 'k', 'LineWidth', 3)
        hold on
        plot(squeeze(real(exp(1i*phases(V1, i, rangeAfter))))')
        title('PostStim')

        subplot(2,1,2)
        plot(squeeze(real(exp(1i*meanPhase(V1,:,rangeAfter)))), 'k', 'LineWidth', 3)
        hold on
        plot(squeeze(real(exp(1i*phases(V1, i, rangeBefore))))')
        title('PreStim')
        
    end
end



%%
totSets = 1%100;

for a = 1:size(allExp,1)
    for b = 1:size(allExp,2)
        if isnan(allExp(a,b))
            continue
        end
        
        load(dataMatrixFlashes(allExp(a,b)).expName, 'meanSubData', 'info', 'aveTrace', 'uniqueSeries', 'indexSeries')
        
        V1 = info.lowLat;
        
        experimentName = info.expName(1:end-4);
        
        load([filtStimDir, experimentName, 'wave.mat'], ['filtSig', num2str(fr)], 'Freq')
        
        [indices] = getStimIndices(stimIndex, indexSeries, uniqueSeries);
        aveTraceIndex = find(ismember(stimIndex, uniqueSeries, 'rows'));
        
        numTrials = round(length(indices)/2);
        
        for i = 1:totSets
            trials = randsample(indices, numTrials);
            dotMeanBefore = [];
            dotMeanAfter = [];
            
            %             beforeDists = pdist2(zscore(squeeze(singTrials(V1, :, rangeBefore))), zscore(squeeze(singTrials(V1, :, rangeAfter))));
            %             afterDists = pdist2(zscore(squeeze(singTrials(V1, :, rangeAfter))), zscore(squeeze(singTrials(V1, :, rangeAfter))));
            beforeDists = pdist2(zscore(squeeze(sig(rangeAfter, V1, :))), zscore(squeeze(sig(rangeAfter, V1, :))));
            afterDists = pdist2(zscore(squeeze(sig(rangeBefore, V1, :))), zscore(squeeze(sig(rangeAfter, V1, :))));
            
            beforeDists = pdist2((squeeze(sig(rangeAfter, V1, :))), (squeeze(sig(rangeAfter, V1, :))));
            afterDists = pdist2((squeeze(sig(rangeBefore, V1, :))), (squeeze(sig(rangeAfter, V1, :))));
            
            figure
            clf
            histogram(beforeDists)
            hold on
            histogram(afterDists)
        end
        
        eval(['sig = filtSig', num2str(fr), '(:, :,indices);']);
        
        meanFiltSig = nanmean(sig(:,info.lowLat, indices), 3);
        singTrials = meanSubData(:,indices,:);
        
        
        %         dotMeanBefore = [];
        %         dotMeanAfter = [];
        %         dotFiltBefore = [];
        %         dotFiltAfter = [];
        
        for i = 1:size(singTrials,2)
            dotMeanBefore(i) = zscore(squeeze(singTrials(V1, i, rangeBefore)))'* zscore(squeeze(aveTrace(aveTraceIndex, V1, rangeAfter)));
            dotMeanAfter(i) = zscore(squeeze(singTrials(V1, i, rangeAfter)))'* zscore(squeeze(aveTrace(aveTraceIndex, V1, rangeAfter)));
            dotFiltAfter(i) = zscore(squeeze(sig(rangeAfter, V1, i)))'* zscore(squeeze(meanFiltSig(rangeAfter,:)));
            dotFiltBefore(i) = zscore(squeeze(sig(rangeBefore, V1, i)))'* zscore(squeeze(meanFiltSig(rangeAfter,:)));
        end
        %
        %         for i = 1:size(singTrials,2)
        %             dotMeanBefore(i) = sum((zscore(squeeze(singTrials(V1, i, rangeBefore)))- zscore(squeeze(aveTrace(aveTraceIndex, V1, rangeAfter)))).^2);
        %             dotMeanAfter(i) = sum((zscore(squeeze(singTrials(V1, i, rangeAfter)))-zscore(squeeze(aveTrace(aveTraceIndex, V1, rangeAfter)))).^2);
        %             dotFiltAfter(i) = sum((zscore(squeeze(sig(rangeAfter, V1, i)))- zscore(squeeze(meanFiltSig(rangeAfter,:)))).^2);
        %             dotFiltBefore(i) = sum((zscore(squeeze(sig(rangeBefore, V1, i)))- zscore(squeeze(meanFiltSig(rangeAfter,:)))).^2);
        %         end
        %
        
        figure(1);
        clf
        [~, edges] = histcounts([dotFiltAfter, dotFiltBefore], 20);
        histogram(dotFiltAfter, 'BinEdges', edges)
        hold on
        histogram(dotFiltBefore, 'BinEdges', edges)
        title('Filtered')
        legend()
        
        figure(2)
        clf;
        [~, edges] = histcounts([dotMeanAfter, dotMeanBefore], 20);
        histogram(dotMeanAfter, 'BinEdges', edges)
        hold on
        histogram(dotMeanBefore, 'BinEdges', edges)
        title('Mean')
        legend()
        
        i = [3, 6, 18, 9, 39];
        
        figure(3)
        clf
        subplot(2,1,1)
        plot(squeeze(aveTrace(aveTraceIndex, V1, rangeAfter)), 'k', 'LineWidth', 3)
        hold on
        plot(squeeze(singTrials(V1, i, rangeAfter))')
        title('PostStim')
        subplot(2,1,2)
        plot(squeeze(aveTrace(aveTraceIndex, V1, rangeAfter)), 'k', 'LineWidth', 3)
        hold on
        plot(squeeze(singTrials(V1, i, rangeBefore))')
        title('PreStim')
        
        figure(4)
        clf
        subplot(2,1,1)
        plot(squeeze(meanFiltSig(rangeAfter,:)), 'k', 'LineWidth', 3)
        hold on
        plot(squeeze(sig(rangeAfter, V1, i)))
        title('PostStim')
        
        subplot(2,1,2)
        plot(squeeze(meanFiltSig(rangeAfter,:)), 'k', 'LineWidth', 3)
        hold on
        plot(squeeze(sig(rangeBefore, V1, i)))
        title('PreStim')
        
    end
end

