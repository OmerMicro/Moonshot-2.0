function start_gui()
% START_GUI Launch Electromagnetic Gun Simulation GUI
%
% This script sets up the MATLAB path and launches the electromagnetic
% gun simulation GUI with all required dependencies.
%
% Usage:
%   start_gui()  % Launch the GUI
%
% Requirements:
%   - MATLAB R2015b or later (for better UI components)
%   - Python with required packages (numpy, scipy, matplotlib)
%   - Electromagnetic gun simulation backend (emgun_simulate.m)

    fprintf('\n=======================================================\n');
    fprintf('Electromagnetic Gun Simulation GUI\n');
    fprintf('=======================================================\n');
    
    % Get current directory
    current_dir = fileparts(mfilename('fullpath'));
    project_root = fileparts(current_dir);
    
    % Add required paths
    fprintf('Setting up MATLAB paths...\n');
    
    % Add GUI directory
    addpath(current_dir);
    fprintf('✓ Added GUI path: %s\n', current_dir);
    
    % Add matlab_wrappers directory
    wrapper_dir = fullfile(project_root, 'matlab_wrappers');
    if exist(wrapper_dir, 'dir')
        addpath(wrapper_dir);
        fprintf('✓ Added wrappers path: %s\n', wrapper_dir);
    else
        warning('matlab_wrappers directory not found at: %s', wrapper_dir);
    end
    
    % Add matlab_simple directory
    simple_dir = fullfile(project_root, 'matlab_simple');
    if exist(simple_dir, 'dir')
        addpath(simple_dir);
        fprintf('✓ Added simple interface path: %s\n', simple_dir);
    else
        warning('matlab_simple directory not found at: %s', simple_dir);
    end
    
    % Check for required functions
    fprintf('\nChecking dependencies...\n');
    
    if exist('emgun_simulate', 'file') == 2
        fprintf('✓ emgun_simulate function found\n');
    else
        fprintf('✗ emgun_simulate function not found\n');
        fprintf('  Please ensure matlab_wrappers is in MATLAB path\n');
    end
    
    if exist('emgun', 'file') == 2
        fprintf('✓ emgun function found\n');
    else
        fprintf('⚠ emgun function not found (optional)\n');
    end
    
    % Test basic functionality
    fprintf('\nTesting backend connection...\n');
    try
        % Quick test of emgun_simulate if available
        if exist('emgun_simulate', 'file') == 2
            test_result = emgun_simulate('voltage', 400, 'stages', 6, 'max_time', 0.005);
            if isstruct(test_result) && isfield(test_result, 'final_velocity')
                fprintf('✓ Backend test successful: %.3f m/s final velocity\n', test_result.final_velocity);
            else
                fprintf('⚠ Backend test returned unexpected result\n');
            end
        else
            fprintf('⚠ Skipping backend test - emgun_simulate not available\n');
        end
    catch ME
        fprintf('⚠ Backend test failed: %s\n', ME.message);
        fprintf('  GUI will still launch but simulations may not work\n');
    end
    
    % Launch GUI
    fprintf('\nLaunching GUI...\n');
    try
        emgun_gui();
        fprintf('✓ GUI launched successfully!\n');
        fprintf('\nInstructions:\n');
        fprintf('1. Adjust parameters using sliders and input fields\n');
        fprintf('2. Click "Run Simulation" to execute\n');
        fprintf('3. Click "Show Plots" to visualize results\n');
        fprintf('4. Use "Export Data" to save results\n');
        
    catch ME
        fprintf('✗ Failed to launch GUI: %s\n', ME.message);
        fprintf('\nTroubleshooting:\n');
        fprintf('- Ensure you are in the correct directory\n');
        fprintf('- Check that all required files are present\n');
        fprintf('- Verify MATLAB version compatibility\n');
        rethrow(ME);
    end
    
    fprintf('\n=======================================================\n\n');
end

function print_system_info()
    % Display system information for debugging
    
    fprintf('\nSystem Information:\n');
    fprintf('==================\n');
    fprintf('MATLAB Version: %s\n', version);
    fprintf('Platform: %s\n', computer);
    fprintf('Current Directory: %s\n', pwd);
    
    % Check Python availability
    try
        [status, python_version] = system('python --version');
        if status == 0
            fprintf('Python: %s', python_version);
        else
            fprintf('Python: Not available in PATH\n');
        end
    catch
        fprintf('Python: Cannot determine version\n');
    end
    
    fprintf('==================\n');
end