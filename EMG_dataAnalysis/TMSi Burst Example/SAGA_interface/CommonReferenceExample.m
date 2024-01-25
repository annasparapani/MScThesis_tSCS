% Add path to /+TMSiSAGA folder
addpath('../');

% Step 2: Calculate max EMG signal


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
    device.setReferenceMethod('common');
    device.setAutoReferenceMethod(true);
    
    % We need to update the configuration of the device
    device.updateDeviceConfig();

    % Create a memory storage
    fplot = TMSiSAGA.RealTimePlot('Plot', device.sample_rate, device.getActiveChannels());
    fplot.show();
    data = TMSiSAGA.Data('Plot', device.sample_rate, device.getActiveChannels());
    
    % Start sampling on the device
    device.start();
    
    % Sample untill plot is closed
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
    
   % Disconnect from device
    device.disconnect();
catch e
    % In case of an error close all still active devices and clean up
    % library itself
    lib.cleanUp();
    
    % Rethrow error to ensure you get a message in console
    rethrow(e)
end