%EXAMPLE - Sample data from device and store as a Poly5 file.
%   Sample data from the device and stream the data to a Poly5 file. This
%   will not keep the data in memory and will stream the data as soon as
%   possible to the harddrive. Should be used in long running experiments.
% 
%   When closing the realtime plot window, sampling will stop.

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

    % We need to update the configuration of the device
    device.updateDeviceConfig();
    
    % Create a real time plot
    rPlot = TMSiSAGA.RealTimePlot('Plot', device.sample_rate, device.getActiveChannels());
    rPlot.show();
    
    % Create a file storage
    poly5 = TMSiSAGA.Poly5('./SampleToPoly5.poly5', 'Plot', device.sample_rate, device.getActiveChannels());
    
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
            poly5.append(samples);
            rPlot.draw();
        end
    end
    
    % Stop sampling on the device
    device.stop();
    
    % Close file
    poly5.close();
  
    % Disconnect from device
    device.disconnect();
catch e
    % In case of an error close all still active devices and clean up
    % library itself
    lib.cleanUp();
    
    % Rethrow error to ensure you get a message in console
    rethrow(e)
end