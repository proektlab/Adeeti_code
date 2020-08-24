%% Analyze Neuralynx files Pipeline 

% 10/05/18 AA

VOLTS = 10^6; %saves data in microvolts
DO_NOT_INVERT = 'true';
USE_SINGLE_FOLDER = 1; %zero if parent directory, 1 if testing on one experimental file 

CHEETAH_VER = 1; %use 1 if using 5.6.3, use 2 if using 5.0.2

if CHEETAH_VER ==1
    ADBitVoltInd = 16;
    sampInd = 14;
    inputInvertInd = 22;
elseif CHEETAH_VER ==2
    ADBitVoltInd = 15;
    sampInd = 13;
    inputInvertInd = 20;
end

    

% convert all the .ncs files into mat files
% datadir='/data/adeeti/ecog/rawPropStates2018/'; %looks in this directory for all .nsc files
datadir = [pwd, '/'];

% addpath(genpath('/home/alex/MatlabCode/Neuralynx'));
cd(datadir);

if ~USE_SINGLE_FOLDER
    [~, s]=system('find  -name CSC*.ncs'); %finds all files with .ncs
else
    s=ls('CSC*.ncs');
end
s=strsplit(s);

badfiles=[];

for i=1:length(s)
    ERR=[];
    disp([num2str(i) ' of ' num2str(length(s))]);
    infile=s{i};
    if ~USE_SINGLE_FOLDER
        infile=[datadir infile(3:end)];
    else
        infile=[datadir infile(1:end)];
    end
    try
    [timestamps, dataSamples, blah] = Nlx2MatCSC_v3(infile, [1 0 0 0 1], 1, 1);
    catch ERR
      if ~isempty(ERR)
          disp(i);
      else
          disp('OK');
      end
    end
    if ~isempty(dataSamples)
        disp('good');
        trace=dataSamples(:);
        
        if strcmpi(blah{inputInvertInd}(16:end), DO_NOT_INVERT)
            trace = -1*trace;
        end
        
        stupidFactor = regexp(blah{ADBitVoltInd},['[.\d]+'],'match');
        stupidFactor = str2num(stupidFactor{1});
        stupidFactor = stupidFactor*VOLTS;
        
        trace = trace*stupidFactor;
        
        outfile=[infile(1:end-3) 'mat'];
        save(outfile, 'trace', 'timestamps', 'blah', '-v7.3');            
    else
        badfiles=[badfiles, i];
    end
end


%% find all the directories where valid files were found


good=setdiff(1:length(s), badfiles);
pathstr=cell(size(good));
for i=1:length(good)
   [temp,~,~]=fileparts(s{good(i)});
   pathstr{i}=temp;   
    
end
pathstr=unique(pathstr);

%% extract Events for each relevant directory and create the mat file after converting to seconds
eveCatalog=[];
noEvents=[];
for i=2:length(pathstr)
    temp=pathstr{i};
    infile=[datadir, temp(2:end) '/Events.nev'];
    try 
         eve=getRawTTLs(infile);
   
    catch ERR
        if ~isempty(ERR)
            disp(ERR);
        end
    end
    if ~isempty(eve)
       
        eveTime=eve(:,1);
        eveTime=(eveTime-eveTime(1))./1000000;
        pulse=eve(:,2);
        eveID=pulse;
   % blanks=find(pulse==0);
  %  eveTime(blanks)=[];
  %  pulse(blanks)=[];
 %   onTime=eveTime(1:2:length(pulse));
  %  offTime=eveTime(2:2:length(pulse));
        outfile=infile(1:end-3);
        save([outfile 'mat'],'eveTime', 'eveID', '-v7.3');
        eveCatalog=vertcat(eveCatalog, [i.*ones(size(eveTime)), eveTime, pulse]);
    else
        noEvents=[NoEvents, i];
    end
    
end

% save([datadir '/eventCatalog.mat'], 'eveCatalog');

%% go through each directory, create a time vector for all the recordings. Pull all the individual channels into a single array. Extract sampling frequency. 
% TotalChannels=64;           % define total number of channels
% 
% for i=2:length(pathstr);
%     disp([num2str(i) ' of ' num2str(length(pathstr))])
%     temp=pathstr{i};
%     cd([datadir, temp(2:end)]);
%     ff=dir('CS*.mat');
%     if length(ff)<TotalChannels
%         disp([datadir, temp(2:end)]);
%         disp('some channels are missing');
%     end
%     load(ff(1).name);
%     temp=blah{14};                  % get the header field 14 for sampling rate
%     sp=strfind(temp, ' ');
%     Fs=str2num(temp(sp+1:end));     % get sampling rate;
%     time=0:length(trace)-1;
%     time=time./Fs;
%     grid=zeros(TotalChannels, size(trace,1));
%     
%     grid(1,:)=trace;
%     
%     for j=2:length(ff)
%        load(ff(j).name, 'trace');
%        grid(j,:)=trace;
%         
%     end
%     save('gridData.mat', 'grid', 'time', 'Fs');
%     
% end
% 
% %% Go through each channel to manually select bad channels;
% 
% for i=7:length(pathstr)
%     temp=pathstr{i};
%     disp([datadir, temp(2:end)])
%     cd([datadir, temp(2:end)]);
%     load('gridData.mat');
%     chanLabel=ExamChannel(grid, Fs);
%     save('ChanLabels.mat', 'chanLabel');
% end
% 
% %% channel ordering i.e. which CSDXX.ncs is which row in the grid file.
% 
% 
% for i=1:length(pathstr);
%     disp([num2str(i) ' of ' num2str(length(pathstr))])
%     temp=pathstr{i};
%     cd([datadir, temp(2:end)]);
%     ff=dir('CS*.mat');
%     chanNumbers=zeros(length(ff),1);
%         for j=1:length(chanNumbers)
%             temp=str2num(ff(j).name(regexp(ff(j).name, '\d')));
%             chanNumbers(j)=temp;            
%         end
%     save('ChanNumbering.mat', 'chanNumbers');
%     
% end
% 
% %%
% ChanLayout=[3 7 19 23 24 28 8 12 ; 2 6 18 22 25 29 9 13; 1 5 17 21 26 30 10 14; 0 4 16 20 27 31 11 15];
% [X,Y]=meshgrid(1:8, 1:4);
% ChanLocs{1}=X;
% ChanLocs{2}=Y;
% 
% 
