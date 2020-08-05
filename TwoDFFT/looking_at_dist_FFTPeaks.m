%% findning number and distribution of peaks

%plotTime for movies = [50:300]

load('gaborCoh2018-07-07_16-28-49.mat')
%% making histograms of all heights 

prestimTimePoints = [1:30];

poststimTimePoints = [60:301];

prestimHeightDist = [];
poststimHeightDist = [];

for i = 1:length(prestimTimePoints)
    prestimHeightDist = [prestimHeightDist, allheights{prestimTimePoints(i)}];
end

for i = 1:length(poststimTimePoints)
    poststimHeightDist = [poststimHeightDist, allheights{poststimTimePoints(i)}];
end

figure
histogram(log(prestimHeightDist), 100)
hold on
histogram(log(poststimHeightDist), 100)


figure
subplot(2,1,1)
for i = 1:20
    plot(allheights{i})
    hold on
end
title('Prestim')
subplot(2,1,2)
for i = 80:100
    plot(allheights{i})
    hold on
end
title('Poststim')


%% lets try normalizng to baseline spec

baselineSpec = allSpec(prestimTimePoints,:,:);

m_base = squeeze(mean(baselineSpec,1));
std_base = squeeze(std(baselineSpec,0,1));

figure
subplot(2,1,1)
imagesc(squeeze(m_base))
title('Mean Baseline')
subplot(2,1,2)
imagesc(squeeze(std_base))
title('STD Baseline')

zheights = {};
for t = 1:length(allheights)
    for h = 1:length(allheights{t})
        zheights{t}(h) = (allheights{t}(h) - m_base(allYs{t}(h), allXs{t}(h)))/std_base(allYs{t}(h), allXs{t}(h));
    end
end


prestimHeightDist = [];
poststimHeightDist = [];

for i = 1:length(prestimTimePoints)
    prestimHeightDist = [prestimHeightDist, zheights{prestimTimePoints(i)}];
end

for i = 1:length(poststimTimePoints)
    poststimHeightDist = [poststimHeightDist, zheights{poststimTimePoints(i)}];
end

figure
histogram(prestimHeightDist, 100)
hold on
histogram(poststimHeightDist,  100)


figure
subplot(2,1,1)
for i = 1:20
    plot(zheights{i})
    hold on
end
title('Prestim')
subplot(2,1,2)
for i = 80:100
    plot(zheights{i})
    hold on
end
title('Poststim')

pre_thresh = 15;
s= pre_thresh*std(prestimHeightDist);


truePeakInd = {};
numpeaks =[];
for t = 1:length(zheights)
    truePeakInd{t} = find(zheights{t} >s);
    numpeaks(t)= numel(truePeakInd{t});
end


figure
plot(numpeaks, 'ok')

figure
for t = 1:length(zheights)
    histogram(zheights{t}, 10)
    title(['Time = ', num2str(t-50)])
    pause(0.5)
end


%% what about using FastPeakFind.m
% seems like we wil need to play with ap
image = squeeze(allSpec(70,:,:));
p=FastPeakFind(image);
figure

imagesc(image); hold on
plot(p(1:2:end),p(2:2:end),'r+')



%% what about smoothing with a 2D gaussian filter 
sigma =[0.5, 0.75, 1];
ff= figure;
ff.Position = [16,54,1902,924];
clear movieOutput

for t = 1:length(allSpec)
    specTest = squeeze(allSpec(t,:,:));
    smoothSpecTest= [];
    for s_ind = 1:length(sigma)
        smoothSpecTest(s_ind,:,:) = imgaussfilt(specTest,sigma(s_ind));
        
        cropTest = squeeze(smoothSpecTest(s_ind,:,:));
        BW = imregionalmax(cropTest');
        [xs, ys] = ind2sub(size(BW), find(BW==1));
        heights = [];
        for i = 1:length(xs)
            heights(i) = cropTest(ys(i), xs(i));
        end
        sig_X{s_ind,t} = xs;
        sig_Y{s_ind,t} = ys;
        sig_heights{s_ind,t} = heights;
    end
    
    
    subplot(1,4,1)
    hold off
    surf(specTest);
    hold on;
    scatter3(allXs{t}, allYs{t}, allheights{t}, 'rx');
    title('Unflitered FFT')
    for s_ind = 1:length(sigma)
        subplot(1,4,s_ind+1)
        hold off
        surf(squeeze(smoothSpecTest(s_ind,:,:)));
        hold on;
        scatter3(sig_X{s_ind,t}, sig_Y{s_ind,t}, sig_heights{s_ind,t}, 'rx');
        title(['Smooth FFT, sigma = ', num2str(sigma(s_ind))])
    end
    sgtitle(['Time = ', num2str(t-50)])
    
    drawnow
    pause(0.15);
    movieOutput(t) = getframe(gcf);
end

v = VideoWriter(['Z:\adeeti\GaborTests', 'testGausFFT_Interp100.avi']);

open(v)
if sum(size(movieOutput(1).cdata) == size(movieOutput(2).cdata)) ==3
    writeVideo(v,movieOutput(2:end))
else
    writeVideo(v,movieOutput)
end
close(v)



cellfun(@(x)numel(x), sig_heights)


%% how does this work with multitaper testing 

taper1=dpss(length(x), 5);                          % define tapers. the second parameter is the degree of smoothing
Spec=zeros(size(M,1),size(M,2), size(taper1,2)); % M is an image
for i=1:size(Spec,3)
   Spec(:,:,i)=fft(taper1(:,i).*fft(taper1(:,i).*M).').';
end
Spec=squeeze(mean(Spec,3));                     % final spectrum is the mean across tapers. Could jacknife across






