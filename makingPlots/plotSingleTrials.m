function [currentFig] = plotSingleTrials(plotData, finalTime, info)

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
        imagesc(finalTime,1:size(plotData,2),squeeze(plotData(ch,:,:)))
        vectData = plotData(:);
        randSamp = randsample(vectData, 10000);
       % top5per = quantile(randSamp,0.95);
      %  bottom5per = quantile(randSamp,0.05);
       % set(gca, 'clim', [bottom5per, top5per])
        set(gca, 'clim', [min(randSamp), max(randSamp)])
        colorbar

   title(num2str(trueChannel));
    
end
