function emgun_gui_simple()
% EMGUN_GUI_SIMPLE Simple Electromagnetic Gun Simulation GUI
%
% Simplified GUI using the proven emgun.m backend to avoid array issues.
% Provides essential parameter controls and visualization capabilities.
%
% Usage:
%   emgun_gui_simple()  % Launch the simplified GUI

    % Create main figure
    fig = figure('Name', 'Electromagnetic Gun Simulation - Simple GUI', ...
                 'Position', [100, 100, 650, 500], ...
                 'MenuBar', 'none', ...
                 'ToolBar', 'none', ...
                 'Resize', 'off', ...
                 'NumberTitle', 'off', ...
                 'CloseRequestFcn', @close_gui);
    
    % Initialize GUI data structure
    gui_data = struct();
    gui_data.fig = fig;
    gui_data.last_result = [];
    
    % Create GUI components
    gui_data = create_simple_controls(fig, gui_data);
    gui_data = create_simple_buttons(fig, gui_data);
    gui_data = create_simple_results(fig, gui_data);
    
    % Store GUI data
    guidata(fig, gui_data);
    
    % Set default values
    set_simple_defaults(fig);
    
    % Make figure visible
    set(fig, 'Visible', 'on');
    
    fprintf('Simple Electromagnetic Gun GUI launched!\n');
    fprintf('Using proven emgun.m backend for reliable operation.\n\n');
end

function gui_data = create_simple_controls(fig, gui_data)
    % Create simplified parameter controls
    
    % Main parameter panel
    param_panel = uipanel('Parent', fig, ...
                         'Title', 'Simulation Parameters', ...
                         'FontSize', 12, ...
                         'FontWeight', 'bold', ...
                         'Position', [0.05, 0.45, 0.65, 0.5]);
    
    % Voltage control
    uicontrol('Parent', param_panel, 'Style', 'text', ...
              'String', 'Voltage per Stage (V):', ...
              'Position', [20, 180, 150, 20], ...
              'HorizontalAlignment', 'left', 'FontSize', 11);
    
    gui_data.voltage_slider = uicontrol('Parent', param_panel, 'Style', 'slider', ...
                                       'Min', 100, 'Max', 1000, 'Value', 400, ...
                                       'Position', [20, 160, 250, 20], ...
                                       'Callback', @update_voltage_display);
    
    gui_data.voltage_edit = uicontrol('Parent', param_panel, 'Style', 'edit', ...
                                     'String', '400', ...
                                     'Position', [280, 160, 60, 20], ...
                                     'Callback', @update_voltage_slider);
    
    uicontrol('Parent', param_panel, 'Style', 'text', ...
              'String', '[100 - 1000]', ...
              'Position', [350, 160, 80, 20], ...
              'HorizontalAlignment', 'left', 'FontSize', 9, ...
              'ForegroundColor', [0.5, 0.5, 0.5]);
    
    % Number of stages control
    uicontrol('Parent', param_panel, 'Style', 'text', ...
              'String', 'Number of Stages:', ...
              'Position', [20, 120, 150, 20], ...
              'HorizontalAlignment', 'left', 'FontSize', 11);
    
    gui_data.stages_popup = uicontrol('Parent', param_panel, 'Style', 'popupmenu', ...
                                     'String', {'3', '4', '5', '6', '7', '8', '9', '10', '11', '12'}, ...
                                     'Value', 4, ...  % Default to 6 stages
                                     'Position', [280, 120, 60, 20]);
    
    % Information text
    uicontrol('Parent', param_panel, 'Style', 'text', ...
              'String', 'Note: This simplified GUI uses default values for mass (1kg), tube length (0.5m), and time (0.01s)', ...
              'Position', [20, 60, 400, 40], ...
              'HorizontalAlignment', 'left', 'FontSize', 9, ...
              'ForegroundColor', [0.4, 0.4, 0.4]);
    
    % Quick presets
    uicontrol('Parent', param_panel, 'Style', 'text', ...
              'String', 'Quick Presets:', ...
              'Position', [20, 30, 100, 20], ...
              'HorizontalAlignment', 'left', 'FontSize', 10, 'FontWeight', 'bold');
    
    uicontrol('Parent', param_panel, 'Style', 'pushbutton', ...
              'String', 'Low (200V)', ...
              'Position', [120, 30, 70, 20], ...
              'Callback', @(src,evt) set_preset(src, 200, 4));
    
    uicontrol('Parent', param_panel, 'Style', 'pushbutton', ...
              'String', 'Default (400V)', ...
              'Position', [200, 30, 80, 20], ...
              'Callback', @(src,evt) set_preset(src, 400, 6));
    
    uicontrol('Parent', param_panel, 'Style', 'pushbutton', ...
              'String', 'High (800V)', ...
              'Position', [290, 30, 70, 20], ...
              'Callback', @(src,evt) set_preset(src, 800, 8));
end

function gui_data = create_simple_buttons(fig, gui_data)
    % Create simplified control buttons
    
    button_panel = uipanel('Parent', fig, ...
                          'Position', [0.05, 0.3, 0.65, 0.12]);
    
    % Run Simulation button
    gui_data.run_button = uicontrol('Parent', button_panel, 'Style', 'pushbutton', ...
                                   'String', 'Run Simulation', ...
                                   'Position', [20, 15, 140, 40], ...
                                   'FontSize', 12, 'FontWeight', 'bold', ...
                                   'BackgroundColor', [0.2, 0.8, 0.2], ...
                                   'Callback', @run_simple_simulation);
    
    % Reset button
    uicontrol('Parent', button_panel, 'Style', 'pushbutton', ...
              'String', 'Reset', ...
              'Position', [180, 15, 80, 40], ...
              'FontSize', 11, ...
              'Callback', @reset_simple_parameters);
    
    % Plot button
    gui_data.plot_button = uicontrol('Parent', button_panel, 'Style', 'pushbutton', ...
                                    'String', 'Create Plot', ...
                                    'Position', [280, 15, 100, 40], ...
                                    'FontSize', 11, ...
                                    'Enable', 'off', ...
                                    'Callback', @create_simple_plot);
end

function gui_data = create_simple_results(fig, gui_data)
    % Create simplified results display
    
    results_panel = uipanel('Parent', fig, ...
                           'Title', 'Simulation Results', ...
                           'FontSize', 12, ...
                           'FontWeight', 'bold', ...
                           'Position', [0.05, 0.05, 0.65, 0.22]);
    
    % Results text displays
    gui_data.velocity_text = uicontrol('Parent', results_panel, 'Style', 'text', ...
                                      'String', 'Final Velocity: --- m/s', ...
                                      'Position', [20, 80, 250, 20], ...
                                      'HorizontalAlignment', 'left', 'FontSize', 11, ...
                                      'FontWeight', 'bold');
    
    gui_data.position_text = uicontrol('Parent', results_panel, 'Style', 'text', ...
                                      'String', 'Final Position: --- m', ...
                                      'Position', [20, 60, 250, 20], ...
                                      'HorizontalAlignment', 'left', 'FontSize', 10);
    
    gui_data.efficiency_text = uicontrol('Parent', results_panel, 'Style', 'text', ...
                                        'String', 'Energy Efficiency: --- %', ...
                                        'Position', [20, 40, 250, 20], ...
                                        'HorizontalAlignment', 'left', 'FontSize', 10);
    
    gui_data.time_text = uicontrol('Parent', results_panel, 'Style', 'text', ...
                                  'String', 'Simulation Time: --- ms', ...
                                  'Position', [20, 20, 250, 20], ...
                                  'HorizontalAlignment', 'left', 'FontSize', 10);
    
    % Status display
    gui_data.status_text = uicontrol('Parent', results_panel, 'Style', 'text', ...
                                    'String', 'Ready to run simulation', ...
                                    'Position', [280, 20, 200, 80], ...
                                    'HorizontalAlignment', 'left', 'FontSize', 9, ...
                                    'ForegroundColor', [0.4, 0.4, 0.8]);
end

function set_simple_defaults(fig)
    % Set default parameter values
    gui_data = guidata(fig);
    set(gui_data.voltage_slider, 'Value', 400);
    set(gui_data.voltage_edit, 'String', '400');
    set(gui_data.stages_popup, 'Value', 4);  % 6 stages
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

function set_preset(src, voltage, stages_value)
    fig = ancestor(src, 'figure');
    gui_data = guidata(fig);
    
    % Set voltage
    set(gui_data.voltage_slider, 'Value', voltage);
    set(gui_data.voltage_edit, 'String', sprintf('%.0f', voltage));
    
    % Set stages (convert to popup index)
    stages_map = [3, 4, 5, 6, 7, 8, 9, 10, 11, 12];
    stages_idx = find(stages_map == stages_value, 1);
    if ~isempty(stages_idx)
        set(gui_data.stages_popup, 'Value', stages_idx);
    end
    
    fprintf('Preset applied: %dV, %d stages\n', voltage, stages_value);
end

function run_simple_simulation(src, ~)
    fig = ancestor(src, 'figure');
    gui_data = guidata(fig);
    
    % Disable run button during simulation
    set(gui_data.run_button, 'Enable', 'off', 'String', 'Running...');
    set(gui_data.status_text, 'String', 'Running simulation...');
    drawnow;
    
    try
        % Get parameters from GUI
        voltage = get(gui_data.voltage_slider, 'Value');
        stages_list = [3, 4, 5, 6, 7, 8, 9, 10, 11, 12];
        stages_idx = get(gui_data.stages_popup, 'Value');
        num_stages = stages_list(stages_idx);
        
        fprintf('Running simulation: %.0fV, %d stages...\n', voltage, num_stages);
        
        % Ensure emgun.m is available
        if exist('emgun', 'file') ~= 2
            % Try to add matlab_simple to path
            current_dir = fileparts(mfilename('fullpath'));
            simple_dir = fullfile(fileparts(current_dir), 'matlab_simple');
            if exist(simple_dir, 'dir')
                addpath(simple_dir);
            else
                error('Cannot find emgun function. Please ensure matlab_simple is in MATLAB path.');
            end
        end
        
        % Run simulation using the proven emgun function
        result = emgun(voltage, num_stages);
        
        % Store result
        gui_data.last_result = result;
        gui_data.last_voltage = voltage;
        gui_data.last_stages = num_stages;
        guidata(fig, gui_data);
        
        % Update results display
        update_simple_results(gui_data, result);
        
        % Enable plot button
        set(gui_data.plot_button, 'Enable', 'on');
        
        set(gui_data.status_text, 'String', sprintf('✓ Simulation completed\n%.0fV, %d stages\n→ %.3f m/s', ...
                                                    voltage, num_stages, result.velocity));
        
        fprintf('✓ Simulation completed successfully!\n');
        fprintf('  Final velocity: %.6f m/s\n', result.velocity);
        
    catch ME
        % Handle errors
        error_msg = sprintf('Simulation failed: %s', ME.message);
        set(gui_data.status_text, 'String', error_msg);
        errordlg(error_msg, 'Simulation Error');
        fprintf('✗ %s\n', error_msg);
    end
    
    % Re-enable run button
    set(gui_data.run_button, 'Enable', 'on', 'String', 'Run Simulation');
end

function update_simple_results(gui_data, result)
    % Update results text displays
    set(gui_data.velocity_text, 'String', ...
        sprintf('Final Velocity: %.6f m/s', result.velocity));
    set(gui_data.position_text, 'String', ...
        sprintf('Final Position: %.3f m', result.position));
    set(gui_data.efficiency_text, 'String', ...
        sprintf('Energy Efficiency: %.2f%%', result.efficiency * 100));
    set(gui_data.time_text, 'String', ...
        sprintf('Simulation Time: %.2f ms', result.time * 1000));
end

function reset_simple_parameters(src, ~)
    fig = ancestor(src, 'figure');
    gui_data = guidata(fig);
    
    % Reset to defaults
    set(gui_data.voltage_slider, 'Value', 400);
    set(gui_data.voltage_edit, 'String', '400');
    set(gui_data.stages_popup, 'Value', 4);  % 6 stages
    
    % Clear results
    set(gui_data.velocity_text, 'String', 'Final Velocity: --- m/s');
    set(gui_data.position_text, 'String', 'Final Position: --- m');
    set(gui_data.efficiency_text, 'String', 'Energy Efficiency: --- %');
    set(gui_data.time_text, 'String', 'Simulation Time: --- ms');
    set(gui_data.status_text, 'String', 'Parameters reset to defaults\nReady to run simulation');
    
    % Disable plot button
    set(gui_data.plot_button, 'Enable', 'off');
    
    fprintf('Parameters reset to defaults (400V, 6 stages).\n');
end

function create_simple_plot(src, ~)
    fig = ancestor(src, 'figure');
    gui_data = guidata(fig);
    
    if isempty(gui_data.last_result)
        warndlg('No simulation results to plot. Run a simulation first.', 'No Data');
        return;
    end
    
    % Create a simple summary plot
    result = gui_data.last_result;
    voltage = gui_data.last_voltage;
    stages = gui_data.last_stages;
    
    % Create new figure for results
    plot_fig = figure('Name', 'Electromagnetic Gun Results', ...
                      'Position', [200, 150, 800, 500]);
    
    % Create a simple bar chart of key results
    subplot(1, 2, 1);
    metrics = [result.velocity, result.position, result.efficiency*100, result.time*1000];
    metric_names = {'Velocity (m/s)', 'Position (m)', 'Efficiency (%)', 'Time (ms)'};
    bar(metrics);
    set(gca, 'XTickLabel', metric_names);
    title(sprintf('Simulation Results: %dV, %d stages', voltage, stages));
    ylabel('Value');
    grid on;
    
    % Add text annotations
    for i = 1:length(metrics)
        text(i, metrics(i) + max(metrics)*0.02, sprintf('%.3f', metrics(i)), ...
             'HorizontalAlignment', 'center', 'FontWeight', 'bold');
    end
    
    % Create a comparison chart
    subplot(1, 2, 2);
    
    % Generate comparison data for different voltages
    voltages = [200, 400, 600, 800];
    velocities = zeros(size(voltages));
    
    % Estimate velocities (approximate scaling)
    base_velocity = result.velocity;
    base_voltage = voltage;
    
    for i = 1:length(voltages)
        % Simple scaling approximation
        velocities(i) = base_velocity * sqrt(voltages(i) / base_voltage);
    end
    
    plot(voltages, velocities, 'bo-', 'LineWidth', 2, 'MarkerSize', 8);
    hold on;
    
    % Highlight current result
    current_idx = find(voltages == voltage, 1);
    if ~isempty(current_idx)
        plot(voltage, result.velocity, 'ro', 'MarkerSize', 12, 'LineWidth', 3);
        text(voltage, result.velocity, ' ← Current', 'FontWeight', 'bold', 'Color', 'red');
    else
        plot(voltage, result.velocity, 'ro', 'MarkerSize', 12, 'LineWidth', 3);
        text(voltage, result.velocity, sprintf(' %dV (actual)', voltage), ...
             'FontWeight', 'bold', 'Color', 'red');
    end
    
    xlabel('Voltage per Stage (V)');
    ylabel('Final Velocity (m/s)');
    title('Voltage vs Velocity Relationship');
    grid on;
    legend('Estimated', 'Current Result', 'Location', 'northwest');
    
    % Add overall title
    sgtitle(sprintf('Electromagnetic Gun Simulation: %dV, %d stages → %.3f m/s', ...
                    voltage, stages, result.velocity), 'FontSize', 14);
    
    fprintf('Results plot created successfully.\n');
end

function close_gui(src, ~)
    delete(src);
    fprintf('Simple Electromagnetic Gun GUI closed.\n');
end