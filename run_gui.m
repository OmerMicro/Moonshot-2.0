function run_gui()
% RUN_GUI Launch Electromagnetic Gun Simulation GUI
%
% This script launches the modular electromagnetic gun simulation GUI
% with automatic path setup and system verification.
%
% Usage:
%   run_gui()
%
% Features:
%   - Modular design with small, focused files
%   - Uses proven emgun.m backend (no array issues)
%   - Plots matching Python simulation layout
%   - Simple parameter controls and visualization

    fprintf('\n=======================================================\n');
    fprintf('Electromagnetic Gun Simulation GUI Launcher\n');
    fprintf('=======================================================\n');
    
    % Get project root directory
    project_root = pwd;
    fprintf('Project directory: %s\n', project_root);
    
    % Setup paths
    setup_matlab_paths(project_root);
    
    % Verify backend
    verify_backend();
    
    % Launch GUI
    launch_gui();
    
    % Display instructions
    display_instructions();
end

function setup_matlab_paths(project_root)
    % Setup required MATLAB paths
    fprintf('\nSetting up MATLAB paths...\n');
    
    % Add GUI directory
    gui_dir = fullfile(project_root, 'matlab_gui');
    if exist(gui_dir, 'dir')
        addpath(gui_dir);
        fprintf('✓ Added GUI path: %s\n', gui_dir);
    else
        error('GUI directory not found: %s\nPlease ensure you are in the project root directory.', gui_dir);
    end
    
    % Add matlab_simple directory (for emgun.m backend)
    simple_dir = fullfile(project_root, 'matlab_simple');
    if exist(simple_dir, 'dir')
        addpath(simple_dir);
        fprintf('✓ Added backend path: %s\n', simple_dir);
    else
        error('Backend directory not found: %s\nPlease ensure matlab_simple folder exists.', simple_dir);
    end
    
    % Add matlab_wrappers directory (optional)
    wrapper_dir = fullfile(project_root, 'matlab_wrappers');
    if exist(wrapper_dir, 'dir')
        addpath(wrapper_dir);
        fprintf('✓ Added wrappers path: %s\n', wrapper_dir);
    end
end

function verify_backend()
    % Verify backend is available and working
    fprintf('\nVerifying backend...\n');
    
    if exist('emgun', 'file') ~= 2
        error('Backend function emgun.m not found. Please check matlab_simple directory.');
    end
    
    fprintf('✓ Backend (emgun.m) is available\n');
    
    % Quick backend test
    try
        fprintf('Testing backend connection...\n');
        test_result = emgun(400, 6);
        
        if isstruct(test_result) && isfield(test_result, 'velocity') && isfinite(test_result.velocity)
            fprintf('✓ Backend test successful: %.6f m/s\n', test_result.velocity);
        else
            warning('Backend test returned unexpected result');
        end
        
    catch ME
        warning('Backend test failed: %s\nGUI will launch but simulations may not work', ME.message);
    end
end

function launch_gui()
    % Launch the modular GUI
    fprintf('\nLaunching Modular Electromagnetic Gun GUI...\n');
    
    try
        % Verify GUI components exist
        required_functions = {'emgun_gui_main', 'run_emgun_simulation', 'create_emgun_plots'};
        
        for i = 1:length(required_functions)
            if exist(required_functions{i}, 'file') ~= 2
                error('Required GUI function not found: %s.m', required_functions{i});
            end
        end
        
        % Start the main GUI
        emgun_gui_main();
        
        fprintf('✓ GUI launched successfully!\n');
        
    catch ME
        fprintf('✗ Failed to launch GUI: %s\n', ME.message);
        display_troubleshooting();
        rethrow(ME);
    end
end

function display_instructions()
    % Display user instructions
    fprintf('\n=======================================================\n');
    fprintf('GUI Instructions:\n');
    fprintf('1. Adjust voltage (100-1000V) using slider or input field\n');
    fprintf('2. Select number of stages (3-12) from dropdown\n');
    fprintf('3. Use quick presets for common configurations\n');
    fprintf('4. Click "Run Simulation" to execute\n');
    fprintf('5. Click "Show Plots" to view 2x2 plot layout\n');
    fprintf('\nDefault Configuration:\n');
    fprintf('• Voltage: 400V per stage\n');
    fprintf('• Stages: 6 acceleration stages\n');
    fprintf('• Mass: 1.0 kg (fixed)\n');
    fprintf('• Tube: 0.5 m (fixed)\n');
    fprintf('• Time: 0.01 s (fixed)\n');
    fprintf('\nExpected Result: ~0.008 m/s final velocity\n');
    fprintf('\nPlot Layout (matches Python simulation):\n');
    fprintf('• Top-left: Position vs Time (mm vs ms)\n');
    fprintf('• Top-right: Velocity vs Time (m/s vs ms)\n');
    fprintf('• Bottom-left: Force vs Time (N vs ms)\n');
    fprintf('• Bottom-right: Energy vs Time (J vs ms)\n');
    fprintf('=======================================================\n\n');
end

function display_troubleshooting()
    % Display troubleshooting information
    fprintf('\nTroubleshooting:\n');
    fprintf('1. Ensure you are in the project root directory\n');
    fprintf('2. Check that matlab_gui/ folder exists with all .m files\n');
    fprintf('3. Check that matlab_simple/ folder exists with emgun.m\n');
    fprintf('4. Try running: emgun(400, 6) to test backend directly\n');
    fprintf('5. Check MATLAB version (R2015b+ recommended)\n');
    
    % Check current directory structure
    fprintf('\nCurrent directory contents:\n');
    dir_contents = dir('.');
    for i = 1:length(dir_contents)
        if dir_contents(i).isdir && ~startsWith(dir_contents(i).name, '.')
            fprintf('  [DIR]  %s\n', dir_contents(i).name);
        end
    end
    
    % Check for key files
    key_files = {'run_gui.m', 'matlab_gui', 'matlab_simple'};
    fprintf('\nKey components:\n');
    for i = 1:length(key_files)
        if exist(key_files{i}, 'file') || exist(key_files{i}, 'dir')
            fprintf('  ✓ %s\n', key_files{i});
        else
            fprintf('  ✗ %s\n', key_files{i});
        end
    end
end