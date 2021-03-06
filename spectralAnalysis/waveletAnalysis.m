%% Wavelet analysis
% 8/8/18 AA editted for multistim delivery

% clear
% close all
% 
% dirIn = '/synology/adeeti/ecog/iso_awake_VEPs/GL_early/';
% dirPic1 = '/synology/adeeti/ecog/images/Iso_Awake_VEPs/GL_early/AverageSpec/';
% %dirPic2 = '/data/adeeti/ecog/images/Iso_Awake_VEPs/singleTrialSpec/';
% dirWAVE = [dirIn, 'Wavelets/'];
% 
% identifier = '2019*.mat';
% 
% USE_SNIPPITS = 1;

if USE_SNIPPITS == 1
    SNIPPITS_SIZE = 3001;
else
    SNIPPITS_SIZE = nan;
end

%addpath(genpath('/home/alex/MatlabCode/alex/Wavelet'));

cd(dirIn)
mkdir(dirWAVE)
if PLOT_AVERAGE_SPEC ==1
mkdir(dirPic1)
%mkdir(dirPic2)
end

allData = dir(identifier);
screensize=get(groot, 'Screensize');

%% Loop through experiments 
for experiment = 1:length(allData)
    dirName = allData(experiment).name(1:end-4);
    
    % find what kind and how much of each trials do we have
    
    load(allData(experiment).name, 'meanSubData', 'dataSnippits', 'finalSampR', 'info', 'uniqueSeries', 'indexSeries')
   
    useData = meanSubData;
    
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
   %% plot averages
   if PLOT_AVERAGE_SPEC ==1
    for i = 1:size(uniqueSeries, 1)
        strStimInd = uniqueSeries(i,:);
        [stimIndexSeriesString] = stimIndex2string4saving(strStimInd, finalSampR);
        
        [indices] = getStimIndices(uniqueSeries(i,:), indexSeries, uniqueSeries);
        useWAVE = WAVE(:,:,:,indices);
        avgWAVE = squeeze(abs(nanmean(useWAVE,4)));
        meanBaseline =  nanmean(avgWAVE(:, 501:1000,:), 2);
        normSpec = 10*log10(avgWAVE./ repmat(meanBaseline, [1, size(avgWAVE,2), 1]));
        
        
       
        close all
        currentFig = figure('Position', screensize); clf
        
        gridIndicies = info.gridIndicies;
        for i = 1:size(smallSnippits, 1)
            [electrodeX(i), electrodeY(i)] = ind2sub(size(gridIndicies), find(gridIndicies == i));
        end
        
        for ch = 1:size(smallSnippits, 1)
            trueChannel = ch;%info.goodChannels(ch);
            channelIndex = sub2ind([size(gridIndicies,2), size(gridIndicies,1)], electrodeY(trueChannel), electrodeX(trueChannel));
            h(ch) = subplot(size(gridIndicies,1),size(gridIndicies,2), channelIndex);
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
    clearvars avgWAVE normSpec meanBaseline
   end
    
    %% saving wavelet
    for i=1:size(WAVE,1)
        genvarname('WAVE',  num2str(i));
        temp1 = ['WAVE',  num2str(i)];
        if USE_SNIPPITS ==1
            eval(['WAVE' num2str(i) '= squeeze(WAVE(i,:,:,:));']);
        else
            eval(['WAVE' num2str(i) '= squeeze(WAVE(i,:,:));']);
        end
        if i ==1
            save([dirWAVE, dirName, 'wave.mat'], temp1)
            eval('clearvars WAVE1')
            disp(['Saving frequency ', num2str(i)])
        else
            save([ dirWAVE, dirName, 'wave.mat'], temp1, '-append')
            eval(['clearvars WAVE' num2str(i)])
            disp(['Saving frequency ', num2str(i)])
        end
    end
    save([ dirWAVE, dirName, 'wave.mat'], 'Freq', 'PERIOD', 'SCALE' ,'COI' ,'DJ', 'PARAMOUT', 'K', 'info', '-append')
    if exist('uniqueSeries')
        save([ dirWAVE, dirName, 'wave.mat'], 'uniqueSeries', 'indexSeries', '-append')
    end
    if exist('smallSnippits') %&& ~isnan(smallSnippits)
        save([dirIn, allData(experiment).name], 'smallSnippits', '-append')
    end
   % toc
end
