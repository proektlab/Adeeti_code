
meanSubData = permute(filtSig35, [2, 3, 1]);



%%

concatTrials = [];

%allChan = [1:64];
%allChan(info.noiseChannels) = [];
allChan = info.lowLat;

timeEP = [1030:1500];
useEP = permute(meanSubData(allChan,:,timeEP), [1,3,2]);

concatTrials = reshape(useEP, [size(useEP,2), size(useEP,1)*size(useEP,3)])';

figure
imagesc(concatTrials)

corrMatrix = corr(concatTrials');
covarianceMatrix = concatTrials * concatTrials';
stdTrials = sqrt(sum(concatTrials.^2,2));
corrMatrix = covarianceMatrix ./ (stdTrials * stdTrials');

figure
imagesc(corrMatrix)

%%

distances = 1 - corrMatrix;
distances = (distances + distances') / 2;
distances(logical(eye(size(distances)))) = 0;

% distances = 1 - kron(eye(4), ones(10));
% randOrder = randsample(size(distances,1), size(distances,1));
% distances = distances(randOrder, randOrder);

tree = linkage(squareform(distances));


indexOrder = optimalleaforder(tree, distances);

figure
imagesc(1 - distances(indexOrder,indexOrder))


%% Baseline

concatTrials = [];

allChan = [1:64];
allChan(info.noiseChannels) = [];
%allChan = info.lowLat;

timeEP = [1:300];
useEP = permute(meanSubData(allChan,:,timeEP), [1,3,2]);

concatTrials = reshape(useEP, [size(useEP,1), size(useEP,2)*size(useEP,3)]);

figure
imagesc(concatTrials)




[U, S, V] = svd(concatTrials);

figure(2);
clf;
plot(cumsum(diag(S)/sum(S(:))*100))

inputData = zeros(1,64);
inputData(allChan) = U(:,4);

[currentFig, colorMatrix, gridData] = PlotOnECoG(inputData, info, 1)


%% flash


concatTrials = [];

allChan = [1:64];
allChan(info.noiseChannels) = [];
%allChan = info.lowLat;

timeEP = [1030:1300];
useEP = permute(meanSubData(allChan,:,timeEP), [1,3,2]);

concatTrials = reshape(useEP, [size(useEP,1), size(useEP,2)*size(useEP,3)]);

figure
imagesc(concatTrials)

colrs = lines(8)


[U2, S2, V2] = svd(concatTrials);

figure(1);
clf;
plot(cumsum(diag(S2)/sum(S2(:))*100))

inputData = zeros(1,64);
inputData(allChan) = U2(:,4);

[currentFig, colorMatrix, gridData] = PlotOnECoG(inputData, info, 1)



% corrMatrix = corr(concatTrials');
% covarianceMatrix = concatTrials * concatTrials';
% stdTrials = sqrt(sum(concatTrials.^2,2));
% corrMatrix = covarianceMatrix ./ (stdTrials * stdTrials');
% 
% figure
% imagesc(corrMatrix)

%%

[X, Y] = meshgrid([1:10]);

mode = sin(X/10*2*pi);

figure
subplot(2,2,1)
imagesc(mode)

vectoizedMode = mode(:);
time = 1:200;
amplitude = sin(time/100*4*2*pi);
timeSeries = vectoizedMode * amplitude;
subplot(2,2,1)
imagesc(timeSeries)

[U2, S2, V2] = svd(timeSeries);

imagesc(reshape(U2(:,1), [10 10]));
clf
plot(V2(:,1))


