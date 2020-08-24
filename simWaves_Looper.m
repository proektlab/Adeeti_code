%% Test cases for looper for oscillatory signals

interpBy = 1;

srate = 1000;
baseFreq = 35; %Hz
secFreq = baseFreq;%+5; %[baseFreq+.1, baseFreq+0.25, baseFreq+0.5, baseFreq+1, baseFreq+2, baseFreq+5, baseFreq+10];

numTr=20;
fracTr = 2;
waveTr = randsample(numTr, numTr/fracTr);

timeStep= 200;

x = 0:0.5/interpBy:2.5; %6 electrodes
y = 0:0.5/interpBy:5; %11 electrodes
[X, Y] = meshgrid(x, y);
times = (1:timeStep).*(1/srate);

noiseCo = 0.5;
noiseCoNoWave = 0.5;
if ispc
    load( 'Z:\adeeti\ecog\iso_awake_VEPs\goodMice\GL13\2020-01-25_11-17-00.mat', 'info')
else 
    load( '/synology/adeeti/ecog/iso_awake_VEPs/goodMice/GL13/2020-01-25_11-17-00.mat', 'info')    
end

% Run looper on one wave
allDelTime = [2];
allDelCount = [1];
allNN = [8];

oneWaveR2 = [];
oneWaveNumLoops = [];
oneWaveMapLoopsNum = [];
oneWaveMapLoops =[];


twoWaveR2 = [];
twoWaveNumLoops = [];
twoWaveMapLoopsNum = [];
twoWaveMapLoops =[];


%% one wave pattern, which noise on some or all trials
for h = 2%1:2
    if h ==1
        USE_HALF= 0;
    elseif h ==2
        USE_HALF= 1;
    end
    % make waves
    combined_data_rand = [];
    for tr = 1:numTr
        wave_array = struct();
        wave_array(1).timesteps = [1:timeStep]; %in s
        wave_array(1).y_center = ones(1,timeStep);
        wave_array(1).x_center = ones(1,timeStep);
        wave_array(1).type = 'plane';
        wave_array(1).theta = ones(1,timeStep).*pi;
        wave_array(1).temp_freq = ones(1,timeStep).*baseFreq;
        wave_array(1).spatial_freq = ones(1,timeStep)*2;
        wave_array(1).amplitude = ones(1,timeStep);
        
        data1 = populate_wave(wave_array(1), X, Y, times);
        
        if USE_HALF ==1
            if ismember(tr, waveTr)
                combined_data_rand(tr,:,:,:) = data1 + normrnd(0,noiseCo,size(data1));
            else
                combined_data_rand(tr,:,:,:)  = normrnd(0,noiseCoNoWave,size(data1));
            end
        else
            combined_data_rand(tr,:,:,:) = data1 + normrnd(0,noiseCo,size(data1));
        end
    end
    %
    %     meanWave = squeeze(nanmean(combined_data_rand,1));
    %     figure
    %     for t = 1:timeStep
    %         imagesc(squeeze(meanWave(:,:,t)));
    %         title(['Time: ' num2str(t) '; Movie Length: ' num2str(timeStep)]);
    %         set(gca,'clim', [-2,2])
    %         colorbar;
    %         pause(0.001);
    %     end
    
    conData = [];
    for tr = 1:numTr
        useData = squeeze(combined_data_rand(tr,:,:,:));
        useData = permute(useData, [3, 1, 2]);
        [concatChanTimeData, interpGridInd, interpNoiseInd, interpNoiseGrid] = ...
            makeInterpGridInd(useData, interpBy, info);
        conData(tr,:,:) = concatChanTimeData;
    end
    conData = permute(conData, [2,3,1]);
    
    for dT = 1:length(allDelTime)
        delTime = allDelTime(dT);
        for dC = 1:length(allDelCount)
            delCount = allDelCount(dC);
            for nn = 1:length(allNN)
                NN= allNN(nn);
                
                NN = 10;
                [params] = makeLooperParams(delTime, delCount, NN);
                saveData = [];
                LOOPER(saveData, true, conData, [], [], params);
                
                %results
                oneWaveR2(h,dT,dC,nn) = saveData.Ouputs.RSquared;
                oneWaveNumLoops(h,dT,dC,nn) = saveData.BestLoopCount;
                oneWaveMapLoopsNum(h,dT,dC,nn) = numel(unique(saveData.BestStateMap(:,1)));
                oneWaveMapLoops{h,dT,dC,nn} = saveData.BestStateMap(:,1);
                
                
                %  oneWaveLooperData(h).data = saveData;
            end
        end
    end
    
    %     figure
    %     plot(oneWaveMapLoops)
end


%% Make two waves with noise
% 2 waves with some frequency (temporal & spatial)
% check efficacy as lim(d_freq) --> 0
% randomize other parameters (including wave type)

noiseCo = 0.3;
noiseCoNoWave = 0.3;

for h = 3%:3
    % make 2 waves
    if h ==1
        HALF_BOTH_OTHER_NOWAVE= 1;
        HALF_WAVE1_OTHER_WAVE2 = 0;
        HALF_BOTH_OTHER_WAVE2 = 0;
    elseif h ==1
        HALF_BOTH_OTHER_NOWAVE= 0;
        HALF_WAVE1_OTHER_WAVE2 = 1;
        HALF_BOTH_OTHER_WAVE2 = 0;
    elseif h ==1
        HALF_BOTH_OTHER_NOWAVE= 0;
        HALF_WAVE1_OTHER_WAVE2 = 0;
        HALF_BOTH_OTHER_WAVE2 = 1;
    end
    % make waves
    combined_data_rand = [];
    for tr = 1:numTr
        wave_array = struct();
        for i=1:2
            wave_array(i).timesteps = [1:5000]; %in s
        end
        wave_array(1).y_center = ones(1,5000);
        wave_array(1).x_center = ones(1,5000);
        wave_array(1).type = 'plane';
        wave_array(1).theta = ones(1,5000).*pi;
        wave_array(1).temp_freq = ones(1,5000).*baseFreq;
        wave_array(1).spatial_freq = ones(1,5000)*2;
        wave_array(1).amplitude = ones(1,5000);
        
        wave_array(2).y_center = ones(1,5000)*2;
        wave_array(2).x_center = ones(1,5000)*1;
        wave_array(2).type = 'rotational'; %'rotational';
        wave_array(2).theta = ones(1,5000).*(0.25*pi);
        wave_array(2).temp_freq = ones(1,5000).*secFreq;
        wave_array(2).spatial_freq = ones(1,5000)*3;
        wave_array(2).amplitude = ones(1,5000)*1;
        
        data1 = populate_wave(wave_array(1), X, Y, times);
        data2 = populate_wave(wave_array(2), X, Y, times);
        combined_data = data1 + data2;
        
        if HALF_BOTH_OTHER_NOWAVE ==1
            if ismember(tr, waveTr)
                combined_data_rand(tr,:,:,:) = combined_data + normrnd(0,noiseCo,size(data1));
            else
                combined_data_rand(tr,:,:,:)  = normrnd(0,noiseCoNoWave,size(data1));
            end
        elseif HALF_WAVE1_OTHER_WAVE2 ==1
            if ismember(tr, waveTr)
                combined_data_rand(tr,:,:,:) = data1 + normrnd(0,noiseCo,size(data1));
            else
                combined_data_rand(tr,:,:,:)  = data2+ normrnd(0,noiseCoNoWave,size(data1));
            end
        elseif HALF_BOTH_OTHER_WAVE2 ==1
            if ismember(tr, waveTr)
                combined_data_rand(tr,:,:,:) = combined_data + normrnd(0,noiseCo,size(data1));
            else
                combined_data_rand(tr,:,:,:)  = data2+ normrnd(0,noiseCo,size(data1));
            end
        else
            combined_data_rand(tr,:,:,:) = combined_data + normrnd(0,noiseCo,size(data1));
        end
    end
    
    % meanWave = squeeze(nanmean(combined_data_rand,1));
    % figure
    % for t = 1:timeStep
    %     imagesc(squeeze(meanWave(:,:,t)));
    %     title(['Time: ' num2str(t) '; Movie Length: ' num2str(timeStep)]);
    %     set(gca,'clim', [-2,2])
    %     colorbar;
    %     pause(0.001);
    % end
    
    conData = [];
    for tr = 1:numTr
        useData = squeeze(combined_data_rand(tr,:,:,:));
        useData = permute(useData, [3, 1, 2]);
        [concatChanTimeData, interpGridInd, interpNoiseInd, interpNoiseGrid] = ...
            makeInterpGridInd(useData, interpBy, info);
        conData(tr,:,:) = concatChanTimeData;
    end
    conData = permute(conData, [2,3,1]);
    
    
    
    for dT = 1:length(allDelTime)
        delTime = allDelTime(dT);
        for dC = 1:length(allDelCount)
            delCount = allDelCount(dC);
            for nn = 1:length(allNN)
                NN= allNN(nn);
                
                saveData = [];
                [params] = makeLooperParams(delTime, delCount, NN)
                LOOPER(saveData, true, conData, [], [], params);
                
                %results
                twoWaveR2(h,dT,dC,nn) = saveData.Ouputs.RSquared;
                twoWaveNumLoops(h,dT,dC,nn) = saveData.BestLoopCount;
                twoWaveMapLoopsNum(h,dT,dC,nn) = numel(unique(saveData.BestStateMap(:,1)));
                twoWaveMapLoops{h,dT,dC,nn} = saveData.BestStateMap(:,1);
            end
        end
    end
    
    
    % figure
    % plot(twoWaveMapLoops)
end

%%

function [params] = makeLooperParams(DelayTime, DelayCount,NearestNeighbors)
params = [];

if nargin<3||isempty(NearestNeighbors)
    params.NearestNeighbors = NearestNeighbors;
else
    params.NearestNeighbors = [6];
end

if nargin<2||isempty(DelayCount)
    params.PreprocessData.DelayCount = [2];  %, 3, 5, 10];
else
    params.PreprocessData.DelayCount =DelayCount;
end

if nargin<1||isempty(DelayTime)
    params.PreprocessData.DelayTime = [5]; %, 5, 10, 15, 20, 30];
else
    params.PreprocessData.DelayTime = DelayTime;
end

params.PreprocessData.ZScore = 1; %or 0
params.PreprocessData.Smoothing = 0; %or 0 - this is in sigma
params.UseLocalDimensions =1; %will want this as 1
params.PutativeLoopCounts = [5,4,3,2,1];
params.UseTerminalState = 1;
params.TotalStates = 40;


end




