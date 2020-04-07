%% to fix my mistakes in making Giant Ass Wavelet files

%% getting rid of fake waves in wavelet folder 
% %
% % loadFreq = {};
% %
% % for f= 1:40
% %     temp = ['WAVE', num2str(f)];
% %     loadFreq{f} = {temp};
% % end
% 
% clear
% 
% cd('/data/adeeti/ecog/matFlashesJanMar2017/Wavelets')
% allData = dir('2017*.mat')
% 
% for i = 51:length(allData)
%     clearvars -except allData i %loadFreq
% %     for f = 1:40
% %         load(allData(i).name, char(loadFreq{f}))
% %     end
%     load(allData(i).name, 'COI', 'DJ', 'Freq', 'H', 'HInd', 'K', 'PARAMOUT', 'SCALE', 'WAVE1', 'WAVE10', 'WAVE11', 'WAVE12', 'WAVE13', 'WAVE14', 'WAVE15', 'WAVE16', 'WAVE17', 'WAVE18', 'WAVE19', 'WAVE2', 'WAVE20', 'WAVE21', 'WAVE22', 'WAVE23', 'WAVE24', 'WAVE25', 'WAVE26', 'WAVE27', 'WAVE28', 'WAVE29', 'WAVE3', 'WAVE30', 'WAVE31', 'WAVE32', 'WAVE33', 'WAVE34', 'WAVE35', 'WAVE36', 'WAVE37', 'WAVE38', 'WAVE39', 'WAVE4', 'WAVE40', 'WAVE5', 'WAVE6', 'WAVE7', 'WAVE8', 'WAVE9', 'filtSingal', 'filtSingalInd')
%     save(allData(i).name, 'info', 'COI', 'DJ', 'Freq', 'H', 'HInd', 'K', 'PARAMOUT', 'SCALE', 'WAVE1', 'WAVE10', 'WAVE11', 'WAVE12', 'WAVE13', 'WAVE14', 'WAVE15', 'WAVE16', 'WAVE17', 'WAVE18', 'WAVE19', 'WAVE2', 'WAVE20', 'WAVE21', 'WAVE22', 'WAVE23', 'WAVE24', 'WAVE25', 'WAVE26', 'WAVE27', 'WAVE28', 'WAVE29', 'WAVE3', 'WAVE30', 'WAVE31', 'WAVE32', 'WAVE33', 'WAVE34', 'WAVE35', 'WAVE36', 'WAVE37', 'WAVE38', 'WAVE39', 'WAVE4', 'WAVE40', 'WAVE5', 'WAVE6', 'WAVE7', 'WAVE8', 'WAVE9', 'filtSingal', 'filtSingalInd')
%     disp(['Saving experiment ', num2str(i), ' out of ', num2str(length(allData))])
% end
% 
% %% Putting V1 in info files
% 
% clear
% 
% cd('/data/adeeti/ecog/matFlashesJanMar2017/')
% [allV1] = V1forEachMouse(pwd);
% allData = dir('2017*.mat');
% 
% for i = 31:length(allData)
%     load(allData(i).name, 'info')
%     V1 = allV1(2,(find(allV1(1,:)== info.exp)));
%     info.V1 = V1;
%     save(allData(i).name, 'info', '-append')
%     disp(['Saving experiment ', num2str(i), ' out of ', num2str(length(allData))])
% end


%% Putting info for each experiment in wavelets folder
% 
% clear
% 
% cd('/data/adeeti/ecog/matFlashesJanMar2017/Wavelets')
% allData = dir('2017*.mat')
% 
% for i = 35:length(allData)
%     temp = allData(i).name;
%     temp = temp(1:end-8);
%     temp = [temp, '.mat'];
%     load(['/data/adeeti/ecog/matFlashesJanMar2017/', temp], 'info')
%     save(allData(i).name, 'info', '-append')
%     disp(['Saving experiment ', num2str(i), ' out of ', num2str(length(allData))])
% end

%%
clear
moviesCoherence


% %% 
% clear
% interSitePhaseClustering_AA

%%
clear
savingITPCforallExp


