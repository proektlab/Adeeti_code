%% Trying out AR1 on my data 

genDir = '/synology/adeeti/ecog/iso_awake_VEPs/GL7/';

experiment = '2019-11-26_18-07-00.mat';

cd(genDir)

load(experiment, 'info', 'meanSubData', 'meanSubFullTrace')

time4AR1 = 1:5000;

data 




































































srate = 1000;
temp_freqs = 1;
base_freq = 35; %in Hz
delta_freq = 1; % how much to change by
noise_levels = [.5, 1, 2];

for k = 1:numel(noise_levels)
    noise_amp = noise_levels(k);
    %make data
    wave_array = struct();
    for i=1
        wave_array(i).type = 'plane';
        wave_array(i).y_center = ones(1,5000);
        wave_array(i).x_center = ones(1,5000);
        wave_array(i).theta = ones(1,5000);
        wave_array(i).temp_freq = ones(1,5000);
        wave_array(i).spatial_freq = ones(1,5000)*5;
        wave_array(i).amplitude = ones(1,5000);
        wave_array(i).timesteps = [1:5000]; %in s
    end
    
    % add changing freq over time
    wave_array(1).temp_freq = base_freq - delta_freq.*(sin((temp_freqs(1).*(2*pi))./srate*(1:5000)));
    
    %initialize grid
    x = -1:0.1:1; %num electrodes
    y = 0;
    [X, Y] = meshgrid(x, y);
    times = (1:5000)*(1/srate);
    
    data = populate_wave(wave_array(1), X, Y, times);
    combined_data_rand = data; + normrnd(0,noise_amp,size(data));
    combined_data = combined_data_rand; %for ar1
    yetAnotherData = data;
    data = squeeze(data);
    ar1_output = zeros(100,4536);
    wavelet_output = zeros(100,4536);
    analysis_output = struct();
    for j = 1:2
        %add new randomness to wave
        combined_data_rand = data + normrnd(0,2,size(data));
        % wave done, now use wavelet to get phase
        freq = 1:.1:100;
        srate = 1000;
        window = 3;
        
        % visualize peaks at pi*frequency. The change in power is due to how the
        % wavelet cuts off parts of the window based on the window size
        c = window*pi;
        
        % 5th input is for baseline: no baseline correction here
        [wvlt_amp, ~] = morletwave(freq,c,squeeze(combined_data_rand(1,:)),srate,0);
        
        %peaks(i) = max(wvlt_amp(:,:,1));
        
        % ar1
        %define constants
        win = numel(x)*3; % twice the number of electrodes
        n_tp = size(combined_data_rand, 2);
        data = reshape(combined_data_rand, [] ,n_tp);
        n_eig = 4;
        
        % initialize A - elec x elec x time
        A = zeros(numel(x), numel(x), (n_tp - win));
        % initialize eigenvalues and vectors
        eig_vect = zeros(numel(x), n_eig, (n_tp - win));
        eig_val = zeros(n_eig, (n_tp - win));
        
        for i = 1:n_tp - win
            A_curr = zeros(numel(x), numel(x));
            %fprintf('\n...%d', i)
            % get time chunk
            data_chunk = data(:,i:i+win);
            
            % demean
            data_chunk = data_chunk - repmat(mean(data_chunk,2), [1, size(data_chunk,2)]);
            % y = data_chunk(:,2:end);
            % x_hat = data_chunk(:, 1:end-1);
            
            % get A
            [w,A_curr,C] = arfit(data_chunk',1,1,'sbc'); % data_n should be a time chunk;
            %for j = 1:numel(x)
            %    A_curr(j,:) = y(j,:)'\x_hat';
            %end
            
            A(:,:,i) = A_curr;
            [vect, val] = eigs(A_curr, n_eig);
            eig_val(:,i) = diag(val);
            eig_vect(:,:,i) = vect;
        end
        
        %correct ar1 output
        ar1_extracted_frequencies = (angle(eig_val(1,:))./(2*pi)).*srate;
        %
        %     %correct wavelet output
        wavelet_output_tmp = squeeze(wvlt_amp(31:end,:,1));
        %wavelet_output(1:30,:) = []; %correct to make sure max isn't first few frequencies
        freq_new = freq(31:end); %freq_new(1:30) = [];
        wavelet_output_tmp = wavelet_output_tmp(:,win+1:end); %correct offset to be the same as AR1 (used to be setting to [])
        [~, max_freq_index] = max(wavelet_output_tmp);
        wavelet_extracted_frequencies = freq_new(max_freq_index);
        
        %take out first & last 200 ms
        ar1_extracted_frequencies = ar1_extracted_frequencies(201:end-201);
        wavelet_extracted_frequencies = wavelet_extracted_frequencies(201:end-201);
        disp(['ar1 - ' num2str(numel(ar1_extracted_frequencies))]);
        disp(['wavelet - ' num2str(numel(wavelet_extracted_frequencies))]);
        %load into output array
        ar1_output(j,:) = ar1_extracted_frequencies;
        wavelet_output(j,:) = wavelet_extracted_frequencies;
    end
    
    %get true frequencies
    rawData = squeeze(yetAnotherData(1,1,:));
    [~, peakTimes] = findpeaks(rawData);
    frequencyTimes = peakTimes;
    frequencies = diff(peakTimes);
    frequencies(end+1) = frequencies(end);
    trueFrequencies = [interp1(frequencyTimes, srate./frequencies, 1:5000)];
    sigma = 50;
    x = -3*sigma:3*sigma;
    gaussianFilter = exp(-x.^2/(2*sigma^2));
    gaussianFilter = gaussianFilter ./ sum(gaussianFilter);
    trueFrequencies = convn(trueFrequencies, gaussianFilter, 'same');
    trueFrequencies = trueFrequencies(201:end-201);
    % cut out additional window length
    trueFrequencies = trueFrequencies(win+1:end);
    %trueFrequencies(1:63) = [];
    %trueFrequencies(1:200) = [];
    %trueFrequencies(numel(trueFrequencies)-200:numel(trueFrequencies)) = [];
    
    % run stats
    [wave_zscore_avg, wave_zscore] = return_avg_zcore(trueFrequencies, wavelet_output);
    [ar1_zscore_avg, ar1_zscore] = return_avg_zcore(trueFrequencies, ar1_output);
    save(['C:\Users\jenis\tcnproject\ar1MouseECoG\noise_', num2str(k)], ...
        'wave_zscore', 'wave_zscore_avg', 'ar1_zscore', 'ar1_zscore_avg')
    clear wavelet_zscore ar1_zscore trueFrequencies wavelet_output ar1_output
end