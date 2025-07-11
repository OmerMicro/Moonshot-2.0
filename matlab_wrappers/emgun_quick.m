function result = emgun_quick(voltage, num_stages)
% EMGUN_QUICK Quick electromagnetic gun simulation with minimal parameters
%
% Simplified interface for fast simulations with just voltage and stage count.
% Uses default values for all other parameters.
%
% Syntax:
%   result = emgun_quick(voltage, num_stages)
%
% Parameters:
%   voltage    - Stage voltage in Volts (e.g., 400)
%   num_stages - Number of acceleration stages (e.g., 6)
%
% Returns:
%   result - Structure with key simulation results
%
% Example:
%   result = emgun_quick(400, 6);
%   fprintf('Final velocity: %.3f m/s\n', result.final_velocity);

    if nargin < 2
        error('Usage: emgun_quick(voltage, num_stages)');
    end
    
    % Run simulation with specified parameters
    result = emgun_simulate('voltage', voltage, 'stages', num_stages);
    
    % Display quick summary
    fprintf('\n=== Electromagnetic Gun Simulation Results ===\n');
    fprintf('Voltage per stage: %.0f V\n', voltage);
    fprintf('Number of stages:  %d\n', num_stages);
    fprintf('Final velocity:    %.3f m/s\n', result.final_velocity);
    fprintf('Energy efficiency: %.1f%%\n', result.energy_efficiency * 100);
    fprintf('Total time:        %.2f ms\n', result.total_time * 1000);
    fprintf('============================================\n\n');
end