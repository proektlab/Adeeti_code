%% Trains in their own folder 

allData = dir('**.mat');

mkdir('/data/adeeti/ecog', 'mouseTrainTrials')

for i = 1:length(allData)
    load(allData(i).name, 'info');
    if strcmpi(info.TypeOfTrial, 'trains') == 1
        movefile(allData(i).name, ['mouseTrainTrials/', allData(i).name])
    end
end

%% Extracting Propofol trials names from flash trials 

mkdir('/data/adeeti/ecog', 'propTrialsJanMar2017')

propTrials1 = dir('2017-02-22*')
propTrials2 = dir('2017-03-01*')

cd('/data/adeeti/ecog/rawMouseDataJanMar2017/')

for i = 1:length(propTrials1)
    movefile(propTrials1(i).name, ['/data/adeeti/ecog/propTrialsJanMar2017/', propTrials1(i).name])
end

for i = 1:length(propTrials2)
    movefile(propTrials2(i).name, ['/data/adeeti/ecog/propTrialsJanMar2017/', propTrials2(i).name])
end


%% Put raw data into its own folder

allData = dir('*_*');

mkdir('/data/adeeti/ecog', 'rawMouseDataJanMar2017')

for i = 1:length(allData)
    if allData(i).isdir == 1
        movefile(allData(i).name, ['rawMouseDataJanMar2017/', allData(i).name])
    end
end

%% Putting all Flash Trials into its own directory 

allData = dir('**.mat');

mkdir('/data/adeeti/ecog', 'mouseFlashTrialsJanMar2017')

for i = 1:length(allData)
    load(allData(i).name, 'info');
    if strcmpi(info.TypeOfTrial, 'flashes') == 1
        movefile(allData(i).name, ['mouseFlashTrialsJanMar2017/', allData(i).name])
    end
end


%% Sorting out the Train Trials

% get names of train directories
trainTrials = ls('/data/adeeti/ecog/mouseTrainTrials/*.mat');
trainTrials = strsplit(trainTrials);
trainTrials = trainTrials(1:end-1);

for i = 1:length(trainTrials);
   temp = trainTrials{i};
   k = strfind(temp, '/');
   trainTrials{i} = temp(k(end)+1:end-4);  
end

% Get the names of baseline trials
baselineTrials = ls('/data/adeeti/ecog/mouseBaselineTialsJanMar2017/*.mat');
baselineTrials = strsplit(baselineTrials);
baselineTrials = baselineTrials(1:end-1);

for i = 1:length(baselineTrials);
   temp = baselineTrials{i};
   k = strfind(temp, '/');
   baselineTrials{i} = temp(k(end)+1:end-4);  
end

% Moving train trials and baseline trials
cd('/data/adeeti/ecog/rawMouseDataJanMar2017/')

mkdir('/data/adeeti/ecog', 'mouseTrainTrialsTakeTwo')
mkdir('/data/adeeti/ecog', 'mouseBaselineTrialsTakeTwo')

for i = 1:length(trainTrials)
        movefile(trainTrials{i}, ['/data/adeeti/ecog/mouseTrainTrialsTakeTwo/', trainTrials{i}])
end

cd('/data/adeeti/ecog/rawMouseDataJanMar2017/')
for i = 1:length(baselineTrials)
        movefile(baselineTrials{i}, ['/data/adeeti/ecog/mouseBaselineTrialsTakeTwo/', baselineTrials{i}])
end


%% Extracting info from old files

cd('/data/adeeti/ecog/matPropFlashesJanMar2017/')

allData = dir();
errorInfoTransfer = [];

for i = 3:length(allData)
    try
    load(['/data/adeeti/mouseFlashTrialsJanMar2017/', allData(i).name], 'info')
    save(['/data/adeeti/ecog/matPropFlashesJanMar2017/', allData(i).name], 'info', '-append')
    catch
    errorInfoTransfer = [errorInfoTransfer,  allData(i).name];
    end
end

    
