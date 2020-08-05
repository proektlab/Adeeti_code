%% Looking at spatial frequency for waves

% Make movie of spatial phase of signal at 35 Hz for all experiments
clear

load('/data/adeeti/ecog/matFlashesJanMar2017/dataMatrixFlashes.mat')

directory = '/data/adeeti/ecog/images/011118/';

cd('/data/adeeti/ecog/matFlashesJanMar2017/Wavelets');
mkdir(directory);
allData = dir('2017*.mat');

%trial = 50;
fr = 2;
start = 900; %time before in ms
endTime = 1300; %time after in ms
screensize=get(groot, 'Screensize');
movieOutput = [];


%% finding experiments with the same characteristics

expLabel =unique(vertcat(dataMatrixFlashes(:).exp));
intPulse = unique(vertcat(dataMatrixFlashes(:).IntensityPulse));
durationPulse = unique(vertcat(dataMatrixFlashes(:).LengthPulse));
isoLevel = unique(vertcat(dataMatrixFlashes(:).AnesLevel));

for exp = 1:length(expLabel)
    for int = 1:length(intPulse)
        for dur = 1:length(durationPulse)
            compExp = find([dataMatrixFlashes.exp] == expLabel(exp) & [dataMatrixFlashes.IntensityPulse] == intPulse(int) & [dataMatrixFlashes.LengthPulse] == durationPulse(dur));
            
            %disp(['exp: ' num2str(expLabel(exp)) 'int: ' num2str(intPulse(int)) 'dur: ' num2str(durationPulse(dur)) ]);
            
            for t = 1:length(compExp)
                temp = dataMatrixFlashes(compExp(t)).name;
                compIso{exp, int, dur, t} = [temp(length(temp)-22:end-4), 'wave.mat'];
            end
            
        end
    end
end

%%

for exp = 1:length(expLabel)
    for int = 1:length(intPulse)
        for dur = 1:length(durationPulse)
            close all;

            disp(['Exp: ', num2str(expLabel(exp)), ' int: ', num2str(intPulse(int)), ' dur: ', num2str(durationPulse(dur))]);
            plotIndex = 0;
            validExperiments = findMyExp(dataMatrixFlashes, expLabel(exp), [],  intPulse(int), durationPulse(dur));
            numExp = length(validExperiments);
            if numExp ==0
                numExp = 1;
            end
            
            for drugCon = 1:size(compIso, 4)
                if ~exist(compIso{exp, int, dur, drugCon})
                    continue
                end
                plotIndex = plotIndex+1;
                load(compIso{exp, int, dur, drugCon}, 'filtSingalInd','info') %(fr,time,ch,trials)
                sig = squeeze(mean(filtSingalInd(fr,:,:,:),4));
                m = mean(sig(1:1000,:),1);
                s = std(sig(1:1000,:),1);
                ztransform=(m-sig)./s;
                filtSig(drugCon,:,:) = ztransform;
                isoCon(drugCon) = info.AnesLevel;
            end
            
            