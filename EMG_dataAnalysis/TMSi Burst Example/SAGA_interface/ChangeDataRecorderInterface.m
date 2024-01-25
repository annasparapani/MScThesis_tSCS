%EXAMPLE - Change data recorder interface
%   Shows how to change the interface being used by the data recorder.

% Initialize the library
lib = TMSiSAGA.Library();

% Code within the try-catch to ensure that all devices are stopped and 
% closed properly in case of a failure.
try
    % Get a single device from the connected devices
    device = lib.getFirstAvailableDevice('usb', 'electrical');
    
    % Open a connection to the device
    device.connect();

	% Read the device configuration
	device.getDeviceConfig(); 
	
    % Disable all channels
    device.disableChannels(device.channels);
    
    % Enable the first 32 unipolar channels
    device.enableChannels(2:33);
    
    % Set sample rate to 500Hz
    device.setBaseSampleRate(4000);
    device.setDividers('uni', 3);
    
    % We need to update the configuration of the device
    device.updateDeviceConfig();
    
    % Change interface for data recorder to wifi
    device.changeDataRecorderInterfaceTo('wifi');
       
    % Wait for the device to be ready
    disp('Wait for the device to be connected to wifi.');
    pause
    
    % Get device by wifi
    device = lib.getFirstAvailableDevice('usb', 'wifi');
    
    % Wait for the device to be ready
    disp('Wait for the device to be connected to wifi.');
    pause
     
    % Open a connection to the device
    device.connect();
    
    % Create a real time plot
    rPlot = TMSiSAGA.RealTimePlot('Plot', device.sample_rate, device.getActiveChannels());
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