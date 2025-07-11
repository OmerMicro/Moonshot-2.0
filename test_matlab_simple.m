% Test script for simple MATLAB integration
% Run this from the project root directory

fprintf('Testing MATLAB integration...\n');

% Add matlab_simple to path
addpath('matlab_simple');

% Test the function
try
    result = emgun(400, 6);
    fprintf('✓ Success! Final velocity: %.6f m/s\n', result.velocity);
    fprintf('✓ Position: %.6f m\n', result.position);
    fprintf('✓ Efficiency: %.6f%%\n', result.efficiency * 100);
catch ME
    fprintf('✗ Error: %s\n', ME.message);
end

fprintf('Test complete.\n');