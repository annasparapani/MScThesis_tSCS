classdef DockingStationInfo < TMSiSAGA.HiddenHandle
    %DOCKINGSTATIONINFO - A class that encapsulates the docking station info.
    %
    %DOCKINGSTATIONINFO Properties:
    %   interface_type - Interface type of the docking station.
    %   serial_number - Serial number of docking station.
    %   temperature - Current temprature of docking station.
    %   sync_out_divider - The sync out divider.
    %   sync_out_duty_cycle - The sync out duty cycle.
    %
    %DOCKINGSTATIONINFO Methods:
    %   DockingStationInfo - Simple constructor.

    properties
        % Interface type of the docking station.
        interface_type

        % Serial number of docking station.
        serial_number

        % Current temprature of docking station.
        temperature
        
        % The sync out divider.
        sync_out_divider

        % The sync out duty cycle.
        sync_out_duty_cycle
    end

    methods
        function obj = DockingStationInfo(obj)
        end
    end

end