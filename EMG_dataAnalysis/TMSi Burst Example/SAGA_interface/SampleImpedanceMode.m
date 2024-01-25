% Add path to /+TMSiSAGA folder
addpath('../');

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
    
    % Turn on impedance mode
    device.setImpedanceMode(true);
    
    %Channel names 
    for i=1:length(device.getActiveChannels())
        channel_names{i}=device.getActiveChannels{i}.alternative_name;
    end
    
    % Start sampling on the device
    device.start();
    pause(1)
   
    i=1;
    %Sample 10 times
    while i<=10
        % Sample from device
        [samples, num_sets, type] = device.sample();
        
        % Append samples to the plot and redraw
        % need to divide by 10^6 to obtain kOhms.
        if num_sets > 0
            s=samples ./ 10^6;
            impedances=[channel_names', num2cell(s(:,end))]
            i=i+1;
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