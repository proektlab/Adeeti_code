

%%
load('2017-02-23_17-55-22.mat')
% 61 seconds in -- trial 20
% 98-104 seconds - trials 32-33
concatData = reshape(permute(dataSnippits, [1 3 2]), 64, (size(dataSnippits,2)*3001));
eegplot(concatData, 'srate', finalSampR)

%%
experiment = '2017-02-23_17-55-22';
trials = 50:52;

AlexMeanSubData = squeeze(meanSubData(:, trials, :));
AlexMeanSubData = squeeze(reshape(permute(AlexMeanSubData, [1, 3, 2]), size(AlexMeanSubData, 1), (size(AlexMeanSubData, 2)*3001)));
AlexData = squeeze(dataSnippits(:, trials, :));
AlexData = squeeze(reshape(permute(AlexData, [1, 3, 2]), size(AlexData, 1), (size(AlexData, 2)*3001)));

AlexTime = linspace(0, numel(trials), (3*numel(trials)*finalSampR)+numel(trials));

%%
AlexRange = 5000;
f=figure;
f.Units='inches';
f.Position=[0 1 8.5 11];

USE_DATA = 1; %if USE_DATA =1, use mean sub data, else use nonmean sub data

if USE_DATA ==1
    plotData = AlexMeanSubData;
else
    plotData = AlexData;
end

for ch = 1:size(plotData, 1)
    if ch == 1
        h(ch)=axes('Position', [0.1 0.9 0.8 0.025]);
        plot(AlexTime(1:AlexRange), plotData(ch, 1:AlexRange))
        h(ch).Visible = 'off';
    elseif ch == 18
        h(ch)=axes('Position', [0.1 (0.9-0.0125*(ch-1)), 0.8 0.025]);
        plot(AlexTime(1:AlexRange), plotData(ch, 1:AlexRange), 'color', prettyGreen, 'LineWidth', 3)
        h(ch).Visible = 'off';
    elseif ch == 34
        h(ch)=axes('Position', [0.1 (0.9-0.0125*(ch-1)), 0.8 0.025]);
        plot(AlexTime(1:AlexRange), plotData(ch, 1:AlexRange), 'color', darkViolet, 'LineWidth', 3)
        h(ch).Visible = 'off';
    elseif ch == 13
        h(ch)=axes('Position', [0.1 (0.9-0.0125*(ch-1)), 0.8 0.025]);
        plot(AlexTime(1:AlexRange), plotData(ch, 1:AlexRange), 'color', orange, 'LineWidth', 3)
        h(ch).Visible = 'off';
    elseif ch == 61
        h(ch)=axes('Position', [0.1 (0.9-0.0125*(ch-2)), 0.8 0.025]);
        plot(AlexTime(1:AlexRange), plotData(ch, 1:AlexRange), 'color', crimson, 'LineWidth', 3)
        h(ch).Visible = 'off';
    elseif ch >= 50
        h(ch)=axes('Position', [0.1 (0.9-0.0125*(ch-2)), 0.8 0.025]);
        plot(AlexTime(1:AlexRange), plotData(ch, 1:AlexRange))
        h(ch).Visible = 'off';
    else
        h(ch)=axes('Position', [0.1 (0.9-0.0125*(ch-1)), 0.8 0.025]);
        plot(AlexTime(1:AlexRange), plotData(ch, 1:AlexRange))
        h(ch).Visible = 'off';
    end
end

hold on 

h(ch+1)=axes('Position', [0.1 (0.9-0.0125*(ch-1)), 0.16 0.025]);
line([0 1], [1 1], 'LineWidth', 2, 'color', 'k');
t=text(0.4, -0.75, '1 s', 'FontName', 'Arial', 'FontSize', 12)
h(ch+1).Visible = 'off';

% if USE_DATA ==1
%     suptitle(['Mean Subtracted data, trials: ', num2str(trials), 'Exp: ', experiment]);
% else
%     suptitle(['Non-Mean Subtracted, trials: ', num2str(trials), 'Exp: ', experiment])
% end

    %% to plot all channels
    
    figure;
    %plot(AlexData([1:48 50:64],:)')
    h = axes;
    plot(AlexMeanSubData(:, 1:AlexRange)');
    h.Visible = 'off';
    hold on;
    line([500 750], [10000 10000], 'LineWidth', 2, 'Color', 'k');
    line([500 500], [10000 12500], 'LineWidth', 2, 'Color', 'k');
    
    tt=text(300, 11000, '0.25 mV', 'FontName', 'Arial', 'FontSize', 12)
    tt2=text(550, 9600, '250 ms', 'FontName', 'Arial', 'FontSize', 12)



    %%
    % calculate shift
    minData = min(AlexNewData,[],2);
    maxData = max(AlexNewData,[],2);
    shift = (max(maxData(:)) + max(abs(minData(:))))
    shift = repmat(shift,1,length(finalTime));
    % shift = cumsum([0; abs(maxData(1:end-1))+abs(minData(2:end))]);
    % shift = repmat(shift,1,1024);
    
    
    
    figure
    for ch = 1:size(AlexNewData, 1)
        if ch == 1
            plot(finalTime, AlexNewData(ch,:), 'b');
            AlexDataShift = AlexNewData;
        else
            AlexDataShift = AlexDataShift + shift;
            plot(finalTime,AlexDataShift(ch, :), 'b')
            hold on
        end
    end
    %
    % % edit axes
    % set(gca,'ytick',mean(sig+shift,2),'yticklabel',1:32)
    % grid on
    % ylim([minData(1) max(max(shift+sig))])
    % end
