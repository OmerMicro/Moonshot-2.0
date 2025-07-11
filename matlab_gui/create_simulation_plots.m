function create_simulation_plots(result)
% CREATE_SIMULATION_PLOTS Display comprehensive simulation results
%
% Creates a 2x2 subplot figure showing position, velocity, force, and
% energy versus time for electromagnetic gun simulation results.
%
% Input:
%   result - Structure from emgun_simulate containing:
%     .time            - Time array (s)
%     .position        - Position array (m)
%     .velocity        - Velocity array (m/s)
%     .force           - Force array (N)
%     .kinetic_energy  - Kinetic energy array (J)
%     .final_velocity  - Final velocity (m/s)
%     .energy_efficiency - Energy efficiency (0-1)
%
% Example:
%   result = emgun_simulate('voltage', 400, 'stages', 6);
%   create_simulation_plots(result);

    % Validate input
    if ~isstruct(result)
        error('Input must be a result structure from emgun_simulate');
    end
    
    required_fields = {'time', 'position', 'velocity', 'force', 'kinetic_energy'};
    for i = 1:length(required_fields)
        if ~isfield(result, required_fields{i})
            error('Result structure missing required field: %s', required_fields{i});
        end
    end
    
    % Create new figure
    fig = figure('Name', 'Electromagnetic Gun Simulation Results', ...
                 'Position', [200, 100, 1200, 800], ...
                 'Color', 'white');
    
    % Convert time to milliseconds for better readability
    time_ms = result.time * 1000;
    
    % Plot 1: Position vs Time
    subplot(2, 2, 1);
    plot(time_ms, result.position * 1000, 'b-', 'LineWidth', 2);
    xlabel('Time (ms)', 'FontSize', 11);
    ylabel('Position (mm)', 'FontSize', 11);
    title('Capsule Position', 'FontSize', 12, 'FontWeight', 'bold');
    grid on;
    set(gca, 'GridAlpha', 0.3);
    
    % Add final position annotation
    final_pos_mm = result.position(end) * 1000;
    text(0.7, 0.9, sprintf('Final: %.1f mm', final_pos_mm), ...
         'Units', 'normalized', 'FontSize', 10, ...
         'BackgroundColor', 'yellow', 'EdgeColor', 'black');
    
    % Plot 2: Velocity vs Time
    subplot(2, 2, 2);
    plot(time_ms, result.velocity, 'r-', 'LineWidth', 2);
    xlabel('Time (ms)', 'FontSize', 11);
    ylabel('Velocity (m/s)', 'FontSize', 11);
    title('Capsule Velocity', 'FontSize', 12, 'FontWeight', 'bold');
    grid on;
    set(gca, 'GridAlpha', 0.3);
    
    % Add final velocity annotation
    text(0.7, 0.9, sprintf('Final: %.3f m/s', result.velocity(end)), ...
         'Units', 'normalized', 'FontSize', 10, ...
         'BackgroundColor', 'yellow', 'EdgeColor', 'black');
    
    % Plot 3: Force vs Time
    subplot(2, 2, 3);
    plot(time_ms, result.force, 'g-', 'LineWidth', 2);
    xlabel('Time (ms)', 'FontSize', 11);
    ylabel('Force (N)', 'FontSize', 11);
    title('Electromagnetic Force', 'FontSize', 12, 'FontWeight', 'bold');
    grid on;
    set(gca, 'GridAlpha', 0.3);
    
    % Add max force annotation
    max_force = max(result.force);
    text(0.7, 0.9, sprintf('Max: %.1f N', max_force), ...
         'Units', 'normalized', 'FontSize', 10, ...
         'BackgroundColor', 'yellow', 'EdgeColor', 'black');
    
    % Plot 4: Kinetic Energy vs Time
    subplot(2, 2, 4);
    plot(time_ms, result.kinetic_energy, 'm-', 'LineWidth', 2);
    xlabel('Time (ms)', 'FontSize', 11);
    ylabel('Kinetic Energy (J)', 'FontSize', 11);
    title('Kinetic Energy', 'FontSize', 12, 'FontWeight', 'bold');
    grid on;
    set(gca, 'GridAlpha', 0.3);
    
    % Add final energy annotation
    text(0.7, 0.9, sprintf('Final: %.3f J', result.kinetic_energy(end)), ...
         'Units', 'normalized', 'FontSize', 10, ...
         'BackgroundColor', 'yellow', 'EdgeColor', 'black');
    
    % Add overall title with summary information
    if isfield(result, 'final_velocity') && isfield(result, 'energy_efficiency')
        main_title = sprintf('Electromagnetic Gun Simulation Results - %.3f m/s (%.1f%% efficiency)', ...
                           result.final_velocity, result.energy_efficiency * 100);
    else
        main_title = 'Electromagnetic Gun Simulation Results';
    end
    sgtitle(main_title, 'FontSize', 14, 'FontWeight', 'bold');
    
    % Add summary text box
    if isfield(result, 'parameters')
        params = result.parameters;
        summary_text = {
            'Simulation Parameters:',
            sprintf('• Voltage: %.0f V', params.stage_voltage),
            sprintf('• Stages: %d', params.num_stages),
            sprintf('• Mass: %.1f kg', params.capsule_mass),
            sprintf('• Tube: %.1f m', params.tube_length),
            sprintf('• Time: %.1f ms', params.max_time * 1000)
        };
        
        % Add text annotation to figure
        annotation(fig, 'textbox', [0.02, 0.02, 0.25, 0.15], ...
                   'String', summary_text, ...
                   'FontSize', 9, ...
                   'BackgroundColor', 'white', ...
                   'EdgeColor', 'black', ...
                   'FitBoxToText', 'on');
    end
    
    % Adjust subplot spacing
    set(fig, 'Units', 'normalized');
    subplot_positions = {
        [0.1, 0.55, 0.35, 0.35],   % Top left
        [0.55, 0.55, 0.35, 0.35],  % Top right
        [0.1, 0.1, 0.35, 0.35],    % Bottom left
        [0.55, 0.1, 0.35, 0.35]    % Bottom right
    };
    
    for i = 1:4
        subplot(2, 2, i);
        set(gca, 'Position', subplot_positions{i});
    end
    
    % Add export capability
    add_export_menu(fig, result);
    
    fprintf('Simulation plots displayed successfully.\n');
    fprintf('Use File menu to export plots or data.\n');
end

function add_export_menu(fig, result)
    % Add export menu to figure
    
    % Create File menu
    file_menu = uimenu(fig, 'Label', 'File');
    
    % Export plot submenu
    uimenu(file_menu, 'Label', 'Export Plot as PNG...', ...
           'Callback', @(src,evt) export_plot(fig, 'png'));
    uimenu(file_menu, 'Label', 'Export Plot as PDF...', ...
           'Callback', @(src,evt) export_plot(fig, 'pdf'));
    uimenu(file_menu, 'Label', 'Export Plot as EPS...', ...
           'Callback', @(src,evt) export_plot(fig, 'eps'));
    
    % Separator
    uimenu(file_menu, 'Label', 'Export Data...', 'Separator', 'on', ...
           'Callback', @(src,evt) export_plot_data(result));
    
    % Close menu
    uimenu(file_menu, 'Label', 'Close', 'Separator', 'on', ...
           'Callback', @(src,evt) close(fig));
end

function export_plot(fig, format)
    % Export plot in specified format
    
    [filename, pathname] = uiputfile({['*.' format], [upper(format) ' files (*.' format ')']}, ...
                                    ['Save plot as ' upper(format)]);
    
    if filename == 0
        return; % User cancelled
    end
    
    full_path = fullfile(pathname, filename);
    
    try
        switch lower(format)
            case 'png'
                print(fig, full_path, '-dpng', '-r300');
            case 'pdf'
                print(fig, full_path, '-dpdf', '-r300');
            case 'eps'
                print(fig, full_path, '-deps', '-r300');
        end
        
        fprintf('Plot exported to: %s\n', full_path);
        msgbox(['Plot successfully exported to: ' filename], 'Export Complete');
        
    catch ME
        errordlg(['Export failed: ' ME.message], 'Export Error');
    end
end

function export_plot_data(result)
    % Export simulation data from plot
    
    [filename, pathname] = uiputfile({'*.csv', 'CSV files (*.csv)'; ...
                                     '*.mat', 'MATLAB files (*.mat)'}, ...
                                     'Save simulation data');
    
    if filename == 0
        return; % User cancelled
    end
    
    [~, ~, ext] = fileparts(filename);
    full_path = fullfile(pathname, filename);
    
    try
        if strcmpi(ext, '.csv')
            % Create table for CSV export
            data_table = table(result.time', result.position', result.velocity', ...
                              result.force', result.kinetic_energy', ...
                              'VariableNames', {'Time_s', 'Position_m', 'Velocity_ms', 'Force_N', 'KineticEnergy_J'});
            writetable(data_table, full_path);
        elseif strcmpi(ext, '.mat')
            % Save as MATLAB file
            save(full_path, 'result');
        end
        
        fprintf('Data exported to: %s\n', full_path);
        msgbox(['Data successfully exported to: ' filename], 'Export Complete');
        
    catch ME
        errordlg(['Export failed: ' ME.message], 'Export Error');
    end
end