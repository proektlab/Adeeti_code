%% Saving fake data and wavelet for each experiment
clear

dirIn = '/data/adeeti/ecog/mat_OpenEphys_WhiskerTesting/';
dirOut = '/data/adeeti/ecog/matFlashesJanMar2017/Wavelets/';
identifier = '2017*mat';

cd(dirIn);
allData = dir(identifier);

mkdir(dirOut);

cd(dirIn);
%%
for experiment = 1:length(allData)
    load(allData(experiment).name, 'info', 'smallSnippits', 'meanSubData', 'finalSampR', 'uniqueSeries', 'indexSeries')
    
    %% Run wavelet on real data
    disp('Wavelet on Real Data')
    WAVE=zeros(40, 2001, size(smallSnippits,1), size(smallSnippits,2));
    for i=1:size(WAVE,3)
        disp(i);
        for j = 1:size(smallSnippits,2)
            sig=detrend(squeeze(smallSnippits(i, j,:)));
            % [temp,PERIOD,SCALE,COI,DJ, PARAMOUT, K] = contwt(sig,1/1000,1, 0.1);
            [temp,PERIOD,SCALE,COI,DJ, PARAMOUT, K] = contwt(sig, 1/finalSampR, 1, 0.25);
            WAVE(:,:,i, j)=temp; %WAVE is in freq by time by channels by trials
            Freq=1./PERIOD;
        end
    end
    
    %% saving wavelet
    
   for i=1:size(WAVE,1)
        genvarname('WAVE',  num2str(i));
        temp = ['WAVE',  num2str(i)];
        eval(['WAVE' num2str(i) '= squeeze(WAVE(i,:,:,:));']);
        if i ==1
        save([ '/data/adeeti/ecog/matFlashesJanMar2017/Wavelets/', allData(experiment).name(1:end-4), 'wave.mat'], temp)  
        eval('clearvars WAVE1')
        disp(['Saving frequency ', num2str(i)])
        else
        save([ '/data/adeeti/ecog/matFlashesJanMar2017/Wavelets/', allData(experiment).name(1:end-4), 'wave.mat'], temp, '-append') 
        eval(['clearvars WAVE' num2str(i)])
        disp(['Saving frequency ', num2str(i)])
        end
    end
    save([dirOut, allData(experiment).name(1:end-4), 'wave.mat'], 'Freq', 'PERIOD', 'SCALE' ,'COI' ,'DJ', 'PARAMOUT', 'K', 'info', 'uniqueSeries', 'indexSeries', '-append')
end
