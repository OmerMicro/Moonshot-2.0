# Simple MATLAB Integration - Electromagnetic Gun Simulation

## Quick Setup

1. Run setup: `setup_matlab.bat`
2. In MATLAB: `addpath('matlab_simple')`  
3. Run simulation: `result = emgun(400, 6)`

## Usage

```matlab
% Basic simulation (400V, 6 stages)
result = emgun(400, 6);

% Custom voltage and stages  
result = emgun(500, 8);

% Results
fprintf('Final velocity: %.3f m/s\n', result.velocity);
fprintf('Efficiency: %.1f%%\n', result.efficiency * 100);
```

## Parameter Sweep Example

```matlab
voltages = 200:100:800;
velocities = [];

for v = voltages
    result = emgun(v, 6);
    velocities(end+1) = result.velocity;
end

plot(voltages, velocities);
xlabel('Voltage (V)'); ylabel('Velocity (m/s)');
```

## Requirements

- Python installed with `numpy`, `scipy`, `matplotlib`
- Run `setup_matlab.bat` once to install dependencies

That's it! Simple and straightforward.