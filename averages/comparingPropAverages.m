%% Comparing experiments with the same duration and intensity level of flash (in same animal) with different iso levels
cd('/data/adeeti/ecog/matPropFlashesJanMar2017')
mkdir('/data/adeeti/ecog/images/082217/PropAverages/')

load('dataMatrixFlashes.mat')

before = 1;
l = 3;
flashOn = [0,0];
markTime = -before:.2:l-before;
screensize=get(groot, 'Screensize');
plotColors = {'g', 'b', 'm', 'c', 'k', 'r'};

gridIndicies = [[5 17 0 0 33 53]; ...
                [6 18 28 44 34 54]; ...
                [7 19 29 45 35 55]; ...
                [8 20 30 46 36 56]; ...
                [9 21 31 47 37 57]; ...
                [10 22 32 48 38 58]; ...
                [11 16 27 43 64 59]; ...
                [4 15 26 42 63 52]; ...
                [3 14 25 41 62 51]; ...
                [2 13 24 40 61 50]; ...
                [1 12 23 39 60 49]];
            
for i = 1:64
    [electrodeX(i), electrodeY(i)] = ind2sub(size(gridIndicies), find(gridIndicies == i));
end

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
                compProp{exp, int, dur, t} = temp(length(temp)-22:end);
            end
            
        end
    end
end


%%

for exp = 2%:length(expLabel)
    for int = 1%:length(intPulse)
        for dur = 1%:length(durationPulse)
%             close all;
            plotIndex = 0;
            currentFig = figure('Position', screensize); clf;
            isoStrings = {};
            
            disp(['Exp: ', num2str(expLabel(exp)), ' int: ', num2str(intPulse(int)), ' dur: ', num2str(durationPulse(dur))]);
                
            for trial = 1:size(compProp, 4)
                
                if ~exist(compProp{exp, int, dur, trial})
                    continue
                end
                if trial == 2 
                    continue
                end
                
                
                load(compProp{exp, int, dur, trial})
                ave(trial,:,:) = aveTrace;
                isoStrings = [isoStrings, {['Propofol: ' num2str(info.AnesLevel) 'mg/kg, 90% points']}];
                isoStrings = [isoStrings, {['Propofol: ' num2str(info.AnesLevel) 'mg/kg average']}];
                
                %to make grid
                for ch = 1:size(meanSubData, 1)
                    trueChannel = ch; %info.goodChannels(ch);
                    channelIndex = sub2ind([6 11], electrodeY(trueChannel), electrodeX(trueChannel));
                    subplot(11,6,channelIndex);

                    ciplot(lowerCIBound(ch,:), upperCIBound(ch,:), finalTime, plotColors{trial})
                    hold on
                    plot(finalTime, squeeze(ave(trial, ch,:)), plotColors{trial})
                end
                plotIndex = 1;
            end
            
            if plotIndex
                
                % adding flash on and time markers
                for ch = 1:size(meanSubData, 1)
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
                
                suptitle(['Comparing Propofol Levels Experiment: ', num2str(expLabel(exp)), ' Intensity: ', num2str(intPulse(int)), ' Duration: ' num2str(durationPulse(dur))])
                l = legend(isoStrings);
                
                l.Position = [0.05 0.5 0.0235 0.05];
                
                saveas(currentFig, ['/data/adeeti/ecog/images/082217/PropAverages/', num2str(expLabel(exp)), 'Int', num2str(intPulse(int)), 'Dur' num2str(durationPulse(dur)), '.png'])
            end
            
        end
    end
end

