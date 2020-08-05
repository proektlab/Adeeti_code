function [fakeWAVE, fakeSnippits] = makeFakeWave('info', 'smallSnippets', 'meanSubData')

[fakeSnippits] = makeFakeSnippits(meanSubData, smallSnippets);

disp('Wavelet on Fake Data')
    fakeWAVE=zeros(40, 2001, size(fakeSnippits,1), size(fakeSnippits,2));
    for i=1:size(fakeWAVE,3)
        disp(i);
        for j = 1:size(fakeSnippits,2)
            sig=detrend(squeeze(fakeSnippits(i, j,:)));
            % [temp,PERIOD,SCALE,COI,DJ, PARAMOUT, K] = contwt(sig,1/1000,1, 0.1);
            [temp,PERIOD,SCALE,COI,DJ, PARAMOUT, K] = contwt(sig,1/1000,1, 0.25);
            fakeWAVE(:,:,i, j)=temp; %WAVE is in freq by time by channels by trials
            Freq=1./PERIOD;
        end
    end
end