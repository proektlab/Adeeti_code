%% How to link axis for spectra and data plot

%% Multi-taper parameters

win = 1; % size of window (secs) for spectrum
win_step = .1; % size of window step (secs) for spectrum (in this case we are taking 10sec windows, stepping by 1sec)
ktapers = 10;  % number of tapers for mutlitaper analysis
NW = 19;  %

%% Concatonate the data and find spectral data

    data = meanSubData;
    concatData = reshape(permute(data, [1 3 2]), 64, (size(data,2)*3001));
    data = concatData;
    
    sf = finalSampR;
	
	addpath('/home/alex/MatlabCode/Spectra');
    
    %perform spectral analysis on one of the frontal channels 
    
    noiseChannels = info.noiseChannels;
    
    if isempty(find(noiseChannels ==5))
        [out, taper, concentration]=swTFspecAnalog(data(5,:), sf, ktapers, [], win*sf, win_step*sf, NW,[],[],[],[]); %multitaper spectral analysis on the entire length of data 
        myChannel = 5;
        disp('Spectral analysis of channel 5')
    elseif isempty(find(noiseChannels == 17))
        [out, taper, concentration]=swTFspecAnalog(data(17,:), sf, ktapers, [], win*sf, win_step*sf, NW,[],[],[],[]); %multitaper spectral analysis on the entire length of data 
        myChannel = 17;
        disp('Spectral analysis of channel 17')
    elseif isempty(find(noiseChannels == 33))
        [out, taper, concentration]=swTFspecAnalog(data(33,:), sf, ktapers, [], win*sf, win_step*sf, NW,[],[],[],[]); %multitaper spectral analysis on the entire length of data 
        myChannel = 33;
        disp('Spectral analysis of channel 33')
    elseif isempty(find(noiseChannels == 53))
        [out, taper, concentration]=swTFspecAnalog(data(53,:), sf, ktapers, [], win*sf, win_step*sf, NW,[],[],[],[]); %multitaper spectral analysis on the entire length of data 
        myChannel = 53;
        disp('Spectral analysis of channel 53')
%     else
%         randCh = datasample(1:size(data,1), 1);
%         if exist(find(noiseChannels == randCh))
%             continue
%         end
%         [out, taper, concentration]=swTFspecAnalog(data(randCh,:), sf, ktapers, [], win*sf, win_step*sf, NW,[],[],[],[]); %multitaper spectral analysis on the entire length of data - arbitrary middle channel in the grid
%         disp(['Spectral analysis of channel ', num2str(randCh)])
    end
    
    freq=out.freq_grid; %extract freq evaluated
    T=out.time_grid; %extract time windows evaluated
    spectrum=squeeze(out.tfse); % size = 1 x windows x freq; tfse = power at each freq and time point
    

%% Normalize the spectra

    totalPower = sum(spectrum,2);  %add up the power at each freq for every time window ==> time windows x 1
    totalSpectrum = spectrum./repmat(totalPower,1, length(freq));   % normalizing power at each freq by the total power: replicate the total power at all freq and then divide each power at each time window by the total  
    meanSpectrum=mean(10*log10(spectrum),1); %take the mean power for each freq ==> 1 x freq 
    normSpectrum=10*log10(spectrum)-repmat(meanSpectrum, size(spectrum, 1), 1); % deviations from mean spectrum (already normalized to the total power)
    
    addpath('/home/rachel/scripts/pca/');
    
    %lowFreq = find(freq>0.1, 1, 'first');
    %highFreq = find(freq>150, 1, 'first');
    lowFreq = 1;
    highFreq = size(freq, 2);
    freqScale = lowFreq:highFreq;

%% Plotting the data and the multi-taper spectra together

figure
h1=subplot(3,1,1)
plot(data(myChannel,:));
h2=subplot(3,1,[2 3])
pcolor((1:size(normSpectrum, 1))*(win_step*sf), freq(freqScale), normSpectrum(:,freqScale)'); shading 'flat'
set(gca, 'Yscale', 'log')
colorbar
set(gca, 'Clim', [-12 12])
linkaxes([h1 h2], 'x')
