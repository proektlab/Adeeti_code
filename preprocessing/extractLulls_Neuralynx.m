function [lullSnippits, finalTime] = extractLulls(onTime, before, finalSampR)
% [lullSnippits, finalTime] = extractLulls(onTime, before, finalSampR)
% onTime should be a vector with the time of the first flash and the times
% of flash when comes back on after a time off 
% before should be the offtime of the LED 
if nargin <3
    finalSampR = 1000; %in Hz
end

% extracting the sampling rate
load('CSC1.mat', 'blah')
Fs = blah{14};
Fs = str2num(Fs(20:end));

% convert to units of samples
b=floor(before*Fs);

% find starting and ending point for each window

starts=floor(onTime.*Fs)-b;
starts(1) = 1;

ends=starts+b;

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
k=arrayfun(f, starts, ends,'UniformOutput', false);               % create an array of indices that will be loaded from each file

% now start the main loop for getting data

for l = 1:size(k,1)
    
    temp=zeros(length(ind), size(k{l},2));                           % alocate empty matrix for evoked potentials
    
    for j=1:length(ind)                     % loop over file names
        matobj=matfile(files{j});          % create a mat obj to get parts of variables
        disp(['Loading data from ' files{j}])
        temp(j,:)= detrend(matobj.trace(k{l},:), 1);
    end
    
    ogTime = linspace(0, before(l), size(temp, 2));
    
    if Fs == 30303
        newFs = 30000;
    elseif Fs == 3030.3
        newFs = 3000;
    end
    
    newTime = linspace(0, before(l), before(l)*newFs+1);
    finalTime{l} = linspace(0, before(l), before(l)*finalSampR+1);
    
    lullSnippits{l} = zeros(size(temp,1), size(finalTime{l}, 2));
    
    disp('Interpolating and decimating')
    for ch = 1:size(temp, 1)
        interpData = interp1(ogTime, squeeze(temp(ch,:)), newTime);
        lullSnippits{l}(ch, :) = decimate(interpData, newFs/finalSampR);
    end
    
end


end

