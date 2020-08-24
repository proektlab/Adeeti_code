function [LFPData, fullTraceTime] = extractLFPTrace_OpenEphys(Fs, finalSampR)
% [LFPData, fullTraceTime] = extractLFPTrace_OpenEphys(Fs, finalSampR)
% Fs = origional sample rate
% finalSampR = final sampling rate that you want


if nargin <1
    Fs = 30000;
end

if nargin <2
    finalSampR = 1000;
end

%%
if Fs == 30303
    newFs = 30000;
elseif Fs == 3030.3
    newFs = 3000;
else 
    newFs = Fs;
end

% % extracting the sampling rate
% load('CSC1.mat', 'blah')
% Fs = blah{14};
% Fs = str2num(Fs(20:end));
%%

% file name processing BS
files=strsplit(strtrim(ls('CH*.mat')));                                     % this gets the files from neuralynx (in the current directory

f=@(x) str2num(x(regexp(x, '\d')));                                        % anonymous function that extracts numbers from strings
temp=cell2mat(cellfun(f, files, 'UniformOutput', false));                  % channel index of each CS file
[~, ind]=sort(temp, 'ascend');                                             % arrange in terms of ascending chanel order;

files=files(ind);                                                          %reorder the files according to channel index


% gets the sizes or relevant variables. This assumes that all files will
% have a variable trace and will have exactly the same size. If this is not
% true, can mofify
matobj=matfile(files{1});
[traceL, ~]=size(matobj, 'trace');

%%
% now start the main loop for getting data

for j=1:length(ind)                     % loop over file names
    matobj=matfile(files{j});          % create a mat obj to get parts of variables
    disp(['Loading data from ' files{j}])
    
    outLFP = matobj.trace(:,1);
    
    totalLengthInSec = size(outLFP,1)/Fs;
    
    ogTime = linspace(0, totalLengthInSec, traceL);
    
    if ~(newFs == Fs)
        interpDataLFP = interp1(ogTime, outLFP, newTime);
    else
        interpDataLFP = outLFP;
    end
    
    LFPData(j,:) = decimate(interpDataLFP, newFs/finalSampR);
    
end

fullTraceTime = linspace(0, totalLengthInSec, length(outLFP)/Fs*finalSampR+1);

end

