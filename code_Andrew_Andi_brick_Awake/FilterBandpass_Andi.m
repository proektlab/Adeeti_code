%%
clear all

Datadir = '/Users/Brenna/Documents/AndiData/';
name = 'M10';

Direction = {'IND', 'EMG'}; % create strings to specify induction or emergence

% for direc = 1:2
% %% Substrace average and filter signals
%     d = load([Datadir, name, '/cleaned_', Direction{direc}, '.mat'], 'cleandata');
%     data = d.cleandata;
%     
%     wfilt_data = cell(3,1);
%     H_wfilt_data = cell(3,1);
%     for f = 1:size(data,2)
%         bigY = data{f}(:,:);
%         channum = size(bigY,2);
%         for chan = 1:channum
%             Y = bigY(:,chan);
%
%
%         end
% %         clf
% %         kp = 0;
% %         for i = 1 
% %             subplot(2,1,kp+1), plot(Y(20000:22500,1)); axis tight; 
% %             title(['Original signal ',num2str(i*6)])
% %             subplot(2,1,kp+2), plot(Y_den(20000:22500,1)); axis tight;
% %             title(['Denoised signal ',num2str(i*6)])
% %             kp = kp + 2;
% %         end
%         wfilt_data{f,1} = Y_den;
%         H_wfilt_data{f,1} = hilbert(Y_den);
%         
%         clearvars Y_den
%     end
%     
%     clearvars Y temp den_signal
%     
%     save([Datadir, name,'/waveletfilt_', Direction{direc}],'wfilt_data')
%     save([Datadir, name,'/Hilb_waveletfilt_', Direction{direc}],'H_wfilt_data')
% end

%% Bandpass filter

% It may not actually be a bandpass filter that I want here. I need to read
% and look at what range of frequencies people use. I may want to use a
% lowpass filter instead.

% Parameters for filter design
n = 100; % filter order
% f is a vector of frequecy points between 0 and 1. These numbers define important points along the x axis.
%   Here, 1 is equal to the Nyquist frequency.
%   A larger distance between points 2 and 3 and points 4 and 5 define a
%   smoother filter that will have less ringing.
f = [0, 4/125, 5/125, 40/125, 44/125, 125/125]; % I don't remember the signficance of the number 125. It may have just been something I was trying when things worked.
% a is a vector of desired amplitude for the points defined in f.
a = [0, 0, 1, 1, 0, 0];

b = firls(n, f, a);

figure(1);
clf;
[H,g] = freqz(b,1,512,2);
plot(g,abs(H))
hold on
for i = 1:2:length(a) 
   plot([f(i) f(i+1)],[a(i) a(i+1)],'r--')
end
legend('firls design','Ideal')
grid on
xlabel('Normalized Frequency (\times\pi rad/sample)')
ylabel('Magnitude')



b = firls(n, f, a);