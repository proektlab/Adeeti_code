function [databyconc, concdur] = RecordingSelector_BComp(subs, subject, INDorEMG, choicechan, indir)

%% Pull out data for selected channel
% Create index vector for each subject that tells you which indices of the
% total data length belong to which subject.
count = 0;
for s = subs
    count = count + 1;
    D = dir([indir, subject{s}, '/', INDorEMG, '/*.mat']);
    NConc = size(D,1); % number of concentrations for the subject
    % Pull out the names of the files you need
    for n = 1:NConc
        fname = D(n).name;
        temp = load([indir,subject{s}, '/', INDorEMG,'/',fname]);
        data = temp.de';
        % Grab for data for a given channel for each concentration
        dbc{n} = data(choicechan,:);
        concdur{count,1}(n,1) = size(dbc{n},2); % this will be the length of this conc step for this subject
        clear fname data temp
    end
    databyconc{count,1} = dbc;
    clear dbc
end

% Now we have:
%       databyconc -- a double cell array. First order cells are the
%       different subjects, if you are looking at more than one. Second
%       order cells are the concentration steps for the subject.
%       expdate -- strings that give the date the experiment/subject names
%       concdur -- a cell array that, for each subject selected, gives the
%       duration of each concentration in units of data points