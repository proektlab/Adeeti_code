
directoryISPC = '/data/adeeti/ecog/matFlashesJanMar2017/Wavelets/ISPC/';
directoryInfo = '/data/adeeti/ecog/matFlashesJanMar2017/';

load('/data/adeeti/ecog/matFlashesJanMar2017/dataMatrixFlashes.mat')

plotEigs = 2;

exp = 7;
iso = [];
int = 3;
dur = 10;

compIso = findMyExp(dataMatrixFlashes, exp, iso, int, dur);

for c = 1:length(compIso)
    compIsoStrings{c} = dataMatrixFlashes(compIso(c)).name(end-22:end-4);
end


%%
for c = 1:length(compIso)
    load([directoryISPC, compIsoStrings{c}, 'wave.mat'])
    load([directoryInfo, compIsoStrings{c}, '.mat'], 'info')
    e=zeros(64-length(info.noiseChannels), 2001);
    figure;
    displayFreq = find(Freq<=200 & Freq>13);
    ax=zeros(size(displayFreq));
    for j=1:length(displayFreq)
        for i=1:2001
            displayTime = i;
            connectivity = eval(['ISPC' num2str(displayFreq(j)) '(:,:,' num2str(displayTime) ')']);
            connectivity(:,info.noiseChannels) = [];
            connectivity(info.noiseChannels,:) = [];
            temp=sort(abs(eig(connectivity-mean(connectivity(:)))), 'descend');
            e(:,i)=temp;
        end
        normalizedE = e ./ repmat(sum(e,1), [size(e,1) 1]);
        
        eMean= mean(normalizedE, 2);
        eCorr = normalizedE.*repmat(eMean, 1, size(e, 2));
        eCorrSum(j) = max(1-sum(eCorr, 1));
        
        if plotEigs ==1
            
        ax(j)=subplot(3,5,j);
        imagesc(normalizedE);
        colorbar
        title(num2str(Freq(displayFreq(j))))
        end

    end
    if plotEigs ==1
        suptitle(['Mouse ID ', num2str(exp), ' Iso:', num2str(info.AnesLevel)])
    else
        plot(Freq(displayFreq), eCorrSum)
        suptitle(['Mouse ID ', num2str(exp), ' Iso:', num2str(info.AnesLevel)])
    end
end



%%

figure
