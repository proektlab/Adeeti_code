%% Comparing experiments with the same duration and intensity level of flash (in same animal) with different iso levels
cd('/data/adeeti/ecog/matFlashesJanMar2017/')
mkdir('/data/adeeti/ecog/images/121217/largeIsoAveragesNoCIsameScale/')

load('dataMatrixFlashes.mat')

load('2017-01-31_15-27-05.mat', 'finalSampR')

TRUNC = 0;

if TRUNC == 1
    before = .1;
    l = .3;
    marks = .05;
    plotTime = [finalSampR*(1-before):1:(1+l-before)*finalSampR];
    finalTime = [-before:(1/finalSampR):(l-before)];
else 
    before = 1;
    l = 3;
    marks = .2;
    plotTime = [1:l*finalSampR+1];
    load('2017-01-31_15-27-05.mat', 'finalTime')
end

flashOn = [0,0];
markTime = -before:marks:l-before;
screensize=get(groot, 'Screensize');

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
            currentFig = figure('Position', screensize); clf;
            isoStrings = {};
            
            disp(['Exp: ', num2str(expLabel(exp)), ' int: ', num2str(intPulse(int)), ' dur: ', num2str(durationPulse(dur))]);
                
            for trial = 1:size(compIso, 4)
                
                if ~exist(compIso{exp, int, dur, trial})
                    continue
                end
                
                load(compIso{exp, int, dur, trial}, 'aveTrace', 'lowerCIBound', 'upperCIBound', 'info')
                ave(trial,:,:) = aveTrace;
                isoStrings = [isoStrings, {['isoLevel: ' num2str(info.AnesLevel) '%, 95% CI']}];
                %isoStrings = [isoStrings, {['isoLevel: ' num2str(info.AnesLevel) '%, average']}];
                if info.AnesLevel == 0.6
                    plotColor = 'c';
                elseif info.AnesLevel == 0.8
                    plotColor = 'g';
                elseif info.AnesLevel == 1.0
                    plotColor = 'm';
                elseif info.AnesLevel == 1.2
                    plotColor = 'b';
                elseif info.AnesLevel == 1.1
                    plotColor = 'k';
                else 
                end
                
                %to make grid
                for ch = 1:size(aveTrace, 1)
                    trueChannel = ch; %info.goodChannels(ch);
                    channelIndex = sub2ind([6 11], electrodeY(trueChannel), electrodeX(trueChannel));
                    subplot(11,6,channelIndex);

                    %ciplot(lowerCIBound(ch,plotTime), upperCIBound(ch,plotTime), finalTime, plotColor)
                    %hold on
                    plot(finalTime, squeeze(ave(trial, ch, plotTime)), plotColor)
                    hold on
                end
                plotIndex = 1;
            end
            
            if plotIndex
                
                % adding flash on and time markers
                for ch = 1:size(aveTrace, 1)
                    trueChannel = ch; %info.goodChannels(ch);
                    channelIndex = sub2ind([6 11], electrodeY(trueChannel), electrodeX(trueChannel));
                    
                    subplot(11,6,channelIndex);
                    
                    title(num2str(trueChannel));
                    
                    if min(ave(:))<-5000 && max(ave(:))> 5000
                        set(gca, 'ylim', [min(ave(:)), max(ave(:))])
                        yAxis = get(gca, 'YLim');
                    elseif max(ave(:))> 5000
                        set(gca, 'ylim', [-5000, max(ave(:))])
                        yAxis = get(gca, 'YLim');
                    elseif min(ave(:))<- 4000
                        set(gca, 'ylim', [min(ave(:)), 5000])
                        yAxis = get(gca, 'YLim');
                    else 
                        set(gca, 'ylim', [-5000, 5000])
                        yAxis = get(gca, 'YLim');
                    end
                    for t = 1:length(markTime)
                        line([markTime(t), markTime(t)], yAxis, 'Color', [.9 .9 .9])
                        hold on
                    end
                    plot(flashOn, yAxis, 'r')
                    
                end
                
                suptitle(['Comparing Iso Levels Experiment: ', num2str(expLabel(exp)), ' Intensity: ', num2str(intPulse(int)), ' Duration: ' num2str(durationPulse(dur))])
                l = legend(isoStrings);
                
                l.Position = [0.05 0.5 0.0235 0.05]
                
                saveas(currentFig, ['/data/adeeti/ecog/images/121217/largeIsoAveragesNoCIsameScale/', num2str(expLabel(exp)), 'Int', num2str(intPulse(int)), 'Dur' num2str(durationPulse(dur)), '.png'])
            end
            
        end
    end
end

