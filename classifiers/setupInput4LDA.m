function [inputData_ms, inputData_dc, slide_data ,slide_data_dc, boot_inputData, ...
    boot_inputData_dc] = setupInput4LDA(input_meanSubData, channels, timeFrame, decBy,  window)
% [inputData_ms, inputData_dc, slide_data ,slide_data_dc, boot_inputData, ...
%  boot_inputData_dc] = setupInput4LDA(input_meanSubData, channels, timeFrame, decBy,  window)

if nargin <5
    window = 3;
end
if nargin <4
    decBy = 4;
end
if nargin <3
    timeFrame = 1020:1350;
end
if nargin <2
    disp('need timeframe, data, and channels')
end

%%
inputData_ms = [];
inputData_dc =[];
slide_data =[];
slide_data_dc =[];
boot_inputData = [];
boot_inputData_dc =[];
%%

sqInputData = squeeze(input_meanSubData(channels,:,timeFrame));
inputData_ms = sqInputData - repmat(mean(sqInputData,2), 1, size(sqInputData,2));

for i = 1:size(inputData_ms,1)
    inputData_dc(i,:) = decimate(inputData_ms(i,:),decBy);
end

for i = 1:size(inputData_ms,1)
    if i <=size(inputData_ms,1)-window
        slide_data(i,:) = mean(inputData_ms(i:i+window,:),1);
        slide_data_dc(i,:) = mean(inputData_dc(i:i+window,:),1);
    end
end

for i = 1:size(inputData_ms,1)
    useTrial = randsample(size(inputData_ms,1), window, 1);
    boot_inputData(i,:) = mean(inputData_ms(useTrial,:),1);
    boot_inputData_dc(i,:) = mean(inputData_dc(useTrial,:),1);
end
