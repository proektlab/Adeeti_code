%% Figure for human EEG - 128 Channels 

load('AndrewTNI1118eyesopen_20161117_114108.mat')

concatData = AndrewTNI1118Set3_20161117_121334mff;

data = detrend(concatData);
sf = EEGSamplingRate;

% freq between 1 and 40 hz

	high_cutoff = 1;
    low_cutoff = 60;
	[b,a] = butter(4,[high_cutoff, low_cutoff]/(sf/2),'bandpass');
	for i = 1:size(data,1)
		data(i,:) = filtfilt(b,a,double(data(i,:)));
	end

eegplot(data, 'srate', EEGSamplingRate)