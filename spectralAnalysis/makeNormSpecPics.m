%% baselinenorm wavelet spectra

%% Wavelet analysis
% 8/8/18 AA editted for multistim delivery

if USE_SNIPPITS == 1
    SNIPPITS_SIZE = 3001;
else
    SNIPPITS_SIZE = nan;
end

cd(dirIn)
mkdir(dirPic1)

allData = dir(identifier);

screensize=get(groot, 'Screensize');
%%
for experiment = 1:length(allData)
    dirName = allData(experiment).name(1:end-4);
    
    % find what kind and how much of each trials do we have
    
    load(allData(experiment).name, 'meanSubData', 'dataSnippits', 'finalSampR', 'info', 'uniqueSeries', 'indexSeries')
    
    useData = dataSnippits;
    
    if USE_SNIPPITS == 1
        smallSnippits = useData(:,:,1:SNIPPITS_SIZE); %smallSnippits, meanSubData, dataSnippets
        % WAVE=zeros(100, 2001, size(Snippets,1), size(Snippets,2));
        %WAVE=zeros(40, SNIPPITS_SIZE, size(smallSnippits,1), size(smallSnippits,2));
        for i=1:size(smallSnippits,1)
            disp(i);
            %tic
            
            for j = 1:size(smallSnippits,2)
                sig=detrend(squeeze(smallSnippits(i, j,:)));
                % [temp,PERIOD,SCALE,COI,DJ, PARAMOUT, K] = contwt(sig,1/1000,1, 0.1);
                [temp,PERIOD,SCALE,COI,DJ, PARAMOUT, K] = contwt(sig,1/finalSampR,1, 0.25); % EEG data, 1/finalSampR, 1 = pad with zeros, 0.25 = default scale res
                if i ==1 && j ==1
                    WAVE=zeros(length(PERIOD), SNIPPITS_SIZE, size(smallSnippits,1), size(smallSnippits,2));
                end
                WAVE(:,:,i, j)=temp;
                Freq=1./PERIOD;
            end
            
        end
    else
        %WAVE=zeros(40, size(meanSubData,2), size(meanSubData,1));
        for i=1:size(useData,1)
            disp(i);
            %tic
            sig=detrend(squeeze(useData(i,:)));
            % [temp,PERIOD,SCALE,COI,DJ, PARAMOUT, K] = contwt(sig,1/1000,1, 0.1);
            [temp,PERIOD,SCALE,COI,DJ, PARAMOUT, K] = contwt(sig,1/finalSampR,1, 0.25); % EEG data, 1/finalSampR, 1 = pad with zeros, 0.25 = default scale res
            if i ==1
                WAVE=zeros(length(PERIOD), size(useData,2), size(useData,1));
            end
            WAVE(:,:,i)=temp;
            Freq=1./PERIOD;
        end
    end
    
    for i = 1:size(uniqueSeries, 1)
        strStimInd = uniqueSeries(i,:);
        [stimIndexSeriesString] = stimIndex2string4saving(strStimInd, finalSampR);
        
        [indices] = getStimIndices(uniqueSeries(i,:), indexSeries, uniqueSeries);
        useWAVE = WAVE(:,:,:,indices);
        avgWAVE = squeeze(abs(nanmean(useWAVE,4)));
        meanBaseline =  nanmean(avgWAVE(:, 501:1000,:), 2);
        normSpec = 10*log10(avgWAVE./ repmat(meanBaseline, [1, size(avgWAVE,2), 1]));
        
        
        %% plot averages
        close all
        currentFig = figure('Position', screensize); clf
        
        gridIndicies = info.gridIndicies;
        for i = 1:64
            [electrodeX(i), electrodeY(i)] = ind2sub(size(gridIndicies), find(gridIndicies == i));
        end
        
        for ch = 1:size(smallSnippits, 1)
            trueChannel = ch;%info.goodChannels(ch);
            channelIndex = sub2ind([6 11], electrodeY(trueChannel), electrodeX(trueChannel));
            h(ch) = subplot(11,6,channelIndex);
            pcolor(1:size(WAVE,2), Freq, normSpec(:,:, ch)); shading flat;
            %pcolor(1:size(WAVE,2), Freq, avgWAVE(:,:, ch)); shading flat;
            set(gca, 'Yscale', 'Log')
            colorbar
            title(num2str(trueChannel));
        end
        
        vectData = normSpec(:);
        %vectData = avgWAVE(:);
        set(h, 'XTick', [], 'YTick', [1, 10, 50, 100])
        
        suptitle(['Average of spectral data, ', dirName]);
        
        saveas(currentFig, [dirPic1, info.expName(1:end-4), '_', info.TypeOfTrial, stimIndexSeriesString, '_avgSpec.png'])
        close all
    end  
    clear WAVE avgWAVE normSpec meanBaseline
end


