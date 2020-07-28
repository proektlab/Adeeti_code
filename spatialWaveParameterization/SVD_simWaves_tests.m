%% Make two waves with noise
% 2 waves with some frequency (temporal & spatial)
% check efficacy as lim(d_freq) --> 0
% randomize other parameters (including wave type)
interpBy = 2;

srate = 1000;
baseFreq = 4; %Hz
secFreq = baseFreq;%+5; %[baseFreq+.1, baseFreq+0.25, baseFreq+0.5, baseFreq+1, baseFreq+2, baseFreq+5, baseFreq+10];

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
    imagesc(squeeze(data1(:,:,t)));
    title(['Time: ' num2str(t) '; Movie Length: ' num2str(5000)]);
    set(gca,'clim', [-2,2])
    colorbar;
    pause(0.001);
end

%%

useData = data1;

concatChanTimeData = reshape(useData, ...
    [size(useData,1)*size(useData,2), size(useData,3)]);
    %concat wave data into chan by time so that we can SVD

%%
useSpace = randsample(size(concatChanTimeData,1), 3, 'false');
useTime = randsample(size(concatChanTimeData,2), 3, 'false');

A = concatChanTimeData(useSpace,useTime);

[Vec,Diag] = eigs(A);
Diag

figure 
imagesc(A)


%%

C = zeros(40, 200);

C(5,:) = 1;

for t = 2:200
    C(5,t) = 2*C(5,t-1);
end


figure
imagesc(C)

[U, S, V] = svd(C);
S(1:4,1:4)

%%

C  = zeros(11,6,200);

C(3,:,:) = 1;
for t = 2:200
    C(3,:,t) = 2*C(3,:,t-1);
end

figure
for t=1:200
imagesc(squeeze(C(:,:,t)))
title(['t = ', num2str(t)])
colorbar
pause(0.1)
end

interpBy = 1;
useData = permute(C, [3,1,2]);

[concatChanTimeData, interpGridInd, interpNoiseInd, interpNoiseGrid] = ...
    makeInterpGridInd(useData, interpBy, info);









