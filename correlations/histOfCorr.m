%% Plotting histogram of max corralations at a function of channel space

%% finding adjacent channels in the left, right, top, and bottom directions of V1 

V1 = 25; % channel number at which latency of onset of the average is the shortest

addChan = 3; % number of channels want to show drop of for

[adjRight, adjLeft, adjTop, adjBottom] = findChanFromV1(V1, addChan);


%% plotting and making figures
screensize=get(groot, 'Screensize');
before = 1;
l = 3;
flashOn = [0,0];
markTime = -before:.1:l-before;
screensize=get(groot, 'Screensize');
diameter = 2*addChan+1;
center = (diameter*addChan) +addChan +1;

currentFig = figure('Position', screensize)

%plotting average of V1 at center
subplot(diameter,diameter,center)
plot(finalTime, squeeze(aveTrace(V1,:)));
% set(gca, 'ylim', [min(aveTrace(:)),  max(aveTrace(:))])
 yAxis = get(gca, 'YLim');
hold on
for t = 1:length(markTime)
    line([markTime(t), markTime(t)], yAxis, 'Color', [.85 .85 .85])
    hold on
end
hold on
plot(flashOn, yAxis, 'r')
% if exist('latency')
%     plot([1 1] * latency(trueChannel) / 1000, yAxis, 'k')
% end
hold off;

%plotting left histograms
for left = 1:length(adjLeft)
    if isnan(adjLeft(left))
        continue
    end
    if ismember(adjLeft(left), info.noiseChannels)
        continue
    end
    subplot(diameter, diameter, center-left)
    if V1 > adjLeft(left)
        hist(maxCorrMatrix(:, adjLeft(left),V1))
    else
        hist(maxCorrMatrix(:, V1, adjLeft(left)))
    end
end

%plotting right histograms
for right = 1:length(adjRight)
    if isnan(adjRight(right))
        continue
    end
    if ismember(adjRight(right), info.noiseChannels)
        continue
    end
    subplot(diameter, diameter, center+right)
    if V1 > adjLeft(left)
        hist(maxCorrMatrix(:, adjRight(right),V1))
    else
        hist(maxCorrMatrix(:, V1, adjRight(right)))
    end
end

%plotting top histograms
for top = 1:length(adjTop)
    if isnan(adjTop(top))
        continue
    end
    if ismember(adjTop(top), info.noiseChannels)
        continue
    end
    subplot(diameter, diameter, center-(diameter*top))
    if V1 > adjLeft(left)
        hist(maxCorrMatrix(:, adjTop(top),V1))
    else
        hist(maxCorrMatrix(:, V1, adjTop(top)))
    end
end

%plotting bottom histograms
for bottom = 1:length(adjBottom)
    if isnan(adjBottom(bottom))
        continue
    end
    if ismember(adjBottom(bottom), info.noiseChannels)
        continue
    end
    subplot(diameter, diameter, center+(diameter*bottom))
    if V1 > adjBottom(bottom)
        hist(maxCorrMatrix(:, adjBottom(bottom),V1))
    else
        hist(maxCorrMatrix(:, V1, adjBottom(bottom)))
    end
end