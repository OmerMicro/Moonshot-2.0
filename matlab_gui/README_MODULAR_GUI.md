# Modular MATLAB GUI for Electromagnetic Gun Simulation

## 📁 File Structure

This directory contains a modular MATLAB GUI system with small, focused files:

```
matlab_gui/
├── emgun_gui_main.m          # Main GUI interface (236 lines)
├── run_emgun_simulation.m    # Backend helper (66 lines)
├── create_emgun_plots.m      # Plotting system (115 lines)
└── README_MODULAR_GUI.md     # This documentation
```

## 🎯 Design Philosophy

### Small, Focused Files
- **emgun_gui_main.m**: GUI layout and controls only
- **run_emgun_simulation.m**: Backend interface and validation
- **create_emgun_plots.m**: Plotting functions matching Python simulation

### Clear Separation of Concerns
- **GUI Logic**: User interface and event handling
- **Backend Interface**: Simulation execution and error handling
- **Visualization**: Plot generation matching Python layout

## 🖥️ GUI Components

### Main Interface (`emgun_gui_main.m`)
- **Parameter Controls**: Voltage slider (100-1000V) and stages dropdown (3-12)
- **Quick Presets**: Low Power (200V, 4 stages), Default (400V, 6 stages), High Power (800V, 8 stages)
- **Control Buttons**: Run Simulation, Reset, Show Plots
- **Results Display**: Final velocity, position, efficiency, simulation time

### Backend Helper (`run_emgun_simulation.m`)
- **Input Validation**: Parameter bounds checking
- **Path Management**: Automatic addition of matlab_simple directory
- **Error Handling**: Clear error messages for troubleshooting
- **Result Validation**: Ensures simulation returns valid data

### Plotting System (`create_emgun_plots.m`)
- **2x2 Layout**: Matches Python simulation exactly
  - Top-left: Position vs Time (mm vs ms)
  - Top-right: Velocity vs Time (m/s vs ms)
  - Bottom-left: Force vs Time (N vs ms)
  - Bottom-right: Energy vs Time (J vs ms)
- **Annotations**: Final values displayed on each plot
- **Summary Box**: Parameters and results overview

## 🚀 Usage

### Quick Start
```matlab
% From project root directory:
run_gui()
```

### Manual Launch
```matlab
% If paths are already set:
emgun_gui_main()
```

### Direct Function Usage
```matlab
% Test backend directly:
result = run_emgun_simulation(400, 6);

% Create plots from result:
create_emgun_plots(result, 400, 6);
```

## 🔧 Technical Details

### Dependencies
- **emgun.m**: Backend simulation function (in matlab_simple directory)
- **MATLAB R2015b+**: For UI components and plotting functions
- **No additional toolboxes required**

### Data Flow
```
GUI Controls → Input Validation → emgun.m Backend → 
Result Processing → Display Update → Plot Generation
```

### Error Handling
- **Parameter Validation**: Real-time bounds checking
- **Backend Errors**: Clear messages for simulation failures
- **Path Issues**: Automatic detection and resolution
- **Result Validation**: Ensures data integrity

## 📊 Plot Details

### Synthetic Time Series Generation
Since `emgun.m` returns summary results (not time series), the plotting system generates realistic time series data based on:
- **Physics Principles**: Quadratic acceleration, exponential force decay
- **Final Results**: Curves end at actual simulation results
- **Representative Behavior**: Matches expected electromagnetic gun physics

### Plot Styling
- **Colors**: Blue (position), Red (velocity), Green (force), Magenta (energy)
- **Grid**: Semi-transparent for readability
- **Annotations**: Yellow boxes with final/max values
- **Layout**: Professional spacing and fonts

## 🎯 Advantages of Modular Design

### Maintainability
- **Small Files**: Easy to understand and modify
- **Clear Purpose**: Each file has a single responsibility
- **Minimal Dependencies**: Files can be tested independently

### Reliability
- **Isolated Errors**: Problems in one component don't affect others
- **Easy Debugging**: Small files are easier to troubleshoot
- **Proven Backend**: Uses working emgun.m function

### Extensibility
- **Easy to Add Features**: New functions can be added without modifying existing files
- **Pluggable Components**: Backend or plotting can be easily replaced
- **Clean Interfaces**: Well-defined function signatures

## 🔍 Function Reference

### `emgun_gui_main()`
- **Purpose**: Launch main GUI interface
- **Parameters**: None
- **Returns**: Nothing (creates GUI figure)

### `run_emgun_simulation(voltage, num_stages)`
- **Purpose**: Execute simulation with validation
- **Parameters**: 
  - `voltage`: 100-1000V
  - `num_stages`: 3-12 integer
- **Returns**: Result structure with velocity, position, time, efficiency

### `create_emgun_plots(result, voltage, num_stages)`
- **Purpose**: Create 2x2 plot layout matching Python simulation
- **Parameters**: 
  - `result`: Structure from simulation
  - `voltage`: Voltage used (for labeling)
  - `num_stages`: Stages used (for labeling)
- **Returns**: Nothing (creates plot figure)

## 🎓 Best Practices

### Code Organization
- **One Function per File**: Except for closely related helper functions
- **Clear Names**: Function names describe exactly what they do
- **Consistent Style**: Standard MATLAB coding conventions

### Error Handling
- **Input Validation**: Check parameters before processing
- **Clear Messages**: User-friendly error descriptions
- **Graceful Degradation**: GUI remains usable after errors

### User Experience
- **Immediate Feedback**: Real-time parameter validation
- **Clear Instructions**: Status messages guide user actions
- **Consistent Layout**: Logical organization of controls

This modular design provides a robust, maintainable MATLAB GUI system for the electromagnetic gun simulation while keeping individual files small and focused.