classdef TMSiUtils < TMSiSAGA.HiddenHandle
    %TMSIUTILS - Class with usefull functions that are used.
    %
    %   Internal use only

    methods (Static = true)

        function [method_info, struct_info, enum_info] = getLibraryInfo()
            persistent p_method p_struct p_enum;

            if isempty(p_method) || isempty(p_struct) || isempty(p_enum)
                [p_method, p_struct, p_enum] = TMSiSAGA.TMSiSagaDeviceLib64();
            end

            method_info = p_method;
            struct_info = p_struct;
            enum_info = p_enum;
        end

        function info(device_name, message)
            disp(['[' device_name '] ' message])
        end

        function s = toLibraryStructure(name, values)
            [~, structs, ~] = TMSiSAGA.TMSiUtils.getLibraryInfo();

            if ~isfield(structs, name)
                throw(MException('TMSiUtils:getStructureInstance', 'Structure is not defined in header file.'));
            end

            s_def = structs.(name).members;
            s_def_fields = fieldnames(s_def);

            unrolled = repmat(struct, 1, numel(values));
            for struct_i = 1:numel(values)
                for field_i = 1:numel(s_def_fields)
                    unrolled(struct_i).(s_def_fields{field_i}) = 0;
                end
                
                s_fields = fieldnames(values(struct_i));
                for field_i = 1:numel(s_fields)
                    field_name = s_fields{field_i};
                    field_value = values(struct_i).(field_name);
                    
                    if any(~cellfun(@isempty, regexp(s_def_fields, ['^' field_name '$'])))
                        unrolled(struct_i).(field_name) = field_value;
                    else
                        if sum(~cellfun(@isempty, regexp(s_def_fields, ['^' s_fields{field_i} '__\d+$']))) < numel(field_value)
                            throw(MException('TMSiUtils:getStructureInstance', 'Field %s has too many elements.', s_fields{field_i}));
                        end

                        for char_i = 1:numel(field_value)
                            unrolled(struct_i).([s_fields{field_i} '__' num2str(char_i)]) = uint8(field_value(char_i));
                        end
                    end
                end
            end
            
            s = libstruct(name, unrolled);
            s = libpointer([name 'Ptr'], s);
        end

        function s = toMatlabStructure(name, ptr, num)
            if ~exist('num', 'var')
                num = 1;
            end

            [~, structs, ~] = TMSiSAGA.TMSiUtils.getLibraryInfo();

            if ~isfield(structs, name)
                throw(MException('TMSiUtils:getStructureInstance', 'Structure is not defined in header file.'));
            end

            s_def = structs.(name).members;
            s_def_fields = fieldnames(s_def);

            s = struct();
            for struct_i = 1:num
                elem_ptr = ptr + (struct_i - 1);
                elem = elem_ptr.Value;

                for field_i = 1:numel(s_def_fields)
                    field_name = s_def_fields{field_i};
                    field_value = elem.(field_name);

                    matches = regexp(field_name, '^(?<name>\w+)__(?<num>\d+)$', 'names');
                    if isempty(matches)
                        s(struct_i).(field_name) = field_value;
                    else
                        if ~isfield(s(struct_i), matches.name)
                            s(struct_i).(matches.name) = [];
                        end
                        arr = s(struct_i).(matches.name);
                        arr(str2double(matches.num)) = field_value;
                        s(struct_i).(matches.name) = arr;
                    end
                end
            end
        end

        function result = toChannelTypeNumber(channel_type) 
            % 0=Unknown, 1=ExG, 2=BIP, 3=AUX, 4=DIGRAW/Sensor,5=DIGSTAT, 6=SAW

            switch lower(channel_type)
                case {'exg', 'uni'}
                    result = 1;
                case 'bip'
                    result = 2;
                case 'aux'
                    result = 3;
                case {'dig', 'digraw', 'digraw/sensor', 'sensor'}
                    result = 4;
                case {'digstat', 'trigger', 'triggers'}
                    result = 5;
                case {'saw', 'counter'}
                    result = 6;
                otherwise
                    throw(MException('TMSiUtils:toChannelTypeNumber', 'Unknown channel type specified.'));
            end
        end

        function result = toChannelTypeString(channel_type_number) 
            % 0=Unknown, 1=ExG, 2=BIP, 3=AUX, 4=DIGRAW/Sensor,5=DIGSTAT, 6=SAW

            switch lower(channel_type_number)
                case 1
                    result = 'exg';
                case 2
                    result = 'bip';
                case 3
                    result = 'aux';
                case 4
                    result = 'dig';
                case 5
                    result = 'digstat';
                case 6
                    result = 'counter';
                otherwise
                    result = 'unknown';
            end
        end

        function result = toInterfaceTypeNumber(interface_type)
            [~, ~, enum_info] = TMSiSAGA.TMSiUtils.getLibraryInfo();

            switch lower(interface_type)
                case 'usb'
                    result = enum_info.TMSiInterfaceType.IF_TYPE_USB;
                case 'network'
                    result = enum_info.TMSiInterfaceType.IF_TYPE_NETWORK;
                case 'wifi'
                    result = enum_info.TMSiInterfaceType.IF_TYPE_WIFI;
                case 'electrical'
                    result = enum_info.TMSiInterfaceType.IF_TYPE_ELECTRICAL;
                case 'optical'
                    result = enum_info.TMSiInterfaceType.IF_TYPE_OPTICAL;
                case 'bluetooth'
                    result = enum_info.TMSiInterfaceType.IF_TYPE_BLUETOOTH;
                otherwise
                    result = enum_info.TMSiInterfaceType.IF_TYPE_UNKOWN;
            end
        end

        function result = toInterfaceTypeString(interface_type)
            [~, ~, enum_info] = TMSiSAGA.TMSiUtils.getLibraryInfo();

            switch lower(interface_type)
                case enum_info.TMSiInterfaceType.IF_TYPE_USB
                    result = 'usb';
                case enum_info.TMSiInterfaceType.IF_TYPE_NETWORK
                    result = 'network';
                case enum_info.TMSiInterfaceType.IF_TYPE_WIFI
                    result = 'wifi';
                case enum_info.TMSiInterfaceType.IF_TYPE_ELECTRICAL
                    result = 'electrical';
                case enum_info.TMSiInterfaceType.IF_TYPE_OPTICAL
                    result = 'optical';
                case enum_info.TMSiInterfaceType.IF_TYPE_BLUETOOTH
                    result = 'bluetooth';
                otherwise
                    result = 'unknown';
            end
        end

        function result = getErrorString(error_number)
            [~, ~, enum_info] = TMSiSAGA.TMSiUtils.getLibraryInfo();

            result = sprintf('%s: ', dec2hex(error_number));

            switch error_number
                case enum_info.TMSiDeviceRetValType.TMSI_OK
                    result = 'ok';
                case enum_info.TMSiDeviceRetValType.TMSI_DR_CHECKSUM_ERROR
                    result = strcat(result, 'data recorder checksum error');
                case enum_info.TMSiDeviceRetValType.TMSI_DS_CHECKSUM_ERROR
                    result = strcat(result, 'docking station checksum error');
                case enum_info.TMSiDeviceRetValType.TMSI_DR_UNKNOWN_COMMAND
                    result = strcat(result, 'data recorder unknown command');
                case enum_info.TMSiDeviceRetValType.TMSI_DS_UNKNOWN_COMMAND
                    result = strcat(result, 'docking station unknown command');
                case enum_info.TMSiDeviceRetValType.TMSI_DR_RESPONSE_TIMEMOUT
                    result = strcat(result, 'data recorder response timeout');
                case enum_info.TMSiDeviceRetValType.TMSI_DS_RESPONSE_TIMEMOUT
                    result = strcat(result, 'docking station response timeout');
                case enum_info.TMSiDeviceRetValType.TMSI_DR_DEVICE_BUSY
                    result = strcat(result, 'data recorder is currently busy, try again');
                case enum_info.TMSiDeviceRetValType.TMSI_DS_DEVICE_BUSY
                    result = strcat(result, 'docking station is currently busy, try again');
                case enum_info.TMSiDeviceRetValType.TMSI_DR_COMMAND_NOT_SUPPORTED
                    result = strcat(result, 'data recorder command is not supported');
                case enum_info.TMSiDeviceRetValType.TMSI_DS_COMMAND_NOT_SUPPORTED
                    result = strcat(result, 'docking station command is not supported');
                case enum_info.TMSiDeviceRetValType.TMSI_DR_COMMAND_NOT_POSSIBLE
                    result = strcat(result, 'data recorder command is currently not possible');
                case enum_info.TMSiDeviceRetValType.TMSI_DR_DEVICE_NOT_AVAILABLE
                    result = strcat(result, 'data recorder is not avaliable');
                case enum_info.TMSiDeviceRetValType.TMSI_DS_DEVICE_NOT_AVAILABLE
                    result = strcat(result, 'docking station is not available');
                case enum_info.TMSiDeviceRetValType.TMSI_DS_INTERFACE_NOT_AVAILABLE
                    result = strcat(result, 'docking station interface is not available');
                case enum_info.TMSiDeviceRetValType.TMSI_DS_COMMAND_NOT_ALLOWED
                    result = strcat(result, 'docking station command is currently not possible');
                case enum_info.TMSiDeviceRetValType.TMSI_DS_PROCESSING_ERROR
                    result = strcat(result, 'a processing error in the docking station');
                case enum_info.TMSiDeviceRetValType.TMSI_DS_UNKOWN_INTERNAL_ERROR
                    result = strcat(result, 'unknown internal error in the docking station');
                case enum_info.TMSiDeviceRetValType.TMSI_DR_COMMAND_NOT_SUPPORTED_BY_CHANNEL
                    result = strcat(result, 'command is not supported by data recorder channel');
                case enum_info.TMSiDeviceRetValType.TMSI_DR_AMBREC_ILLEGAL_START_CTRL
                    result = strcat(result, 'data recorder illegal start control of ambulant recording');
                case enum_info.TMSiDeviceRetValType.TMSI_DLL_NOT_IMPLEMENTED
                    result = strcat(result, 'function not yet implemented');
                case enum_info.TMSiDeviceRetValType.TMSI_DLL_INVALID_PARAM
                    result = strcat(result, 'invalid parameter');
                case enum_info.TMSiDeviceRetValType.TMSI_DLL_CHECKSUM_ERROR
                    result = strcat(result, 'checksum error');
                case enum_info.TMSiDeviceRetValType.TMSI_DLL_ETH_HEADER_ERROR
                    result = strcat(result, 'ethernet header error');
                case enum_info.TMSiDeviceRetValType.TMSI_DLL_INTERNAL_ERROR
                    result = strcat(result, 'internal error');
                case enum_info.TMSiDeviceRetValType.TMSI_DLL_BUFFER_ERROR
                    result = strcat(result, 'buffer error');
                case enum_info.TMSiDeviceRetValType.TMSI_DLL_INVALID_HANDLE
                    result = strcat(result, 'invalid handle');
                case enum_info.TMSiDeviceRetValType.TMSI_DLL_ETH_OPEN_ERROR
                    result = strcat(result, 'ethernet open error');
                case enum_info.TMSiDeviceRetValType.TMSI_DLL_ETH_CLOSE_ERROR
                    result = strcat(result, 'ethernet close error');
                case enum_info.TMSiDeviceRetValType.TMSI_DLL_ETH_SEND_ERROR
                    result = strcat(result, 'ethernet send error');
                case enum_info.TMSiDeviceRetValType.TMSI_DLL_ETH_RECV_ERROR
                    result = strcat(result, 'ethernet received error');
                case enum_info.TMSiDeviceRetValType.TMSI_DLL_ETH_RECV_TIMEOUT
                    result = strcat(result, 'ethernet timeout');
                case enum_info.TMSiDeviceRetValType.TMSI_DLL_LOST_CONNECTION
                    result = strcat(result, 'lost connection with data recorder');
                otherwise
                    result = strcat(result, 'unknown error occurred');
            end
        end
    end
end
