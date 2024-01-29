classdef SensorChannelDummy < TMSiSAGA.HiddenHandle
    %SENSORCHANNELDUMMY - Class that represents a dummy sensor channel.
    %
    %   There are multiple types of sensor channel, and the dummy channel doesn't do 
    %   anything. The transform does not change anything.
    %
    %SENSORCHANNELDUMMY Properties:
    %   device - Device object.
    %   sensor - Sensor object.
    %   channel_number - Located on this channel number.
    %   struct_id - Id of the structure (FFFF).
    %
    %SENSORCHANNELDUMMY Methods:
    %   SensorChannelDummy - Constructor for sensor dummy object.
    %   linkChannel - Links this sensor to the channel.
    %   transform - Transform the samples.
    %   size - Get the size of the dummy structure.
    %
    
    properties 
        % Device
        device

        % Sensor
        sensor

        % Channel number
        channel_number

        % Struct ID
        struct_id

    end

    methods
        function obj = SensorChannelDummy()
            %SENSORCHANNELDUMMY - Constructor for a dummy sensor channel.
            %

            obj.device = device;
            obj.channel_number = channel_number;
            obj.sensor = sensor;

            obj.struct_id = typecast(data(1:2), 'uint16');
            if obj.struct_id ~= hex2dec('FFFF')
                throw(MException('SensorChannelType0:parse', 'Incorrect struct id'));
            end
        end

        function linkChannel(obj, channel)
            %LINKCHANNEL - Links the sensor to the channel.
            %
            %   Does nothing with the channel.
            %
            %   channel - Channel objects.

            % NOOP    
        end

        function samples = transform(obj, samples)
            %TRANSFORM - Transform the samples.
            %
            %   Does nothing with the samples.
            %
            %   samples - Samples

            % NOOP
        end

        function size = size(obj) 
            %SIZE - Get size of structure
            %
            %   Get the size of the structure required for parsing.
            
            size = 2;
        end
    end
end
