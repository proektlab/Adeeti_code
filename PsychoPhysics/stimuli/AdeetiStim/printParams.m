function printParams(expParams, times, locations, startTime, fileName)
%function printParams(params, times, locations, [fileName])
%Saves params, as well as a table of stimuli times and locations to .mat
%files
%file
%expParams - structure containing parameters to be saved
%times - column matrix with times of all stimuli
%locations - column matrix with locations of all stimuli
%fileName - fie name of mat file


if isempty(startTime)
    startTime = datestr(now);
end

if isempty(fileName)
    fileName = ['Experiment-', startTime];
end

save([fileName, '.mat'],'-struct', 'expParams')

timesTable= {"Trial", "Time", "Location on Screen"};
timesTable(2:numel(times)+1, 1)= num2cell((1:numel(times))');
timesTable(2:numel(times)+1, 2)= num2cell(times);
timesTable(2:numel(times)+1, 3)= num2cell(locations);
save([fileName, '.mat'], 'timesTable',  '-append');

end