function result = run_emgun_simulation(voltage, num_stages)
% RUN_EMGUN_SIMULATION Backend helper for running electromagnetic gun simulation
%
% This function provides a clean interface to the emgun.m backend
% with proper error handling and path management.
%
% Usage:
%   result = run_emgun_simulation(voltage, num_stages)
%
% Input:
%   voltage    - Voltage per stage in Volts (100-1000)
%   num_stages - Number of acceleration stages (3-12)
%
% Output:
%   result - Structure with simulation results:
%     .velocity   - Final velocity in m/s
%     .position   - Final position in m
%     .time       - Total simulation time in s
%     .efficiency - Energy efficiency (0-1)

    % Input validation
    if nargin < 2
        error('Both voltage and num_stages are required');
    end
    
    if ~isnumeric(voltage) || voltage < 100 || voltage > 1000
        error('Voltage must be between 100 and 1000 V');
    end
    
    if ~isnumeric(num_stages) || num_stages < 3 || num_stages > 12 || mod(num_stages, 1) ~= 0
        error('Number of stages must be an integer between 3 and 12');
    end
    
    % Ensure emgun.m is available
    if exist('emgun', 'file') ~= 2
        % Try to add matlab_simple to path
        current_dir = fileparts(mfilename('fullpath'));
        project_root = fileparts(current_dir);
        simple_dir = fullfile(project_root, 'matlab_simple');
        
        if exist(simple_dir, 'dir')
            addpath(simple_dir);
            fprintf('Added path: %s\n', simple_dir);
        else
            error('Cannot find emgun function. Please ensure matlab_simple directory exists.');
        end
    end
    
    % Run the simulation
    try
        result = emgun(voltage, num_stages);
        
        % Validate result structure
        if ~isstruct(result)
            error('emgun function returned invalid result (not a structure)');
        end
        
        required_fields = {'velocity', 'position', 'time', 'efficiency'};
        for i = 1:length(required_fields)
            if ~isfield(result, required_fields{i})
                error('emgun result missing field: %s', required_fields{i});
            end
        end
        
        % Validate result values
        if ~isnumeric(result.velocity) || ~isfinite(result.velocity)
            error('Invalid velocity result: %s', num2str(result.velocity));
        end
        
        if result.velocity < 0
            error('Negative velocity result: %f m/s', result.velocity);
        end
        
    catch ME
        if contains(ME.message, 'emgun')
            % Re-throw emgun-specific errors as-is
            rethrow(ME);
        else
            % Wrap other errors with context
            error('Simulation backend error: %s', ME.message);
        end
    end
    
    % Log successful result
    fprintf('Backend simulation successful: %.6f m/s\n', result.velocity);
end