classdef SensorChannelType0 < TMSiSAGA.HiddenHandle
    %SENSORCHANNELTYPE0 - Class that represents a dummy sensor channel.
    %
    %   There are multiple types of sensor channel, type 0 is a simple
    %   sensor channel type. It applies a gain, offset and exponent to 
    %   received samples. (samples + offset) * gain / 10^exponent.
    %
    %SENSORCHANNELTYPE0 Properties:
    %   sensor - Sensor
    %   channel_number - Channel number
    %   channel - Channel
    %   struct_id - Struct ID
    %   channel_name - Channel name
    %   unit_name - Unit name
    %   exponent - Exponent
    %   gain - Gain
    %   offset - Offset
    %
    %SENSORCHANNELTYPE0 Methods:
    %   SensorChannelType0 - Constructor for channel type 0 object.
    %   linkChannel - Links this sensor to the channel.
    %   transform - Transform the samples.
    %   size - Get the size of the dummy structure.
    %
    
    properties
        % Sensor
        sensor

        % Channel number
        channel_number

        % Channel
        channel

        % Struct ID
        struct_id

        % Channel name
        channel_name

        % Unit name
        unit_name

        % Exponent
        exponent

        % Gain
        gain

        % Offset
        offset
    end

    methods
        function obj = SensorChannelType0(sensor, channel_number, data)
            %SENSORCHANNELTYPE0 - Constructor for a type 0 sensor channel.
            %
            %   Constructor for a type 0 sensor channel.
            %
            %   sensor - Parent sensor
            %   channel_number - The channel number this channel is located at.
            %   data - The raw byte data of a structure that has to be parsed.%


            obj.channel_number = channel_number;
            obj.sensor = sensor;

            obj.struct_id = typecast(data(1:2), 'uint16');
            if obj.struct_id ~= 0
                throw(MException('SensorChannelType0:parse', 'Incorrect struct id'));
            end

            obj.channel_name = char(data(3:12));
            obj.unit_name = char(data(13:22));
            obj.exponent = typecast(data(23:24), 'int16');
            obj.gain = typecast(data(25:28), 'single');
            obj.offset = typecast(data(29:32), 'single');
        end

        function linkChannel(obj, channel)
            %LINKCHANNEL - Links the sensor to the channel.
            %
            %   Sets the channel unit name, exponent and alternative name to the
            %   one retrieved from the sensor structure.
            %
            %   channel - Channel objects.

            obj.channel = channel;
            
            obj.channel.setUnitName(obj.unit_name);
            obj.channel.setExponent(obj.exponent);
            obj.channel.setAlternativeName(obj.channel_name);
        end

        function samples = transform(obj, samples)
            %TRANSFORM - Transform the samples.
            %
            %   Transforms the samples as (samples + offset) * gain / 10^exponent.
            %
            %   samples - Samples
            samples = ((samples + obj.offset) * obj.gain) ./ 10^double(obj.exponent);
        end

        function size = size(obj) 
            %SIZE - Get size of structure
            %
            %   Get the size of the structure required for parsing.

            size = 32;
        end
    end
end
