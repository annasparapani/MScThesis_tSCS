classdef Device < TMSiSAGA.HiddenHandle
    %DEVICE Class provides access to a single TMSi device.
    %
    %   When a device object is created the initial device config is retrieved from
    %   the device all properties are set and the connection is closed. Depending on 
    %   which functions you call some will require to "sync" your MATLAB device object
    %   with the actual device. This will require a call to updateDeviceConfig(). In case
    %   you forgot a warning will be shown in the console.
    %
    %DEVICE Properties:
    %   device_id - Device ID
    %   handle - Internal device handle for TMSi device
    %   is_connected - Keep track whether or not device is connected
    %   docking_station - Contains information about docking station
    %   data_recorder - Contains information about recording device
    %   api_version - Current API version
    %   num_batteries - Number of batteries available
    %   num_channels - Number of channels available
    %   power_state - Current power state of system
    %   batteries - Battery information
    %   time - Time information
    %   max_storage_size - Max available storage size
    %   available_storage_size - Still available storage size
    %   num_hw_channels - Number of hardware channels
    %   num_sensors - Number of sensors
    %   base_sample_rate - Current base sample rate
    %   alternative_base_sample_rate - Current alternative base sample rate
    %   interface_bandwidth - Interface bandwidth requirement
    %   triggers - Triggers enabled/disabled
    %   reference_method - Reference method enabled/disabled
    %   auto_reference_method - Auto reference method enabled/disabled
    %   repair_logging - Repair logging enabled/disabled
    %   ambulant_recording - Ambulant recording enabled/disabled
    %   avaliable_recordings - Recordings available
    %   name - Name of device
    %   channels - Channels 
    %   sensors - Sensors
    %   impedance_mode - Impedance Mode
    %   num_active_channels - Num active channels
    %   num_active_impedance_channels - Num active impedance channels
    %   missing_samples - Missing samples
    %   sample_rate - Sample rate
    %   dividers - Dividers
    %   out_of_sync - Out of Sync with device
    %   is_sampling - True, if a sampler is sampling
    %   pinkey - Pin key
    %
    %DEVICE Methods:
    %   Device - Constructor for Device object.
    %   connect - Connect to the device.
    %   disconnect - Disconnect the device.
    %   start - Start sampling in sample or impedance mode.
    %   stop - Stop sampling.
    %   sample - Retrieve samples from the device.
    %   getMissingSamples - Get missing samples after a sampling session.
    %   changeDataRecorderInterfaceTo - Change the data recorder connection interface.
    %   resetDeviceConfig - Reset the device configuration to factory settings.
    %   enableChannels - Enable channels.
    %   disableChannels - Disable channels.
    %   getSensorChannels - Get all sensor channels.
    %   getActiveChannels - Get all active channels.
    %   setImpedanceMode - Turn on/off impedance mode.
    %   setDividers - Set dividers for the different channel types (uni, bip, exg, etc.).
    %   setBaseSampleRate - Set base sample rate (4000 or 4096).
    %   setTriggers - Turn on/off triggers.
    %   setReferenceMethod - Set reference method (common or average).
    %   setAutoReferenceMethod - Turn on/off auto reference method.
    %   setRepairLogging - Turn on/off repair logging.
    %   setDataRecorderSyncOutDivider - Set data recorder sync out divider.
    %   setDataRecorderSyncOutDutyCycle - Set data recorder sync out duty cycle.
    %   updateDeviceConfig - Push the changed device configs to the actual TMSi device.
    %   getDeviceInfo - Get all device information from the device.
    %   updateDynamicInfo - Update dynamic calculated information for the device.
    %   getDeviceStatus - Get device status.
    %   getDeviceConfig - Get device config.
    %
    %DEVICE Example
    %   device = library.getFirstAvailableDevice('network', 'electrical');
    %
    %   disp(['Sample Rate: ' num2str(device.sample_rate)]);
    %   disp(['Channel Name: ' device.channels{1}.alternative_name]);
    %   disp(['Unit: ' device.channels{1}.unit_name]);
    %

    properties
        % Device ID
        device_id

        % Internal device handle for TMSi device
        handle

        % Keep track whether or not device is connected
        is_connected

        % Contains information about docking station
        docking_station

        % Contains information about recording device
        data_recorder

        % Current API version
        api_version

        % Number of batteries available
        num_batteries

        % Number of channels available
        num_channels

        % Current power state of system
        power_state

        % Battery information
        batteries

        % Time information
        time

        % Max available storage size
        max_storage_size

        % Still available storage size
        available_storage_size

        % Number of hardware channels
        num_hw_channels

        % Number of sensors
        num_sensors

        % Current base sample rate
        base_sample_rate

        % Current alternative base sample rate
        alternative_base_sample_rate

        % Interface bandwidth requirement
        interface_bandwidth

        % Triggers enabled/disabled
        triggers

        % Reference method enabled/disabled
        reference_method

        % Auto reference method enabled/disabled
        auto_reference_method

        % Repair logging enabled/disabled
        repair_logging

        % Ambulant recording enabled/disabled
        ambulant_recording

        % Recordings available
        avaliable_recordings

        % Name of device
        name

        % Channels 
        channels

        % Sensors
        sensors

        % Impedance Mode
        impedance_mode

        % Num active channels
        num_active_channels

        % Num active impedance channels
        num_active_impedance_channels

        % Missing samples
        missing_samples

        % Sample rate
        sample_rate

        % Dividers
        dividers

        % Out of Sync with device
        out_of_sync
        
        % True, if a sampler is sampling
        is_sampling

        % Pin key
        pinkey
    end

    properties (Access = private)
        % Library 
        lib

        % Size of sample buffer
        prepared_sample_buffer_length

        % Sample buffer
        prepared_sample_buffer

        % Active channel indices
        active_channel_indices

        % Current counter channel index
        current_counter_channel_index

        % Current status channel index
        current_status_channel_index
    end

    methods (Access = private)
        
        function updateDeviceConfig_(obj, perform_factory_reset, store_as_default, web_interface_control)
            if ~exist('perform_factory_reset', 'var')
                perform_factory_reset = 0;
            end

            if ~exist('store_as_default', 'var')
                store_as_default = 0;
            end

            if ~exist('web_interface_control', 'var')
                web_interface_control = 0;
            end

            device_config = struct( ...
                'DRSerialNumber', obj.data_recorder.serial_number, ...
                'NrOfChannels', obj.num_channels, ...
                'SetBaseSampleRateHz', uint16(obj.base_sample_rate), ...
                'SetConfiguredInterface', uint16(TMSiSAGA.TMSiUtils.toInterfaceTypeNumber(obj.data_recorder.interface_type)), ...
                'SetTriggers', int16(obj.triggers), ...
                'SetRefMethod', int16(obj.reference_method), ...
                'SetAutoRefMethod', int16(obj.auto_reference_method), ...
                'SetDRSyncOutDiv', int16(obj.data_recorder.sync_out_divider), ...
                'DRSyncOutDutyCycl', int16(obj.data_recorder.sync_out_duty_cycle), ...
                'SetRepairLogging', int16(obj.repair_logging), ...
                'PerformFactoryReset', perform_factory_reset, ...
                'StoreAsDefault', store_as_default, ...
                'WebIfCtrl', web_interface_control, ...
                'PinKey', uint8(obj.pinkey) ...
            );

            channels = struct();
            for i=1:numel(obj.channels)
                channels(i).ChanNr = obj.channels{i}.number;

                if obj.channels{i}.divider ~= -1
                   
                    % diver per channel type
                    channels(i).ChanDivider = obj.dividers(obj.channels{i}.type);
                else
                    channels(i).ChanDivider = -1;
                end

                channels(i).AltChanName = obj.channels{i}.alternative_name;
            end

            TMSiSAGA.DeviceLib.setDeviceConfig(obj.handle, device_config, channels);

            
            TMSiSAGA.TMSiUtils.info(obj.name, 'sent device configuration')
        end

    end

    methods
        function obj = Device(lib, device_id, dr_interface_type)
            %DEVICE - Constructor for device object.
            %
            %   Constructor for a device object. The library is required to be initialized and to
            %   keep track of all connected en sampling devices. Creation of device can be done with
            %   and id and interface type. 
            %
            %   lib - Library object that keeps track of all the open devices.
            %   device_id - Unique device id for this device.
            %   dr_interface_type - Interface type that is used by the data recorder.
            %

            obj.lib = lib;
            obj.data_recorder = TMSiSAGA.DataRecorderInfo();
            obj.docking_station = TMSiSAGA.DockingStationInfo();

            obj.device_id = device_id;
            obj.data_recorder.interface_type = dr_interface_type;
            obj.is_connected = false;

            obj.api_version = 0;
            
            obj.num_batteries = 0;
            obj.num_channels = 0;

            obj.power_state = 0;

            obj.batteries = struct();
            obj.time = struct();
            obj.channels = {};

            obj.max_storage_size = 0;
            obj.available_storage_size = 0;

            obj.impedance_mode = false;
            obj.num_active_channels = 0;
            obj.out_of_sync = true;

            obj.dividers = [0, 0, 0, 0, 0, 0];
            obj.pinkey = [0, 0, 0, 0];

            obj.getDeviceInfo();

            obj.prepared_sample_buffer_length = max(obj.base_sample_rate, obj.alternative_base_sample_rate) * obj.num_channels * 5;
            obj.prepared_sample_buffer = TMSiSAGA.DeviceLib.createDataBuffer(obj.prepared_sample_buffer_length);
        end

        function connect(obj, dr_interface_type)
            %CONNECT - Open a connection to a TMSi SAGA device.
            %
            %   Opens a connection to a TMSi SAGA device.
            %
            %   dr_interface_type - (Optional) Interface type with which to connect. Defaults
            %       to the one set previously.

            if (obj.is_connected)
                return
            end

            if ~exist('dr_interface_type', 'var')
                dr_interface_type = obj.data_recorder.interface_type;
            end

            % Connect device
            obj.handle = TMSiSAGA.DeviceLib.openDevice(obj.device_id, ...
                TMSiSAGA.TMSiUtils.toInterfaceTypeNumber(dr_interface_type));

            obj.is_connected = true;
            TMSiSAGA.TMSiUtils.info('N/A', 'opened connection to device')

            obj.lib.deviceConnected(obj);
        end

        function disconnect(obj)
            %DISCONNECT - Closes the connection to a TMSi device.
            %   
            %   Closes a connection to a TMSi Device.

            if (~obj.is_connected)
                return
            end
    
            TMSiSAGA.DeviceLib.closeDevice(obj.handle);
            obj.is_connected = false;
            
            TMSiSAGA.TMSiUtils.info(obj.name, 'closed connection to device')

            obj.lib.deviceDisconnected(obj);
        end

        function start(obj, disable_avg_ref_calculation)
            %START - Start sampling on a TMSi device.
            %   
            %   Starts sampling of a TMSi device.
            %
            %   disable_avg_ref_calculation - Disable the average reference calculation for
            %       during this sample session.

            if ~obj.is_connected
                throw(MException('Device:start', 'Device has not been connected.'));
            end

            % Show out of sync warning
            if obj.out_of_sync
                warning('Are you sure you want to start sampling, it seems that the device config is out of sync with your current settings.');
            end

            if obj.is_sampling
                return;
            end

            if ~exist('disable_avg_ref_calculation', 'var')
                disable_avg_ref_calculation = false;
            end

            % Get channel info values
            %   1. Look up STATUS and COUNTER index
            obj.active_channel_indices = [];
            for channel_index=1:numel(obj.channels)
                if obj.channels{channel_index}.isActive(obj.impedance_mode)
                    obj.active_channel_indices(numel(obj.active_channel_indices) + 1) = channel_index;

                    if obj.channels{channel_index}.isCounter()
                        obj.current_counter_channel_index = numel(obj.active_channel_indices);
                    end

                    if obj.channels{channel_index}.isStatus()
                        obj.current_status_channel_index = numel(obj.active_channel_indices);
                    end
                end
            end

            obj.missing_samples = [];
            TMSiSAGA.DeviceLib.resetDeviceDataBuffer(obj.handle);

            if obj.impedance_mode
                TMSiSAGA.DeviceLib.setDeviceImpedance(obj.handle, struct('SetImpedanceMode', uint16(1)));
            else
                device_sample_request = struct( ...
                    'SetSamplingMode', uint16(1), ...
                    'DisableAutoswitch', ~obj.auto_reference_method, ...
                    'DisableRepairLogging', ~obj.repair_logging, ...
                    'DisableAvrRefCalc', disable_avg_ref_calculation ...
                );
                TMSiSAGA.DeviceLib.setDeviceSampling(obj.handle, device_sample_request);
            end

            obj.is_sampling = true;
            
            TMSiSAGA.TMSiUtils.info(obj.name, 'started sampling from device')
            TMSiSAGA.TMSiUtils.info(obj.name, ['    autoswitch=' num2str(obj.auto_reference_method)])
            TMSiSAGA.TMSiUtils.info(obj.name, ['    repair_logging=' num2str(obj.repair_logging)])
            TMSiSAGA.TMSiUtils.info(obj.name, ['    avr_ref_calc=' num2str(~disable_avg_ref_calculation)])
            
            obj.lib.deviceStartedSampling(obj);
        end

        function stop(obj)
            %STOP - Stop sampling on a TMSi device.
            %   
            %   Stops sampling of a TMSi device.
            %
            %   Can be called when:
            %   - Device is connected.
            %   - Device is (not) sampling.

            if ~obj.is_connected
                throw(MException('Device:stop', 'Device has not been connected.'));
            end

            if ~obj.is_sampling
                return
            end

            if obj.impedance_mode
                TMSiSAGA.DeviceLib.setDeviceImpedance(obj.handle, struct('SetImpedanceMode', uint16(0)));
            else
                device_sample_request = struct( ...
                    'SetSamplingMode', uint16(0), ...
                    'DisableAutoswitch', false, ...
                    'DisableRepairLogging', false, ...
                    'DisableAvrRefCalc', false ...
                );
                TMSiSAGA.DeviceLib.setDeviceSampling(obj.handle, device_sample_request);
            end
            
            obj.is_sampling = false;

            TMSiSAGA.TMSiUtils.info(obj.name, 'stopped sampling from device')
            
            obj.lib.deviceStoppedSampling(obj);
        end

        function [data, num_sets, data_type] = sample(obj)
            %SAMPLE - Retrieves samples from the device and does some basic processing.
            %
            %   Retrieves samples from the device and does some basic processing on them. The 
            %   returned samples are in double format, but have been converted from float, int32
            %   or other types. Potential transformations like sensor calculations and/or exponents
            %   have already been applied.
            %
            %   Can be called when:
            %   - Device is connected.
            %   - Device is sampling.

            % Can only be called when sampling
            if ~obj.is_sampling
                throw(MException('Device:sample', 'failed because device was not open for sampling'));
            end

            data = [];

            % Get data from device and reshape into channels x sets
            [raw_data, num_sets, data_type] = TMSiSAGA.DeviceLib.getDeviceData(obj.handle, obj.prepared_sample_buffer, obj.prepared_sample_buffer_length);
           
            num_channels = obj.num_active_channels;
            if obj.impedance_mode
                num_channels = obj.num_active_impedance_channels;
            end 

            raw_data = reshape(raw_data(1:(num_sets * num_channels)), [num_channels, num_sets]);

            % No need to do anything if empty
            if num_sets == 0
                return
            end

            % Data in double format
            data = zeros(num_channels, num_sets);

            % Loop over channels and transform raw_data to data
            for i=1:numel(obj.active_channel_indices)
                channel = obj.channels{obj.active_channel_indices(i)};

                if channel.isActive(obj.impedance_mode)
                    data(i, :) = channel.transform(raw_data(i, :));
                end
            end
            
            % If repair logging is on, check for missing samples
            missing_samples_mask = bitand(uint32(data(obj.current_status_channel_index, :)), uint32(hex2dec('100')));
            missing_samples_mask(missing_samples_mask > 0) = 1;
            
            if obj.repair_logging && numel(missing_samples_mask) > 0 && any(missing_samples_mask)
                index = data(obj.current_counter_channel_index, 1);
                count = 0;

                for i=1:num_sets
                    if missing_samples_mask(i)
                        count = count + 1;
                    else
                        if count > 0
                            obj.missing_samples = [obj.missing_samples, index, count + 1]; 
                        end

                        index = data(obj.current_counter_channel_index, i);
                        count = 0;
                    end
                end
                
                if count > 0
                    obj.missing_samples = [obj.missing_samples, index, count + 1]; 
                end
            end
        end

        function [data_d, num_sets] = getMissingSamples(obj)
            %GETMISSINGSAMPLES - This function retrieves all missing samples.
            %
            %   This function returns a data set with all the missing samples that have
            %   been detected during sampling. A missing sample is detected by checking
            %   the STATUS channel for overflow value.
            %
            %   Can be called when:
            %   - Device is connected.
            %   - Device is not sampling.

            if obj.is_sampling
                throw(MException('Sampler:getMissingSamples', 'cannot get missing samples while sampling'));
            end  
            
            num_samples = 0;
            for i=1:2:numel(obj.missing_samples)
                num_samples = num_samples + obj.missing_samples(i + 1);
            end

            num_channels = obj.num_active_channels;
            if obj.impedance_mode
                num_channels = obj.num_active_impedance_channels;
            end

            if numel(obj.missing_samples) == 0
                data_d = zeros([num_channels, 0]);
                num_sets = 0;
                return
            end
            
            TMSiSAGA.TMSiUtils.info(obj.name, 'start retrieving missing samples')

            d = single(zeros(1, num_samples));
            num_sets = 0;
            counter = 1;
            max_number_of_sample_sets = 4; %floor(32000 / obj.num_channels);

            for i=1:2:numel(obj.missing_samples)
                sample_start = obj.missing_samples(i);
                num_sample_sets = obj.missing_samples(i + 1);

                for j=1:max_number_of_sample_sets:num_sample_sets
                    repair_request = struct(...
                        'SampleStartCntr', sample_start + (j - 1), ...
                        'NROfSampleSets', min(max_number_of_sample_sets, (num_sample_sets - j) + 1) ...
                    );

                    [d, n] = TMSiSAGA.DeviceLib.getDeviceRepairData(obj.handle, obj.prepared_sample_buffer, obj.prepared_sample_buffer_length, repair_request);

                    data(counter:(counter + n - 1)) = d(1:n);
                    num_sets = num_sets + n / num_channels; 
                    counter = counter + n;
                end
                    
                TMSiSAGA.TMSiUtils.info(obj.name, ['at sample ' num2str(num_sets) ' of ' num2str(num_samples)]);
            end

            data = reshape(data(1:(num_sets * num_channels)), [num_channels, num_sets]);

            % Data in double format
            data_d = zeros(num_channels, num_sets);

            % Transforming repaired data
            TMSiSAGA.TMSiUtils.info(obj.name, 'transforming missing sample data')

            % Loop over channels and transform raw_data to data
            for i=1:numel(obj.active_channel_indices)
                channel = obj.channels{obj.active_channel_indices(i)};

                if channel.isActive(obj.impedance_mode)
                    data_d(i, :) = channel.transform(data(i, :));
                end
            end
            
            TMSiSAGA.TMSiUtils.info(obj.name, 'done retrieving missing samples')
        end

        function changeDataRecorderInterfaceTo(obj, dr_interface_type)
            %CHANGEDATARECORDERINTERFACETO - Change interface of the data recorder.
            %
            %   This function will change the interface type of the data recorder and
            %   immediatly disconnects the device. To use the device you will have to 
            %   reconnect to it by help of the library.
            %
            %   Can be called when:
            %   - Device is connected.
            %   - Device is not sampling.

            if ~obj.is_connected
                throw(MException('Device:changeDataRecorderInterfaceTo', 'Can only change interface while connected to device.'));
            end

            if obj.is_sampling
                throw(MException('Device:changeDataRecorderInterfaceTo', 'Cannot change data recorder interface while sampling.'));
            end

            obj.data_recorder.interface_type = dr_interface_type;
            
            obj.updateDeviceConfig_();
            obj.disconnect();
        end

        function resetDeviceConfig(obj)
            %RESETDEVICECONFIG - Will restore the device config back the factory values.
            %
            %   Function will reset all configuration back to basic values.
            %
            %   Can be called when:
            %   - Device is connected.
            %   - Device is not sampling.

            if ~obj.is_connected
                throw(MException('Device:resetDeviceConfig', 'Can only reset device config while connected to device.'));
            end

            if obj.is_sampling
                throw(MException('Device:resetDeviceConfig', 'Cannot reset device config while sampling.'));
            end

            obj.updateDeviceConfig(true);

            TMSiSAGA.TMSiUtils.info(obj.name, 'reset configuration back to factory settings')
            obj.disconnect
            obj.connect
        end

        function enableChannels(obj, channels)
            %ENABLECHANNELS Will enable all channels that are selected.
            %
            %   This function will enable all channels that are given as parameter. Other 
            %   channels will NOT be disabled, it only enables channels. The channels parameter
            %   can be an array of channel numbers, or a cell array of Channel objects. The
            %   channels are only enabled in MATLAB. To ensure the device sees this, call the
            %   updateDeviceConfig() function.
            %
            %   channels - An array of channel numbers or a cell array of Channel objects.
            %
            %   Can be called when:
            %   - Device is connected.
            %   - Device is not sampling.

            if obj.is_sampling
                throw(MException('Device:enableChannels', 'Cannot enable/disable channels while sampling.'));
            end

            for i=1:numel(channels)
                if isa(channels, 'double')
                    obj.channels{channels(i)}.enable();
                else
                    channels{i}.enable();
                end
            end

            obj.out_of_sync = true;
        end

        function disableChannels(obj, channels)
            %DISABLECHANNELS Will disable all channels that are selected.
            %
            %   This function will disable all channels that are given as parameter. Other 
            %   channels will NOT be enabled, it only disables channels. The channels parameter
            %   can be an array of channel numbers, or a cell array of Channel objects. The
            %   channels are only disabled in MATLAB. To ensure the device sees this, call the
            %   updateDeviceConfig() function.
            %
            %   channels - An array of channel numbers or a cell array of Channel objects.
            %
            %   Can be called when:
            %   - Device is connected.
            %   - Device is not sampling.

            if obj.is_sampling
                throw(MException('Device:disableChannels', 'Cannot enable/disable channels while sampling.'));
            end

            for i=1:numel(channels)
                if isa(channels, 'double')
                    obj.channels{channels(i)}.disable();
                else
                    channels{i}.disable();
                end
            end

            obj.out_of_sync = true;
        end

        function channels = getSensorChannels(obj)
            %GETSENSORCHANNELS Get a cell array of sensor channels.
            %
            %   This function will return a cell array of Channel objects that are sensors.
            %

            channels = {};

            for i=1:numel(obj.sensors)
                for j=1:obj.sensors{i}.num_channels
                    channels{numel(channels) + 1} = obj.channels{obj.sensors{i}.channel_number + j};
                end
            end
        end

        function channels = getActiveChannels(obj)
            %GETACTIVECHANNELS - Get a cell array of active channels.
            %
            %   This function will return a cell array of Channels object of all channels that
            %   are active. An channel is active when the divider of the channel does not equals 
            %   -1. When impedance mode is on it will return all channels that are active in 
            %   impedance mode.
            
            channels = {};

            for i=1:numel(obj.channels)
                if obj.channels{i}.isActive(obj.impedance_mode)
                    channels{numel(channels) + 1} = obj.channels{i};
                end
            end
        end

        function setImpedanceMode(obj, is_on)
            %SETIMPEDANCEMODE - This function turn on/off impedance mode.
            %
            %   This function will turn on/off the impedance mode of the device. Will require
            %   and update of the device config.
            %
            %   is_on - A logical value true/false to turn on/off impedance mode.
            %
            %   This function can be called when:
            %   - Device is connected
            %   - Device is not sampling

            if ~isa(is_on, 'logical')
                throw(MException('Device:SetImpedanceMode', 'Argument type should be a boolean.'));
            end

            if obj.is_sampling
                throw(MException('Device:SetImpedanceMode', 'Cannot set impedance mode while sampling.'));
            end

            obj.impedance_mode = is_on;
        end

        function setDividers(obj, type, divider)
            %SETDIVIDERS - This function sets the dividers for a single type of channel.
            %
            %   This function will set the divider for all channels of that type. The types are
            %   exg, bip, aux, dig, digstat. To apply the dividers you will have to update the
            %   device config.
            %
            %   type - A string representing the channel type (exg, bip, aux, dig, digstat).
            %   divider - A value with which the sample rate is set as base_sample_rate / 2^divider.
            %
            %   This function can be called when:
            %   - Device is connected
            %   - Device is not sampling
            
            if ~isa(type, 'char')
                throw(MException('Device:setDividers', 'Argument type should be a string.'));
            end

            if obj.is_sampling
                throw(MException('Device:setDividers', 'Cannot set dividers while sampling.'));
            end
            
            %TODO: this function allows to set divers per channel type,
            % this is not yet supported in SAGA DR FW 1.03 / DS FW 1.02
            % all types must have the same divider
            
            %function that supports different types:
            %obj.dividers(TMSiSAGA.TMSiUtils.toChannelTypeNumber(type)) = divider;
            
            %function that supports just one sample rate for all types:
            obj.dividers(:) = divider;
        end

        function setBaseSampleRate(obj, sample_rate)
            %SETBASESAMPLERATE - This function will set the base sample rate of the device.
            %
            %   The device can sample on 4000Hz, or 4096Hz. This function will allow you to change
            %   the base sample rate. The base sample rate is used to determine the sample rate at
            %   which the device is actually running based on the channel dividers. After updating the
            %   device config you can find the sample rate at which the device is running by checking the
            %   sample_rate property of the device.
            %
            %   sample_rate - A value should be 4000, or 4096.
            %
            %   This function can be called when:
            %   - Device is connected
            %   - Device is not sampling

            if sample_rate ~= 4000 && sample_rate ~= 4096
                throw(MException('Device:setBaseSampleRate', 'Currently only sample rates of 4000 and 4096 are supported as base sample rate.'));
            end

            if obj.is_sampling
                throw(MException('Device:setBaseSampleRate', 'Cannot set base sample rate while sampling.'));
            end

            obj.base_sample_rate = sample_rate;

            obj.out_of_sync = true;
        end

        function setTriggers(obj, triggers)
            %SETTRIGGERS - This functionw will turn on/off triggers.
            %
            %   This function will turn on/off triggers, will require an update of the device config.
            %
            %   triggers - A boolean.
            %
            %   This function can be called when:
            %   - Device is connected
            %   - Device is not sampling

            if ~isa(triggers, 'logical')
                throw(MException('Device:setTriggers', 'Argument should be true or false.'));
            end

            if obj.is_sampling
                throw(MException('Device:setTriggers', 'Cannot set triggers while sampling.'));
            end

            obj.triggers = triggers;

            obj.out_of_sync = true;
        end

        function setReferenceMethod(obj, reference_method)
            %SETTRIGGERS - This function will set the reference method.
            %
            %   This function will set the reference method of the device, which can
            %   be either 'common', or 'average'. In case of common reference method
            %   all channels are referenced with respect to a single common channel. 
            %   With average reference method, the average of all connected channels 
            %   is used. Requires an update of device config.
            %
            %   reference_method - A boolean.
            %
            %   This function can be called when:
            %   - Device is connected
            %   - Device is not sampling

            if ~isa(reference_method, 'char')
                throw(MException('Device:setReferenceMethod', 'Argument should be a string (common, average).'));
            end

            if obj.is_sampling
                throw(MException('Device:setReferenceMethod', 'Cannot set reference method while sampling.'));
            end

            if strcmp(reference_method, 'common')
                obj.reference_method = 0;
            elseif strcmp(reference_method, 'average')
                obj.reference_method = 1;
            end

            obj.out_of_sync = true;
        end

        function setAutoReferenceMethod(obj, is_on)
            %SETAUTOREFERENCEMETHOD - This function will turn on/off auto reference method.
            %
            %   This function will turn on/off the auto reference method common -> average, when 
            %   the common reference is disconnected. This function does not require a device config 
            %   update.
            %
            %   This function can be called when:
            %   - Device is connected
            %   - Device is not sampling 

            if ~isa(is_on, 'logical')
                throw(MException('Device:setAutoReferenceMethod', 'Argument should be true or false.'));
            end

            if obj.is_sampling
                throw(MException('Device:setAutoReferenceMethod', 'Cannot change auto reference method while sampling.'));
            end

            obj.auto_reference_method = is_on;
        end

        function setRepairLogging(obj, repair_logging)
            %SETREPAIRLOGGING - This function will turn on/off repair logging.
            %
            %   This function will turn on/off the repair logging. When turned on the device object will
            %   keep track of all missing samples, and the TMSi device will store all samples so that
            %   missing samples can be retrieved later on. This function does not require an update to 
            %   device config.
            %
            %   This function can be called when:
            %   - Device is connected
            %   - Device is not sampling 
            
            if ~isa(repair_logging, 'logical')
                throw(MException('Device:setRepairLogging', 'Argument should be true or false.'));
            end

            if obj.is_sampling
                throw(MException('Device:setRepairLogging', 'Cannot turn on/off repair logging method while sampling.'));
            end

            obj.repair_logging = repair_logging;
        end

        function setDataRecorderSyncOutDivider(obj, sync_out_divider)
            %SETDATARECORDERSYNCOUTDIVIDER - Set the sync out divider of the data recorder.
            %
            %   This function will set the sync out divider of the data recorder. Will require an
            %   update to the device config.
            %
            %   This function can be called when:
            %   - Device is connected
            %   - Device is not sampling 

            if obj.is_sampling
                throw(MException('Device:setDataRecorderSyncOutDivider', 'Cannot change sync out divider while sampling.'));
            end

            obj.data_recorder.sync_out_divider = sync_out_divider;

            obj.out_of_sync = true;
        end

        function setDataRecorderSyncOutDutyCycle(obj, sync_out_duty_cycle)
            %SETDATARECORDERSYNCOUTDUTYCYCLE - Set the sync out duty cycle of the data recorder.
            %
            %   This function will set the sync out duty cycle of the data recorder. Will require an
            %   update to the device config.
            %
            %   This function can be called when:
            %   - Device is connected
            %   - Device is not sampling 

            if obj.is_sampling
                throw(MException('Device:setDataRecorderSyncOutDutyCycle', 'Cannot change sync out duty cycle while sampling.'));
            end

            obj.data_recorder.sync_out_duty_cycle = sync_out_duty_cycle;

            obj.out_of_sync = true;
        end

        function updateDeviceConfig(obj, perform_factory_reset, store_as_default, web_interface_control)
            %UPDATEDEVICECONFIG - Apply config changes to the device.
            %
            %   This function will apply the device config that have been made to the Device object, to
            %   the actual TMSi Device. This function will also call getDeviceInfo() and will override all
            %   settings with how they have been interperted by the actual device. So after this call
            %   the device object and TMSi device should be in sync with respect to configuration.
            %
            %   perform_factory_reset - If true, this will cause an factory reset.
            %   store_as_default - If true, will store the current settings as default on TMSi Device.
            %   web_interface_control - If true, turn on web interface control.
            %
            %   This function can be called when:
            %   - Device is connected
            %   - Device is not sampling 

            if obj.is_sampling
                throw(MException('Device:updateDeviceConfig', 'Device config can not be set while sampling.'));
            end
            
            if ~exist('perform_factory_reset', 'var')
                perform_factory_reset = 0;
            end

            if ~exist('store_as_default', 'var')
                store_as_default = 0;
            end

            if ~exist('web_interface_control', 'var')
                web_interface_control = 0;
            end

            obj.updateDeviceConfig_(perform_factory_reset, store_as_default, web_interface_control)
            obj.getDeviceInfo();
        end

        function getDeviceInfo(obj)
            %GETDEVICEINFO - Retrieve all device info from a TMSi device.
            %
            %   This function will connect to the TMSi device if not yet connected. It will
            %   disconnect the device if it was connected within this function. It will retrieve
            %   the device status, device config and update dynamic info.
            %

            to_disconnect = false;

            try 
                if ~obj.is_connected
                    obj.connect();
                    to_disconnect = true;
                end

                obj.getDeviceStatus();
                obj.getDeviceConfig();
                obj.updateDynamicInfo();

                if to_disconnect
                    obj.disconnect();
                end
            catch e
                if to_disconnect
                    obj.disconnect();
                end
            end

            obj.out_of_sync = false;
        end

        function updateDynamicInfo(obj)
            %UPDATEDYNAMICINFO - Update info that has to be calculated based on the device status and config.

            min_divider = 100000;
            for i=1:numel(obj.channels)
                if obj.channels{i}.divider ~= -1 && ~obj.channels{i}.isCounter() && ~obj.channels{i}.isStatus() && obj.channels{i}.divider < min_divider
                    min_divider = obj.channels{i}.divider;
                end
            end

            obj.sample_rate = obj.base_sample_rate / 2^min_divider;
        end

        function getDeviceStatus(obj)
            %GETDEVICESTATUS - Get basic status information of the device.
            %
            %   Information like serial number, battery status, power status, time and storage are retrieved and updated on this 
            %   device object.
            %

            if (~obj.is_connected) 
                throw(MException('Device:getDeviceStatus', 'Device has not been connected.'));
            end

            device_report = TMSiSAGA.DeviceLib.getDeviceStatus(obj.handle);

            obj.docking_station.serial_number = int64(device_report.DSSerialNr);
            obj.data_recorder.serial_number = int64(device_report.DRSerialNr);
            obj.docking_station.interface_type = TMSiSAGA.TMSiUtils.toInterfaceTypeString(device_report.DSInterface);
            obj.data_recorder.interface_type = TMSiSAGA.TMSiUtils.toInterfaceTypeString(device_report.DRInterface);
            obj.api_version = int64(device_report.DSDevAPIVersion);
            obj.data_recorder.available = int64(device_report.DRAvailable);
            obj.num_batteries = int64(device_report.NrOfBatteries);
            obj.num_channels = int64(device_report.NrOfChannels);

            [device_report, battery_report_list, time_report, storage_report] = ...
                TMSiSAGA.DeviceLib.getFullDeviceStatus(obj.handle, obj.num_batteries);

            obj.power_state = int64(device_report.PowerState);
            obj.docking_station.temperature = int64(device_report.DSTemp);
            obj.data_recorder.temperature = int64(device_report.DRTemp);

            for i = 1:obj.num_batteries
                obj.batteries(i).id = int64(battery_report_list(i).BatID);
                obj.batteries(i).temprature = int64(battery_report_list(i).BatTemp);
                obj.batteries(i).voltage = int64(battery_report_list(i).BatVoltage);
                obj.batteries(i).remaining_capacity = int64(battery_report_list(i).BatRemainingCapacity);
                obj.batteries(i).full_charge_capacity = int64(battery_report_list(i).BatFullChargeCapacity);
                obj.batteries(i).average_current = int64(battery_report_list(i).BatAverageCurrent);
                obj.batteries(i).minutes_remaining = int64(battery_report_list(i).BatTimeToEmpty);
                obj.batteries(i).capacity = int64(battery_report_list(i).BatStateOfCharge);
                obj.batteries(i).health = int64(battery_report_list(i).BatStateOfHealth);
                obj.batteries(i).cycle_count = int64(battery_report_list(i).BatCycleCount);
            end

            obj.time.seconds = int64(time_report.Seconds);
            obj.time.minutes = int64(time_report.Minutes);
            obj.time.hours = int64(time_report.Hours);
            obj.time.day_of_month = int64(time_report.DayOfMonth);
            obj.time.month = int64(time_report.Month);
            obj.time.year = int64(time_report.Year);
            obj.time.week_day = int64(time_report.WeekDay);
            obj.time.year_day = int64(time_report.YearDay);

            obj.max_storage_size = int64(storage_report.TotalSizeMB);
            obj.available_storage_size = int64(storage_report.UsedSizeMB);
        end

        function getDeviceConfig(obj)
            %GETDEVICECONFIG - Get and update specific device configuration information.
            %
            %   This function will update the device configuration properties as they are currently set
            %   on the device.
            %

            if (~obj.is_connected) 
                throw(MException('Device:getDeviceConfig', 'Device has not been connected.'));
            end
            
            [rec_conf, channel_list] = TMSiSAGA.DeviceLib.getDeviceConfig(obj.handle, obj.num_channels);

            obj.data_recorder.serial_number = int64(rec_conf.DRSerialNumber);
            obj.data_recorder.id = int64(rec_conf.DRDevID);
            obj.num_hw_channels = int64(rec_conf.NrOfHWChannels);
            obj.num_channels = int64(rec_conf.NrOfChannels);
            obj.num_sensors = int64(rec_conf.NrOfSensors);
            obj.base_sample_rate = int64(rec_conf.BaseSampleRateHz);
            obj.alternative_base_sample_rate = int64(rec_conf.AltBaseSampleRateHz);
            obj.interface_bandwidth = int64(rec_conf.InterFaceBandWidth);
            obj.triggers = int64(rec_conf.TriggersEnabled);
            obj.reference_method = int64(rec_conf.RefMethod);
            obj.auto_reference_method = int64(rec_conf.AutoRefMethod);
            obj.data_recorder.sync_out_divider = int64(rec_conf.DRSyncOutDiv);
            obj.data_recorder.sync_out_duty_cycle = int64(rec_conf.DRSyncOutDutyCycl);
            obj.docking_station.sync_out_divider = int64(rec_conf.DSSyncOutDiv);
            obj.docking_station.sync_out_duty_cycle = int64(rec_conf.DSSyncOutDutyCycl);
            obj.repair_logging = int64(rec_conf.RepairLogging);
            obj.ambulant_recording = int64(rec_conf.AmbRecording);
            obj.avaliable_recordings = int64(rec_conf.AvailableRecordings);
            obj.name = rec_conf.DeviceName;

            obj.num_active_channels = 0;
            obj.num_active_impedance_channels = 0;
            obj.channels = TMSiSAGA.Channel.empty;
            for i=1:numel(channel_list)
                channel_list(i).Number = i - 1;
                obj.channels{i} = TMSiSAGA.Channel(obj, channel_list(i));

                if obj.channels{i}.isActive()
                    obj.num_active_channels = obj.num_active_channels + 1;
                    
                    %TODO: set the divider per channel type to a valid
                    % value when reading the configuration from the device.
                    obj.dividers(:) = obj.channels{i}.divider;
                 
                end

                if obj.channels{i}.isActive(true)
                    obj.num_active_impedance_channels = obj.num_active_impedance_channels + 1;
                end
            end

            sensor_list = TMSiSAGA.DeviceLib.getDeviceSensors(obj.handle, obj.num_sensors);
            for i=1:numel(sensor_list)
                obj.sensors{i} = TMSiSAGA.Sensor(obj, sensor_list(i));
                
                for j=1:numel(obj.sensors{i}.channels)
                    obj.channels{obj.sensors{i}.channels{j}.channel_number}.sensor_channel = obj.sensors{i}.channels{j};
                end
            end
        end

    end
end