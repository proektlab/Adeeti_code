%% Comparing Intensity of pulse (same iso, same duration, same mouse)

clear

dirIn = '/data/adeeti/ecog/matFlashesJanMar2017/';
dirOut = '/data/adeeti/ecog/images/2017IsoSingleFlash/CompAvg_SmallCIs/IntAverages/';

cd(dirIn)
mkdir(dirOut)

identifier = '2017*.mat';

load('dataMatrixFlashes.mat')

allData = dir(identifier);
load(allData(1).name, 'finalTime', 'finalSampR')

PLOT_CI = 0; %1 if want to plot confidence intervals, 0 if not

before = 1;
after = 2;
flashOn = [0,0];
possibleIntensity = [[0 2]; [2.1 4]; [4.1 6]; [6.1 8]; [8.1 10]];
plotColors = {'k', 'g', 'm', 'c', 'b'};


markTime = -before:.2:after;
screensize=get(groot, 'Screensize');

startPlot = find(finalTime > (-before - 1/(finalSampR*10)) & finalTime < (-before + 1/(finalSampR*10)));
endPlot = find(finalTime > (after - 1/(finalSampR*10)) & finalTime < (after + 1/(finalSampR*10)));

expLabel =unique(vertcat(dataMatrixFlashes(:).exp));
intPulse = unique(vertcat(dataMatrixFlashes(:).IntensityPulse));
durationPulse = unique(vertcat(dataMatrixFlashes(:).LengthPulse));
isoLevel = unique(vertcat(dataMatrixFlashes(:).AnesLevel));

%%

for exp = 1:length(expLabel)
    for iso = 1:length(isoLevel)
        for dur = 1:length(durationPulse)
            compExp = find([dataMatrixFlashes.exp] == expLabel(exp) & [dataMatrixFlashes.AnesLevel] == isoLevel(iso) & [dataMatrixFlashes.LengthPulse] == durationPulse(dur));
            
            %disp(['exp: ' num2str(expLabel(exp)) 'int: ' num2str(intPulse(int)) 'dur: ' num2str(durationPulse(dur)) ]);
            
            for t = 1:length(compExp)
                temp = dataMatrixFlashes(compExp(t)).name;
                compInt{exp, iso, dur, t} = temp(length(temp)-22:end);
            end
            
        end
    end
end


%%

for exp = 1:length(expLabel)
    for iso = 1:length(isoLevel)
        for dur = 1:length(durationPulse)
            close all;
            plotIndex = 0;
            plotCounter = 0;
            currentFig = figure('Position', screensize); clf;
            intStrings = {};
            ave = [];
            
            disp(['Exp: ', num2str(expLabel(exp)), ' iso: ', num2str(isoLevel(iso)), ' dur: ', num2str(durationPulse(dur))]);
                
            for trial = 1:size(compInt, 4)
                
                if ~exist(compInt{exp, iso, dur, trial})
                    continue
                end
                
                load(compInt{exp, iso, dur, trial}, 'aveTrace', 'upperCIBound', 'lowerCIBound', 'info')
                plotCounter = plotCounter +1;
                
                if plotCounter == 1
                    gridIndicies = info.gridIndicies;
                    for i = 1:info.channels
                        [electrodeX(i), electrodeY(i)] = ind2sub(size(gridIndicies), find(gridIndicies == i));
                    end
                end
                
                ave(trial,:,:) = aveTrace(:, startPlot:endPlot);
                
                intensity= info.IntensityPulse;
                
                for level = 1:size(possibleIntensity, 1)
                    if ~(floor(intensity) >= possibleIntensity(level,1) && floor(intensity) <= possibleIntensity(level,2))
                        continue
                    end
                    useColor = plotColors{level};
                end
                
                if PLOT_CI ==1
                    intStrings = [intStrings, {['Intesity: ' num2str(info.IntensityPulse) ', 95% CI']}];
                end
                
                intStrings = [intStrings, {['Intesity: ' num2str(info.IntensityPulse) ', average']}];
                
                %to make grid
                for ch = 1:info.channels
                    trueChannel = ch; %info.goodChannels(ch);
                    channelIndex = sub2ind([6 11], electrodeY(trueChannel), electrodeX(trueChannel));
                    subplot(11,6,channelIndex);
                    if PLOT_CI ==1
                    	ciplot(lowerCIBound(ch,startPlot:endPlot), upperCIBound(ch,startPlot:endPlot), finalTime(startPlot:endPlot), useColor)
                        hold on
                    end
                    plot(finalTime(startPlot:endPlot), squeeze(ave(trial, ch,:)), useColor)
                    hold on 
                end
                plotIndex = 1;
            end
            
            if plotIndex
                
                % adding flash on and time markers
                for ch = 1:info.channels
                    trueChannel = ch; %info.goodChannels(ch);
                    channelIndex = sub2ind([6 11], electrodeY(trueChannel), electrodeX(trueChannel));
                    
                    subplot(11,6,channelIndex);
                    
                    title(num2str(trueChannel));
                    
                    set(gca, 'ylim', [min(ave(:)), max(ave(:))])
                    yAxis = get(gca, 'YLim');
                    for t = 1:length(markTime)
                        line([markTime(t), markTime(t)], yAxis, 'Color', [.9 .9 .9])
                        hold on
                    end
                    plot(flashOn, yAxis, 'r')
                    
                end
                
                suptitle(['Comparing Intensity Levels Experiment: ', num2str(expLabel(exp)), ' Iso Concentration: ', num2str(isoLevel(iso)), ' Duration: ' num2str(durationPulse(dur))])
                l = legend(intStrings);
                
                l.Position = [0.05 0.5 0.0235 0.05];
                
                saveas(currentFig, [dirOut, 'Exp', num2str(expLabel(exp)), 'Iso', num2str(isoLevel(iso)), 'Dur' num2str(durationPulse(dur)), '.png'])
            end
            
        end
    end
end

