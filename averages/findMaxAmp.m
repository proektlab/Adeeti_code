%% Finding highest peaking amplitude

%%
% mkdir('/data/adeeti/ecog/images/061217/')
% mkdir('/data/adeeti/ecog/images/061217/maxAbsAmp/')
% mkdir('/data/adeeti/ecog/images/061217/maxAmp/')

dirIn = '/data/adeeti/ecog/matIsoPropMultiStim/';
dirOutAmp = '/data/adeeti/ecog/images/matIsoPropMultiStim/maxAmp/';
identifier = '2018*.mat';
START_AT = 1;
cd(dirIn)

before=1;
l = 3;
flashOn = [0,0];
thresh=4;
maxThresh = 8;
consistent = 4;
endMeasure = 0.35;
finalSampR = 1000;

beforeInd = before*finalSampR;
endMeasureInd = beforeInd + (endMeasure*finalSampR);

allData = dir(identifier);

loadingWindow = waitbar(0, 'Converting data...');
totalExp = length(allData);

for e = START_AT%:length(allData)
    load(allData(e).name, 'aveTrace', 'meanSubData', 'finalSampR', 'info', 'indexSeries', 'uniqueSeries')

    
    for i =1:size(aveTrace,1)
        data = squeeze(aveTrace(i,:,:));
        [ zData, latency ] = normalizedThreshold(data, thresh, maxThresh, consistent, endMeasure, before, finalSampR);
        
        maxAbsAmp = max(abs(zData(:, beforeInd:endMeasureInd)), [], 2);
        minAmp = min(zData(:, beforeInd:endMeasureInd), [], 2);
        maxAmp = zeros(size(maxAbsAmp));
        
        for ch = 1:length(minAmp)
            if abs(minAmp(ch)) == maxAbsAmp(ch)
                maxAmp(ch) = minAmp(ch);
            else
                maxAmp(ch) = maxAbsAmp(ch);
            end
        end
        
        for ch = 1:length(maxAbsAmp)
            if maxAbsAmp(ch) < maxThresh
                maxAbsAmp(ch) = NaN;
                maxAmp(ch) = NaN;
            end
        end
        
        
        %     [currentFig, colorMatrix, gridData]=PlotOnECoG(maxAbsAmp, info, 2);
        %
        %     title({['Determining Peak Amplitude (Absolute Value): Experiment ', info.date],
        %         ['Drug Concentration ', num2str(info.AnesLevel), ',  Duration: ' num2str(info.LengthPulse), ',  Intensity: ', num2str(info.IntensityPulse)]})
        %
        %     saveas(currentFig, ['/data/adeeti/ecog/images/061217/maxAbsAmp/HeatExp', num2str(info.exp), 'Int', num2str(info.IntensityPulse), 'Dur' num2str(info.LengthPulse), 'Iso', num2str(info.AnesLevel), '.png'])
        %
        close all
        
        [currentFig, colorMatrix, gridData]=PlotOnECoG(maxAmp, info, 3);
        
        title({['Determining Peak Amplitude: M', num2str(info.exp)],
            [info.AnesType, ', Concentration: ', num2str(info.AnesLevel)]})
        
%         saveas(currentFig, [dirOut, num2str(info.exp), 'Int', num2str(info.IntensityPulse), 'Dur' num2str(info.LengthPulse), 'Iso', num2str(info.AnesLevel), '.png'])
    end
    
%     close all
%     waitbar(e/totalExp)
end

close(loadingWindow)
