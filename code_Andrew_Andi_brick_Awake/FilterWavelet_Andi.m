%%
clear all

Datadir = '/Users/Brenna/Documents/AndiData/';
name = 'M10';

Direction = {'IND', 'EMG'}; % create strings to specify induction or emergence

for direc = 1:2
%% Substrace average and filter signals
    d = load([Datadir, name, '/cleaned_', Direction{direc}, '.mat'], 'cleandata');
    data = d.cleandata;
    
    wfilt_data = cell(3,1);
    H_wfilt_data = cell(3,1);
    for f = 1:size(data,2)
        bigY = data{f}(:,:);
        channum = size(bigY,2);
        for chan = 1:channum
            Y = bigY(:,chan);
    %         % use wavelets to filter data and create spectrogram
    %         mother = 'DOG';
    %         param = -1;
    %         dt = 1;
    %         s0 = 0.1;
    %         dj = 0.1;
    %         J1 = -1; % set to default
    %         pad = -1;   
    % 
    %         [wave,period,scale,coi] = wavelet(Y,dt,pad,dj,s0,J1,mother,param);

            % This seems really dumb, but I need to break the signal into steps
            % to make the wavelet denoising function work.
            MAX_SAMPLES = 50000;
            % size(Y,1) is the size of my samples vector.
            steps = ceil(size(Y,1)/MAX_SAMPLES);

            level = 5;
            wname = 'sym4';
            tptr  = 'sqtwolog';
            sorh  = 's';
            npc_app = 'heur';
            npc_fin = 'heur';

            den_signal = zeros(size(Y,1),1);

            for i=1:steps
                if (i*MAX_SAMPLES) <= size(Y,1)
                   temp = wmulden(Y((((i-1)*MAX_SAMPLES) + 1):(i*MAX_SAMPLES)), level, wname, npc_app, npc_fin, tptr, sorh);
                   den_signal((((i-1)*MAX_SAMPLES) + 1):i*MAX_SAMPLES) = temp;
                else
                    old_step = (((i-1)*MAX_SAMPLES) + 1);
                    new_step = size(Y,1) - old_step;
                    last_step = old_step + new_step;
                    temp = wmulden(Y((((i-1)*MAX_SAMPLES) + 1):last_step ), level, wname, npc_app, npc_fin, tptr, sorh);
                    den_signal((((i-1)*MAX_SAMPLES) + 1):last_step) = temp;
                end
            end
            Y_den(:,chan) = den_signal;
        end
%         clf
%         kp = 0;
%         for i = 1 
%             subplot(2,1,kp+1), plot(Y(20000:22500,1)); axis tight; 
%             title(['Original signal ',num2str(i*6)])
%             subplot(2,1,kp+2), plot(Y_den(20000:22500,1)); axis tight;
%             title(['Denoised signal ',num2str(i*6)])
%             kp = kp + 2;
%         end
        wfilt_data{f,1} = Y_den;
        H_wfilt_data{f,1} = hilbert(Y_den);
        
        clearvars Y_den
    end
    
    clearvars Y temp den_signal
    
    save([Datadir, name,'/waveletfilt_', Direction{direc}],'wfilt_data')
    save([Datadir, name,'/Hilb_waveletfilt_', Direction{direc}],'H_wfilt_data')
end