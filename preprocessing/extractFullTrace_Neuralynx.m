function [dataSnippits, finalTime] = extractFullTrace(finalSampR, CHEETAH_VER)
% [baselineData, finalTime] = reformatBaselineFromRaw(finalSampR, CHEETAH_VER)
% finalSampR = final sampling rate for the data 
% note that this code DOES NOT detrend the data 
%CHEETAH_VER =  1 if using 5.6.3, use 2 if using 5.0.2; default is 1

% 08/21/18 AA
% 10/05/18 AA
%%
if nargin <1
    finalSampR = 1000; %in Hz
end

if nargin <2
    CHEETAH_VER = 1; %in Hz
end

if CHEETAH_VER ==1
    ADBitVoltInd = 16;
    sampInd = 14;
    inputInvertInd = 22;
if CHEETAH_VER ==2
    ADBitVoltInd = 15;
    sampInd = 13;
    inputInvertInd = 20;
end


% extracting the sampling rate
load('CSC1.mat', 'blah')
Fs = blah{sampInd};
Fs = str2num(Fs(20:end));

% file name processing BS
files=strsplit(strtrim(ls('CS*.mat')));                                     % this gets the files from neuralynx (in the current directory

f=@(x) str2num(x(regexp(x, '\d')));                                        % anonymous function that extracts numbers from strings
temp=cell2mat(cellfun(f, files, 'UniformOutput', false));                  % channel index of each CS file
[~, ind]=sort(temp, 'ascend');                                             % arrange in terms of ascending chanel order;

files=files(ind);                                                          %reorder the files according to channel index


% gets the sizes or relevant variables. This assumes that all files will
% have a variable trace and will have exactly the same size. If this is not
% true, can mofify
matobj=matfile(files{1});
[traceL, ~]=size(matobj, 'trace');


% now will generate an array of indices for each channel that surround the
% stimulus
% f=@(x, y) x:y;                                                              % define an anonymous function that interpolates between two points
% k=cell2mat(arrayfun(f, starts, ends,'UniformOutput', false));               % create an array of indices that will be loaded from each file

out=zeros(length(ind), traceL);                              % alocate empty matrix for evoked potentials

% now start the main loop for getting data

for j=1:length(ind)                     % loop over file names
    matobj=matfile(files{j});          % create a mat obj to get parts of variables
    disp(['Loading data from ' files{j}])
    out(j,:) = matobj.trace(:,1);
end

totalLengthInSec = size(out,2)/Fs;
ogTime = linspace(0, totalLengthInSec, size(out,2));

if Fs == 30303
    newFs = 30000;
elseif Fs == 3030.3
    newFs = 3000;
end

newTime = linspace(0, totalLengthInSec, totalLengthInSec*newFs+1);
finalTime = linspace(0, totalLengthInSec, size(out,2)/Fs*finalSampR+1);

dataSnippits = zeros(size(out,1), floor(totalLengthInSec*finalSampR+1));

disp('Interpolating and decimating')
for ch = 1:size(out, 1)
        interpData = interp1(ogTime, squeeze(out(ch,:)), newTime);
        dataSnippits(ch, :) = decimate(interpData, newFs/finalSampR);
end


end
