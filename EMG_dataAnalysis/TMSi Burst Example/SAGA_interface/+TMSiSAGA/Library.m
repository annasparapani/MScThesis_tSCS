classdef Library < TMSiSAGA.HiddenHandle
    %LIBRARY Class to initialize the TMSiSAGA library.
    %
    %   This class has to be instantized atleast once in your application. It will allow you
    %   to query devices, based on the interface of the docking station and data recorder. 
    %   It also keeps track of which devices are currently in open state and/or are currently
    %   in sampling mode. The function cleanUp(), can be used to stop all sampling and disconnect
    %   all devices created with this library, it will also unload the currently library to leave
    %   the entire system in a stable state. The function cleanUp() should be used in a try catch
    %   statement (see examples on how to use it).
    %
    %LIBRARY Properties:
    %   connected_devices - Keep tracks of all open devices
    %   sampling_devices - Keep track of all sampling devices
    %   
    %LIBRARY Methods:
    %   Library - Constructor to create an instance of this object.
    %   getDevices - Get a list of Device objects of all found devices.
    %   getDevice - Get a single Device object based on id and interface type.
    %   getFirstAvailableDevice - Get first available device on given interfaces.
    %   deviceConnected - (internal use) Called when a device connects.
    %   deviceDisconnected - (internal use) Called when a device disconnects.
    %   deviceStartedSampling - (internal use) Called when a device starts sampling.
    %   deviceStoppedSampling - (internal use) Called when a device stops sampling.
    %   stopSamplingOnAllDevices - Stop all devices that are currently sampling.
    %   disconnectAllDevices - Disconnect all device that are currently open.
    %   cleanUp - All devices stop sampling, and are disconnected, and library is unloaded.
    %
    %LIBRARY Example 1:
    %   library = TMSiSAGA.Library();
    %
    %   device = library.getFirstAvailableDevice('network', 'electrical');
    %
    %   library.cleanUp();
    %
    %LIBRARY Example 2:
    %   library = TMSiSAGA.Library();
    %   
    %   try
    %       % Code and device sampling here
    %   catch e
    %       library.cleanUp();
    %   end
    %
    %LIBRARY Example 3:
    %   library = TMSiSAGA.Library();
    %   
    %   try
    %       device = library.getDevice(1, 'wifi');
    %
    %       % Code and device sampling here
    %   catch e
    %       library.cleanUp();
    %   end

    properties
        % Keep tracks of all open devices
        connected_devices

        % Keep track of all sampling devices
        sampling_devices 
    end

    methods
        function obj = Library(obj)
            %LIBRARY - Initialize the library 
            
            obj.connected_devices = {};
            obj.sampling_devices = {};

            obj.loadLibrary();
        end

        function devices = getDevices(obj, ds_interface, dr_interface)
            %GETDEVICES - Get a list of devices that are connected to the
            %PC with the specified interfaces. By default it searches on
            %ds_interface = network and dr_interface = electrical.
            
            if ~exist('ds_interface', 'var')
                ds_interface = 'network';
            end
        
            if ~exist('dr_interface', 'var')
                dr_interface = 'electrical';
            end
        
            devices = TMSiSAGA.DeviceLib.getDeviceList(...
                TMSiSAGA.TMSiUtils.toInterfaceTypeNumber(ds_interface), ...
                TMSiSAGA.TMSiUtils.toInterfaceTypeNumber(dr_interface));
        
            devices_r = {};
            for i=1:numel(devices)
                devices_r{i} = TMSiSAGA.Device(obj, int64(devices(i).TMSiDeviceID), dr_interface);
            end
        
            devices = devices_r;
        end

        function device = getDevice(obj, device_id, dr_interface)
            %GETDEVICE - Get a single device by ID and DR interface.
            
            device = TMSiSAGA.Device(obj, int64(device_id), dr_interface);
        end

        function device = getFirstAvailableDevice(obj, ds_interface, dr_interface)
            %GETFIRSTAVAILABLEDEVICE - Get the first device available on
            %the selected interfaces. It will select the first one that is
            %'available', this is just the first device that is returned by
            %the getDevices function.
            
            if ~exist('ds_interface', 'var')
                ds_interface = 'network';
            end
        
            if ~exist('dr_interface', 'var')
                dr_interface = 'electrical';
            end
        
            devices = obj.getDevices(ds_interface, dr_interface);
        
            if numel(devices) < 1
                throw(MException('getFirstDevice', 'No device found'));
            end
        
            device = devices{1};
        end

        function deviceConnected(obj, device)
            %DEVICECONNECTED - This function is used by the framework to
            %keep track what device has been connected so far. Should not be
            %used by the user.
            
            for i=1:numel(obj.connected_devices)
                if obj.connected_devices{i}.device_id == device.device_id
                    return
                end
            end

            obj.connected_devices{numel(obj.connected_devices) + 1} = device;
        end

        function deviceDisconnected(obj, device)
            %DEVICEDISCONNECTED - This function is used by the framework to
            %keep track which device has been disconnected. Should not be
            %used by the user.
            
            index = false(1, numel(obj.connected_devices));
            
            for i=1:numel(obj.connected_devices)
                index(i) = obj.connected_devices{i}.device_id ~= device.device_id;
            end

            obj.connected_devices = obj.connected_devices(index);
        end

        function deviceStartedSampling(obj, device)
            %DEVICESTARTEDSAMPLING - Is called by the framework when a
            %device has started sampling. Should not be called by the user
            %directly.
            
            for i=1:numel(obj.sampling_devices)
                if obj.sampling_devices{i}.device_id == device.device_id
                    return
                end
            end

            obj.sampling_devices{numel(obj.sampling_devices) + 1} = device;
        end

        function deviceStoppedSampling(obj, device)
            %DEVICESTOPPEDSAMPLING - Is called by the framework when a
            %device has stopped sampling. Should not be called by the user
            %directly.
            
            index = false(1, numel(obj.sampling_devices));
            
            for i=1:numel(obj.sampling_devices)
                index(i) = obj.sampling_devices{i}.device_id ~= device.device_id;
            end

            obj.sampling_devices = obj.sampling_devices(index);
        end

        function stopSamplingOnAllDevices(obj)
            %STOPSAMPLINGONALLDEVICES - A function that can be called to
            %stop sampling on all connected and sampling devices.
            
            for i=1:numel(obj.sampling_devices)
                obj.sampling_devices{i}.stop();
            end
        end

        function disconnectAllDevices(obj)
            %DISCONNECTALLDEVICES - A function that can be called to
            %disconnect all devices that are currently connected.
            
            for i=1:numel(obj.connected_devices)
                obj.connected_devices{i}.disconnect();
            end
        end

        function cleanUp(obj)
            %CLEANUP - Call this function when you have to 'reset' the
            %devices. It will stop sampling on all devices, then
            %disconnects all devices and finally unloads the library.
            %Starting new sampling requires you to create a new library.
            
            obj.stopSamplingOnAllDevices();
            obj.disconnectAllDevices();
            obj.unloadLibrary();
        end
    end

    methods (Access = private)
        function loadLibrary(obj)
            if ~obj.libraryIsLoaded()
                loadlibrary('TMSiSagaDeviceLib.dll', @TMSiSAGA.TMSiSagaDeviceLib64);
            end
        end

        function unloadLibrary(obj)
            if obj.libraryIsLoaded()
                unloadlibrary TMSiSagaDeviceLib;
            end
        end

        function is_loaded = libraryIsLoaded(obj)
            is_loaded = libisloaded('TMSiSagaDeviceLib');
        end

    end
end