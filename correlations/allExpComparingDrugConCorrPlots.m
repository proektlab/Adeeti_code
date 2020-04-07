%% Comparing anes for corr decay for one experiment

mkdir('/data/adeeti/ecog/images/110317/');
load('dataMatrixFlashes.mat')

% to use particular corr and lags (pos or neg only)
USE_NEG_ONLY = 1; %one for only neg lags from V1, 0 for positve lags from V1
addChan = 8; % number of channels want to show drop of for
screensize=get(groot, 'Screensize');

%%
expLabel =unique(vertcat(dataMatrixFlashes(:).exp));
intPulse = unique(vertcat(dataMatrixFlashes(:).IntensityPulse));
durationPulse = unique(vertcat(dataMatrixFlashes(:).LengthPulse));
isoLevel = unique(vertcat(dataMatrixFlashes(:).AnesLevel));

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

%% Code to run comparing anes levels for all experiments

for exp = 1:length(expLabel)
    if expLabel(exp) ==1 %%these come from the mode of the shortest latency channels for each experiment with the avg above 30ms
        V1 = 29;
    elseif expLabel(exp) ==3
        V1 = 25;
    elseif expLabel(exp) == 4
        V1 = 27;
    elseif expLabel(exp) == 7
        V1 = 31;
    elseif expLabel(exp) ==8
        V1 = 22;
    elseif expLabel(exp) ==9
        V1 = 25;
    end
    for int = 1:length(intPulse)
        for dur = 1:length(durationPulse)
            close all;
            currentFig = figure('Position', screensize); clf;
            legendTitles = {};
            legendIndex = 1;
            disp(['Exp: ', num2str(expLabel(exp)), ' int: ', num2str(intPulse(int)), ' dur: ', num2str(durationPulse(dur))]);
            plotIndex = 0;
            
            validExperiments = findMyExp(dataMatrixFlashes, expLabel(exp), [],  intPulse(int), durationPulse(dur));
            
            for drugCon = 1:size(compIso, 4)
                if ~exist(compIso{exp, int, dur, drugCon})
                    continue
                end
                if expLabel(exp) ==9 && drugCon == 1 && length(validExperiments)>=4
                    continue
                end
                plotIndex = plotIndex+1;
                
                load(compIso{exp, int, dur, drugCon})
                
                NUM_TR = size(maxCorrMatrix,1);
                CI_Val = 1.96;
                
                %finding adjacent channels in the left, right, top, and bottom directions of V1
                
                [adjRight, adjLeft, adjTop, adjBottom] = findChanFromV1(V1, addChan);
                
                %defining data set for correlations and lags
                if USE_NEG_ONLY == 1
                    useCorrMatrix = negOnlyMaxCorr;
                    useLagMatrix = negOnlyLag;
                else
                    useCorrMatrix = posOnlyMaxCorr;
                    useLagMatrix = posOnlyLag;
                end
                
                %finding means and std for corr and lags
                meanMaxCorr = squeeze(nanmean(useCorrMatrix,1));
                seMaxCorr = CI_Val*(squeeze(nanstd(useCorrMatrix,[],1))/sqrt(NUM_TR));
                meanMaxLag = squeeze(nanmean(useLagMatrix,1));
                seMaxLag = CI_Val*(squeeze(nanstd(useLagMatrix,[],1))/sqrt(NUM_TR));
                
                meanMaxCorrV1 = nan(4,addChan); %in first dim: 1 - Left, 2 - right, 3 - top, 4- bottom
                seMaxCorrV1 = nan(4,addChan);
                meanMaxLagV1 = nan(4,addChan); %in first dim: 1 - Left, 2 - right, 3 - top, 4- bottom
                seMaxLagV1 = nan(4,addChan);
                
                indexDirection = [adjLeft; adjRight; adjTop; adjBottom];
                
                % extracting mean and std corr and lags for each channel of
                % interest away from V1
                for ID = 1:size(indexDirection, 1)
                    for direction = 1:size(indexDirection, 2)
                        if isnan(indexDirection(ID, direction))
                            continue
                        end
                        if ismember(indexDirection(ID, direction), info.noiseChannels)
                            continue
                        end
                        meanMaxCorrV1(ID, direction) = meanMaxCorr(V1, indexDirection(ID, direction));
                        meanMaxLagV1(ID, direction) = meanMaxLag(V1, indexDirection(ID, direction));
                        seMaxCorrV1(ID, direction) = seMaxCorr(V1, indexDirection(ID, direction));
                        seMaxLagV1(ID, direction) = seMaxLag(V1, indexDirection(ID, direction));
                    end
                end
                
                legendTitles{legendIndex} = ['Anes level: ' num2str(info.AnesLevel)];
                
                %plot corr
                subplot(2,2,1)
                errorbar(meanMaxCorrV1(1,:), seMaxCorrV1(1, :), '-o')
                hold on
                title('Correlations of Channels to the left of V1')
                ylabel('Correlation Coefficient')
                xlabel('Channel')
                
                subplot(2,2,2)
                errorbar(meanMaxCorrV1(2,:), seMaxCorrV1(2, :), '-o')
                hold on
                title('Correlations of Channels to the right of V1')
                ylabel('Correlation Coefficient')
                xlabel('Channel')
                
                subplot(2,2,3)
                errorbar(meanMaxCorrV1(3,:), seMaxCorrV1(3, :), '-o')
                hold on
                title('Correlations of Channels to the top of V1')
                ylabel('Correlation Coefficient')
                xlabel('Channel')
                
                subplot(2,2,4)
                errorbar(meanMaxCorrV1(4,:), seMaxCorrV1(4, :), '-o')
                hold on
                title('Correlations of Channels to the bottom of V1')
                ylabel('Correlation Coefficient')
                xlabel('Channel')
                
                legendIndex = legendIndex + 1;
                
            end
            legend(legendTitles);
            hold off
            suptitle(['Comparing Iso Levels Experiment: ', num2str(expLabel(exp)), ' Intensity: ', num2str(intPulse(int)), ' Duration: ' num2str(durationPulse(dur)), ' V1 = ', num2str(V1)])
            if plotIndex
                saveas(currentFig, ['/data/adeeti/ecog/images/110317/', num2str(expLabel(exp)), 'Int', num2str(intPulse(int)), 'Dur' num2str(durationPulse(dur)), '.png'])
            end
        end
    end
end









%%
