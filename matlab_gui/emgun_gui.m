function emgun_gui()
% EMGUN_GUI Electromagnetic Gun Simulation GUI
%
% Interactive MATLAB GUI for controlling electromagnetic gun simulation
% parameters and visualizing results.
%
% Usage:
%   emgun_gui()  % Launch the GUI
%
% Features:
%   - Parameter control with sliders and input fields
%   - Real-time parameter validation
%   - Post-simulation plotting
%   - Data export capabilities
%   - Built on proven emgun_simulate backend

    % Create main figure
    fig = figure('Name', 'Electromagnetic Gun Simulation Control Panel', ...
                 'Position', [100, 100, 700, 550], ...
                 'MenuBar', 'none', ...
                 'ToolBar', 'none', ...
                 'Resize', 'off', ...
                 'NumberTitle', 'off', ...
                 'CloseRequestFcn', @close_gui);
    
    % Initialize GUI data structure
    gui_data = struct();
    gui_data.fig = fig;
    gui_data.last_result = [];
    
    % Create GUI components and store handles in gui_data
    gui_data = create_parameter_controls(fig, gui_data);
    gui_data = create_control_buttons(fig, gui_data);
    gui_data = create_results_display(fig, gui_data);
    
    % Store GUI data
    guidata(fig, gui_data);
    
    % Set default parameters
    set_default_parameters(fig);
    
    % Make figure visible
    set(fig, 'Visible', 'on');
    
    fprintf('Electromagnetic Gun GUI launched successfully!\n');
    fprintf('Backend: emgun_simulate.m (proven working system)\n\n');
end

function gui_data = create_parameter_controls(fig, gui_data)
    % Create parameter control panel
    
    % Main parameter panel
    param_panel = uipanel('Parent', fig, ...
                         'Title', 'Simulation Parameters', ...
                         'FontSize', 12, ...
                         'FontWeight', 'bold', ...
                         'Position', [0.05, 0.4, 0.6, 0.55]);
    
    % Voltage control
    uicontrol('Parent', param_panel, 'Style', 'text', ...
              'String', 'Voltage per Stage (V):', ...
              'Position', [20, 210, 150, 20], ...
              'HorizontalAlignment', 'left', 'FontSize', 10);
    
    gui_data.voltage_slider = uicontrol('Parent', param_panel, 'Style', 'slider', ...
                                       'Min', 100, 'Max', 1000, 'Value', 400, ...
                                       'Position', [20, 190, 200, 20], ...
                                       'Callback', @update_voltage_display);
    
    gui_data.voltage_edit = uicontrol('Parent', param_panel, 'Style', 'edit', ...
                                     'String', '400', ...
                                     'Position', [230, 190, 60, 20], ...
                                     'Callback', @update_voltage_slider);
    
    uicontrol('Parent', param_panel, 'Style', 'text', ...
              'String', '[100 - 1000]', ...
              'Position', [300, 190, 80, 20], ...
              'HorizontalAlignment', 'left', 'FontSize', 9, ...
              'ForegroundColor', [0.5, 0.5, 0.5]);
    
    % Number of stages control
    uicontrol('Parent', param_panel, 'Style', 'text', ...
              'String', 'Number of Stages:', ...
              'Position', [20, 160, 150, 20], ...
              'HorizontalAlignment', 'left', 'FontSize', 10);
    
    gui_data.stages_popup = uicontrol('Parent', param_panel, 'Style', 'popupmenu', ...
                                     'String', {'3', '4', '5', '6', '7', '8', '9', '10', '11', '12'}, ...
                                     'Value', 4, ...  % Default to 6 stages
                                     'Position', [230, 160, 60, 20]);
    
    % Capsule mass control
    uicontrol('Parent', param_panel, 'Style', 'text', ...
              'String', 'Capsule Mass (kg):', ...
              'Position', [20, 110, 150, 20], ...
              'HorizontalAlignment', 'left', 'FontSize', 10);
    
    gui_data.mass_slider = uicontrol('Parent', param_panel, 'Style', 'slider', ...
                                    'Min', 0.5, 'Max', 5.0, 'Value', 1.0, ...
                                    'Position', [20, 90, 200, 20], ...
                                    'Callback', @update_mass_display);
    
    gui_data.mass_edit = uicontrol('Parent', param_panel, 'Style', 'edit', ...
                                  'String', '1.0', ...
                                  'Position', [230, 90, 60, 20], ...
                                  'Callback', @update_mass_slider);
    
    uicontrol('Parent', param_panel, 'Style', 'text', ...
              'String', '[0.5 - 5.0]', ...
              'Position', [300, 90, 80, 20], ...
              'HorizontalAlignment', 'left', 'FontSize', 9, ...
              'ForegroundColor', [0.5, 0.5, 0.5]);
    
    % Tube length control
    uicontrol('Parent', param_panel, 'Style', 'text', ...
              'String', 'Tube Length (m):', ...
              'Position', [20, 60, 150, 20], ...
              'HorizontalAlignment', 'left', 'FontSize', 10);
    
    gui_data.tube_slider = uicontrol('Parent', param_panel, 'Style', 'slider', ...
                                    'Min', 0.3, 'Max', 2.0, 'Value', 0.5, ...
                                    'Position', [20, 40, 200, 20], ...
                                    'Callback', @update_tube_display);
    
    gui_data.tube_edit = uicontrol('Parent', param_panel, 'Style', 'edit', ...
                                  'String', '0.5', ...
                                  'Position', [230, 40, 60, 20], ...
                                  'Callback', @update_tube_slider);
    
    uicontrol('Parent', param_panel, 'Style', 'text', ...
              'String', '[0.3 - 2.0]', ...
              'Position', [300, 40, 80, 20], ...
              'HorizontalAlignment', 'left', 'FontSize', 9, ...
              'ForegroundColor', [0.5, 0.5, 0.5]);
    
    % Simulation time control
    uicontrol('Parent', param_panel, 'Style', 'text', ...
              'String', 'Max Time (s):', ...
              'Position', [20, 10, 150, 20], ...
              'HorizontalAlignment', 'left', 'FontSize', 10);
    
    gui_data.time_edit = uicontrol('Parent', param_panel, 'Style', 'edit', ...
                                  'String', '0.01', ...
                                  'Position', [230, 10, 60, 20]);
    
    uicontrol('Parent', param_panel, 'Style', 'text', ...
              'String', '[0.005 - 0.1]', ...
              'Position', [300, 10, 80, 20], ...
              'HorizontalAlignment', 'left', 'FontSize', 9, ...
              'ForegroundColor', [0.5, 0.5, 0.5]);
end

function gui_data = create_control_buttons(fig, gui_data)
    % Create control buttons
    
    button_panel = uipanel('Parent', fig, ...
                          'Position', [0.05, 0.25, 0.6, 0.12]);
    
    % Run Simulation button
    gui_data.run_button = uicontrol('Parent', button_panel, 'Style', 'pushbutton', ...
                                   'String', 'Run Simulation', ...
                                   'Position', [20, 20, 120, 35], ...
                                   'FontSize', 11, 'FontWeight', 'bold', ...
                                   'BackgroundColor', [0.2, 0.8, 0.2], ...
                                   'Callback', @run_simulation_callback);
    
    % Reset button
    uicontrol('Parent', button_panel, 'Style', 'pushbutton', ...
              'String', 'Reset to Default', ...
              'Position', [160, 20, 120, 35], ...
              'FontSize', 10, ...
              'Callback', @reset_parameters_callback);
    
    % Export button
    gui_data.export_button = uicontrol('Parent', button_panel, 'Style', 'pushbutton', ...
                                      'String', 'Export Data', ...
                                      'Position', [300, 20, 100, 35], ...
                                      'FontSize', 10, ...
                                      'Enable', 'off', ...
                                      'Callback', @export_data_callback);
end

function gui_data = create_results_display(fig, gui_data)
    % Create results display panel
    
    results_panel = uipanel('Parent', fig, ...
                           'Title', 'Results Summary', ...
                           'FontSize', 12, ...
                           'FontWeight', 'bold', ...
                           'Position', [0.05, 0.05, 0.6, 0.18]);
    
    % Results text displays
    gui_data.velocity_text = uicontrol('Parent', results_panel, 'Style', 'text', ...
                                      'String', 'Final Velocity: --- m/s', ...
                                      'Position', [20, 60, 200, 20], ...
                                      'HorizontalAlignment', 'left', 'FontSize', 10);
    
    gui_data.position_text = uicontrol('Parent', results_panel, 'Style', 'text', ...
                                      'String', 'Final Position: --- m', ...
                                      'Position', [250, 60, 200, 20], ...
                                      'HorizontalAlignment', 'left', 'FontSize', 10);
    
    gui_data.force_text = uicontrol('Parent', results_panel, 'Style', 'text', ...
                                   'String', 'Max Force: --- N', ...
                                   'Position', [20, 40, 200, 20], ...
                                   'HorizontalAlignment', 'left', 'FontSize', 10);
    
    gui_data.efficiency_text = uicontrol('Parent', results_panel, 'Style', 'text', ...
                                        'String', 'Energy Efficiency: --- %', ...
                                        'Position', [250, 40, 200, 20], ...
                                        'HorizontalAlignment', 'left', 'FontSize', 10);
    
    gui_data.time_text = uicontrol('Parent', results_panel, 'Style', 'text', ...
                                  'String', 'Simulation Time: --- ms', ...
                                  'Position', [20, 20, 200, 20], ...
                                  'HorizontalAlignment', 'left', 'FontSize', 10);
    
    % Show Plots button
    gui_data.plot_button = uicontrol('Parent', fig, 'Style', 'pushbutton', ...
                                    'String', 'Show Plots', ...
                                    'Position', [480, 50, 150, 40], ...
                                    'FontSize', 12, 'FontWeight', 'bold', ...
                                    'BackgroundColor', [0.2, 0.4, 0.8], ...
                                    'ForegroundColor', 'white', ...
                                    'Enable', 'off', ...
                                    'Callback', @show_plots_callback);
end

function set_default_parameters(fig)
    % Set default parameter values
    gui_data = guidata(fig);
    set(gui_data.voltage_slider, 'Value', 400);
    set(gui_data.voltage_edit, 'String', '400');
    set(gui_data.stages_popup, 'Value', 4);  % 6 stages
    set(gui_data.mass_slider, 'Value', 1.0);
    set(gui_data.mass_edit, 'String', '1.0');
    set(gui_data.tube_slider, 'Value', 0.5);
    set(gui_data.tube_edit, 'String', '0.5');
    set(gui_data.time_edit, 'String', '0.01');
end

% Callback functions
function update_voltage_display(src, ~)
    fig = ancestor(src, 'figure');
    gui_data = guidata(fig);
    value = get(src, 'Value');
    set(gui_data.voltage_edit, 'String', sprintf('%.0f', value));
end

function update_voltage_slider(src, ~)
    fig = ancestor(src, 'figure');
    gui_data = guidata(fig);
    value = str2double(get(src, 'String'));
    if isnan(value) || value < 100 || value > 1000
        value = max(100, min(1000, value));
        set(src, 'String', sprintf('%.0f', value));
    end
    set(gui_data.voltage_slider, 'Value', value);
end

function update_mass_display(src, ~)
    fig = ancestor(src, 'figure');
    gui_data = guidata(fig);
    value = get(src, 'Value');
    set(gui_data.mass_edit, 'String', sprintf('%.1f', value));
end

function update_mass_slider(src, ~)
    fig = ancestor(src, 'figure');
    gui_data = guidata(fig);
    value = str2double(get(src, 'String'));
    if isnan(value) || value < 0.5 || value > 5.0
        value = max(0.5, min(5.0, value));
        set(src, 'String', sprintf('%.1f', value));
    end
    set(gui_data.mass_slider, 'Value', value);
end

function update_tube_display(src, ~)
    fig = ancestor(src, 'figure');
    gui_data = guidata(fig);
    value = get(src, 'Value');
    set(gui_data.tube_edit, 'String', sprintf('%.1f', value));
end

function update_tube_slider(src, ~)
    fig = ancestor(src, 'figure');
    gui_data = guidata(fig);
    value = str2double(get(src, 'String'));
    if isnan(value) || value < 0.3 || value > 2.0
        value = max(0.3, min(2.0, value));
        set(src, 'String', sprintf('%.1f', value));
    end
    set(gui_data.tube_slider, 'Value', value);
end

function run_simulation_callback(src, ~)
    fig = ancestor(src, 'figure');
    gui_data = guidata(fig);
    
    % Disable run button during simulation
    set(gui_data.run_button, 'Enable', 'off', 'String', 'Running...');
    drawnow;
    
    try
        % Get parameters from GUI
        voltage = get(gui_data.voltage_slider, 'Value');
        stages_list = {'3', '4', '5', '6', '7', '8', '9', '10', '11', '12'};
        stages_idx = get(gui_data.stages_popup, 'Value');
        num_stages = str2double(stages_list{stages_idx});
        mass = get(gui_data.mass_slider, 'Value');
        tube_length = get(gui_data.tube_slider, 'Value');
        max_time = str2double(get(gui_data.time_edit, 'String'));
        
        % Validate max_time
        if isnan(max_time) || max_time < 0.005 || max_time > 0.1
            max_time = 0.01;
            set(gui_data.time_edit, 'String', '0.01');
        end
        
        % Run simulation using existing emgun_simulate function
        fprintf('Running simulation: %.0fV, %d stages, %.1fkg, %.1fm tube...\n', ...
                voltage, num_stages, mass, tube_length);
        
        % Check if emgun_simulate is available
        if exist('emgun_simulate', 'file') ~= 2
            % Try to add matlab_wrappers to path
            current_dir = fileparts(mfilename('fullpath'));
            wrapper_dir = fullfile(fileparts(current_dir), 'matlab_wrappers');
            if exist(wrapper_dir, 'dir')
                addpath(wrapper_dir);
            else
                error('Cannot find emgun_simulate function. Please ensure matlab_wrappers is in MATLAB path.');
            end
        end
        
        result = emgun_simulate('voltage', voltage, ...
                               'stages', num_stages, ...
                               'mass', mass, ...
                               'tube_length', tube_length, ...
                               'max_time', max_time);
        
        % Store result
        gui_data.last_result = result;
        guidata(fig, gui_data);
        
        % Update results display
        update_results_display(gui_data, result);
        
        % Enable plot and export buttons
        set(gui_data.plot_button, 'Enable', 'on');
        set(gui_data.export_button, 'Enable', 'on');
        
        fprintf('✓ Simulation completed successfully!\n');
        
    catch ME
        % Handle errors
        errordlg(['Simulation failed: ' ME.message], 'Simulation Error');
        fprintf('✗ Simulation failed: %s\n', ME.message);
    end
    
    % Re-enable run button
    set(gui_data.run_button, 'Enable', 'on', 'String', 'Run Simulation');
end

function update_results_display(gui_data, result)
    % Update results text displays
    set(gui_data.velocity_text, 'String', ...
        sprintf('Final Velocity: %.3f m/s', result.final_velocity));
    set(gui_data.position_text, 'String', ...
        sprintf('Final Position: %.3f m', result.final_position));
    set(gui_data.force_text, 'String', ...
        sprintf('Max Force: %.1f N', result.max_force));
    set(gui_data.efficiency_text, 'String', ...
        sprintf('Energy Efficiency: %.1f%%', result.energy_efficiency * 100));
    set(gui_data.time_text, 'String', ...
        sprintf('Simulation Time: %.2f ms', result.total_time * 1000));
end

function reset_parameters_callback(src, ~)
    fig = ancestor(src, 'figure');
    gui_data = guidata(fig);
    
    % Reset to defaults
    set(gui_data.voltage_slider, 'Value', 400);
    set(gui_data.voltage_edit, 'String', '400');
    set(gui_data.stages_popup, 'Value', 4);  % 6 stages
    set(gui_data.mass_slider, 'Value', 1.0);
    set(gui_data.mass_edit, 'String', '1.0');
    set(gui_data.tube_slider, 'Value', 0.5);
    set(gui_data.tube_edit, 'String', '0.5');
    set(gui_data.time_edit, 'String', '0.01');
    
    % Clear results
    set(gui_data.velocity_text, 'String', 'Final Velocity: --- m/s');
    set(gui_data.position_text, 'String', 'Final Position: --- m');
    set(gui_data.force_text, 'String', 'Max Force: --- N');
    set(gui_data.efficiency_text, 'String', 'Energy Efficiency: --- %');
    set(gui_data.time_text, 'String', 'Simulation Time: --- ms');
    
    % Disable plot and export buttons
    set(gui_data.plot_button, 'Enable', 'off');
    set(gui_data.export_button, 'Enable', 'off');
    
    fprintf('Parameters reset to defaults.\n');
end

function show_plots_callback(src, ~)
    fig = ancestor(src, 'figure');
    gui_data = guidata(fig);
    
    if isempty(gui_data.last_result)
        warndlg('No simulation results to plot. Run a simulation first.', 'No Data');
        return;
    end
    
    % Create plots using separate plotting function
    create_simulation_plots(gui_data.last_result);
end

function export_data_callback(src, ~)
    fig = ancestor(src, 'figure');
    gui_data = guidata(fig);
    
    if isempty(gui_data.last_result)
        warndlg('No simulation results to export. Run a simulation first.', 'No Data');
        return;
    end
    
    % Get filename from user
    [filename, pathname] = uiputfile({'*.mat', 'MATLAB Data (*.mat)'; ...
                                     '*.csv', 'CSV File (*.csv)'}, ...
                                     'Save Simulation Results');
    
    if filename == 0
        return; % User cancelled
    end
    
    [~, ~, ext] = fileparts(filename);
    full_path = fullfile(pathname, filename);
    
    try
        if strcmpi(ext, '.mat')
            % Save as MAT file
            result = gui_data.last_result; %#ok<NASGU>
            save(full_path, 'result');
            fprintf('Results saved to: %s\n', full_path);
        elseif strcmpi(ext, '.csv')
            % Save as CSV file
            data_table = table(gui_data.last_result.time', ...
                              gui_data.last_result.position', ...
                              gui_data.last_result.velocity', ...
                              gui_data.last_result.force', ...
                              gui_data.last_result.kinetic_energy', ...
                              'VariableNames', {'Time_s', 'Position_m', 'Velocity_ms', 'Force_N', 'Energy_J'});
            writetable(data_table, full_path);
            fprintf('Results saved to: %s\n', full_path);
        end
        
        msgbox(['Results successfully saved to: ' filename], 'Export Complete');
        
    catch ME
        errordlg(['Export failed: ' ME.message], 'Export Error');
    end
end

function close_gui(src, ~)
    delete(src);
    fprintf('Electromagnetic Gun GUI closed.\n');
end