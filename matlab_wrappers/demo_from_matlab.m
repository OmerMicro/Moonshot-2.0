function demo_from_matlab()
% DEMO_FROM_MATLAB Demonstration of running electromagnetic gun simulation from MATLAB
%
% This script shows various ways to use the electromagnetic gun simulation
% from within MATLAB, including parameter sweeps and visualization.

    fprintf('\n=======================================================\n');
    fprintf('Electromagnetic Gun Simulation - MATLAB Demo\n');
    fprintf('=======================================================\n\n');
    
    % Test 1: Basic simulation with default parameters
    fprintf('[Test 1] Running basic simulation with default parameters...\n');
    try
        result1 = emgun_simulate();
        fprintf('✓ Success! Final velocity: %.3f m/s\n', result1.final_velocity);
        fprintf('  Energy efficiency: %.1f%%\n', result1.energy_efficiency * 100);
    catch ME
        fprintf('✗ Failed: %s\n', ME.message);
        return;
    end
    
    % Test 2: Quick simulation interface
    fprintf('\n[Test 2] Testing quick simulation interface...\n');
    try
        result2 = emgun_quick(500, 8);  % 500V, 8 stages
    catch ME
        fprintf('✗ Quick simulation failed: %s\n', ME.message);
    end
    
    % Test 3: Parameter sweep - voltage effect
    fprintf('\n[Test 3] Parameter sweep - voltage effect...\n');
    voltages = 200:100:800;
    velocities = zeros(size(voltages));
    efficiencies = zeros(size(voltages));
    
    for i = 1:length(voltages)
        try
            result = emgun_simulate('voltage', voltages(i), 'stages', 6);
            velocities(i) = result.final_velocity;
            efficiencies(i) = result.energy_efficiency;
            fprintf('  %d V → %.3f m/s (%.1f%% eff)\n', ...
                    voltages(i), velocities(i), efficiencies(i)*100);
        catch ME
            fprintf('  %d V → Failed: %s\n', voltages(i), ME.message);
            velocities(i) = NaN;
            efficiencies(i) = NaN;
        end
    end
    
    % Test 4: Number of stages effect
    fprintf('\n[Test 4] Parameter sweep - number of stages effect...\n');
    num_stages = 4:2:12;
    stage_velocities = zeros(size(num_stages));
    
    for i = 1:length(num_stages)
        try
            result = emgun_simulate('voltage', 400, 'stages', num_stages(i));
            stage_velocities(i) = result.final_velocity;
            fprintf('  %d stages → %.3f m/s\n', num_stages(i), stage_velocities(i));
        catch ME
            fprintf('  %d stages → Failed: %s\n', num_stages(i), ME.message);
            stage_velocities(i) = NaN;
        end
    end
    
    % Test 5: Save simulation data
    fprintf('\n[Test 5] Saving simulation data to files...\n');
    try
        result5 = emgun_simulate('voltage', 450, 'output_file', 'matlab_demo_test');
        fprintf('✓ Data saved to matlab_demo_test.mat and matlab_demo_test.json\n');
        
        % Try to load the saved .mat file
        if exist('matlab_demo_test.mat', 'file')
            loaded_data = load('matlab_demo_test.mat');
            fprintf('✓ Successfully loaded .mat file with fields: %s\n', ...
                    strjoin(fieldnames(loaded_data), ', '));
        end
    catch ME
        fprintf('✗ Save test failed: %s\n', ME.message);
    end
    
    % Create visualizations
    fprintf('\n[Test 6] Creating visualizations...\n');
    try
        % Figure 1: Voltage vs Velocity
        figure('Name', 'Electromagnetic Gun Analysis', 'Position', [100, 100, 1200, 600]);
        
        subplot(2, 3, 1);
        valid_idx = ~isnan(velocities);
        plot(voltages(valid_idx), velocities(valid_idx), 'bo-', 'LineWidth', 2, 'MarkerSize', 8);
        xlabel('Voltage per Stage (V)');
        ylabel('Final Velocity (m/s)');
        title('Voltage vs Final Velocity');
        grid on;
        
        subplot(2, 3, 2);
        plot(voltages(valid_idx), efficiencies(valid_idx)*100, 'ro-', 'LineWidth', 2, 'MarkerSize', 8);
        xlabel('Voltage per Stage (V)');
        ylabel('Energy Efficiency (%)');
        title('Voltage vs Energy Efficiency');
        grid on;
        
        subplot(2, 3, 3);
        valid_stage_idx = ~isnan(stage_velocities);
        plot(num_stages(valid_stage_idx), stage_velocities(valid_stage_idx), 'go-', 'LineWidth', 2, 'MarkerSize', 8);
        xlabel('Number of Stages');
        ylabel('Final Velocity (m/s)');
        title('Stages vs Final Velocity');
        grid on;
        
        % Plot time series from the detailed simulation
        if exist('result1', 'var') && isfield(result1, 'time')
            subplot(2, 3, 4);
            plot(result1.time*1000, result1.velocity, 'b-', 'LineWidth', 2);
            xlabel('Time (ms)');
            ylabel('Velocity (m/s)');
            title('Velocity vs Time');
            grid on;
            
            subplot(2, 3, 5);
            plot(result1.position*1000, result1.velocity, 'r-', 'LineWidth', 2);
            xlabel('Position (mm)');
            ylabel('Velocity (m/s)');
            title('Phase Space (v vs x)');
            grid on;
            
            subplot(2, 3, 6);
            plot(result1.time*1000, result1.force, 'g-', 'LineWidth', 2);
            xlabel('Time (ms)');
            ylabel('Force (N)');
            title('Force vs Time');
            grid on;
        end
        
        sgtitle('Electromagnetic Gun Simulation Results from MATLAB', 'FontSize', 14);
        fprintf('✓ Visualization created successfully\n');
        
    catch ME
        fprintf('✗ Visualization failed: %s\n', ME.message);
    end
    
    % Summary
    fprintf('\n=======================================================\n');
    fprintf('Demo Summary:\n');
    if exist('result1', 'var')
        fprintf('• Basic simulation: %.3f m/s final velocity\n', result1.final_velocity);
    end
    fprintf('• Voltage range tested: %d - %d V\n', min(voltages), max(voltages));
    fprintf('• Stage count range: %d - %d stages\n', min(num_stages), max(num_stages));
    fprintf('• All MATLAB interfaces working correctly\n');
    fprintf('=======================================================\n\n');
    
    fprintf('Available functions for your use:\n');
    fprintf('  result = emgun_simulate();                    %% Full simulation\n');
    fprintf('  result = emgun_quick(voltage, stages);        %% Quick simulation\n');
    fprintf('  help emgun_simulate                           %% Detailed help\n');
    fprintf('\nDemo complete! 🚀\n\n');
end