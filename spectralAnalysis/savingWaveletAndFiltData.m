%% Saving fake data and wavelet for each experiment
clear

dirIn = '/data/adeeti/ecog/iso_awake_VEPs/';
dirWavelet = '/data/adeeti/ecog/iso_awake_VEPs/Wavelets/';
dirFiltSig = '/data/adeeti/ecog/iso_awake_VEPs/FiltSig/';
identifier = '2019*mat';


USE_SNIPPITS = 1;

if USE_SNIPPITS == 1
    SNIPPITS_SIZE = 3001;
else
    SNIPPITS_SIZE = nan;
end


cd(dirIn);
allData = dir(identifier);

mkdir(dirWavelet);
mkdir(dirFiltSig);

cd(dirIn);

%%
for experiment = 1:length(allData)
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
    
    %% Band of interest
    band = find(Freq>20 & Freq<80);
    
    % band=find(Freq>4 & Freq<150);
    % bandpt5hz= find(Freq>0 & Freq<0.6, 1, 'first');
    % band1hz = find(Freq>.9 & Freq<1.5, 1, 'first');
    % band2hz = find(Freq>2 & Freq<2.5, 1, 'first');
    % band3hz = find(Freq>3 & Freq<3.5, 1, 'first');
    
    % band = [ band band3hz band2hz band1hz bandpt5hz];
    % loadFreq = {};
    
    for i= 1:length(band)
        temp = ['WAVE', num2str(band(i))];
        loadFreq{i} = temp;
    end
    
    %% For saving filtered data 
    
    for i = 1:length(band)
        load(allData(experiment).name, loadFreq{i})
        waveVariables = WAVE(band(i),:,:,:);
        filtWavelet=zeros(size(WAVE));
        filtWavelet(band(i),:,:,:) = waveVariables;
        
        filtTemp = squeeze(invcwt(filtWavelet, 'MORLET', SCALE, PARAMOUT, K)); %filtSingal in timepoints x channels x trials
        eval([['filtSig', num2str(floor(Freq(band(i))))] '= filtTemp;'])
        sigTemp = ['filtSig', num2str(floor(Freq(band(i))))];
        
        disp(['Saving filtered data: ', num2str(experiment), ' out of ', num2str(length(allData)), ' frequency', num2str(floor(Freq(band(i))))])
        if i ==1
            save([dirFiltSig, allData(experiment).name], sigTemp, 'Freq', 'info','uniqueSeries', 'indexSeries')
            clearvars filtSig* 
        else
            save([dirFiltSig, allData(experiment).name], sigTemp, '-append')
            clearvars filtSig*
        end
    end
    

    %% saving wavelet
    
    for i=1:size(WAVE,1)
        genvarname('WAVE',  num2str(i));
        temp = ['WAVE',  num2str(i)];
        eval(['WAVE' num2str(i) '= squeeze(WAVE(i,:,:,:));']);
        if i ==1
            save([dirWavelet, allData(experiment).name(1:end-4), 'wave.mat'], temp)
            eval('clearvars WAVE1')
            disp(['Saving frequency ', num2str(i)])
        else
            save([ dirWavelet, allData(experiment).name(1:end-4), 'wave.mat'], temp, '-append')
            eval(['clearvars WAVE' num2str(i)])
            disp(['Saving frequency ', num2str(i)])
        end
    end
    save([dirWavelet, allData(experiment).name(1:end-4), 'wave.mat'], 'Freq', 'PERIOD', 'SCALE' ,'COI' ,'DJ', 'PARAMOUT', 'K', 'info', 'uniqueSeries', 'indexSeries', '-append')
end
