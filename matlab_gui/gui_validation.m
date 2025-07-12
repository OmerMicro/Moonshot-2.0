function [is_valid, error_msg] = validate_parameters(params)
% VALIDATE_PARAMETERS Validate electromagnetic gun simulation parameters
%
% Checks if all simulation parameters are within acceptable ranges
% and returns validation status with descriptive error messages.
%
% Input:
%   params - Structure with fields:
%     .voltage     - Stage voltage (V)
%     .num_stages  - Number of stages
%     .mass        - Capsule mass (kg)
%     .tube_length - Tube length (m)
%     .max_time    - Maximum simulation time (s)
%
% Output:
%   is_valid  - Boolean indicating if all parameters are valid
%   error_msg - String with error description (empty if valid)
%
% Example:
%   params.voltage = 400;
%   params.num_stages = 6;
%   params.mass = 1.0;
%   params.tube_length = 0.5;
%   params.max_time = 0.01;
%   [valid, msg] = validate_parameters(params);

    is_valid = true;
    error_msg = '';
    
    % Define parameter limits
    limits = struct();
    limits.voltage = [-1000, 10000];      % Volts
    limits.num_stages = [3, 12];       % Integer stages
    limits.mass = [0.5, 5.0];          % kg
    limits.tube_length = [0.3, 2.0];   % meters
    limits.max_time = [0.005, 0.1];    % seconds
    
    % Check if params is a structure
    if ~isstruct(params)
        is_valid = false;
        error_msg = 'Parameters must be provided as a structure';
        return;
    end
    
    % Required fields
    required_fields = {'voltage', 'num_stages', 'mass', 'tube_length', 'max_time'};
    
    % Check for missing fields
    for i = 1:length(required_fields)
        field = required_fields{i};
        if ~isfield(params, field)
            is_valid = false;
            error_msg = sprintf('Missing required field: %s', field);
            return;
        end
    end
    
    % Validate voltage
    if ~isnumeric(params.voltage) || isnan(params.voltage) || ~isfinite(params.voltage)
        is_valid = false;
        error_msg = 'Voltage must be a finite numeric value';
        return;
    end
    if params.voltage < limits.voltage(1) || params.voltage > limits.voltage(2)
        is_valid = false;
        error_msg = sprintf('Voltage must be between %.0f and %.0f V', ...
                           limits.voltage(1), limits.voltage(2));
        return;
    end
    
    % Validate number of stages
    if ~isnumeric(params.num_stages) || isnan(params.num_stages) || ...
       mod(params.num_stages, 1) ~= 0
        is_valid = false;
        error_msg = 'Number of stages must be an integer';
        return;
    end
    if params.num_stages < limits.num_stages(1) || params.num_stages > limits.num_stages(2)
        is_valid = false;
        error_msg = sprintf('Number of stages must be between %d and %d', ...
                           limits.num_stages(1), limits.num_stages(2));
        return;
    end
    
    % Validate mass
    if ~isnumeric(params.mass) || isnan(params.mass) || ~isfinite(params.mass)
        is_valid = false;
        error_msg = 'Mass must be a finite numeric value';
        return;
    end
    if params.mass <= 0
        is_valid = false;
        error_msg = 'Mass must be positive';
        return;
    end
    if params.mass < limits.mass(1) || params.mass > limits.mass(2)
        is_valid = false;
        error_msg = sprintf('Mass must be between %.1f and %.1f kg', ...
                           limits.mass(1), limits.mass(2));
        return;
    end
    
    % Validate tube length
    if ~isnumeric(params.tube_length) || isnan(params.tube_length) || ~isfinite(params.tube_length)
        is_valid = false;
        error_msg = 'Tube length must be a finite numeric value';
        return;
    end
    if params.tube_length <= 0
        is_valid = false;
        error_msg = 'Tube length must be positive';
        return;
    end
    if params.tube_length < limits.tube_length(1) || params.tube_length > limits.tube_length(2)
        is_valid = false;
        error_msg = sprintf('Tube length must be between %.1f and %.1f m', ...
                           limits.tube_length(1), limits.tube_length(2));
        return;
    end
    
    % Validate max time
    if ~isnumeric(params.max_time) || isnan(params.max_time) || ~isfinite(params.max_time)
        is_valid = false;
        error_msg = 'Maximum time must be a finite numeric value';
        return;
    end
    if params.max_time <= 0
        is_valid = false;
        error_msg = 'Maximum time must be positive';
        return;
    end
    if params.max_time < limits.max_time(1) || params.max_time > limits.max_time(2)
        is_valid = false;
        error_msg = sprintf('Maximum time must be between %.3f and %.1f s', ...
                           limits.max_time(1), limits.max_time(2));
        return;
    end
    
    % Additional physics-based validations
    
    % Check if simulation time is reasonable for tube length
    % Estimate time needed for capsule to traverse tube at reasonable speeds
    estimated_time = params.tube_length / 10; % Assume ~10 m/s average speed
    if params.max_time < estimated_time / 10
        is_valid = false;
        error_msg = sprintf('Maximum time %.3f s may be too short for %.1f m tube. Consider using at least %.3f s', ...
                           params.max_time, params.tube_length, estimated_time / 5);
        return;
    end
    
    % Check for unrealistic voltage/mass combinations
    if params.voltage > 800 && params.mass < 0.8
        is_valid = false;
        error_msg = 'High voltage (>800V) with low mass (<0.8kg) may cause numerical instability';
        return;
    end
    
    % Check for very long tubes with short simulation times
    if params.tube_length > 1.5 && params.max_time < 0.02
        is_valid = false;
        error_msg = sprintf('Long tube (%.1f m) requires longer simulation time. Consider using at least 0.02 s', ...
                           params.tube_length);
        return;
    end
    
    % All validations passed
    is_valid = true;
    error_msg = '';
end

function print_parameter_limits()
    % Helper function to display parameter limits
    fprintf('\nElectromagnetic Gun Simulation Parameter Limits:\n');
    fprintf('===============================================\n');
    fprintf('Voltage per Stage: -1000 - 1000 V\n');
    fprintf('Number of Stages:  3 - 12\n');
    fprintf('Capsule Mass:      0.5 - 5.0 kg\n');
    fprintf('Tube Length:       0.3 - 2.0 m\n');
    fprintf('Max Time:          0.005 - 0.1 s\n');
    fprintf('===============================================\n\n');
end