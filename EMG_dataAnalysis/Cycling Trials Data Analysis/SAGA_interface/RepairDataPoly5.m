%EXAMPLE - Repair missing data
%   While sampling if you have missing data, you can retrieve missing
%   samples. Example with sampling to Poly5.

% Initialize the library
lib = TMSiSAGA.Library();

% Code within the try-catch to ensure that all devices are stopped and 
% closed properly in case of a failure.
try
    % Get a single device from the connected devices
    device = lib.getFirstAvailableDevice('usb', 'wifi');
    
    % Wait for the device to be ready
    disp('Wait for the device to be connected to wifi.');
    pause
    
    % Open a connection to the device
    device.connect();
	
	% Read device configuration
	device.getDeviceConfig(); 
        
    % Turn on repair logging
    device.setRepairLogging(true);
    
    % We need to update the configuration of the device
    device.updateDeviceConfig();
    
    % Create a real time plot
    rPlot = TMSiSAGA.RealTimePlot('µPlot', device.sample_rate, device.getActiveChannels());
    rPlot.show();
    
    % Create a file storage
    poly5 = TMSiSAGA.Poly5('./RepairData.poly5', 'Plot', device.sample_rate, device.getActiveChannels());
    
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
    
    % Get repair data
    [repair_data, num_sets] = device.getMissingSamples();
    
    % Repair data and save to RepairData.poly5.repaired.poly5
    TMSiSAGA.Repair.repairPoly5('RepairData.poly5', repair_data, numel(device.getActiveChannels()));
    
    % Disconnect from device
    device.disconnect();
catch e
    % In case of an error close all still active devices and clean up
    % library itself
    lib.cleanUp();
    
    % Rethrow error to ensure you get a message in console
    rethrow(e)
end