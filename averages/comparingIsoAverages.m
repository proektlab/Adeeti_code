%% Comparing experiments with the same duration and intensity level of flash (in same animal) with different iso levels

clear

dirIn = '/data/adeeti/ecog/matFlashesJanMar2017/';
dirOut = '/data/adeeti/ecog/images/2017IsoSingleFlash/CompAvg_SmallCIs/IsoAverages/';

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
possibleDrugCon = [[0 .21]; [.22 .41]; [.42 .61]; [.62 .81]; [.82 1.01]; [1.02 1.21]];
plotColors = {'k', 'c', 'r', 'g', 'm', 'b'};


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
    for int = 1:length(intPulse)
        for dur = 1:length(durationPulse)
            compExp = find([dataMatrixFlashes.exp] == expLabel(exp) & [dataMatrixFlashes.IntensityPulse] == intPulse(int) & [dataMatrixFlashes.LengthPulse] == durationPulse(dur));
            
            %disp(['exp: ' num2str(expLabel(exp)) 'int: ' num2str(intPulse(int)) 'dur: ' num2str(durationPulse(dur)) ]);
            
            for t = 1:length(compExp)
                temp = dataMatrixFlashes(compExp(t)).name;
                compIso{exp, int, dur, t} = temp(length(temp)-22:end);
            end
            
        end
    end
end


%%

for exp = 1:length(expLabel)
    for int = 1:length(intPulse)
        for dur = 1:length(durationPulse)
            close all;
            plotIndex = 0;
            plotCounter = 0;
            currentFig = figure('Position', screensize); clf;
            isoStrings = {};
            ave = [];
            
            disp(['Exp: ', num2str(expLabel(exp)), ' int: ', num2str(intPulse(int)), ' dur: ', num2str(durationPulse(dur))]);
            
            for trial = 1:size(compIso, 4)
                
                if ~exist(compIso{exp, int, dur, trial})
                    continue
                end
                
                load(compIso{exp, int, dur, trial}, 'aveTrace', 'upperCIBound', 'lowerCIBound', 'info')
                plotCounter = plotCounter+1;
                
                if plotCounter == 1
                    gridIndicies = info.gridIndicies;
                    for i = 1:info.channels
                        [electrodeX(i), electrodeY(i)] = ind2sub(size(gridIndicies), find(gridIndicies == i));
                    end
                end
                
                ave(trial,:,:) = aveTrace(:, startPlot:endPlot);
                
                drugCon= info.AnesLevel;
                
                for level = 1:size(possibleDrugCon, 1)
                    if ~(drugCon > possibleDrugCon(level,1) && drugCon < possibleDrugCon(level,2))
                        continue
                    end
                    useColor = plotColors{level};
                end
                    
                if PLOT_CI ==1
                    isoStrings = [isoStrings, {['isoLevel: ' num2str(drugCon) '%, 95% CI']}];
                end
                
                isoStrings = [isoStrings, {['isoLevel: ' num2str(drugCon) '%, average']}];
        
                %to make grid
                for ch = 1:info.channels
                    trueChannel = ch; %info.goodChannels(ch);
                    channelIndex = sub2ind([6 11], electrodeY(trueChannel), electrodeX(trueChannel));
                    subplot(11,6,channelIndex);
                    if PLOT_CI ==1
                        ciplot(lowerCIBound(ch,startPlot:endPlot), upperCIBound(ch,startPlot:endPlot), finalTime(startPlot:endPlot), useColor)
                    end
                    hold on
                    plot(finalTime(startPlot:endPlot), squeeze(ave(trial, ch,:)), useColor)
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
                
                suptitle(['Comparing Iso Levels Experiment: ', num2str(expLabel(exp)), ' Intensity: ', num2str(intPulse(int)), ' Duration: ' num2str(durationPulse(dur))])
                l = legend(isoStrings);
                
                l.Position = [0.05 0.5 0.0235 0.05];
                
                saveas(currentFig, [dirOut, 'Exp', num2str(expLabel(exp)), 'Int', num2str(intPulse(int)), 'Dur' num2str(durationPulse(dur)), '.png'])
            end
            
        end
    end
end

