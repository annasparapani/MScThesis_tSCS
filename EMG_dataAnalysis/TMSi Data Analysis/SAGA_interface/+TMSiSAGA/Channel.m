classdef Channel < TMSiSAGA.HiddenHandle
    %CHANNEL Class that represents a single channel on a device.
    %
    %CHANNEL Properties:
    %   number - The number used by the device to identify the channel
    %   type - The channel type like ExG, Uni, etc.
    %   format - The format of the channel, float, int32, uin32, etc.
    %   divider - The sample rate of this channel, is "<base sample rate device> / 2^<divider>". If -1 the channel is disabled.
    %   impedance_divider - The sample rate when in impedance mode, is "<base sample rate device> / 2^<divider>". If -1 the channel is disabled.
    %   bandwidth - The bandwidth required for the data in this channel.
    %   exponent - The exponent to apply to the data.
    %   unit_name - The unit name of the retrieved data.
    %   name - The fixed name of the channel.
    %   alternative_name - The current alternative name set on this channel.
    %   sensor_channel - An optional sensor channel that is connected to this channel.
    %
    %CHANNEL Methods:
    %   Channel - Constructor for the Channel object.
    %   isActive - Is the current channel active in sample, or impedance mode.
    %   enable - Enable the channel.
    %   disable - Disable the channel.
    %   setUnitname - Set the unit for this channel.
    %   setExponent - Set the exponent value for this channel.
    %   setAlternativeName - Set the alternative name for this channel.
    %   isExG - Check if this an ExG channel.
    %   isBip - Check if this an Bip channel.
    %   isAux - Check if this an Aux channel.
    %   isDig - Check if this an Dig channel.
    %   isDigstat - Check if this an Digstat channel.
    %   isSaw - Check if this a saw channel.
    %   isCounter - Check if this is the counter channel.
    %   isStatus - Check if this is the status channel.
    %   transform - A function that transform the raw sample data.
    %
    %CHANNEL Example:
    %   
    %   

    properties
        % The number used by the device to identify the channel
        number

        % The channel type like ExG, Uni, etc.
        type
            
        % The format of the channel, float, int32, uin32, etc.
        format
        
        % The sample rate of this channel, is "<base sample rate device> / 2^<divider>". If -1 the channel is disabled.
        divider
        
        % The sample rate when in impedance mode, is "<base sample rate device> / 2^<divider>". If -1 the channel is disabled.
        impedance_divider
        
        % The bandwidth required for the data in this channel.
        bandwidth
        
        % The exponent to apply to the data.
        exponent
        
        % he unit name of the retrieved data.
        unit_name
        
        % The fixed name of the channel.
        name
        
        % The current alternative name set on this channel.
        alternative_name
        
        % An optional sensor channel that is connected to this channel.
        sensor_channel
    end

    properties (Access = private)
        % The source device of this channel.
        device 

        % The type to which the has to be transformed before using.
        to_type
            
        % The stride that is required for the type conversion.
        to_stride
    end

    methods
        function obj = Channel(device, channel_info)
            %CHANNEL - Constructor for the Channel object.
            %
            %   Constructor for the Channel object. Requires a device, and the raw channel info structure
            %   from the TMSi device. It is not recommended to create a channel directly.
            %
            %   device - The device for which the channel object is created.
            %   channel_info - Basic channel information, should be gotten from the device.

            obj.device = device;
            obj.number = int64(channel_info.Number);
            obj.type = int64(channel_info.ChannelType);
            obj.format = int64(channel_info.ChannelFormat);
            obj.divider = int64(channel_info.ChanDivider);
            obj.impedance_divider = int64(channel_info.ImpDivider);
            obj.bandwidth = int64(channel_info.ChannelBandWidth);
            obj.exponent = int64(channel_info.Exp);
            obj.unit_name = channel_info.UnitName;
            obj.name = channel_info.DefChanName;
            obj.alternative_name = channel_info.AltChanName;
            if obj.alternative_name == ""
                obj.alternative_name = obj.name;
            end
            
            obj.sensor_channel = [];

            obj.to_type = 'double';
            obj.to_stride = 0;

            if bitand(obj.format, int64(hex2dec('FF00'))) == hex2dec('1100')
                obj.to_type = 'single';
                obj.to_stride = 0;
            elseif bitand(obj.format, int64(hex2dec('0100')))
                obj.to_type = ['int' num2str(bitand(obj.format, int64(hex2dec('00FF'))))];
                obj.to_stride = int32(4 / (bitand(obj.format, int64(hex2dec('00FF'))) / 8));
            else
                obj.to_type = ['uint' num2str(bitand(obj.format, int64(hex2dec('00FF'))))];
                obj.to_stride = int32(4 / (bitand(obj.format, int64(hex2dec('00FF'))) / 8));
            end
        end

        function is_active = isActive(obj, impedance_mode)
            %ISACTIVE - A function that checks if the channel is active.
            %
            %   This function checks if a channel is active in sampling mode or
            %   in impedance mode. Cannot check for both cases at a time.
            %
            %   impedance_mode - Optional parameter. Set to TRUE if you want to 
            %       check the active state of the channel when in impedance 
            %       mode. Is FALSE by default.

            is_active = false;
            if exist('impedance_mode', 'var') && impedance_mode
                is_active = obj.impedance_divider >= 0;
            else
                is_active = obj.divider >= 0;
            end
        end

        function enable(obj)
            %ENABLE - A function to enable the channel.
            %
            %   This function will enable the channel and set the divider to the current
            %   divider for this channel type gotten from device.

            if obj.device.is_sampling
                throw(MException('Channel:enable', 'Cannot enable/disable channel while device is sampling.'));
            end

            obj.divider = obj.device.dividers(obj.type);
            obj.device.out_of_sync = true;
        end

        function disable(obj)
            %DISABLE - A function to disable the channel.
            %
            %   This function will disable the channel and set the divider to -1.

            if obj.device.is_sampling
                throw(MException('Channel:disable', 'Cannot enable/disable channel while device is sampling.'));
            end

            obj.divider = -1;
            obj.device.out_of_sync = true;
        end

        function setUnitName(obj, unit_name)
            %SETUNITNAME - A function to set the unit name for this channel.
            %
            %   This function will set the unit name for this channel. Primary use
            %   is to set the unit name when it is a sensor channel.
            %
            %   unit_name - A string containing the unit name.

            if obj.device.is_sampling
                throw(MException('Channel:setUnitName', 'Cannot change unit name while device is sampling.'));
            end

            obj.unit_name = unit_name;
        end

        function setExponent(obj, exponent)
            %SETEXPONENT - A function to set the exponent value for this channel.
            %
            %   This function will set the exponent for this channel. The raw data is 
            %   divided by 10^exponent.
            %
            %   exponent - A value containing the exponent.
            if obj.device.is_sampling
                throw(MException('Channel:setExponent', 'Cannot change exponent while device is sampling.'));
            end

            obj.exponent = exponent;
        end

        function setAlternativeName(obj, alternative_name)
            %SETALTERNATIVENAME - A function to set the alternative name of this channel.
            %
            %   This function will set the alternative name for this channel. By default
            %   the regular channel name is used.
            %
            %   alternative_name - A string to be used as alternative name.
        
            if obj.device.is_sampling
                throw(MException('Channel:setAlternativeName', 'Cannot change alternative name while device is sampling.'));
            end

            obj.alternative_name = alternative_name;

            obj.device.out_of_sync = true;
        end

        function is_true = isExG(obj)
            %ISEXG - A function to check if this channel is an ExG channel.
            %
            %   This function will check if the channel type is ExG (1). 

            is_true = [obj.type] == 1;
        end

        function is_true = isBip(obj)
            %ISBIP - A function to check if this channel is an Bip channel.
            %
            %   This function will check if the channel type is Bip (2). 
            
            is_true = [obj.type] == 2;
        end

        function is_true = isAux(obj)
            %ISAUX - A function to check if this channel is an Aux channel.
            %
            %   This function will check if the channel type is Aux (3). 
            
            is_true = [obj.type] == 3;
        end

        function is_true = isDig(obj)
            %ISDIG - A function to check if this channel is an Dig channel.
            %
            %   This function will check if the channel type is Dig (4). 
            
            is_true = [obj.type] == 4;
        end

        function is_true = isDigstat(obj)
            %ISDIGSTAT - A function to check if this channel is an Digstat channel.
            %
            %   This function will check if the channel type is Digstat (5). 
            
            is_true = [obj.type] == 5;
        end

        function is_true = isSaw(obj)
            %ISSAW - A function to check if this channel is an Saw channel.
            %
            %   This function will check if the channel type is Saw (6). 
            
            is_true = [obj.type] == 6;
        end

        function is_true = isCounter(obj)
            %ISCOUNTER - A function to check if this channel is the counter channel.
            %
            %   This function checks if the name of the channel is COUNTER.

            is_true = strcmp(obj.name, 'COUNTER');
        end

        function is_true = isStatus(obj)
            %ISSTATUS - A function to check if this channel is the status channel.
            %
            %   This function checks if the name of the channel is STATUS.

            is_true = strcmp(obj.name, 'STATUS');
        end

        function result = transform(obj, samples)
            %TRANSFORM - A function that transforms samples, based on channel settings.
            %
            %   This function will transform the raw samples from the device, into the
            %   right types and applies either sensor transform or the default exponent
            %   transform.
            
            if strcmp(obj.to_type, 'single')
                result = double(samples);
            else
                result = typecast(samples, obj.to_type);
                result = double(result(1:obj.to_stride:end));
            end

            if numel(obj.sensor_channel) ~= 0
                result = obj.sensor_channel.transform(result);
            else
                result = result ./ (10^double(obj.exponent));
            end
        end
    end
end