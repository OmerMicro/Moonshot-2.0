function result = emgun_simulate(varargin)
% EMGUN_SIMULATE Run electromagnetic gun simulation from MATLAB
%
% This function provides a MATLAB interface to the Python electromagnetic
% gun simulation. It handles Python environment setup and data conversion.
%
% Syntax:
%   result = emgun_simulate()                    % Default parameters
%   result = emgun_simulate('voltage', 500)      % Custom voltage
%   result = emgun_simulate('mass', 2.0, 'stages', 8)  % Multiple params
%
% Parameters (Name-Value pairs):
%   'mass'        - Capsule mass in kg (default: 1.0)
%   'diameter'    - Capsule diameter in m (default: 0.083)
%   'tube_length' - Tube length in m (default: 0.5)
%   'stages'      - Number of stages (default: 6)
%   'voltage'     - Stage voltage in V (default: 400)
%   'capacitance' - Stage capacitance in F (default: 1000e-6)
%   'max_time'    - Max simulation time in s (default: 0.01)
%   'time_step'   - Time step in s (default: 1e-5)
%   'output_file' - Base name for output files (optional)
%   'python_exe'  - Path to Python executable (auto-detected)
%
% Returns:
%   result - Structure with simulation results:
%     .final_velocity     - Final velocity in m/s
%     .final_position     - Final position in m
%     .total_time         - Total simulation time in s
%     .energy_efficiency  - Energy efficiency (0-1)
%     .time              - Time array
%     .position          - Position array
%     .velocity          - Velocity array
%     .force             - Force array
%     .kinetic_energy    - Kinetic energy array
%     .parameters        - Input parameters used
%
% Examples:
%   % Basic simulation
%   result = emgun_simulate();
%   plot(result.time*1000, result.velocity);
%   xlabel('Time (ms)'); ylabel('Velocity (m/s)');
%
%   % High voltage simulation
%   result = emgun_simulate('voltage', 600, 'stages', 8);
%   fprintf('Final velocity: %.2f m/s\n', result.final_velocity);
%
%   % Save results to file
%   result = emgun_simulate('output_file', 'my_simulation');
%   % Creates my_simulation.mat, my_simulation.json, my_simulation_analysis.m

    % Parse input arguments
    p = inputParser;
    addParameter(p, 'mass', 1.0, @(x) isnumeric(x) && x > 0);
    addParameter(p, 'diameter', 0.083, @(x) isnumeric(x) && x > 0);
    addParameter(p, 'tube_length', 0.5, @(x) isnumeric(x) && x > 0);
    addParameter(p, 'stages', 6, @(x) isnumeric(x) && x > 0 && mod(x,1)==0);
    addParameter(p, 'voltage', 400.0, @(x) isnumeric(x) && x > 0);
    addParameter(p, 'capacitance', 1000e-6, @(x) isnumeric(x) && x > 0);
    addParameter(p, 'max_time', 0.01, @(x) isnumeric(x) && x > 0);
    addParameter(p, 'time_step', 1e-5, @(x) isnumeric(x) && x > 0);
    addParameter(p, 'output_file', '', @ischar);
    addParameter(p, 'python_exe', '', @ischar);
    
    parse(p, varargin{:});
    params = p.Results;
    
    % Find Python executable
    if isempty(params.python_exe)
        python_exe = find_python_executable();
    else
        python_exe = params.python_exe;
    end
    
    if isempty(python_exe)
        error('Python executable not found. Please specify python_exe parameter or ensure Python is in PATH.');
    end
    
    % Get the current file directory to find the project root
    current_dir = fileparts(mfilename('fullpath'));
    project_root = fileparts(current_dir);  % Go up one level from matlab_wrappers
    
    % Path to the Python runner
    python_script = fullfile(project_root, 'src', 'matlab', 'matlab_runner.py');
    
    if ~exist(python_script, 'file')
        error('Python simulation script not found at: %s', python_script);
    end
    
    % Build command line arguments
    cmd_args = {
        python_exe, '-m', 'src.matlab.matlab_runner',
        '--capsule-mass', num2str(params.mass),
        '--capsule-diameter', num2str(params.diameter),
        '--tube-length', num2str(params.tube_length),
        '--num-stages', num2str(params.stages),
        '--voltage', num2str(params.voltage),
        '--capacitance', num2str(params.capacitance),
        '--max-time', num2str(params.max_time),
        '--time-step', num2str(params.time_step),
        '--json-only'
    };
    
    % Add output file if specified
    if ~isempty(params.output_file)
        cmd_args{end+1} = '--output';
        cmd_args{end+1} = params.output_file;
    end
    
    % Change to project directory and run Python script
    original_dir = pwd;
    try
        cd(project_root);
        
        % Execute Python command
        [status, result_json] = system(sprintf('"%s"', strjoin(cmd_args, '" "')));
        
        if status ~= 0
            error('Python simulation failed with status %d:\n%s', status, result_json);
        end
        
        % Parse JSON result
        try
            result = jsondecode(result_json);
        catch ME
            error('Failed to parse simulation results as JSON:\n%s\nOutput was:\n%s', ...
                  ME.message, result_json);
        end
        
        % Convert arrays to MATLAB format
        if isfield(result, 'time')
            result.time = double(result.time);
        end
        if isfield(result, 'position')
            result.position = double(result.position);
        end
        if isfield(result, 'velocity')
            result.velocity = double(result.velocity);
        end
        if isfield(result, 'force')
            result.force = double(result.force);
        end
        if isfield(result, 'kinetic_energy')
            result.kinetic_energy = double(result.kinetic_energy);
        end
        
    finally
        cd(original_dir);
    end
end

function python_exe = find_python_executable()
    % Try to find Python executable in common locations
    python_candidates = {'python', 'python3', 'py'};
    
    for i = 1:length(python_candidates)
        [status, ~] = system(sprintf('%s --version', python_candidates{i}));
        if status == 0
            python_exe = python_candidates{i};
            return;
        end
    end
    
    % If not found in PATH, try common installation directories on Windows
    if ispc
        common_paths = {
            'C:\Python39\python.exe',
            'C:\Python38\python.exe',
            'C:\Python37\python.exe',
            'C:\Users\%USERNAME%\AppData\Local\Programs\Python\Python39\python.exe',
            'C:\Users\%USERNAME%\AppData\Local\Programs\Python\Python38\python.exe',
            'C:\Users\%USERNAME%\AppData\Local\Programs\Python\Python37\python.exe'
        };
        
        for i = 1:length(common_paths)
            expanded_path = expand_environment_variables(common_paths{i});
            if exist(expanded_path, 'file')
                python_exe = expanded_path;
                return;
            end
        end
    end
    
    python_exe = '';
end

function expanded = expand_environment_variables(path)
    % Simple environment variable expansion for Windows
    if ispc && contains(path, '%USERNAME%')
        username = getenv('USERNAME');
        expanded = strrep(path, '%USERNAME%', username);
    else
        expanded = path;
    end
end