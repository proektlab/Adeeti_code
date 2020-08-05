function [info]= adddManNoiseChan_allExpMouse(allData,  ANALYZE_IND, numbOfSamp)
% [info] dddManNoiseChan_allExpMouse(allData,  ANALYZE_IND, numbOfSamp)

if nargin<3
    numbOfSamp = 8;
end
if nargin<2
    ANALYZE_IND = 0;
end

%%
date = 'start';
for i = 1:length(allData)
    dirName = allData(i).name;
    load(dirName, 'info', 'LFPData', 'dataSnippits', 'fullTraceTime', 'finalTime');
    
    if ~exist('dataSnippits', 'var')||isempty(dataSnippits)
        dataSnippits = LFPData;
    end
    
    if ANALYZE_IND ==0 && contains(info.date, date)
        info.noiseChannels = noiseChannels;
        save(dirName, 'info', '-append')
    else
        clearvars noiseChannels
        
        upperBound = max(dataSnippits(:));
        lowerBound = min(dataSnippits(:));
        if ndims(dataSnippits)==2
            [ noiseChannelsManual ] = examChannelBaseline(dataSnippits, fullTraceTime);
        elseif ndims(dataSnippits) == 3
            noiseChannelsManual = examChannelSnippits(dataSnippits, finalTime, numbOfSamp, upperBound, lowerBound);
        end
        
        noiseChannels = unique([info.noiseChannels, noiseChannelsManual']);
        prompt = ['NoiseChannels =', mat2str(noiseChannels), ' Enter other bad channels, if there are none, put []'];
        exNoise = input(prompt);
        noiseChannels = sort([noiseChannels, exNoise]);
        
        info.noiseChannels = noiseChannels;
        
        save(dirName, 'info', '-append')
        
        date = info.date;
        clearvars LFPData dataSnippits fullTraceTime
    end
    %
end