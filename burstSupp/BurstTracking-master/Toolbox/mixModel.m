function [postBurstProb,fitInfo] = mixModel(smoothedData)

%intiate matrixes
postBurstProb = zeros(size(smoothedData));
fitInfo.mu = zeros(size(smoothedData,1),2);
fitInfo.sigma = zeros(size(smoothedData,1),2);
fitInfo.dPrime = zeros(size(smoothedData,1),1);
fitInfo.numIter = zeros(size(smoothedData,1),1);
fitInfo.burstPct = zeros(size(smoothedData,1),1);

%for every channel
for ii = 1:size(smoothedData,1)
    %remove 0s
    dataTemp = smoothedData(ii,:);
    nzidx = find(dataTemp);
    lend = length(dataTemp);
    dataTemp = dataTemp(dataTemp ~= 0);
    x = log10(dataTemp)'; %transform data so it's more gaussian?
    
    %create a gaussian mixture model
    gm = fitgmdist(x,2);
    
    %determine which distribution is bursts and which one is suppresses
    if gm.mu(1) < gm.mu(2)
        midx = [1 2];
    else
        midx = [2 1];
    end
    
    fitInfo.mu(ii,:) = gm.mu(midx);
    fitInfo.sigma(ii,:) = gm.Sigma(1,midx);
    fitInfo.dPrime(ii) = abs(gm.mu(1) - gm.mu(2))./sqrt(gm.Sigma(1,1)+gm.Sigma(1,2));
    fitInfo.numIter(ii) = gm.NumIterations;
    fitInfo.burstPct(ii) = gm.ComponentProportion(midx(2));
    
    postTemp = posterior(gm,x);
    postTemp = postTemp(:,midx(2));
   
    postProb = zeros(lend,1);
    postProb(nzidx) = postTemp;
    zidx = setdiff(1:lend,nzidx);
    
    %somehow compensate for missing indexes from zero removal?
    for zi = 1:(length(zidx))
        idx = zidx(zi);
        if idx == 1
            postProb(idx) = postProb(idx+1);
        elseif idx == lend
            postProb(idx) = postProb(idx-1);
        else
            postProb(idx) = nanmean(postProb([idx+1,idx-1])); 
        end
    end
    postBurstProb(ii,:) = postProb;
end

