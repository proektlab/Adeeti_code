%% To find the lagged crosscor with averages
before = 0;%time in seconds (neg for time before flash and positive for time after flash)
after = 1; %time in seconds
MAX_LAG = 250; %time in milliseconds 

if before <0
    before = finalSampR*abs(before);
elseif before == 0
    before = 1000;
else
    before = 1000 + (finalSampR*before);
end

after = 1000 + (finalSampR*after);
window = before:after;

[adjVector] = findAdjacentChan(aveTrace);

avgLagVector = nan(size(adjVector));

for ch =1:size(adjVector,1)
    for col = 1:size(adjVector,2)
        if isnan(adjVector(ch, col))
           continue
        end
        
        [r, lags] = xcorr(aveTrace(ch,window), aveTrace(adjVector(ch, col),window), MAX_LAG, 'coeff');
        [~, maxIndex] = max(r);
        maxLag = lags(maxIndex);
        if abs(maxLag) == MAX_LAG
            maxLag = NaN;
        end
        avgLagVector(ch, col) = maxLag;
    end
end

%% Finding pairwise crosscor with single trials then averaging

before = 0;%time in seconds (neg for time before flash and positive for time after flash)
after = 1; %time in seconds
MAX_LAG = 250; %time in milliseconds 

if before <0
    before = finalSampR*abs(before);
elseif before == 0
    before = 1000;
else
    before = 1000 + (finalSampR*before);
end

after = 1000 + (finalSampR*after);
window = before:after;

[adjVector] = findAdjacentChan(aveTrace);

lagVector = nan(size(adjVector,1), size(adjVector,2), size(meanSubData,2));

for ch =1:size(adjVector,1)
    for col = 1:size(adjVector,2)
        maxLagVect = [];
        if isnan(adjVector(ch, col))
            continue
        end
        
        for tr = 1:size(meanSubData, 2)
            
            [r, lags] = xcorr(squeeze(meanSubData(ch, tr, window)), squeeze(meanSubData(adjVector(ch, col), tr, window)), MAX_LAG, 'coeff');
            [~, maxIndex] = max(r);
            trialMaxLag = lags(maxIndex);
            if abs(trialMaxLag) == MAX_LAG
                trialMaxLag = NaN;
            end
            lagVector(ch, col, tr) = trialMaxLag;
        end
    end
end

%% Stats on local connections 

chanMeans = nanmean(lagVector, 3);
chanSTD = nanstd(lagVector,[], 3);    

%% Finding Anisotropy


