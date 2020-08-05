function [dataSnippits, finalTime] = extractSnippetsPlexon(gridData, onTime, before, l, finalSampR, startBaseline)
% ontime = event times, put the time of the first event if you want to
% extract baseline
% before = before the stim in seconds (put time to the first event if want
% to extract baseline)
% l = total length of trial in seconds (put time to first event if want to
% extract baseline)
% finalSampR = final sampling rate that you want
% startBaseline = parameter (1 if want to extract baseline, 0 if want to
% extract trials)
% 09/03/18 AA

if nargin <6
    startBaseline = 0;
end
if nargin <5
    finalSampR = 1000; %in Hz
    startBaseline = 0;
end

% convert to units of samples
b=floor(before*finalSampR);
a=floor(l*finalSampR);

% find starting and ending point for each window
if startBaseline == 0
    starts=floor(onTime.*finalSampR)-b;
else
    starts = 1;
end

ends=starts+a;

% gets the sizes or relevant variables. This assumes that all files will
% have a variable trace and will have exactly the same size. If this is not
% true, can mofify

test=find(ends>size(gridData,2));                                                 % see if any evoked potential segments fall outside the trace. and if so get rid of them
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

dataSnippits=zeros(size(gridData,1), size(k,1), size(k,2));                              % alocate empty matrix for evoked potentials

% now start the main loop for getting data

for j=1:size(gridData,1)                     % loop over file names
    gridChan = squeeze(gridData(j,:));
    disp(['Entering data from channel ', num2str(j)])

    parfor i=1:size(k,1)
        dataSnippits(j,i,:)=detrend(gridChan(1, k(i,:)));
    end
end

finalTime = linspace(-before, l-before, l*finalSampR+1);

end

