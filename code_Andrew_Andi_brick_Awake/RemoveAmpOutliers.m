function [cleanData,cleanTime] = RemoveAmpOutliers(alldata,ampCutoff)

time=1:1:size(alldata,2);

stdAmp=std(alldata,0,2); % find total power per frequency bin
% Make thresholds in units of power based on the assigned cutoffs
thresh(1)=-ampCutoff*stdAmp;
thresh(2)=ampCutoff*stdAmp;
% All data outside these quantiles are outliers
outlier=find(alldata(1,:)<thresh(1) | alldata(1,:)>thresh(2));


% Make a vector that tells who is naughty and who is nice.
% naughty = outlier; nice = within quartile bounds
naughtyList=ones(size(time));
naughtyList(outlier)=0; % in the index vector of ones, the outlier bins are zero
cleanData=alldata(find(naughtyList)); % cleanSpec has only the data from the nice list

% Alter the time variable to reflect the outlier channels that have been
% removed
cleanTime = time(find(naughtyList));