% 
% bandPassFilter = designfilt('bandpassiir','FilterOrder',20, ...
%     'HalfPowerFrequency1',10,'HalfPowerFrequency2',14, ...
%     'SampleRate',1000);
% 
% [b,a] = butter(6,[10 14]/500);
% 
% % filteredData = filter(bandPassFilter, squeeze(MeanSUbtracted(12,:,:)));
% filteredData = filtfilt(b, a, squeeze(MeanSUbtracted(12,:,:)));
% 
% figure(1);
% clf;
% hold on
% plot(squeeze(MeanSUbtracted(12,:,:))');
% plot(filteredData(1:10,:)');


[b, a]=butter(6, 20/500, 'low');
[c, d]=butter(6, 20/500, 'high');

figure(1);
clf;
plot((filtfilt(b,a, squeeze(MeanSUbtracted(12,1,:)))))
hold on
plot((filtfilt(c,d, squeeze(MeanSUbtracted(12,1,:)))))

%%
params.Fs=1000;
params.tapers=[5 9];
params.trialave=1;
[S,f]=mtspectrumc(MeanSUbtracted(12,1,:),params);
figure
plot(f,10*log10(S))

%%

channel = 12;
trials = 1:size(MeanSUbtracted,2);
% trials = randsample(1:size(MeanSUbtracted,2), 10, 'false');
time = 1:800;

[~,~,frequencies] = wcoherence(MeanSUbtracted(channel, trials(1), time), MeanSUbtracted(channel, trials(1), time), 1000);

coherenceMatrix = zeros(length(trials), length(trials), length(frequencies), length(time));

for i = 1:length(trials)    
    coherenceRow = zeros(length(trials), length(frequencies), length(time)); %Hack to reduce memory usage
    
    parfor j = 1:length(trials)
        
        coherenceRow(j,:,:) = wcoherence(MeanSUbtracted(channel, trials(i), time), MeanSUbtracted(channel, trials(j), time));
        
    end
    
    coherenceMatrix(i,:,:,:) = coherenceRow;
    
    disp(i);
end

globalCoherenceMatrix = zeros(length(frequencies), length(time));
for t = 1:length(time)
    parfor f = 1:size(coherenceMatrix,3)
        eigenValues = eigs(coherenceMatrix(:,:,f,t), 1);
        
        globalCoherenceMatrix(f,t) = eigenValues / trace(coherenceMatrix(:,:,f,t));
    end
    disp(t);
end

figure(1);
clf;
imagesc(time, 1:length(frequencies), globalCoherenceMatrix);
yticks = get(gca,'YTick');
yticklabels(frequencies(yticks))
xlabel('Time (ms)');
ylabel('Frequency (Hz)');
