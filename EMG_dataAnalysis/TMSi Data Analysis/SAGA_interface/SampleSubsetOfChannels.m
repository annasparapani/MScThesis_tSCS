%EXAMPLE - Sample data from a subset of channels.
%   Instead of sampling all channels, a subset of channels can be used.

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
    
    % Disable all channels
    device.disableChannels(device.channels);
    
    % Enable the first 4 channels
    device.enableChannels(2:5);
    device.channels{2}.setAlternativeName('Fp1');
    device.channels{3}.setAlternativeName('Fp2');
    device.channels{4}.setAlternativeName('F7');
    device.channels{5}.setAlternativeName('F3');
    
    % Set sample rate to 1000Hz
    device.setBaseSampleRate(4000);
    device.setDividers('uni', 2);
    
    % We need to update the configuration of the device
    device.updateDeviceConfig();
    
    % Create a real time plot
    rPlot = TMSiSAGA.RealTimePlot('Plot', device.sample_rate, device.getActiveChannels());
    rPlot.show();
    
    % Create a file storage
    data = TMSiSAGA.Data('Plot', device.sample_rate, device.getActiveChannels());
    
    % Start sampling on the device
    device.start();
    
    % As long as we do not press the X or 'q' keep on sampling from the
    % device.
    while rPlot.is_visible
        % Sample from device
        [samples, num_sets, type] = device.sample();
        
        % Append samples to the plot and redraw
        if num_sets > 0
            rPlot.append(samples);
            rPlot.draw();
            data.append(samples);
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