%% Analyze Andi and Andrew's data.
%   What are we looking for?
%       Do the brain states present and relative frequency change depending
%       on whether mouse is going through induction or emergence?
%   How will we find out?
%       Using the brain state stability analysis that Alex developed.
%   What does that involve?
%       Clean up signals
%       Calculate FFT of signals

Datadir = '/Users/Brenna/Documents/AndiData/';
name = 'M10';

Direction = {'IND', 'EMG'}; % create strings to specify induction or emergence

% for induction and emergence, figure out how many different files there
% are --> The size of the first dimension of Dind and Demg will tell you
% how many files there are and the structures will let you call individual
% files by name in the future.

for direc = 1:2
%% Substrace average and filter signals
    data = dir([Datadir, name, '/', Direction{direc}, '/port*.mat']);

    for f = 1:size(data,1) % loop through the different files
        temp = load([Datadir, name, '/', Direction{direc}, '/', data(f).name],'de'); % load the EEG file from the current file
        traceData = temp.de;
        % subtract mean
        msubData = traceData - repmat(mean(traceData,1), size(traceData,1), 1);

    %     for chan = 1:size(traceData,2) % loop through channels
    %         %% Calculate FFT
    %     
    %         Fs = 250;
    %         T = 1/Fs;
    %         L = size(traceData(:,1),1);
    %         t = (0:L-1)*T;
    % 
    %         X = ind1.de(:,1);
    %         Y = fft(X);
    % 
    %         P2 = abs(Y/L);
    %         P1 = P2(1:L/2+1);
    %         P1(2:end-1) = 2*P1(2:end-1);
    %         f = Fs*(0:(L/2))/L;
    %     end
        cleandata{f} = msubData;
    end

    save([Datadir, name,'/cleaned_', Direction{direc}],'cleandata')
    clear cleandata traceData msubData
end