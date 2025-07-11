function gui_main()
% GUI_MAIN Main Electromagnetic Gun Simulation GUI
%
% Simple, modular GUI for controlling electromagnetic gun simulation
% parameters and visualizing results.
%
% Usage:
%   gui_main()  % Launch the GUI

    % Create main figure
    fig = figure('Name', 'Electromagnetic Gun Simulation', ...
                 'Position', [100, 100, 650, 500], ...
                 'MenuBar', 'none', ...
                 'ToolBar', 'none', ...
                 'Resize', 'off', ...
                 'NumberTitle', 'off', ...
                 'CloseRequestFcn', @close_gui);
    
    % Initialize GUI data
    gui_data = struct();
    gui_data.fig = fig;
    gui_data.last_result = [];
    
    % Create GUI components using separate functions
    gui_data = create_gui_controls(fig, gui_data);
    gui_data = create_gui_buttons(fig, gui_data);
    gui_data = create_gui_results(fig, gui_data);
    
    % Store data and set defaults
    guidata(fig, gui_data);
    set_default_values(fig);
    
    % Make visible
    set(fig, 'Visible', 'on');
    
    fprintf('Electromagnetic Gun GUI launched!\n');
    fprintf('Backend: emgun.m (proven working system)\n\n');
end

function gui_data = create_gui_controls(fig, gui_data)
    % Create parameter control panel
    
    panel = uipanel('Parent', fig, ...
                    'Title', 'Simulation Parameters', ...
                    'FontSize', 12, 'FontWeight', 'bold', ...
                    'Position', [0.05, 0.45, 0.65, 0.5]);
    
    % Voltage control
    uicontrol('Parent', panel, 'Style', 'text', ...
              'String', 'Voltage per Stage (V):', ...
              'Position', [20, 180, 150, 20], ...
              'HorizontalAlignment', 'left', 'FontSize', 11);
    
    gui_data.voltage_slider = uicontrol('Parent', panel, 'Style', 'slider', ...
                                       'Min', 100, 'Max', 1000, 'Value', 400, ...
                                       'Position', [20, 160, 250, 20], ...
                                       'Callback', @voltage_slider_callback);
    
    gui_data.voltage_edit = uicontrol('Parent', panel, 'Style', 'edit', ...
                                     'String', '400', ...
                                     'Position', [280, 160, 60, 20], ...
                                     'Callback', @voltage_edit_callback);
    
    uicontrol('Parent', panel, 'Style', 'text', ...
              'String', '[100 - 1000]', ...
              'Position', [350, 160, 80, 20], ...
              'HorizontalAlignment', 'left', 'FontSize', 9, ...
              'ForegroundColor', [0.5, 0.5, 0.5]);
    
    % Stages control
    uicontrol('Parent', panel, 'Style', 'text', ...
              'String', 'Number of Stages:', ...
              'Position', [20, 120, 150, 20], ...
              'HorizontalAlignment', 'left', 'FontSize', 11);
    
    gui_data.stages_popup = uicontrol('Parent', panel, 'Style', 'popupmenu', ...
                                     'String', {'3', '4', '5', '6', '7', '8', '9', '10', '11', '12'}, ...
                                     'Value', 4, ...  % Default to 6 stages
                                     'Position', [280, 120, 60, 20]);
    
    % Info text
    uicontrol('Parent', panel, 'Style', 'text', ...
              'String', 'Fixed parameters: Mass=1kg, Tube=0.5m, Time=5.0s', ...
              'Position', [20, 80, 400, 20], ...
              'HorizontalAlignment', 'left', 'FontSize', 9, ...
              'ForegroundColor', [0.4, 0.4, 0.4]);
    
    % Quick presets
    uicontrol('Parent', panel, 'Style', 'text', ...
              'String', 'Quick Presets:', ...
              'Position', [20, 50, 100, 20], ...
              'HorizontalAlignment', 'left', 'FontSize', 10, 'FontWeight', 'bold');
    
    uicontrol('Parent', panel, 'Style', 'pushbutton', ...
              'String', 'Low Power', ...
              'Position', [120, 50, 70, 20], ...
              'Callback', @(src,evt) apply_preset(src, 200, 4));
    
    uicontrol('Parent', panel, 'Style', 'pushbutton', ...
              'String', 'Default', ...
              'Position', [200, 50, 70, 20], ...
              'Callback', @(src,evt) apply_preset(src, 400, 6));
    
    uicontrol('Parent', panel, 'Style', 'pushbutton', ...
              'String', 'High Power', ...
              'Position', [280, 50, 70, 20], ...
              'Callback', @(src,evt) apply_preset(src, 800, 8));
end

function gui_data = create_gui_buttons(fig, gui_data)
    % Create control buttons
    
    panel = uipanel('Parent', fig, 'Position', [0.05, 0.3, 0.65, 0.12]);
    
    gui_data.run_button = uicontrol('Parent', panel, 'Style', 'pushbutton', ...
                                   'String', 'Run Simulation', ...
                                   'Position', [20, 15, 140, 40], ...
                                   'FontSize', 12, 'FontWeight', 'bold', ...
                                   'BackgroundColor', [0.2, 0.8, 0.2], ...
                                   'Callback', @run_simulation_callback);
    
    uicontrol('Parent', panel, 'Style', 'pushbutton', ...
              'String', 'Reset', ...
              'Position', [180, 15, 80, 40], ...
              'FontSize', 11, ...
              'Callback', @reset_callback);
    
    gui_data.plot_button = uicontrol('Parent', panel, 'Style', 'pushbutton', ...
                                    'String', 'Show Plots', ...
                                    'Position', [280, 15, 100, 40], ...
                                    'FontSize', 11, ...
                                    'Enable', 'off', ...
                                    'Callback', @show_plots_callback);
end

function gui_data = create_gui_results(fig, gui_data)
    % Create results display panel
    
    panel = uipanel('Parent', fig, ...
                    'Title', 'Simulation Results', ...
                    'FontSize', 12, 'FontWeight', 'bold', ...
                    'Position', [0.05, 0.05, 0.65, 0.22]);
    
    gui_data.velocity_text = uicontrol('Parent', panel, 'Style', 'text', ...
                                      'String', 'Final Velocity: --- m/s', ...
                                      'Position', [20, 80, 250, 20], ...
                                      'HorizontalAlignment', 'left', 'FontSize', 11, ...
                                      'FontWeight', 'bold');
    
    gui_data.position_text = uicontrol('Parent', panel, 'Style', 'text', ...
                                      'String', 'Final Position: --- m', ...
                                      'Position', [20, 60, 250, 20], ...
                                      'HorizontalAlignment', 'left', 'FontSize', 10);
    
    gui_data.efficiency_text = uicontrol('Parent', panel, 'Style', 'text', ...
                                        'String', 'Energy Efficiency: --- %', ...
                                        'Position', [20, 40, 250, 20], ...
                                        'HorizontalAlignment', 'left', 'FontSize', 10);
    
    gui_data.time_text = uicontrol('Parent', panel, 'Style', 'text', ...
                                  'String', 'Simulation Time: --- ms', ...
                                  'Position', [20, 20, 250, 20], ...
                                  'HorizontalAlignment', 'left', 'FontSize', 10);
    
    gui_data.status_text = uicontrol('Parent', panel, 'Style', 'text', ...
                                    'String', 'Ready to run simulation', ...
                                    'Position', [280, 20, 200, 80], ...
                                    'HorizontalAlignment', 'left', 'FontSize', 9, ...
                                    'ForegroundColor', [0.4, 0.4, 0.8]);
end

function set_default_values(fig)
    % Set default parameter values
    gui_data = guidata(fig);
    set(gui_data.voltage_slider, 'Value', 400);
    set(gui_data.voltage_edit, 'String', '400');
    set(gui_data.stages_popup, 'Value', 4);  % 6 stages
end

% Callback functions
function voltage_slider_callback(src, ~)
    fig = ancestor(src, 'figure');
    gui_data = guidata(fig);
    value = get(src, 'Value');
    set(gui_data.voltage_edit, 'String', sprintf('%.0f', value));
end

function voltage_edit_callback(src, ~)
    fig = ancestor(src, 'figure');
    gui_data = guidata(fig);
    value = str2double(get(src, 'String'));
    if isnan(value) || value < 100 || value > 1000
        value = max(100, min(1000, value));
        set(src, 'String', sprintf('%.0f', value));
    end
    set(gui_data.voltage_slider, 'Value', value);
end

function apply_preset(src, voltage, stages_value)
    fig = ancestor(src, 'figure');
    gui_data = guidata(fig);
    
    set(gui_data.voltage_slider, 'Value', voltage);
    set(gui_data.voltage_edit, 'String', sprintf('%.0f', voltage));
    
    stages_map = [3, 4, 5, 6, 7, 8, 9, 10, 11, 12];
    stages_idx = find(stages_map == stages_value, 1);
    if ~isempty(stages_idx)
        set(gui_data.stages_popup, 'Value', stages_idx);
    end
    
    fprintf('Preset applied: %dV, %d stages\n', voltage, stages_value);
end

function run_simulation_callback(src, ~)
    fig = ancestor(src, 'figure');
    gui_data = guidata(fig);
    
    set(gui_data.run_button, 'Enable', 'off', 'String', 'Running...');
    set(gui_data.status_text, 'String', 'Running simulation...');
    drawnow;
    
    try
        % Get parameters
        voltage = get(gui_data.voltage_slider, 'Value');
        stages_list = [3, 4, 5, 6, 7, 8, 9, 10, 11, 12];
        stages_idx = get(gui_data.stages_popup, 'Value');
        num_stages = stages_list(stages_idx);
        
        fprintf('Running simulation: %.0fV, %d stages...\n', voltage, num_stages);
        
        % Run simulation using backend helper
        result = gui_backend(voltage, num_stages);
        
        % Store result
        gui_data.last_result = result;
        gui_data.last_voltage = voltage;
        gui_data.last_stages = num_stages;
        guidata(fig, gui_data);
        
        % Update display
        update_results_display(gui_data, result);
        set(gui_data.plot_button, 'Enable', 'on');
        
        set(gui_data.status_text, 'String', sprintf('✓ Simulation completed\n%.0fV, %d stages\n→ %.6f m/s', ...
                                                    voltage, num_stages, result.velocity));
        
        fprintf('✓ Simulation completed: %.6f m/s\n', result.velocity);
        
    catch ME
        error_msg = sprintf('Simulation failed: %s', ME.message);
        set(gui_data.status_text, 'String', error_msg);
        errordlg(error_msg, 'Simulation Error');
        fprintf('✗ %s\n', error_msg);
    end
    
    set(gui_data.run_button, 'Enable', 'on', 'String', 'Run Simulation');
end

function reset_callback(src, ~)
    fig = ancestor(src, 'figure');
    gui_data = guidata(fig);
    
    % Reset parameters
    set_default_values(fig);
    
    % Clear results
    set(gui_data.velocity_text, 'String', 'Final Velocity: --- m/s');
    set(gui_data.position_text, 'String', 'Final Position: --- m');
    set(gui_data.efficiency_text, 'String', 'Energy Efficiency: --- %');
    set(gui_data.time_text, 'String', 'Simulation Time: --- ms');
    set(gui_data.status_text, 'String', 'Parameters reset\nReady to run simulation');
    
    set(gui_data.plot_button, 'Enable', 'off');
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
    gui_plots(gui_data.last_result, gui_data.last_voltage, gui_data.last_stages);
end

function update_results_display(gui_data, result)
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

function close_gui(src, ~)
    delete(src);
    fprintf('Electromagnetic Gun GUI closed.\n');
end