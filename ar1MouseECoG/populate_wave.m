function [data] = populate_wave(wave_data, x_grid, y_grid, times)
    % Inputs:
    % time:     always in seconds, this is important for giving you the
    %           correct sampling rate
    
    data = zeros(size(x_grid,1), size(y_grid,2), length(times));
    
    X = x_grid;
    Y = y_grid;
    
    timesteps = wave_data.timesteps;
    
    maxTime = min(length(times), length(timesteps));
    
    switch wave_data.type
        case 'plane'
            for i = 1:maxTime
                %vars
                theta = wave_data.theta(i);
                spatial_freq = wave_data.spatial_freq(i);
                A = wave_data.amplitude(i);
                freq = wave_data.temp_freq(i);

                %phase distribution
                phase = spatial_freq*(-cos(theta)*X + sin(theta)*Y);

                %wave distribution
                data(:,:,timesteps(i)) = A*cos((freq*times(i))*(2*pi) + phase);
            end
            
        case 'rotational'
            for i = 1:maxTime
                %vars
                x_center = wave_data.x_center(i);
                y_center = wave_data.y_center(i);
                spatial_freq = wave_data.spatial_freq(i);
                A = wave_data.amplitude(i);
                freq = wave_data.temp_freq(i);

                %phase distribution
                phase = spatial_freq*atan2(x_grid-y_center, y_grid-x_center);

                %wave distribution
                data(:,:,timesteps(i)) = A*cos((freq*times(i))*(2*pi) + phase);
            end

        case 'target'
            for i = 1:maxTime
                %vars
                x_center = wave_data.x_center(i);
                y_center = wave_data.y_center(i);
                spatial_freq = wave_data.spatial_freq(i);
                A = wave_data.amplitude(i);
                freq = wave_data.temp_freq(i);

                %phase distribution
                phase = -spatial_freq*sqrt((X-x_center).^2 + (Y-y_center).^2);

                %wave distribution
                data(:,:,timesteps(i)) = A*cos((freq*times(i))*(2*pi) + phase);
            end

        end
end