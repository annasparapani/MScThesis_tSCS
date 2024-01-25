%EXAMPLE - EMG Example
%   First measure the maximum intensity of a muscle. Which then is used to
%   calculate the 'relative' intensity and shown in a real-time plot. Uses
%   channel UNI1 and UNI2.

% Initialize the library
lib = TMSiSAGA.Library();

% Code within the try-catch to ensure that all devices are stopped and 
% closed properly in case of a failure.
try
    % Get a single device from the connected devices
    device = lib.getFirstAvailableDevice('usb', 'electrical');
    
    % Open a connection to the device
    device.connect();
    
    % Reset device config
    device.resetDeviceConfig();
    
    % Set settings
    % Only selected channels
    device.setReferenceMethod('common');
    device.setAutoReferenceMethod(true);
    device.disableChannels(device.channels);
    device.enableChannels(2:3);
    
    % We need to update the configuration of the device
    device.updateDeviceConfig();

    % =====================================================================
    %   Calculate intensity
    % =====================================================================
    % Create a memory storage
    fplot = TMSiSAGA.RealTimePlot('Plot', device.sample_rate, device.getActiveChannels());
    fplot.show();
    data = TMSiSAGA.Data('Plot', device.sample_rate, device.getActiveChannels());
    
    % Start sampling on the device
    device.start();
    
    % For a hundred sampling of the device append it to the data object
    while fplot.is_visible
        % Sample from device
        [samples, num_sets, type] = device.sample();
        
        % Append samples to the plot and redraw
        if num_sets > 0
            data.append(samples);
            fplot.append(samples);
            fplot.updateScale();
            fplot.draw();
        end
    end
    
    % Cleanup internal data storage buffer
    data.trim();
    
    % Stop sampling on the device
    device.stop();
    
    disp('Select interval to calculate max intensity');
    plot(data.samples(2, :));
    interval = round(ginput(2));

    interval = interval(1, 1):interval(2, 1);
    mean_max_intensity = max(abs(data.samples(1, interval) - data.samples(2, interval)));

    % =====================================================================
    %   EMG Measurement
    % =====================================================================

    % Create a real time plot
    rPlot = TMSiSAGA.RealTimePlot('Plot', device.sample_rate, {struct('alternative_name', 'Intensity', 'unit_name', '%')});
    rPlot.show();
    
    % Start sampling on the device
    device.start();
    
    % As long as we do not press the X or 'q' keep on sampling from the
    % device.
    while rPlot.is_visible
        % Sample from device
        [samples, num_sets, type] = device.sample();
        
        % Append samples to the plot and redraw
        if num_sets > 0
            % Calculate max intensity
            samples = abs(samples(1, :) - samples(2, :)) ./ mean_max_intensity .* 100;
            
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