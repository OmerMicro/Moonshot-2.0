# MATLAB Integration Guide - Electromagnetic Gun Simulation

This guide explains how to compile and run the Python electromagnetic gun simulation from MATLAB.

## Overview

The electromagnetic gun simulation is implemented in Python but provides multiple interfaces for MATLAB users:

1. **MATLAB Wrapper Functions** - Native MATLAB functions that call Python
2. **Standalone Executable** - No Python installation required
3. **Python Module Interface** - Direct Python calls from MATLAB
4. **Data Exchange via .mat files** - For complex workflows

## Quick Start

### 1. Compilation and Setup

Run the compilation script to set up all MATLAB interfaces:

```batch
compile_for_matlab.bat
```

This script will:
- Install Python dependencies
- Create a standalone executable
- Set up MATLAB wrapper functions
- Test all interfaces

### 2. Basic Usage from MATLAB

```matlab
% Quick simulation with default parameters
result = emgun_simulate();

% Quick simulation with custom voltage and stages
result = emgun_quick(400, 6);

% Full parameter control
result = emgun_simulate('voltage', 500, 'stages', 8, 'mass', 1.5);
```

### 3. Run the Demo

```matlab
demo_from_matlab();  % Comprehensive demonstration
```

## Interface Options

### Option 1: MATLAB Wrapper Functions (Recommended)

The easiest way to use the simulation from MATLAB:

```matlab
% Add the matlab_wrappers directory to MATLAB path
addpath('matlab_wrappers');

% Basic simulation
result = emgun_simulate();

% Custom parameters
result = emgun_simulate(...
    'mass', 1.5, ...           % Capsule mass (kg)
    'diameter', 0.083, ...     % Capsule diameter (m)
    'tube_length', 0.5, ...    % Tube length (m)
    'stages', 8, ...           % Number of stages
    'voltage', 500, ...        % Voltage per stage (V)
    'capacitance', 1000e-6, ... % Capacitance per stage (F)
    'max_time', 0.01, ...      % Max simulation time (s)
    'time_step', 1e-5, ...     % Time step (s)
    'output_file', 'my_sim');  % Save to files
```

**Return Structure:**
```matlab
result.final_velocity     % Final velocity (m/s)
result.final_position     % Final position (m)
result.total_time         % Total simulation time (s)
result.energy_efficiency  % Energy efficiency (0-1)
result.time              % Time array
result.position          % Position array  
result.velocity          % Velocity array
result.force             % Force array
result.kinetic_energy    % Kinetic energy array
result.parameters        % Input parameters used
```

### Option 2: Standalone Executable

After running `compile_for_matlab.bat`, use the standalone executable:

```matlab
% Run simulation and capture JSON output
[status, json_result] = system('dist\emgun_simulator.exe --json-only --voltage 400');
result = jsondecode(json_result);
```

### Option 3: Direct Python Module Calls

If Python is installed and accessible:

```matlab
% Basic simulation
[status, json_result] = system('python -m src.matlab.matlab_runner --json-only');
result = jsondecode(json_result);

% With parameters
cmd = sprintf('python -m src.matlab.matlab_runner --voltage %d --stages %d --json-only', 500, 8);
[status, json_result] = system(cmd);
result = jsondecode(json_result);
```

### Option 4: Data Exchange via .mat Files

For complex workflows or when you need to process results in MATLAB:

```matlab
% Run simulation and save to .mat file
emgun_simulate('voltage', 400, 'output_file', 'my_results');

% Load the generated .mat file
data = load('my_results.mat');
sim_results = data.simulation_results;

% Access all data
time_ms = sim_results.time * 1000;
velocity = sim_results.velocity;
position_mm = sim_results.position * 1000;

% Run the auto-generated MATLAB analysis script
run('my_results_analysis.m');
```

## Parameter Reference

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `mass` | double | 1.0 | Capsule mass in kg |
| `diameter` | double | 0.083 | Capsule diameter in m (83mm) |
| `tube_length` | double | 0.5 | Total tube length in m |
| `stages` | integer | 6 | Number of acceleration stages |
| `voltage` | double | 400.0 | Voltage per stage in V |
| `capacitance` | double | 1000e-6 | Capacitance per stage in F |
| `max_time` | double | 0.01 | Maximum simulation time in s |
| `time_step` | double | 1e-5 | Time step for integration in s |
| `output_file` | string | '' | Base name for output files |

## Example Workflows

### Parameter Sweep Analysis

```matlab
% Voltage sweep
voltages = 200:50:800;
velocities = zeros(size(voltages));

for i = 1:length(voltages)
    result = emgun_simulate('voltage', voltages(i));
    velocities(i) = result.final_velocity;
end

plot(voltages, velocities);
xlabel('Voltage (V)'); ylabel('Final Velocity (m/s)');
```

### Optimization Study

```matlab
% Find optimal number of stages for given voltage
stages_range = 4:12;
efficiencies = zeros(size(stages_range));

for i = 1:length(stages_range)
    result = emgun_simulate('voltage', 400, 'stages', stages_range(i));
    efficiencies(i) = result.energy_efficiency;
end

[max_eff, optimal_idx] = max(efficiencies);
optimal_stages = stages_range(optimal_idx);
fprintf('Optimal stages: %d (%.1f%% efficiency)\n', optimal_stages, max_eff*100);
```

### Detailed Analysis with Visualization

```matlab
% Run detailed simulation
result = emgun_simulate('voltage', 450, 'stages', 6, 'output_file', 'detailed_analysis');

% Create comprehensive plots
figure('Position', [100, 100, 1200, 800]);

subplot(2, 3, 1);
plot(result.time*1000, result.velocity, 'b-', 'LineWidth', 2);
xlabel('Time (ms)'); ylabel('Velocity (m/s)'); title('Velocity vs Time');

subplot(2, 3, 2);
plot(result.time*1000, result.position*1000, 'r-', 'LineWidth', 2);
xlabel('Time (ms)'); ylabel('Position (mm)'); title('Position vs Time');

subplot(2, 3, 3);
plot(result.time*1000, result.force, 'g-', 'LineWidth', 2);
xlabel('Time (ms)'); ylabel('Force (N)'); title('Force vs Time');

subplot(2, 3, 4);
plot(result.time*1000, result.kinetic_energy, 'm-', 'LineWidth', 2);
xlabel('Time (ms)'); ylabel('Energy (J)'); title('Kinetic Energy vs Time');

subplot(2, 3, 5);
plot(result.position*1000, result.velocity, 'c-', 'LineWidth', 2);
xlabel('Position (mm)'); ylabel('Velocity (m/s)'); title('Phase Space');

subplot(2, 3, 6);
power = result.force .* result.velocity;
plot(result.time*1000, power, 'k-', 'LineWidth', 2);
xlabel('Time (ms)'); ylabel('Power (W)'); title('Instantaneous Power');

sgtitle(sprintf('Electromagnetic Gun Analysis - %.2f m/s final velocity', result.final_velocity));
```

## Troubleshooting

### Common Issues

1. **Python not found**: Ensure Python is installed and in PATH, or specify `python_exe` parameter
2. **Module import errors**: Run `compile_for_matlab.bat` to install dependencies
3. **Permission errors**: Run MATLAB as administrator if needed
4. **Path issues**: Ensure MATLAB current directory contains the project files

### Verification Tests

```matlab
% Test 1: Basic function availability
if exist('emgun_simulate', 'file') == 2
    fprintf('✓ MATLAB wrapper functions available\n');
else
    fprintf('✗ Add matlab_wrappers to MATLAB path\n');
end

% Test 2: Python accessibility
[status, ~] = system('python --version');
if status == 0
    fprintf('✓ Python accessible from system\n');
else
    fprintf('✗ Python not found in PATH\n');
end

% Test 3: Quick simulation test
try
    result = emgun_quick(400, 6);
    fprintf('✓ Simulation successful: %.3f m/s\n', result.final_velocity);
catch ME
    fprintf('✗ Simulation failed: %s\n', ME.message);
end
```

## Performance Notes

- **Typical simulation time**: 1-5 seconds for standard parameters
- **Memory usage**: ~50MB for typical simulations
- **Recommended time step**: 1e-5 s for accuracy vs speed balance
- **Maximum recommended stages**: 20 (diminishing returns beyond this)

## File Outputs

When using `output_file` parameter, the simulation creates:

- `{name}.json` - JSON format results for programmatic access
- `{name}.mat` - MATLAB format with structured data
- `{name}_analysis.m` - Auto-generated MATLAB analysis script

## Support

For issues or questions:
1. Run `demo_from_matlab.m` to verify installation
2. Check that all dependencies are installed via `compile_for_matlab.bat`
3. Verify Python environment with `python -m src.matlab.matlab_runner --help`

## Architecture

The simulation uses a modular architecture:
- **Core physics**: Electromagnetic calculations, RLC circuits, kinematics
- **MATLAB bridge**: Data conversion and interface layer  
- **Visualization**: Automatic plot generation and analysis
- **Testing**: 42+ unit tests ensure reliability

This provides a robust, production-ready electromagnetic gun simulation accessible from MATLAB with multiple integration options.