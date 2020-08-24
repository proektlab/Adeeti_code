%% Parameterizing the wave using SVD

%% averages for all stimuli for single mouse concatonated

expID = 7;

y = find([dataMatrixFlashes.exp] ==  expID);

x = [];
allNoise = [];

identifier = '2017*';
allData = dir(identifier);

for i = 1:length(y)
    load(allData(y(i)).name, 'info', 'filtSig35');
    meanSig = squeeze(nanmean(filtSig35, 3));
    x = [x, meanSig'];
    allNoise = [allNoise; info.noiseChannels];
end

a= unique(allNoise);

allAverages = x;
allAverages(a,:)= [];

[modes, eigenValues, timeSeries]= svd(allAverages);

plot(diag(eigenValues))

allDataChannels = 1:64;
allDataChannels(a) = [];

allModes = nan(64, size(modes,1));
allModes(allDataChannels,:) = modes;

figure(1)
for i =1:6
    h(i) = subplot(2,3,i);
    [ ~, colorMatrix, gridData] = PlotOnECoG(allModes(:,i), info, 3, 1);
    imagesc(gridData);
    colormap(jet(256));
    caxis([quantile(modes(:), 0.05), quantile(modes(:), 0.95)]);
    title(['MODE: ', num2str(i)])
end


%%

useModes = 1:2;

reducedModel = modes(:,useModes)*eigenValues(useModes,:)*timeSeries';

channel15 = find(allDataChannels == 15);

figure(2)
clf;
plot(reducedModel(channel15,:));
hold on;
plot(allAverages(channel15,:));

%%
timeData = eigenValues*timeSeries';

figure(3)
clf;
plot(timeData(useModes,:)');

%%

[ ~, colorMatrix, gridData] = PlotOnECoG(allModes(:,2)-allModes(:,4), info, 3);

%%


%% single trial

allReducedData= nan(64, size(reducedModel,2));
allReducedData(allDataChannels,:) = reducedModel;

allReducedData = reshape(allReducedData, [64, size(filtSig35,1), size(allAverages,2)/size(filtSig35,1)]);
allReducedData = permute(allReducedData, [1, 3, 2]);

plotMovieData = allReducedData;

% allAveragesWithTrials= nan(64, size(allAverages,2));
% allAveragesWithTrials(allDataChannels,:) = allAverages;
%
% allAveragesWithTrials = reshape(allAveragesWithTrials, [64, 3001, size(allAverages,2)/3001]);
% allAveragesWithTrials = permute(allAveragesWithTrials, [1, 3, 2]);
%
% plotMovieData = allAveragesWithTrials;

start = 950;
finish = 1500;
trial = 15;
counter = 1;
clear movieOutput;
figure
clf
f = gcf;
f.Position = [834 1 795 973];

g = gca;
xGridAxis = fliplr(linspace(0, 2.75, 10+1));
yGridAxis = linspace(0, 5, 20+1);
lowerCax = quantile(plotMovieData(:), 0.001);
upperCax = quantile(plotMovieData(:), 0.999);

for t = start:finish
    plotOnGridInterp(plotMovieData(:,trial, t), 1, info);
    caxis([lowerCax,upperCax]);
    g.XTickMode = 'Manual';
    g.YTickMode = 'Manual';
    g.YTick = linspace(1,1100, 20+1);
    g.XTick = linspace(1,600, 10+1);
    g.XTickLabel = xGridAxis;
    g.YTickLabel = yGridAxis;
    colorbar
    c = colorbar;
    c.Label.String = 'Voltage in uV';
    title(['Time: ', num2str(t-1000), ' msec'])
    ylabel('Ant-Post Distance in mm')
    xlabel('Med-Lat Distance in mm')
    drawnow
    movieOutput(counter) = getframe(gcf);
    counter = counter +1;
    
end

v = VideoWriter(['randomMovie2.avi']);
open(v)
writeVideo(v,movieOutput)
close(v)

%%



