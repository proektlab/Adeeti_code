
dirIn = '/Users/adeetiaggarwal/Dropbox/KelzLab/ecog_MachineLearning/';

cd(dirIn)

load('subject1.mat')

totalDataPoints = 10000;
dataSize = 50;

deicmateAmount = 10;
plotAmount = 10000;

gloveReduced = [];
ecogReduced = [];
for i = 1:size(ecog,2)
    ecogReduced(:,i) = decimate(ecog(:,i), deicmateAmount);
end

for i = 1:size(dataglove,2)
    gloveReduced(:,i) = dataglove(1:deicmateAmount:end,i);
end

% [pcaBasis, ecogPCA] = pca(ecogReduced, 'NumComponents', 10);
% ecogPCA = ecogPCA(:,3:end);

ecogPCA = ecogReduced;


figure(1);
clf;
hold on;
plot((1:deicmateAmount:plotAmount) + deicmateAmount, ecogPCA(1:plotAmount/deicmateAmount, 1));
plot(1:plotAmount, ecog(1:plotAmount, 1));

figure(2);
clf;
hold on;
plot((1:deicmateAmount:plotAmount) + deicmateAmount, gloveReduced(1:plotAmount/deicmateAmount, 2));
plot(1:plotAmount, dataglove(1:plotAmount, 2));

%%

waveletData = [];
waitHandle = parfor_progressbar(size(ecogPCA,2), 'Calculating wavelets');
for j = 1:size(ecogPCA,2)
%     sig=detrend(squeeze(smallSnippits(i, j,:)));
    % [temp,PERIOD,SCALE,COI,DJ, PARAMOUT, K] = contwt(sig,1/1000,1, 0.1);
    [temp,PERIOD,SCALE,COI,DJ, PARAMOUT, K] = contwt(ecogPCA(:,j),1/1000*deicmateAmount,1, 0.25); % EEG data, 1/finalSampR, 1 = pad with zeros, 0.25 = default scale res

    waveletData(:,:,j) = temp;
    
    waitHandle.iterate(1);
end
close(waitHandle);
Freq=1./PERIOD;

waveletData = abs(waveletData(find(Freq > 0.05), :, :));

%%

USE_WAVELET = 1;

XData = [];
YData = [];
% randomPoints = randsample(dataSize+1:size(waveletData,2), totalDataPoints);
randomPoints = dataSize+1:size(waveletData,2);
waitHandle = parfor_progressbar(length(randomPoints), 'Building data');
for i = 1:length(randomPoints)
    if USE_WAVELET
        XData(:,:,:,i) = waveletData(:, randomPoints(i) - dataSize + 1:randomPoints(i),:);
    else
        XData(:,:,:,i) = ecogPCA(randomPoints(i) - dataSize + 1:randomPoints(i),:);
    end
    YData(i,:) = gloveReduced(randomPoints(i),:);
    
    waitHandle.iterate(1);
end
close(waitHandle);

VALIDATION_AMOUNT = 0.3;
validationCount = floor(VALIDATION_AMOUNT * size(XData, 4));
trainIndices = 1:size(XData, 4) - validationCount;
validationIndices = length(trainIndices)+1:size(XData, 4);

trainIndicesPermuted = randsample(trainIndices, length(trainIndices));
validationIndicesPermuted = randsample(validationIndices, length(validationIndices));


% permutation = randsample(1:size(XData,4), size(XData,4));
% 
% XData = XData(:,:,:,permutation);
% YData = YData(permutation,:);

XTrain = XData(:,:,:,trainIndicesPermuted);
YTrain = YData(trainIndicesPermuted,:);
XValidate = XData(:,:,:,validationIndicesPermuted(1:1000));
YValidate = YData(validationIndicesPermuted(1:1000),:);

% XData = [];
% YData = [];
% randomPoints = randsample(dataSize+1:size(gloveReduced,1), totalDataPoints);
% for i = 1:totalDataPoints
%     XData(:,:,1,i) = ecogPCA(randomPoints(i) - dataSize + 1:randomPoints(i),:);
%     YData(i,:) = gloveReduced(randomPoints(i),:);
% end

%%

layers = [
    imageInputLayer([size(XData,1) size(XData,2) size(XData,3)])

%     dropoutLayer(0.2)
    
%     averagePooling2dLayer([10 5],'Stride',5)
    
%     dropoutLayer(0.2)
    
%     dropoutLayer(0.5)
%     
%     convolution2dLayer(5,8,'Padding','same')
%     batchNormalizationLayer
%     reluLayer
%     
%     maxPooling2dLayer(2,'Stride',2)
%     
%     dropoutLayer(0.5)
%     
%     convolution2dLayer(5,16,'Padding','same')
%     batchNormalizationLayer
%     reluLayer
%     
%     maxPooling2dLayer(2,'Stride',2)
%     
%     dropoutLayer(0.5)
%     
%     convolution2dLayer(5,32,'Padding','same')
%     batchNormalizationLayer
%     reluLayer
%     
%     maxPooling2dLayer(2,'Stride',2)
%     
% %     dropoutLayer(0.2)
%     
%     convolution2dLayer(8,16,'Padding','same')
%     batchNormalizationLayer
%     reluLayer
%     
%     averagePooling2dLayer(2,'Stride',2)
%     
%     dropoutLayer(0.2)
%     
%     convolution2dLayer(4,32,'Padding','same')
%     batchNormalizationLayer
%     reluLayer
%     
%     averagePooling2dLayer(2,'Stride',2)
% 
%     convolution2dLayer([24 5],16,'Padding','same')
%     batchNormalizationLayer
%     reluLayer
%     
%     averagePooling2dLayer([2 1],'Stride',2)
%   
%     convolution2dLayer([12 1],32,'Padding','same')
%     batchNormalizationLayer
%     reluLayer
    
    fullyConnectedLayer(2048)
    reluLayer

    fullyConnectedLayer(1024)
    reluLayer
    
    fullyConnectedLayer(512)
%     batchNormalizationLayer
    reluLayer
    
%     dropoutLayer(0.5)
    
    fullyConnectedLayer(256)
%     batchNormalizationLayer
    reluLayer
    
%     dropoutLayer(0.5)
    
    fullyConnectedLayer(128)
%     batchNormalizationLayer
    reluLayer
    
%     dropoutLayer(0.5)
    
    fullyConnectedLayer(64)
%     batchNormalizationLayer
    reluLayer
    
%     dropoutLayer(0.5)
%     
%     fullyConnectedLayer(10)
%     batchNormalizationLayer
%     reluLayer
    
%     dropoutLayer(0.2)
%     
%     fullyConnectedLayer(10)
%     batchNormalizationLayer
%     reluLayer
    
%     dropoutLayer(0.2)
%     
%     fullyConnectedLayer(10)
%     batchNormalizationLayer
%     reluLayer
%     
%     dropoutLayer(0.2)
%     
%     fullyConnectedLayer(5)
%     batchNormalizationLayer
%     reluLayer
%     fullyConnectedLayer(5)
%     batchNormalizationLayer
%     reluLayer
%     fullyConnectedLayer(5)
%     batchNormalizationLayer
%     reluLayer
%     

%     fullyConnectedLayer(40)
%     batchNormalizationLayer
%     leakyReluLayer
%     
%     dropoutLayer(0.2)
% 
%     fullyConnectedLayer(20)
%     batchNormalizationLayer
%     leakyReluLayer
%     
%     dropoutLayer(0.2)

%     fullyConnectedLayer(10)
%     batchNormalizationLayer
%     leakyReluLayer
    
    dropoutLayer(0.5)
    fullyConnectedLayer(size(YValidate,2))
    regressionLayer];




miniBatchSize = 512;
validationFrequency = floor(size(XTrain,4) / miniBatchSize);
options = trainingOptions('adam', ...
    'MiniBatchSize',miniBatchSize, ...
    'MaxEpochs',5000, ...
    'InitialLearnRate',1e-3, ...
    'LearnRateSchedule','piecewise', ...
    'LearnRateDropFactor',0.1, ...
    'LearnRateDropPeriod',20, ...
    'Shuffle','every-epoch', ...
    'ValidationData',{XValidate,YValidate}, ...
    'ValidationFrequency',validationFrequency, ...
    'Plots','training-progress', ...
    'Verbose',true, ...
    'L2Regularization', 1.0000e-01, ...
    'ExecutionEnvironment', 'cpu', ...
    'ValidationPatience', Inf);


net = trainNetwork(XTrain,YTrain,layers,options);

%%

predictions = [];
testPoints = min(validationIndices):10:max(validationIndices);
predictions = predict(net, XData(:,:,:,testPoints));

%%

if USE_WAVELET
    plotPoints = testPoints+size(XData,2);
else
    plotPoints = testPoints;
end
% plotPoints(plotPoints > size(gloveReduced,1)) = [];

fingerIndex = 1;
figure(3);
clf;
hold on;
plot(gloveReduced(plotPoints, fingerIndex));
plot(predictions(:,fingerIndex));

correlations = [];
for i = 1:size(gloveReduced,2)
    correlations(i) = corr(predictions(:,i), gloveReduced(plotPoints, i));
end
correlations


