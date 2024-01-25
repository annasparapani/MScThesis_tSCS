%EXAMPLE - Sample data
%   Simplest example of sampling data from a device.

% Initialize the library
lib = TMSiSAGA.Library();

% Code within the try-catch to ensure that all devices are stopped and 
% closed properly in case of a failure.
try
    % Get a single device from the connected devices
    % possible interfaces 'usb'/'network' and 'electrical'/'optical/'wifi'
    device = lib.getFirstAvailableDevice('usb', 'electrical');
    
    % Open a connection to the device
    device.connect();
    
    % Reset device config
    device.resetDeviceConfig();
    
    % We need to update the configuration of the device
    device.updateDeviceConfig();
  
    % Start sampling on the device
    device.start();
    
   i=1;
   % Sample 10 times.
    while i<=10
        % Sample from device
        [samples, num_sets, type] = device.sample()
        
         if num_sets > 0
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