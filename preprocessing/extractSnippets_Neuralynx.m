function [dataSnippits, out, ogTime, finalTime, finalSampR] = extractSnippets(onTime, before, l, finalSampR, startBaseline)
% ontime = event times, put the time of the first event if you want to
% extract baseline
% before = before the stim in seconds (put time to the first event if want
% to extract baseline)
% l = total length of trial in seconds (put time to first event if want to
% extract baseline)
% finalSampR = final sampling rate that you want
% startBaseline = parameter (1 if want to extract baseline, 0 if want to
% extract trials)

if nargin <5
    startBaseline = 0;
end

if nargin <4
    finalSampR = 1000; %in Hz
    startBaseline = 0;
end

% extracting the sampling rate
load('CSC1.mat', 'blah')
Fs = blah{14};
Fs = str2num(Fs(20:end));

% convert to units of samples
b=floor(before*Fs);
a=floor(l*Fs);

% find starting and ending point for each window
if startBaseline == 0
    starts=floor(onTime.*Fs)-b;
else
    starts = 1;
end

ends=starts+a;

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

test=find(ends>traceL);                                                 % see if any evoked potential segments fall outside the trace. and if so get rid of them
if ~isempty(test);
    ends(test)=[];
    starts(test)=[];
end

test=find(starts<=0);                                                    % also get rid of all windows that starts  before the first point.
if ~isempty(test)
    starts(test)=[];
    ends(test)=[];
end
% now will generate an array of indices for each channel that surround the
% stimulus
f=@(x, y) x:y;                                                              % define an anonymous function that interpolates between two points
k=cell2mat(arrayfun(f, starts, ends,'UniformOutput', false));               % create an array of indices that will be loaded from each file

out=zeros(length(ind), size(k,1), size(k,2));                              % alocate empty matrix for evoked potentials

% now start the main loop for getting data

for j=1:length(ind)                     % loop over file names
    matobj=matfile(files{j});          % create a mat obj to get parts of variables
    disp(['Loading data from ' files{j}])
    
    
    parfor i=1:size(k,1)
        out(j,i,:)=detrend(matobj.trace(k(i,:),1));
    end
end


ogTime = linspace(-before, l-before, size(out, 3));


if Fs == 30303
    newFs = 30000;
elseif Fs == 3030.3
    newFs = 3000;
end

newTime = linspace(-before, l-before, l*newFs+1);
finalTime = linspace(-before, l-before, l*finalSampR+1);

dataSnippits = zeros(size(out,1), size(out, 2), floor(l*finalSampR+1));

disp('Interpolating and decimating')
for ch = 1:size(out, 1)
    for tr = 1:size(out, 2)
        interpData = interp1(ogTime, squeeze(out(ch,tr,:)), newTime);
        dataSnippits(ch, tr, :) = decimate(interpData, newFs/finalSampR);
    end
end


end

