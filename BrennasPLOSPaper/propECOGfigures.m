%%
ch = 17;

load('/data/adeeti/ecog/rawJanMar2017/rawPropJanMar2017/2017-03-01_16-25-56/CSC64.mat', 'blah')
stupidFactor = regexp(blah{16},['[.\d]+'],'match');
stupidFactor = str2num(stupidFactor{1});


load('/data/adeeti/ecog/matBaselinePropJanMar2017/lulls/2017-03-01_16-11-50.mat')
lull1 = 1;
data1 = meanSubData{lull1}(17,:);
time1 = finalTime{lull1};

%eegplot(data1, 'srate', finalSampR);

%time=fliplr(-1.*finalTime);
segment1=find(time1>140 & time1<150);
trace1=data1(segment1);
trace1 = trace1*stupidFactor;

%%
load('/data/adeeti/ecog/matBaselinePropJanMar2017/lulls/2017-03-01_16-25-56.mat');
lull2 = 2;
data2 = squeeze(meanSubData{lull2}(ch,:));
time2 = finalTime{lull2};

%eegplot(data2, 'srate', finalSampR);

%concatData = reshape(permute(meanSubData, [1 3 2]), 64, (size(meanSubData,2)*3001));
%time=(0:size(concatData,2)-1)./1000;
%segment=find(time>=20 & time{3}<=30);
%%
segment2=find(time2>=130 &time2<=140);
trace2=data2(segment2);
trace2 = trace2*stupidFactor;

%%

ff=figure('color', 'w');
%%
h=zeros(2,1);

h(1)=subplot(2,1,1);
plot(trace1,'k', 'linewidth', 1);

title('Target concentration 10 \mug/g', 'FontName', 'Arial', 'FontSize', 20);

h(2)=subplot(2,1,2);
plot(trace2, 'k', 'linewidth', 1);

hold on;
line([2000, 3000], [-(2*10^-4), -(2*10^-4)], 'linewidth', 2, 'color','k');
line([2000, 2000], [-(2*10^-4),-(1*10^-4)], 'linewidth', 2, 'color','k');
text(2500, -(2.3*10^-4), '1 s', 'FontName', 'Arial','FontSize', 14, 'HorizontalAlignment', 'center'); 
text(1800, -(1.5*10^-4), ['100 ', char(181), 'V'], 'FontName', 'Arial','FontSize', 14, 'HorizontalAlignment', 'center'); 
title('Target concentration 15 \mug/g', 'FontName', 'Arial', 'FontSize', 20);
hold off;



%%

set(h, 'Xcolor', 'none', 'Ycolor', 'none');
set(h, 'xlim', [0 10000], 'ylim', [-(4*10^-4),(4*10^-4)]);
%%
print(ff, ['/data/adeeti/ecog/propCompConLargeDiff.pdf'],'-dpdf', '-fillpage')
%%
print(ff, ['/data/adeeti/ecog/propCompConLargeDiff.svg'],'-dsvg')
%%
print(ff, ['/data/adeeti/ecog/propCompConLargeDiff.eps'],'-deps')