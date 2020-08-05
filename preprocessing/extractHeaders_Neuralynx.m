%%  Extracting the headers from each trial 

allData = dir('*_*');

allHeaders = [];
dirCounter = 1;

for i = 1:length(allData)
    if allData(i).isdir
        [~, ~, ~, ~, ~, headerInfo] = getRawCSCTimestamps([allData(i).name, '/CSC1.ncs'])
        
        allHeaders(dirCounter).name = allData(i).name;
        allHeaders(dirCounter).sampleRate = headerInfo(14);
        allHeaders(dirCounter).HPF = headerInfo(25)
        allHeaders(dirCounter).LPF = headerInfo(24)
        allHeaders(dirCounter).AmpGain = headerInfo(26)
        allHeaders(dirCounter).Range = headerInfo(21)
        
        dirCounter = dirCounter + 1;
    end
end

%% Seeing if AD channels match up with CSCs

neuro2neuroChannelIndex =[]

for i = 1:64
    [~, ~, ~, ~, ~, headerInfo] = getRawCSCTimestamps(['2017-02-28_14-52-27/CSC', num2str(i), '.ncs'])
    neuro2neuroChannelIndex(i).CSC = headerInfo(18);
    neuro2neuroChannelIndex(i).numADChan = headerInfo(19);
    neuro2neuroChannelIndex(i).ADChannel = headerInfo(20);s
    
end


