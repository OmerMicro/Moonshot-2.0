function test_gui_system()
% TEST_GUI_SYSTEM Verify electromagnetic gun GUI system functionality
%
% This script tests all components of the GUI system to ensure proper
% operation before user interaction. Tests backend connectivity,
% parameter validation, plotting functions, and GUI components.
%
% Usage:
%   test_gui_system()  % Run all tests
%
% Tests performed:
%   1. Path setup and function availability
%   2. Backend simulation functionality
%   3. Parameter validation system
%   4. Plotting function operation
%   5. GUI component creation (optional)

    fprintf('\n=======================================================\n');
    fprintf('Electromagnetic Gun GUI System Test\n');
    fprintf('=======================================================\n');
    
    % Initialize test results
    tests_passed = 0;
    total_tests = 0;
    
    % Test 1: Check required functions
    fprintf('\n[Test 1] Checking required functions...\n');
    total_tests = total_tests + 1;
    
    required_functions = {'emgun_simulate', 'emgun_gui', 'create_simulation_plots', 'validate_parameters'};
    functions_found = true;
    
    for i = 1:length(required_functions)
        func_name = required_functions{i};
        if exist(func_name, 'file') == 2
            fprintf('  ✓ %s found\n', func_name);
        else
            fprintf('  ✗ %s NOT found\n', func_name);
            functions_found = false;
        end
    end
    
    if functions_found
        fprintf('✓ All required functions available\n');
        tests_passed = tests_passed + 1;
    else
        fprintf('✗ Some required functions missing\n');
    end
    
    % Test 2: Backend simulation test
    fprintf('\n[Test 2] Testing backend simulation...\n');
    total_tests = total_tests + 1;
    
    try
        if exist('emgun_simulate', 'file') == 2
            % Run a quick simulation
            fprintf('  Running test simulation (400V, 6 stages, 5ms)...\n');
            result = emgun_simulate('voltage', 400, 'stages', 6, 'max_time', 0.005);
            
            % Validate result structure
            required_fields = {'final_velocity', 'final_position', 'time', 'velocity'};
            result_valid = true;
            
            for i = 1:length(required_fields)
                if ~isfield(result, required_fields{i})
                    result_valid = false;
                    fprintf('  ✗ Missing field: %s\n', required_fields{i});
                end
            end
            
            if result_valid && isnumeric(result.final_velocity) && result.final_velocity > 0
                fprintf('  ✓ Backend simulation successful\n');
                fprintf('    Final velocity: %.6f m/s\n', result.final_velocity);
                fprintf('    Data points: %d\n', length(result.time));
                tests_passed = tests_passed + 1;
            else
                fprintf('  ✗ Backend simulation returned invalid result\n');
            end
        else
            fprintf('  ✗ emgun_simulate not available - skipping backend test\n');
        end
    catch ME
        fprintf('  ✗ Backend simulation failed: %s\n', ME.message);
    end
    
    % Test 3: Parameter validation
    fprintf('\n[Test 3] Testing parameter validation...\n');
    total_tests = total_tests + 1;
    
    try
        % Test valid parameters
        valid_params = struct();
        valid_params.voltage = 400;
        valid_params.num_stages = 6;
        valid_params.mass = 1.0;
        valid_params.tube_length = 0.5;
        valid_params.max_time = 0.01;
        
        [is_valid, error_msg] = validate_parameters(valid_params);
        
        if is_valid && isempty(error_msg)
            fprintf('  ✓ Valid parameters accepted\n');
        else
            fprintf('  ✗ Valid parameters rejected: %s\n', error_msg);
        end
        
        % Test invalid parameters
        invalid_params = valid_params;
        invalid_params.voltage = 2000;  % Too high
        
        [is_valid, error_msg] = validate_parameters(invalid_params);
        
        if ~is_valid && ~isempty(error_msg)
            fprintf('  ✓ Invalid parameters correctly rejected\n');
            fprintf('    Error: %s\n', error_msg);
            tests_passed = tests_passed + 1;
        else
            fprintf('  ✗ Invalid parameters incorrectly accepted\n');
        end
        
    catch ME
        fprintf('  ✗ Parameter validation test failed: %s\n', ME.message);
    end
    
    % Test 4: Plotting function
    fprintf('\n[Test 4] Testing plotting function...\n');
    total_tests = total_tests + 1;
    
    try
        if exist('result', 'var') && isstruct(result)
            % Test plotting with real data
            fprintf('  Creating test plot (will close automatically)...\n');
            
            % Create plot and close it quickly
            fig_handle = create_simulation_plots(result);
            pause(1);  % Brief pause to see if plot appears
            
            if ishandle(fig_handle)
                fprintf('  ✓ Plotting function created figure successfully\n');
                close(fig_handle);
                tests_passed = tests_passed + 1;
            else
                fprintf('  ✗ Plotting function did not create valid figure\n');
            end
        else
            fprintf('  ⚠ No simulation result available - skipping plot test\n');
        end
    catch ME
        fprintf('  ✗ Plotting function test failed: %s\n', ME.message);
    end
    
    % Test 5: GUI component test (optional)
    fprintf('\n[Test 5] Testing GUI component creation...\n');
    total_tests = total_tests + 1;
    
    try
        fprintf('  Creating test GUI components...\n');
        
        % Create a test figure
        test_fig = figure('Visible', 'off', 'Name', 'GUI Test');
        
        % Test basic UI components
        test_slider = uicontrol('Parent', test_fig, 'Style', 'slider', ...
                               'Position', [10, 10, 100, 20]);
        test_button = uicontrol('Parent', test_fig, 'Style', 'pushbutton', ...
                               'Position', [10, 40, 60, 25], 'String', 'Test');
        
        if ishandle(test_slider) && ishandle(test_button)
            fprintf('  ✓ GUI components created successfully\n');
            tests_passed = tests_passed + 1;
        else
            fprintf('  ✗ GUI component creation failed\n');
        end
        
        % Clean up test figure
        close(test_fig);
        
    catch ME
        fprintf('  ✗ GUI component test failed: %s\n', ME.message);
    end
    
    % Test Summary
    fprintf('\n=======================================================\n');
    fprintf('Test Summary: %d/%d tests passed\n', tests_passed, total_tests);
    
    if tests_passed == total_tests
        fprintf('✓ ALL TESTS PASSED - GUI system ready for use!\n');
        fprintf('\nTo launch the GUI:\n');
        fprintf('  start_gui()     %% Recommended - sets up paths\n');
        fprintf('  emgun_gui()     %% Direct launch\n');
    elseif tests_passed >= total_tests - 1
        fprintf('⚠ MOSTLY WORKING - GUI should function with minor issues\n');
        fprintf('\nTo launch the GUI:\n');
        fprintf('  start_gui()     %% Try this first\n');
    else
        fprintf('✗ MULTIPLE FAILURES - Please fix issues before using GUI\n');
        fprintf('\nTroubleshooting:\n');
        fprintf('1. Ensure you are in the correct project directory\n');
        fprintf('2. Run setup_matlab.bat to install dependencies\n');
        fprintf('3. Check that Python backend is working\n');
        fprintf('4. Verify MATLAB version compatibility (R2015b+)\n');
    end
    
    fprintf('=======================================================\n\n');
    
    % Return test results for automated testing
    if nargout > 0
        varargout{1} = tests_passed;
        varargout{2} = total_tests;
    end
end

function display_system_info()
    % Display system information for debugging
    
    fprintf('\nSystem Information:\n');
    fprintf('==================\n');
    fprintf('MATLAB Version: %s\n', version);
    fprintf('Platform: %s\n', computer);
    fprintf('Current Directory: %s\n', pwd);
    fprintf('MATLAB Path Entries: %d\n', length(strsplit(path, pathsep)));
    
    % Check graphics capability
    try
        test_fig = figure('Visible', 'off');
        close(test_fig);
        fprintf('Graphics: Available\n');
    catch
        fprintf('Graphics: Limited or unavailable\n');
    end
    
    % Check Python
    try
        [status, result] = system('python --version');
        if status == 0
            fprintf('Python: %s', result);
        else
            fprintf('Python: Not available in PATH\n');
        end
    catch
        fprintf('Python: Cannot check version\n');
    end
    
    fprintf('==================\n');
end