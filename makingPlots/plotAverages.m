function [currentFig] = plotAverages(plotData, finalTime, info, yAxis, lowerCIBound, upperCIBound, latency,  before, after, flashOn, finalSampR)
 %[currentFig] = plotAverages(plotData, finalTime, info, yAxis, lowerCIBound, upperCIBound, latency,  before, after, flashOn, finalSampR)
if nargin <4
    yAxis = [min(plotData(:)),  max(plotData(:))];
end
    
if nargin <5
    lowerCIBound = [];
    upperCIBound = [];
end
 
if nargin <7
    latency = [];
end
 
if nargin <8
    before = 1;
    after = 2;
    flashOn = [0,0];
end
 
if nargin <11
    finalSampR = 1000;
end

if isempty(yAxis)
    yAxis = [min(plotData(:)),  max(plotData(:))];
end

 
startPlot = find(finalTime > (-before - 1/(finalSampR*10)) & finalTime < (-before + 1/(finalSampR*10)));
endPlot = find(finalTime > (after - 1/(finalSampR*10)) & finalTime < (after + 1/(finalSampR*10)));
 
markTime = -before:.1:after;
screensize=get(groot, 'Screensize');
 
gridIndicies = info.gridIndicies; 
 
for i = 1:64
    [electrodeX(i), electrodeY(i)] = ind2sub(size(gridIndicies), find(gridIndicies == i));
end
 
% timeLabels = [-beforePeriod:duration];
 
currentFig = figure('Position', screensize);
 
clf
 
for ch = 1:size(plotData, 1)
    trueChannel = ch;%info.goodChannels(ch);
    channelIndex = sub2ind([6 11], electrodeY(trueChannel), electrodeX(trueChannel));
     
    subplot(11,6,channelIndex);
    plot(finalTime(startPlot:endPlot), plotData(ch, startPlot:endPlot))
    title(num2str(trueChannel));
    set(gca, 'ylim', yAxis)
    set(gca, 'xlim', [-before,  after])
    hold on
     
    if ~isempty(lowerCIBound) && ~isempty(upperCIBound)
        ciplot(lowerCIBound(ch,startPlot:endPlot), upperCIBound(ch,startPlot:endPlot), finalTime(startPlot:endPlot), 'b')
    end
     
    for t = 1:length(markTime)
        line([markTime(t), markTime(t)], yAxis, 'Color', [.9 .9 .9])
        hold on
    end
     
    plot(flashOn, yAxis, 'r')
     
    if exist('latency') && ~isempty(latency)
        plot([1 1] * latency(trueChannel) / 1000, yAxis, 'k')
        title(['Latency: ', num2str(latency(ch)), ' msec'])  %, Entropy: ', num2str(entropy(ch))]);
    end
    hold off;
end
 
end
 
%suptitle(['Determining Latency, Experiment', info.date, ' Drug Concentration ', num2str(info.AnesLevel), ' Duration: ' num2str(info.LengthPulse), ' Intensity: ', num2str(info.IntensityPulse)])