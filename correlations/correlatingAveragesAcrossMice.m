%% Quick look to see if all animal's average traces have differences 
allData = dir('2017*.mat')

allV1Averages = [];

[allV1] = V1forEachMouse(pwd);

for i = 1:length(allData)
    load(allData(i).name, 'info', 'aveTrace')
    V1 = allV1(2,(find(allV1(1,:)== info.exp)));
    allV1Averages(i,:) = aveTrace(V1, :);
    allExp(i) = info.exp;
end

timeFrame = 1000:2000;

useAverages = allV1Averages(:, timeFrame);

corr = pdist2(useAverages,useAverages, 'correlation');


figure
subplot(4,1,1)
plot(allExp)
set(gca, 'Xlim', [1 113]);
subplot(4,1,[2 4])
imagesc(1-corr)
set(gca, 'Clim', [0 1])

%% 

win = 1; % size of window (secs) for spectrum
win_step = .1; % size of window step (secs) for spectrum (in this case we are taking 10sec windows, stepping by 1sec)
ktapers = 10;  % number of tapers for mutlitaper analysis
NW = 19;  %

for i = 1:length(allData)
    load(allData(i).name, 'info', 'meanSubData')

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
        
        
        