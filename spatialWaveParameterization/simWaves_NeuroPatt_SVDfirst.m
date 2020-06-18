%% Make two waves with noise
% 2 waves with some frequency (temporal & spatial)
% check efficacy as lim(d_freq) --> 0
% randomize other parameters (including wave type)
interpBy = 2;

srate = 1000;
baseFreq = 4; %Hz
secFreq = baseFreq+5;%+5; %[baseFreq+.1, baseFreq+0.25, baseFreq+0.5, baseFreq+1, baseFreq+2, baseFreq+5, baseFreq+10];

% define constants for wavelet
freq = 1:0.1:80;
windows = 20;
c = windows*pi;

% make 2 waves
wave_array = struct();
for i=1:2
    wave_array(i).timesteps = [1:5000]; %in s
end
wave_array(1).y_center = ones(1,5000);
wave_array(1).x_center = ones(1,5000);
wave_array(1).type = 'plane';
wave_array(1).theta = ones(1,5000).*pi;
wave_array(1).temp_freq = ones(1,5000).*baseFreq;
wave_array(1).spatial_freq = ones(1,5000)*2;
wave_array(1).amplitude = ones(1,5000);

wave_array(2).y_center = ones(1,5000)*2;
wave_array(2).x_center = ones(1,5000)*1;
wave_array(2).type = 'rotational'; %'rotational';
wave_array(2).theta = ones(1,5000).*(0.25*pi);
wave_array(2).temp_freq = ones(1,5000).*secFreq;
wave_array(2).spatial_freq = ones(1,5000)*3;
wave_array(2).amplitude = ones(1,5000)*1;

x = 0:0.5/interpBy:5; %21 electrodes
y = 0:0.5/interpBy:5; %21 electrodes
[X, Y] = meshgrid(x, y);
times = (1:5000).*(1/srate);

data1 = populate_wave(wave_array(1), X, Y, times);
data2 = populate_wave(wave_array(2), X, Y, times);
combined_data = data1 + data2;
combined_data_rand = combined_data + normrnd(0,.3,size(data1));

figure
for t = 1:100
    imagesc(squeeze(combined_data(:,:,t)));
    title(['Time: ' num2str(t) '; Movie Length: ' num2str(5000)]);
    set(gca,'clim', [-2,2])
    colorbar;
    pause(0.001);
end


%% looking at SVD of the sim waves
useData = combined_data;

concatChanTimeData = reshape(useData, ...
    [size(useData,1)*size(useData,2), size(useData,3)]); ...
    %concat wave data into chan by time so that we can SVD

x = 1:size(concatChanTimeData,1);
interpGridInd = reshape(x, [size(useData,1),size(useData,2)]);

rearrange2Gr =1;
N = 5;
badChan = [];
numChan = size(concatChanTimeData, 1);

[SVDout, SpatialAmp, SpatialPhase, TemporalAmp, TemporalPhase,GridOut ] = ...
    WaveSVD(concatChanTimeData, N, rearrange2Gr, interpGridInd, badChan, numChan);

U = SVDout.U;
S = SVDout.S;
V = SVDout.V;
allEPSpAmp = GridOut.SpatialAmp(:,:,1:3);

% looking at spatial modes
figure
for m = 1:3
    subplot(1, 3, m)
    imagesc(squeeze(allEPSpAmp(:,:,m)))
    title(['Mode ', num2str(m)])
end
sgtitle(['Spatial Modes '])

%% reconstructing modes
reconModes = [];
reconModeGrid = [];

for m = 1:3
    useS = S;
    if m ==1
        useS(:,m+1:end) = 0;
    else
        notMode = [1:m-1, m+1:size(S,2)];
        useS(:,notMode) = 0;
    end
    
    reconstData = U*useS*V';
    [tempRec] = hilbert2filtsig(reconstData);
    reconModes(m,:,:) = tempRec;
    
    [tempGrid] = plotOnECoG_interpCon(tempRec, interpGridInd);
    reconModeGrid(m,:,:,:) = tempGrid;
end

%% looking at recon modes
figure
for i = 1:size(reconModeGrid,4)
    for m = 1:size(reconModeGrid,1)
        subplot(1, size(reconModeGrid,1), m)
        imagesc(squeeze(reconModeGrid(m,:,:,i)))
        set(gca, 'clim', [min(min(min(reconModeGrid(m,:,:,:)))), max(max(max(reconModeGrid(m,:,:,:))))])
        colorbar
        title(['Mode ', num2str(m)])
    end
    sgtitle(['Time t = :', num2str(i)])
    pause(0.01)
end


%% Testing neuropattern toolbox
m = 1;
useGridData = squeeze(reconModeGrid(m,:,:,:));
NueropattGUI(useGridData, srate)


