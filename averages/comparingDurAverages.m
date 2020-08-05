%% Comparing Duration of pulse (same iso, same intensity, same mouse)

clear

dirIn = '/data/adeeti/ecog/matFlashesJanMar2017/';
dirOut = '/data/adeeti/ecog/images/2017IsoSingleFlash/CompAvg_SmallCIs/DurAverages/';

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
possibleDuration = [[0 5]; [6 10]; [11 40]; [41 60]; [61 100]];
plotColors = {'k', 'g', 'c', 'm', 'b'};


markTime = -before:.2:after;
screensize=get(groot, 'Screensize');

startPlot = find(finalTime > (-before - 1/(finalSampR*10)) & finalTime < (-before + 1/(finalSampR*10)));
endPlot = find(finalTime > (after - 1/(finalSampR*10)) & finalTime < (after + 1/(finalSampR*10)));

expLabel =unique(vertcat(dataMatrixFlashes(:).exp));
intPulse = unique(vertcat(dataMatrixFlashes(:).IntensityPulse));
durationPulse = unique(vertcat(dataMatrixFlashes(:).LengthPulse));
isoLevel = unique(vertcat(dataMatrixFlashes(:).AnesLevel));


%%  Finding all the trials to compare duration of pulse with all other attributes kept equal

for exp = 1:length(expLabel)
    for int = 1:length(intPulse)
        for iso = 1:length(isoLevel)
            compExp = find([dataMatrixFlashes.exp] == expLabel(exp) & [dataMatrixFlashes.IntensityPulse] == intPulse(int) & [dataMatrixFlashes.AnesLevel] == isoLevel(iso));
            
            %disp(['exp: ' num2str(expLabel(exp)) 'int: ' num2str(intPulse(int)) 'dur: ' num2str(durationPulse(dur)) ]);
            
            for t = 1:length(compExp)
                temp = dataMatrixFlashes(compExp(t)).name;
                compDur{exp, int, iso, t} = temp(length(temp)-22:end);
            end
            
        end
    end
end


%%

for exp = 1:length(expLabel)
    for int = 1:length(intPulse)
        for iso = 1:length(isoLevel)
            close all;
            plotIndex = 0;
            plotCounter = 0;
            currentFig = figure('Position', screensize); clf;
            durStrings = {};
            ave =[];
            
            disp(['Exp: ', num2str(expLabel(exp)), ' int: ', num2str(intPulse(int)), ' iso: ', num2str(isoLevel(iso))]);
            
            for trial = 1:size(compDur, 4)

                if ~exist(compDur{exp, int, iso, trial})
                   continue
                end
                
                load(compDur{exp, int, iso, trial}, 'aveTrace', 'upperCIBound', 'lowerCIBound', 'info')
                plotCounter = plotCounter +1;
                
                if plotCounter == 1
                    gridIndicies = info.gridIndicies;
                    for i = 1:info.channels
                        [electrodeX(i), electrodeY(i)] = ind2sub(size(gridIndicies), find(gridIndicies == i));
                    end
                end
                
                ave(trial,:,:) = aveTrace(:, startPlot:endPlot);
                
                duration= info.LengthPulse;
                
                for level = 1:size(possibleDuration, 1)
                    if ~(floor(duration) >= possibleDuration(level,1) && floor(duration) <= possibleDuration(level,2))
                        continue
                    end
                    useColor = plotColors{level};
                end
                
                if PLOT_CI ==1
                durStrings = [durStrings, {['Duration: ' num2str(info.LengthPulse) ', 95% CI']}];
                end
                durStrings = [durStrings, {['Duration: ' num2str(info.LengthPulse) ' msec, average']}];
                
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
                plotIndex = 1;  %if there are no trials in a data set, then we will not create a figure
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
                
                suptitle(['Comparing Duration of Flash  Experiment: ', num2str(expLabel(exp)), ' Intensity: ', num2str(intPulse(int)), ' Iso Concentration: ' num2str(isoLevel(iso))])
                l = legend(durStrings);
                
                l.Position = [0.05 0.5 0.0235 0.05];
                
                saveas(currentFig, [dirOut,'Exp', num2str(expLabel(exp)), 'Int', num2str(intPulse(int)), 'Iso' num2str(isoLevel(iso)), '.png'])
            end
        end
    end
end

