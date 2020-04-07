%% Coherence between channels

%% notes on connectivity in general

% la placian is a good start to decrease the volume connduction effects
% (attenuates the volume conduction artifacts)

% connectivity over time (this is probably what we are going to do) or trials - ISPC

% directional vs nondirectional
% directional is much harder- esp with noise in data, amplitudes can
% have compounds and need larger data sets
% who's first?
% common input problem
% directional connectivity measured with granger causality
% directional connectivity is hard in understanding exploritory data

% based on phase synchronizaiation

% For EEG- data that shows clustering over 0.5 or 0.6 would probably be
% from volume conduction

% phase lag based methods  - avoiding volume conduction - clustered around
% 0 - strongly volume conduction

% zero phase lag or pi synchronization - could be from volume conduction or
% true very fast connectivity

% some will ignore all connectivity with zero phase lag

% phase lag index (PLI)- are phase angles consistently differnet from pi
% (all pointing up or down from zero on the imaginary axis) - under
% estimates connectivity or misses true connectivity in the data

% phase spinning around in the phase angle circle - can happen if have two
% neighboring frequencies esp if the frequencies are higher

% ISPC - max sensitivity, most volnerable to volume conduction
% PLI - more specific, but better for volume conduction

%% Inter-site phase clustering (ISPC)

% extract phase angle from wavelet transform
% phase - just about timing, invarient of the phase

dirIn = '/Users/adeetiaggarwal/Google Drive/data/matIsoPropMultiStimVIS_ONLY_/flashTrials/';
cd(dirIn)

% mkdir('/data/adeeti/ecog/images/121317/');
%screensize=get(groot, 'Screensize');

dirOut = [dirIn, 'ISPC/'];
mkdir(dirOut);

allData = dir('2018*.mat');

for experiment = 1%:length(allData)
    load(allData(experiment).name, 'info', 'meanSubData')
    disp(['Saving ISPC for ', num2str(experiment), ' out of ', num2str(length(allData))])
    
  for i=1:size(meanSubData,1)
            disp(i);
            %tic
            for j = 1:size(meanSubData,2)
                sig=detrend(squeeze(meanSubData(i, j,:)));
                % [temp,PERIOD,SCALE,COI,DJ, PARAMOUT, K] = contwt(sig,1/1000,1, 0.1);
                [temp,PERIOD,SCALE,COI,DJ, PARAMOUT, K] = contwt(sig,1/finalSampR,1, 0.25); % EEG data, 1/finalSampR, 1 = pad with zeros, 0.25 = default scale res
                if i ==1 && j ==1
                     WAVE=zeros(length(PERIOD), size(meanSubData,3), size(meanSubData,1), size(meanSubData,2));
                end
                WAVE(:,:,i, j)=temp;
                Freq=1./PERIOD;
            end
        end
    
    for fr = 1:length(Freq)
        waveDecop = squeeze(WAVE(fr,:,:,:));
        phaseData = angle(waveDecop);
        
        ISPC = nan(info.channels, info.channels, size(waveDecop,1));
        
        %     phase angles from the wavlet transform
        for ch2= 1:size(waveDecop, 2)
            for ch1 = 1:size(waveDecop, 2)
                angleDiff = phaseData(:, ch1 ,:)-phaseData(:, ch2, :);
                ISPC(ch1, ch2, :) = squeeze(mean(exp(1i*(angleDiff)),3));
            end
        end
        eval([['ISPC', num2str(fr)] '= ISPC;'])
        temp = ['ISPC', num2str(fr)];
        if exist([dirOut, allData(experiment).name])
            save([dirOut, allData(experiment).name], temp, '-append')
        else 
            save([dirOut, allData(experiment).name], temp)
        end
        clearvars temp ISPC angleDiff
    end
    save([dirOut, allData(experiment).name], 'info', '-append')
    clearvars info 
end

    
   
