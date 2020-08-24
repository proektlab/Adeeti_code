

for i = 1:64

    Fs = blah{14};
    Fs = str2num(Fs(20:end));

    finalSampR = 1000;

    if Fs == 30303
        newFs = 30000;
    elseif Fs == 3030.3
        newFs = 3000;
    end

    disp('Interpolating and decimating') 

    allTrace = decimate(trace, newFs/finalSampR);

end


%% Wavelet

disp('Wavelet on Real Data')
WAVE=zeros(40, length(allTrace));
sig=detrend(squeeze(allTrace));
% [temp,PERIOD,SCALE,COI,DJ, PARAMOUT, K] = contwt(sig,1/1000,1, 0.1);
[temp,PERIOD,SCALE,COI,DJ, PARAMOUT, K] = contwt(sig, 1/finalSampR, 1, 0.25);
WAVE=temp; %WAVE is in freq by time by channels by trials
Freq=1./PERIOD;


%% Time evolution of spectral states

useFrequencies = find(Freq >= 0.5 & Freq < 200);

traceIndices = (1:20000)+2*60*1000;

pcolor(1:length(traceIndices), Freq(useFrequencies), abs(WAVE(useFrequencies,traceIndices))); shading flat;
set(gca, 'Yscale', 'Log')

%%

spectralData = abs(WAVE(useFrequencies,:));
norms = sum(abs(WAVE(useFrequencies,:)),1);
norms = repmat(norms, [size(spectralData,1), 1]);

spectralData = spectralData ./ norms;

spectralDataEmbedded = delayEmbed(spectralData, 5, 500, 0);

[~, pcaScores] = pca(spectralDataEmbedded', 'NumComponents', 3);

traceIndices = 1:800000;
plot3(pcaScores(traceIndices,1),pcaScores(traceIndices,2),pcaScores(traceIndices,3))

