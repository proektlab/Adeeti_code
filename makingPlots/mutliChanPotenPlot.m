

%%
% load('2017-03-01_16-11-50.mat')

concatData = reshape(permute(dataSnippits, [1 3 2]), 64, (size(dataSnippits,2)*3001));
eegplot(concatData, 'srate', finalSampR)

%%
%
experiment = '2017-03-01_16-11-50.mat';
trials = 131:134;

plotMeanSubData = squeeze(meanSubData(:, trials, :));
plotMeanSubData = squeeze(reshape(permute(plotMeanSubData, [1, 3, 2]), size(plotMeanSubData, 1), (size(plotMeanSubData, 2)*3001)));
plotData = squeeze(dataSnippits(:, trials, :));
plotData = squeeze(reshape(permute(plotData, [1, 3, 2]), size(plotData, 1), (size(plotData, 2)*3001)));

plotTime = linspace(0, numel(trials), (3*numel(trials)*finalSampR)+numel(trials));

%%
startPlot = 1;
plotEnd = 10000%max(plotTime);
f=figure;
f.Units='inches';
f.Position=[0 1 8.5 11];

axHeight = 0.03;
axWidth = 0.8;
axLeft = (1- axWidth)/2;
axBottom = 1-axLeft;
step = axHeight/2;

USE_DATA = 1; %if USE_DATA =1, use mean sub data, else use nonmean sub data

if USE_DATA ==1
    plotData = plotMeanSubData;
else
    plotData = plotData;
end

plotCounter = 1;

for ch = 1:size(plotData, 1)
    if ismember(ch, info.noiseChannels)
        continue
    end
    if plotCounter == 1
        h(plotCounter)=axes('Position', [axLeft axBottom axWidth axHeight]);
        plot(plotTime(startPlot:plotEnd), plotData(ch, startPlot:plotEnd))
        h(plotCounter).Visible = 'off';
    elseif ch == 18
        h(plotCounter)=axes('Position', [axLeft (axBottom-step*(plotCounter)), axWidth axHeight]);
        plot(plotTime(startPlot:plotEnd), plotData(ch, startPlot:plotEnd), 'color', [0.2 .4 .4], 'LineWidth', 3) %%Green: top left
        h(plotCounter).Visible = 'off';
    elseif ch == 34
        h(plotCounter)=axes('Position', [axLeft (axBottom-step*(plotCounter)), axWidth axHeight]);
        plot(plotTime(startPlot:plotEnd), plotData(ch, startPlot:plotEnd), 'color', [0.6 0.2 1.0], 'LineWidth', 3) %Violet: top right
        h(plotCounter).Visible = 'off'; 
    elseif ch == 13
        h(plotCounter)=axes('Position', [axLeft (axBottom-step*(plotCounter)), axWidth axHeight]);
        plot(plotTime(startPlot:plotEnd), plotData(ch, startPlot:plotEnd), 'color', [1 0.4 0], 'LineWidth', 3) %Orange: bottom left
        h(plotCounter).Visible = 'off';
    elseif ch == 61
        h(plotCounter)=axes('Position', [axLeft (axBottom-step*(plotCounter)), axWidth axHeight]);
        plot(plotTime(startPlot:plotEnd), plotData(ch, startPlot:plotEnd), 'color', [0.8 0 0], 'LineWidth', 3) %Red: bottom right 
        h(plotCounter).Visible = 'off';
    else
        h(plotCounter)=axes('Position', [axLeft (axBottom-step*(plotCounter)), axWidth axHeight]);
        plot(plotTime(startPlot:plotEnd), plotData(ch, startPlot:plotEnd))
        h(plotCounter).Visible = 'off';
    end
    plotCounter = plotCounter+ 1;
end

hold on 

h(plotCounter+1)=axes('Position', [axLeft (axBottom-step*(plotCounter)), (axWidth*finalSampR)/(plotEnd-startPlot) axHeight]);
line([0 1], [1 1], 'LineWidth', 2, 'color', 'k');
t=text(0.4, -0.75, '1 s', 'FontName', 'Arial', 'FontSize', 12);
h(plotCounter+1).Visible = 'off';

if USE_DATA ==1
    suptitle(['Propofol: 10mg/kg, mean subtracted, mouse, ', num2str(round((plotEnd-startPlot)/finalSampR)), ' seconds']);
else
    suptitle(['Propofol: 10mg/kg, ', num2str(round((plotEnd-startPlot)/finalSampR)), ' seconds'])
end

currentFig = f;

saveas(currentFig, ['/data/adeeti/ecog/images/propStateChange_10mg_030117.png'])

    %% to plot all channels
    
%     figure;
%     %plot(AlexData([1:48 50:64],:)')
%     h = axes;
%     plot(plotMeanSubData(:, 1:plotTRange)');
%     h.Visible = 'off';
%     hold on;
%     line([500 750], [10000 10000], 'LineWidth', 2, 'Color', 'k');
%     line([500 500], [10000 12500], 'LineWidth', 2, 'Color', 'k');
%     
%     tt=text(300, 11000, '0.25 mV', 'FontName', 'Arial', 'FontSize', 12)
%     tt2=text(550, 9600, '250 ms', 'FontName', 'Arial', 'FontSize', 12)
% 
% 
% 
%     %%
%     % calculate shift
%     minData = min(AlexNewData,[],2);
%     maxData = max(AlexNewData,[],2);
%     shift = (max(maxData(:)) + max(abs(minData(:))))
%     shift = repmat(shift,1,length(finalTime));
%     % shift = cumsum([0; abs(maxData(1:end-1))+abs(minData(2:end))]);
%     % shift = repmat(shift,1,1024);
%     
%     
%     
%     figure
%     for ch = 1:size(AlexNewData, 1)
%         if ch == 1
%             plot(finalTime, AlexNewData(ch,:), 'b');
%             AlexDataShift = AlexNewData;
%         else
%             AlexDataShift = AlexDataShift + shift;
%             plot(finalTime,AlexDataShift(ch, :), 'b')
%             hold on
%         end
%     end
%     %
    % % edit axes
    % set(gca,'ytick',mean(sig+shift,2),'yticklabel',1:32)
    % grid on
    % ylim([minData(1) max(max(shift+sig))])
    % end
