classdef DataRecorderInfo < TMSiSAGA.HiddenHandle
    %DATARECORDERINFO A class that encapsulates the data recorder info.
    %
    %   The properties for this class can be set directly accessed.
    %
    %DATARECORDERINFO Properties:
    %   sync_out_divider - The sync out divider.
    %   sync_out_duty_cycle - The sync out duty cycle.
    %   interface_type - The interface type on which the data recorder is connected.
    %   serial_number - The serial number of the data recorder.
    %   available - A boolean stating if data recorder is available.
    %   temperature - Current temprature of the data recorder.
    %   id - Id of the data recorder.
    %
    %DATARECORDERINFO Methods:
    %   DataRecorderInfo - A simple constructor for DataRecorderInfo object.
    %

    properties
        % The sync out divider.
        sync_out_divider

        % The sync out duty cycle.
        sync_out_duty_cycle

        % The interface type on which the data recorder is connected.
        interface_type

        % The serial number of the data recorder.
        serial_number

        % A boolean stating if data recorder is available.
        available

        % Current temprature of the data recorder.
        temperature

        % Id of the data recorder.
        id
    end

    methods
        function obj = DataRecorderInfo(obj)
            %DATARECORDERINFO Constructor for the DataRecorderInfo object.
            %
            %   This constructor creates a simple empty DataRecorderInfo object.

        end
    end

end