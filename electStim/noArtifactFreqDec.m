%% Electrical Stim without stim artifact code

dirIn= '/data/adeeti/ecog/mat2018Stim/';

identifier = '2018*mat';

SNIPPITS_SIZE= 2001;

cd(dirIn)

allData = dir(identifier);

for i = 1%:length(allData)
    load(allData(i).name, 'meanSubData', 'finalSampR', 'info')
    
    artifactStart = 999;
    artifcatEnd = 1006;
    
    noArtData = [];    
    noArtDataFilt = [];
    for ch = 1:size(meanSubData, 1)
        linearSpan = [];
        for j = 1:size(meanSubData,2)
            linearSpan(j,:) = linspace(meanSubData(ch,j,artifactStart), meanSubData(ch,j,artifcatEnd), artifcatEnd - artifactStart);
        end
        
        noArtData(ch,:,:) = [squeeze(meanSubData(ch,:,1:artifactStart)) linearSpan squeeze(meanSubData(ch,:,artifcatEnd:end))];
        
        noArtDataFilt(ch,:,:) = filterData(squeeze(noArtData(ch,:,:)),1);
    end
    
    dirName = info.expName;
    
    smallSnippits = noArtDataFilt(:,:,1:SNIPPITS_SIZE); %smallSnippits, meanSubData, dataSnippets
    
    % WAVE=zeros(100, 2001, size(Snippets,1), size(Snippets,2));
    WAVE=zeros(40, SNIPPITS_SIZE, size(smallSnippits,1), size(smallSnippits,2));
    for i=1:size(WAVE,3)
        disp(i);
        for j = 1:size(smallSnippits,2)
            sig=detrend(squeeze(smallSnippits(i, j,:)));
            % [temp,PERIOD,SCALE,COI,DJ, PARAMOUT, K] = contwt(sig,1/1000,1, 0.1);
            [temp,PERIOD,SCALE,COI,DJ, PARAMOUT, K] = contwt(sig,1/finalSampR,1, 0.25); % EEG data, 1/finalSampR, 1 = pad with zeros, 0.25 = default scale res
            WAVE(:,:,i, j)=temp;
            Freq=1./PERIOD;
        end
    end
    %%
    
     %% finding V1 for each experiment based on mode
    [adjVector] = findAdjacentChan(info);
    V1 = info.V1;
    
    %% Parameters for Stats
    totTrialsPerExp = size(noArtDataFilt, 2);
    trialsPerSamp = totTrialsPerExp;
    totSamp = 100;
    
    %% Making fake data flashes onsets (rand time of starts)
    [fakeSnippits] = makeFakeSnippits(noArtDataFilt, smallSnippits);
    
    %% Run wavelet on fake data
    disp('Wavelet on Fake Data')
    fakeWAVE=zeros(40, 2001, size(fakeSnippits,1), size(fakeSnippits,2));
    for i=1:size(fakeWAVE,3)
        disp(i);
        for j = 1:size(fakeSnippits,2)
            sig=detrend(squeeze(fakeSnippits(i, j,:)));
            % [temp,PERIOD,SCALE,COI,DJ, PARAMOUT, K] = contwt(sig,1/1000,1, 0.1);
            [temp,PERIOD,SCALE,COI,DJ, PARAMOUT, K] = contwt(sig,1/1000,1, 0.25);
            fakeWAVE(:,:,i, j)=temp; %WAVE is in freq by time by channels by trials
            Freq=1./PERIOD;
        end
    end
    
    
    %% For intertrial phase coherence
    
    disp('Running ITPC iterations')
    
    myChannels = adjVector(V1,:);
    statsFakeITPC = nan(totSamp, length(myChannels), size(WAVE, 1), size(WAVE, 2));
    statsRealITPC = nan(totSamp, length(myChannels), size(WAVE, 1), size(WAVE, 2));
    
    clear exp
    for i = 1:totSamp
        tic
        trials = randsample(totTrialsPerExp, trialsPerSamp, 'true'); %with replacement
        %     useWAVE = fakeWAVE(:, :, : , trials);
        [ITPCmeasures] = ITPC_AA(fakeWAVE, myChannels, trials);
        statsFakeITPC(i, :, :, :) = ITPCmeasures;
        disp(['Calculating ', num2str(i), ' out of ', num2str(totSamp) ' time taken ' num2str(round(toc*1000)) 'ms'])
    end
    stErrorFakeITPC = squeeze(std(statsFakeITPC, [], 1));
    meanFakeITPC = squeeze(mean(statsFakeITPC, 1));
    
    clear exp
    for i = 1:totSamp
        tic
        trials = randsample(totTrialsPerExp, trialsPerSamp, 'true');
        %     useWAVE = fakeWAVE(:, :, : , trials);
        [ITPCmeasures] = ITPC_AA(WAVE, myChannels, trials);
        statsRealITPC(i, :, :, :) = ITPCmeasures;
        disp(['Calculating ', num2str(i), ' out of ', num2str(totSamp) ' time taken ' num2str(round(toc*1000)) 'ms'])
    end
    trueITPC = ITPC_AA(WAVE);
    stErrorRealITPC = squeeze(std(statsRealITPC, [], 1));
    meanRealITPC = squeeze(mean(statsRealITPC, 1));
    
    %% T test to compare how real data compares with fake data
    % Welch's t test- equal sample size, unequal variances
    screensize=get(groot, 'Screensize');
    tVals = (meanRealITPC- meanFakeITPC)./sqrt((stErrorFakeITPC.^2+stErrorRealITPC.^2));
    pVals = tcdf(tVals,trialsPerSamp-1);
    
    use_p_value = 1; % 1 for p value, 0 for t Value, any other number for true ITPC
    currentFig = figure('Position', screensize); clf;
    
    for ch = 1:length(myChannels)
        channel = myChannels(ch);
        if isnan(channel)
            continue
        end
        
        % plot results- average trace on top and p values of ITPC on the
        % bottom
        h1= subplot(6,3,floor((ch-1)/3)*6 + mod(ch-1,3) + 1)
        plot(squeeze(nanmean(smallSnippits(channel,:,:),2)));
        title(['Average trace channel ', num2str(channel)])
        colorbar
        
        h2= subplot(6, 3, floor((ch-1)/3)*6 + mod(ch-1,3)+4)
        if use_p_value == 1;
            pcolor(1:size(smallSnippits,3), Freq, log10(squeeze(1-squeeze(pVals(ch,:,:))))); shading 'flat';
            set(gca, 'yscale', 'log')
            colorbar
            title(['P-Value ITPC channel ', num2str(channel)])
            set(gca,'clim',[-8 0])
        elseif use_p_value == 0;
            pcolor(1:size(smallSnippits,3), Freq, squeeze(tVals(ch,:,:))); shading 'flat';
            set(gca, 'yscale', 'log')
            colorbar
            title(['t-Value ITPC channel ', num2str(channel)])
        else
            pcolor(1:size(smallSnippits,3), Freq, squeeze(trueITPC(channels,:,:))); shading 'flat';
            set(gca, 'yscale', 'log')
            colorbar
            title(['True ITPC channel ', num2str(channel)])
        end
        
        linkaxes([h1 h2], 'x')
        set(gca, 'xlim', [0, 2001])
    end
    
    suptitle(['ITPC for channels around V1 of ', strrep(info.expName, '_', '\_'), ' iso ', num2str(info.AnesLevel)])
    
    %%
    freqInd = 16;
    waveVariables = WAVE(freqInd, :, :, :);
    filtWavelet=zeros(size(WAVE));
    filtWavelet(freqInd,:,:,:) = waveVariables;
    
    
    filtSig = squeeze(invcwt(filtWavelet, 'MORLET', SCALE, PARAMOUT, K)); %filtSingal in timepoints x channels x trials
    
    
end

