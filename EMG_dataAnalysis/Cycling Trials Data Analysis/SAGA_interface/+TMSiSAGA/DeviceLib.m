classdef DeviceLib < TMSiSAGA.HiddenHandle
    %DEVICELIB A class that encapsulates the low level functions of the library
    %   
    %   Internal class should not be used directly.
    
    methods (Static = true)

        function lib = alias()
            lib = 'TMSiSagaDeviceLib';
        end
        
        function result = trace()
            result = false;
        end

        function device_list = getDeviceList(ds_interface_type, dr_interface_type, max_num_devices)
            %GETDEVICELIST Call the dll TMSiGetDeviceList function (max 256 devices)
            
            if TMSiSAGA.DeviceLib.trace()
                fprintf(1, 'getDeviceList:\n\t ds_interface_type %d\n\t dr_interface_type %d\n\t max_num_devices %d\n', ds_interface_type, dr_interface_type, max_num_devices);
            end
            
            % Default for max_num_devices
            if ~exist('max_num_devices', 'var')
                max_num_devices = 255; 
            end

            % Preallocate memory for call
            
            device_list_buffer = TMSiSAGA.TMSiUtils.toLibraryStructure('TMSiDevList', repmat(struct(), 1, max_num_devices));
            max_num_devices = int32(max_num_devices);
            ds_interface_type = uint32(ds_interface_type);
            dr_interface_type = uint32(dr_interface_type);

            % Call dll function
            status = calllib(TMSiSAGA.DeviceLib.alias(), 'TMSiGetDeviceList', device_list_buffer, ...
                max_num_devices, ds_interface_type, dr_interface_type);
            if status ~= 0
                throw(MException('DeviceLib:getDeviceList', 'failed because of %s', ...
                    TMSiSAGA.TMSiUtils.getErrorString(status)));
            end

            % Return only structures which are actually filled
            for i = 1:max_num_devices
                device_ptr = device_list_buffer + (i - 1);
                if device_ptr.Value.TMSiDeviceID ~= 0
                    device_list(i) = device_ptr.Value;
                end
            end
        end

        function handle = openDevice(device_id, dr_interface_type)
            %OPENDEVICE Opens the device with the given id and interface.

            if TMSiSAGA.DeviceLib.trace()
                fprintf(1, 'openDevice\n\t device_id %d\n\t dr_interface_type %d\n', device_id, dr_interface_type);
            end
            
            handle = libpointer('voidPtrPtr', 0);

            % Call dll function
            status = calllib(TMSiSAGA.DeviceLib.alias(), 'TMSiOpenDevice', handle, device_id, ...
                dr_interface_type);
            if status ~= 0
                throw(MException('DeviceLib:openDevice', 'failed because of %s', ...
                    TMSiSAGA.TMSiUtils.getErrorString(status)));
            end
        end

        function handle = closeDevice(handle)
            %CLOSEDEVICE Closes the device associated to the handle.

            if TMSiSAGA.DeviceLib.trace()
                fprintf(1, 'closeDevice\n');
            end
            
            % Call dll function
            status = calllib(TMSiSAGA.DeviceLib.alias(), 'TMSiCloseDevice', handle);
            if status ~= 0
                throw(MException('DeviceLib:closeDevice', 'failed because of %s', ...
                    TMSiSAGA.TMSiUtils.getErrorString(status)));
            end
        end

        function device_report = getDeviceStatus(handle)
            %GETDEVICESTATUS Get the device status of the device.
    
            if TMSiSAGA.DeviceLib.trace()
                fprintf(1, 'getDeviceStatus\n');
            end
            
            device_report = TMSiSAGA.TMSiUtils.toLibraryStructure('TMSiDevStatReport', struct());

            % Call dll function
            status = calllib(TMSiSAGA.DeviceLib.alias(), 'TMSiGetDeviceStatus', handle, device_report);
            if status ~= 0
                throw(MException('DeviceLib:getDeviceStatus', 'failed because of %s', ...
                    TMSiSAGA.TMSiUtils.getErrorString(status)));
            end

            device_report = device_report.Value;
        end

        function [device_report, battery_report_list, ...
            time_report, storage_report] = getFullDeviceStatus(handle, num_batteries)
        
            if TMSiSAGA.DeviceLib.trace()
                fprintf(1, 'getFullDeviceStatus\n\t num_batteries %d\n', num_batteries);
            end

            device_report = TMSiSAGA.TMSiUtils.toLibraryStructure('TMSiDevFullStatReport', struct());
            battery_reports_ptr = TMSiSAGA.TMSiUtils.toLibraryStructure('TMSiDevBatReport', repmat(struct(), 1, num_batteries));
            time_report = TMSiSAGA.TMSiUtils.toLibraryStructure('TMSiTime', struct());
            storage_report = TMSiSAGA.TMSiUtils.toLibraryStructure('TMSiDevStorageReport', struct());

            % Call dll function
            status = calllib(TMSiSAGA.DeviceLib.alias(), 'TMSiGetFullDeviceStatus', ...
                handle, device_report, battery_reports_ptr, num_batteries, ...
                time_report, storage_report);
            if status ~= 0
                throw(MException('DeviceLib:getFullDeviceStatus', 'failed because of %s', ...
                    TMSiSAGA.TMSiUtils.getErrorString(status)));
            end

            % Return only structures which are actually filled
            for i = 1:num_batteries
                battery_report_ptr = battery_reports_ptr + (i - 1);
                battery_report_list(i) = battery_report_ptr.Value;
            end

            device_report = device_report.Value;
            time_report = time_report.Value;
            storage_report = storage_report.Value;
        end

        function [recorder_configuration, channel_list] = getDeviceConfig(handle, num_channels)
            %GETDEVICECONFIG

            if TMSiSAGA.DeviceLib.trace()
                fprintf(1, 'getDeviceConfig\n\t num_channels %d\n', num_channels);
            end
            
            recorder_configuration = TMSiSAGA.TMSiUtils.toLibraryStructure('TMSiDevGetConfig', struct());
            channel_list_ptr = TMSiSAGA.TMSiUtils.toLibraryStructure('TMSIDevChDesc', repmat(struct(), 1, num_channels));
            
            % Call dll function
            status = calllib(TMSiSAGA.DeviceLib.alias(), 'TMSiGetDeviceConfig', ...
                handle, recorder_configuration, channel_list_ptr, num_channels);
            if status ~= 0
                throw(MException('DeviceLib:getDeviceConfig', 'failed because of %s', ...
                    TMSiSAGA.TMSiUtils.getErrorString(status)));
            end

            recorder_configuration = TMSiSAGA.TMSiUtils.toMatlabStructure('TMSiDevGetConfig', recorder_configuration, 1);
            channel_list = TMSiSAGA.TMSiUtils.toMatlabStructure('TMSIDevChDesc', channel_list_ptr, num_channels);

            recorder_configuration.DeviceName = char(recorder_configuration.DeviceName(1:find(recorder_configuration.DeviceName==0, 1, 'first')-1));
            for i = 1:num_channels
                channel_list(i).UnitName = char(channel_list(i).UnitName(1:find(channel_list(i).UnitName==0, 1, 'first')-1));
                channel_list(i).DefChanName = char(channel_list(i).DefChanName(1:find(channel_list(i).DefChanName==0, 1, 'first')-1));
                channel_list(i).AltChanName = char(channel_list(i).AltChanName(1:find(channel_list(i).AltChanName==0, 1, 'first')-1));
            end
        end

        function setDeviceConfig(handle, recorder_config, channel_configs)
            %SETDEVICECONFIG Set the configuration of the device
            
            if TMSiSAGA.DeviceLib.trace()
                fprintf(1, 'setDeviceConfig\n');
                
                for i=1:numel(channel_configs)
                    fprintf(1, '\tChanNr %d\n', channel_configs(i).ChanNr);
                    fprintf(1, '\tChanDivider %d\n', channel_configs(i).ChanDivider);
                    fprintf(1, '\tAltChanName %s\n', channel_configs(i).AltChanName);
                end
            end
            
            rc = TMSiSAGA.TMSiUtils.toLibraryStructure('TMSiDevSetConfig', recorder_config);
            cc = TMSiSAGA.TMSiUtils.toLibraryStructure('TMSIDevSetChCfg', channel_configs);

            % Call dll function
            status = calllib(TMSiSAGA.DeviceLib.alias(), 'TMSiSetDeviceConfig', handle, ...
                rc, cc, numel(channel_configs));
            if status ~= 0
                throw(MException('DeviceLib:setDeviceConfig', 'failed because of %s', ...
                    TMSiSAGA.TMSiUtils.getErrorString(status)));
            end

        end

        function setDeviceSampling(handle, deviceSamplingMode)
            
            if TMSiSAGA.DeviceLib.trace()
                fprintf(1, 'setDeviceSampling\n');
                fprintf(1, '\tSetSamplingMode %d\n', deviceSamplingMode.SetSamplingMode);
                fprintf(1, '\tDisableAutoswitch %d\n', deviceSamplingMode.DisableAutoswitch);
                fprintf(1, '\tDisableRepairLogging %d\n', deviceSamplingMode.DisableRepairLogging);
                fprintf(1, '\tDisableAvrRefCalc %d\n', deviceSamplingMode.DisableAvrRefCalc);
            end
            
            deviceSamplingMode = TMSiSAGA.TMSiUtils.toLibraryStructure('TMSiDevSampleReq', deviceSamplingMode);

            % Call dll function
            status = calllib(TMSiSAGA.DeviceLib.alias(), 'TMSiSetDeviceSampling', handle, ...
                deviceSamplingMode);
            if status ~= 0
                throw(MException('DeviceLib:setDeviceSampling', 'failed because of %s', ...
                    TMSiSAGA.TMSiUtils.getErrorString(status)));
            end
        end

        function setDeviceImpedance(handle, deviceImpedanceMode)
            if TMSiSAGA.DeviceLib.trace()
                fprintf(1, 'setDeviceImpedance\n');
                fprintf(1, '\tdeviceImpedanceMode %d\n', deviceImpedanceMode);
            end
            
            deviceImpedanceMode = TMSiSAGA.TMSiUtils.toLibraryStructure('TMSiDevImpReq', deviceImpedanceMode);
            
            % Call dll function
            status = calllib(TMSiSAGA.DeviceLib.alias(), 'TMSiSetDeviceImpedance', handle, ...
                deviceImpedanceMode);
            if status ~= 0
                throw(MException('DeviceLib:setDeviceImpedance', 'failed because of %s', ...
                    TMSiSAGA.TMSiUtils.getErrorString(status)));
            end
        end

        function buffer = createDataBuffer(size)
            buffer = libpointer('singlePtr', single(zeros(1, size)));
        end
        
        function [data, num_sets, data_type] = getDeviceData(handle, buffer, max_size)
            num_sets = libpointer('uint32Ptr', 0);
            data_type = libpointer('int32Ptr', 0);

            % Call dll function
            status = calllib(TMSiSAGA.DeviceLib.alias(), 'TMSiGetDeviceData', handle, ...
                buffer, max_size * 4, num_sets, data_type);
            if status ~= 0
                throw(MException('DeviceLib:getDeviceData', 'failed because of %s', ...
                    TMSiSAGA.TMSiUtils.getErrorString(status)));
            end

            data = buffer.Value;
            num_sets = num_sets.Value;
            data_type = data_type.Value;
        end

        function sensors = getDeviceSensors(handle, num_sensors)
            if TMSiSAGA.DeviceLib.trace()
                fprintf(1, 'getDeviceSensors\n');
                fprintf(1, '\tnum_sensors %d\n', num_sensors);
            end
            
            num_sensors_for_real = libpointer('uint32Ptr', num_sensors);
            channel_list_ptr = TMSiSAGA.TMSiUtils.toLibraryStructure('TMSiDevGetSens', repmat(struct(), 1, num_sensors));

            % Call dll function
            status = calllib(TMSiSAGA.DeviceLib.alias(), 'TMSiGetDeviceSensor', handle, ...
                channel_list_ptr, num_sensors, num_sensors_for_real);
            if status ~= 0
                throw(MException('DeviceLib:getDeviceSensor', 'failed because of %s', ...
                    TMSiSAGA.TMSiUtils.getErrorString(status)));
            end
    
            channel_list_ptr = TMSiSAGA.TMSiUtils.toMatlabStructure('TMSiDevGetSens', channel_list_ptr, num_sensors);
            
            for i = 1:num_sensors_for_real.Value
                temp = channel_list_ptr(i);
                sensors(i).ChanNr = temp.ChanNr;
                sensors(i).IOMode = temp.IOMode;
                sensors(i).SensorID = temp.SensorID;
                sensors(i).SensorMetaData = temp.SensorMetaData;
            end

        end

        function resetDeviceDataBuffer(handle)
            if TMSiSAGA.DeviceLib.trace()
                fprintf(1, 'resetDeviceDataBuffer\n');
            end
            
            % Call dll function
            status = calllib(TMSiSAGA.DeviceLib.alias(), 'TMSiResetDeviceDataBuffer', handle);
            if status ~= 0
                throw(MException('DeviceLib:resetDeviceDataBuffer', 'failed because of %s', ...
                    TMSiSAGA.TMSiUtils.getErrorString(status)));
            end
        end


        function [data, num_sets] = getDeviceRepairData(handle, buffer, buffer_len, repair_request)
            %
            num_sets = libpointer('int32Ptr', 0);

            repair_request = TMSiSAGA.TMSiUtils.toLibraryStructure('TMSiDevRepairReq', repair_request);

            % Call dll function
            status = calllib(TMSiSAGA.DeviceLib.alias(), 'TMSiGetDeviceRepairData', handle, buffer, buffer_len, num_sets, repair_request);
            if status ~= 0
                throw(MException('DeviceLib:getDeviceRepairData', 'failed because of %s', ...
                    TMSiSAGA.TMSiUtils.getErrorString(status)));
            end

            data = buffer.Value;
            num_sets = num_sets.Value;
        end
    end

end
