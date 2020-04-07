% Converts all channels including AUX and ADC properly from OpenEphys Recordings
% be in directory where openEphys files were saved

clear
clc

dateToday = '2019-07-12';

dirIn = ['/Users/adeetiaggarwal/Documents/open-ephys/', dateToday];
dirOut = ['/Users/adeetiaggarwal/Documents/open-ephys/', dateToday,' matlab/'];

eventChanID= '*ADC2*';
ogSampR = 30000;

makeLFP = 1;
LFPcutOff = 325;
finalSampR = 1000;

%%
% setting up for low pass FIR filtering
if makeLFP ==1
nyquist = ogSampR/2;
filtbound = [LFPcutOff LFPcutOff*1.15]; % Hz
filt_order = 50;
ffrequencies = [0 filtbound(1)/nyquist filtbound(2)/nyquist 1];
idealresponse = [1 1 0 0];
filterweights= firls(filt_order,ffrequencies,idealresponse,[100 1]);
end

%%

cd(dirIn)
allDataExperiments = dir([dateToday, '*']);

for a = 5:length(allDataExperiments)
    cd(dirIn)
    cd(allDataExperiments(a).name)
    
    % extracting events
    BNC_Chan = dir(eventChanID);
    disp(['Extracting BNC data']);
    [eventData, timesteps, recInfo]=load_open_ephys_data(BNC_Chan.name);
    
    TTLs = zeros(size(eventData));
    TTLs(find(eventData>3)) = 1;
    startTTL = find(diff(TTLs) ==1);
    endTTL = find(diff(TTLs) ==-1);
    save('events.mat', 'TTLs', 'startTTL', 'endTTL', '-v7.3')
    
    
    g=dir('*CH*cont*');
    for i=1:length(g)
        temp=strsplit(g(i).name, '.');
        temp=strsplit(temp{1}, '_');
        temp=temp{2};
        disp(['(' num2str(i) '/' num2str(length(g)) ')']);
        [data, timesteps, recInfo]=load_open_ephys_data(g(i).name);
        % filtering data
        if makeLFP ==1
        if isempty(data)
            continue
        end
        trace = zeros(size(data));
        trace = filtfilt(filterweights,1,double(data));
        end
        save([temp, '.mat'], 'trace', '-v7.3')
    end
    
end
disp('Done')


% 
% 
% file name processing BS
% files=strsplit(strtrim(ls('CS*.mat')));                                     % this gets the files from neuralynx (in the current directory
% 
% f=@(x) str2num(x(regexp(x, '\d')));                                        % anonymous function that extracts numbers from strings
% temp=cell2mat(cellfun(f, files, 'UniformOutput', false));                  % channel index of each CS file
% [~, ind]=sort(temp, 'ascend');                                             % arrange in terms of ascending chanel order;
% 
% files=files(ind);                                                          %reorder the files according to channel index
% 
% 
% 
% 
% BNC_Chan= dir('*mat')
% 
% figure
% for i = 9:14 %2 %1:8
%     load(BNC_Chan(i).name)
%     plot(x)
%     hold on
% end
% 
% eventChan = BNC_Chan(2).name;
% load(eventChan)
% eventsTimepoints = x;
% dsEvents = decimate(eventsTimepoints, ogSampR/finalSampR);
% TTLs = zeros(size(dsEvents));
% TTLs(find(dsEvents>3)) = 1;
% startTTL = find(diff(TTLs) ==1);
% endTTL = find(diff(TTLs) ==-1);
% 
% 
