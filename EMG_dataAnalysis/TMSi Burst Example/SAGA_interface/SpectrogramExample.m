%EXAMPLE - Spectrogram example
%   Shows the frequencies in the signals over time. On the x-axis is time,
%   on the y-axis is the frequency domain running from 0Hz to 1000Hz.

% Initialize the library
lib = TMSiSAGA.Library();

% Code within the try-catch to ensure that all devices are stopped and 
% closed properly in case of a failure.
try
    % Get a single device from the connected devices
    device = lib.getFirstAvailableDevice('network', 'electrical');
    
    % Open a connection to the device
    device.connect();
    
    % Reset device config
    device.resetDeviceConfig();
    
    device.disableChannels(device.channels);
    device.enableChannels(1:2);
    
    % We need to update the configuration of the device
    device.updateDeviceConfig();
    
    % Create a real time plot
    rPlot = TMSiSAGA.RealTimePlot('Plot', device.sample_rate, device.getActiveChannels());
    rPlot.show();
    
    % Spectogram settings
    window_size = 30;
    window_sec = 0.1;
    num_blocks = window_size / window_sec;
    window_samples = floor(window_sec * device.sample_rate());
    sample_buffer = zeros(numel(device.getActiveChannels()), 0);
    
    % Figure for spectrum
    fig_handle = figure('Name', 'Spectral Density');
    plot_handle = imagesc('CData', 0);
    xlim([0 window_size-1]);
    ylim([0 device.sample_rate / 2]);
    colorbar;
    
    % Pre-allocate
    spectrogram = zeros(floor(window_samples / 2 + 1), num_blocks);
    at_block = 0;
    
    % Start sampling on the device
    device.start();
    
    % As long as we do not press the X or 'q' keep on sampling from the
    % device.
    while rPlot.is_visible
        % Sample from device
        [samples, num_sets, type] = device.sample();
        
        if num_sets > 0
            % Append samples to a buffer, so we have always have a minimum of window_samples.
            sample_buffer(:, size(sample_buffer, 2) + size(samples, 2)) = 0;
            sample_buffer(:, end-size(samples, 2) + 1:end) = samples;

            % As long as we have enough samples calculate FFT and plot it.
            while size(sample_buffer, 2) >= window_samples
                fft_y = fft(sample_buffer(1, 1:window_samples));
                length = size(sample_buffer(1, 1:window_samples), 2);

                P2 = abs(fft_y / length);
                P1 = P2(1:length / 2 + 1);
                P1(2:end-1) = 2*P1(2:end-1);
                f = double(device.sample_rate) * (0:(length / 2)) / length;

                x = f;
                y = P1;

                spectrogram(:, mod(at_block, num_blocks) + 1) = y;

                set(plot_handle, 'XData', 0:window_sec:window_size-1, 'YData', x, 'CData', spectrogram);
                drawnow;

                at_block = at_block + 1;
                sample_buffer = sample_buffer(:, window_samples + 1:end);
            end
        
            % Append samples to the plot and redraw
            rPlot.append(samples);
            rPlot.draw();
        end
    end
    
    % Stop sampling on the device
    device.stop();
    
    % Disconnect from device
    device.disconnect();
catch e
    % In case of an error close all still active devices and clean up
    % library itself
    lib.cleanUp();
    
    % Rethrow error to ensure you get a message in console
    rethrow(e)
end