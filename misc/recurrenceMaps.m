conData = [];%zeros(size(meanSubData,1), size(meanSubData,2)*size(meanSubData,3)/50);
 
for ch = 1:size(meanSubData,1)
    tempData = [];
    for tr= 1:size(meanSubData, 2)
        squeezedData = squeeze(meanSubData(ch,tr,:));
        
%         fc = 5;
%         fs = 1000;
%
%         [b,a] = butter(6,fc/(fs/2));
%         
%         squeezedData = filtfilt(b, a, squeezedData);
        
        tempData = [tempData; (squeezedData)];
    end
    
    conData(ch,:) = decimate(tempData,50);
end
 
conData(isnan(conData(:,1)),:) = [];

randConData = conData(randsample(numel(conData),numel(conData)));
randConData = reshape(randConData, size(conData));
 
recurrenceMap = pdist2(randConData', randConData');

 
blockSize = 120;
jumpSize = 60;
 
meanRecurrence = zeros(blockSize,blockSize);
for tr= 1:(size(recurrenceMap,2)/jumpSize+1-blockSize/jumpSize)
    meanRecurrence = meanRecurrence + recurrenceMap((tr-1)*jumpSize+(1:blockSize),(tr-1)*jumpSize+(1:blockSize));
end
