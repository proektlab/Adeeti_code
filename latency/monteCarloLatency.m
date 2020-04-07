%bootChan = jackknife(@statsLatencyFucn, testChan);
% taking just one trial out was not enough for differentiation - good
% becuse that means that there is not that much bias in the data --> worked
% on resampling with excluding more data

%%

load('dataMatrixFlashes.mat')
[myFavoriteExp] = findMyExp(dataMatrixFlashes, 8, [], 10, 10);

while length(myFavoriteExp) >3
    myFavoriteExp(1) = [];
end

fakeArray = [];
means = [];
stds = [];
% myFavoriteExp = [92 92];pM

for e = 1:length(myFavoriteExp)
    load(dataMatrixFlashes(myFavoriteExp(e)).name)
    
    V1Ch = info.V1;
    
    testChan = squeeze(meanSubData(V1Ch,:,:));
    
 
    %% Resampling
    statsLatencyArray = [];
    NUMSAMP = 100;
    NUMTRIAL = 1000;
    
    for i = 1:NUMTRIAL
        trials = randsample(size(testChan, 1), NUMSAMP);
        data = testChan(trials,:);
        statsLatencyArray(i) = statsLatencyFucn(data);
    end
    
    stanError = nanstd(statsLatencyArray)/sqrt(NUMSAMP);
    statsLatencyMean = nanmean(statsLatencyArray);
    
    means(e) = statsLatencyMean;
    stds(e) = stanError;
    
    %% Statistics
    mu = statsLatencyMean;
    n = 100; %%can put whatever you want
    sigma = stanError*sqrt(n);
    
    fakeDis = normrnd(mu,sigma,1, n);

%     fakeDis = statsLatencyArray;
    
    fakeArray(e,:) = fakeDis;
end

%% T test
pMatrix = [];
for i = 1:3
    for j = 1:3
        sp = sqrt((stds(i)^2 + stds(j)^2)/2);
        
        pMatrix(i,j) = (means(i) - means(j))/(sp*sqrt(2/NUMSAMP));
    end
end

%% ANOVAing

% anova1(fakeArray')

