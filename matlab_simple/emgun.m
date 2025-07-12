function result = emgun(voltage, stages, max_time)
% EMGUN Simple electromagnetic gun simulation for MATLAB
%
% Usage: result = emgun(voltage, stages, max_time)
%   voltage  - Voltage per stage in Volts (e.g., 400)
%   stages   - Number of stages (e.g., 6)
%   max_time - Maximum simulation time in seconds
%
% Returns: result.velocity - Final velocity in m/s
%
% Example: result = emgun(400, 6, 0.05);

    if nargin < 2
        voltage = 400;
        stages = 6;
    end
    
    % Get current directory and find project root
    current_dir = pwd;
    project_root = fileparts(fileparts(mfilename('fullpath'))); % Go up from matlab_simple
    
    % Change to project directory temporarily
    cd(project_root);
    
    try
        venv_python = fullfile(project_root, 'venv', 'Scripts', 'python.exe');
        if exist(venv_python, 'file')
            cmd = sprintf('"%s" -m src.matlab.matlab_runner --voltage %g --num-stages %d --max-time %g --json-only', venv_python, voltage, stages, max_time);
        else
            cmd = sprintf('python -m src.matlab.matlab_runner --voltage %g --num-stages %d --max-time %g --json-only', voltage, stages, max_time);
        end

        % Run simulation
        [status, json_output] = system(cmd);
        
        if status ~= 0
            error('Simulation failed: %s', json_output);
        end
        
        % Parse result
        try
            data = jsondecode(json_output);
            result.velocity = data.final_velocity;
            result.position = data.final_position;
            result.time = data.total_time;
            result.efficiency = data.energy_efficiency;
        catch
            error('Failed to parse simulation output');
        end
        
        % Display result
        fprintf('Electromagnetic Gun: %.0fV, %d stages → %.3f m/s\n', voltage, stages, result.velocity);
        
    finally
        % Return to original directory
        cd(current_dir);
    end
end