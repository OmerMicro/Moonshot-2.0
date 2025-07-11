# Electromagnetic Gun Simulation GUI - User Guide

## 🚀 Quick Start

### Installation
1. **Download MATLAB** (R2015b or later recommended)
2. **Ensure Python Backend** is working (see [Backend Setup](#backend-setup))
3. **Navigate to project directory** in MATLAB
4. **Launch GUI**:
   ```matlab
   start_gui()  % Recommended - sets up paths automatically
   % OR
   emgun_gui()  % Direct launch if paths are already set
   ```

### First Run
1. Launch the GUI using `start_gui()`
2. Use default parameters (400V, 6 stages, 1.0kg, 0.5m, 0.01s)
3. Click **"Run Simulation"**
4. Click **"Show Plots"** to visualize results
5. Explore parameter variations!

## 🎨 GUI Interface

### Main Window Layout
```
┌─────────────────────────────────────────────────────────┐
│ Electromagnetic Gun Simulation Control Panel           │
├─────────────────────────────────────────────────────────┤
│ Simulation Parameters:          │                      │
│ • Voltage: [====●====] [400] V  │                      │
│ • Stages: [6 ▼]                 │                      │
│ • Mass: [===●=====] [1.0] kg    │                      │
│ • Tube: [==●======] [0.5] m     │                      │
│ • Time: [0.01] s                │                      │
│                                 │                      │
│ [Run Simulation] [Reset] [Export] │                      │
│                                 │                      │
│ Results Summary:                │                      │
│ • Final Velocity: 0.008 m/s     │    [Show Plots]     │
│ • Energy Efficiency: 0.2%       │                      │
│ • Max Force: 45.2 N             │                      │
└─────────────────────────────────────────────────────────┘
```

### Parameter Controls

#### 1. Voltage per Stage (100V - 1000V)
- **Slider**: Drag to adjust voltage
- **Input Field**: Type exact values
- **Default**: 400V
- **Effect**: Higher voltage → higher final velocity

#### 2. Number of Stages (3 - 12)
- **Dropdown Menu**: Select from predefined values
- **Default**: 6 stages
- **Effect**: More stages → better acceleration efficiency

#### 3. Capsule Mass (0.5kg - 5.0kg)
- **Slider**: Drag to adjust mass
- **Input Field**: Type exact values
- **Default**: 1.0kg
- **Effect**: Heavier capsules → lower final velocity

#### 4. Tube Length (0.3m - 2.0m)
- **Slider**: Drag to adjust length
- **Input Field**: Type exact values
- **Default**: 0.5m
- **Effect**: Longer tubes → more acceleration distance

#### 5. Max Simulation Time (0.005s - 0.1s)
- **Input Field**: Type exact values
- **Default**: 0.01s (10 milliseconds)
- **Effect**: Longer times → more complete simulation

### Control Buttons

#### Run Simulation
- **Function**: Execute electromagnetic gun simulation
- **Status**: Button shows "Running..." during execution
- **Duration**: Typically 1-3 seconds
- **Result**: Updates results summary and enables plotting

#### Reset to Default
- **Function**: Restore all parameters to default values
- **Effect**: Clears results and disables plot/export buttons
- **Use**: Quick return to known working configuration

#### Export Data
- **Function**: Save simulation results to file
- **Formats**: MAT files or CSV files
- **Content**: Time series data (time, position, velocity, force, energy)
- **Available**: Only after successful simulation

#### Show Plots
- **Function**: Display comprehensive 2x2 plot window
- **Content**: Position, velocity, force, and energy vs time
- **Features**: Annotations, export menu, summary statistics
- **Available**: Only after successful simulation

## 📊 Visualization System

### Plot Window (2x2 Layout)
1. **Position vs Time** (top-left)
   - Units: millimeters vs milliseconds
   - Shows capsule trajectory through tube

2. **Velocity vs Time** (top-right)
   - Units: m/s vs milliseconds  
   - Shows acceleration profile

3. **Force vs Time** (bottom-left)
   - Units: Newtons vs milliseconds
   - Shows electromagnetic force peaks

4. **Energy vs Time** (bottom-right)
   - Units: Joules vs milliseconds
   - Shows kinetic energy buildup

### Plot Features
- **Annotations**: Final values displayed on each plot
- **Grid**: Professional grid for easy reading
- **Export Menu**: File → Export Plot as PNG/PDF/EPS
- **Data Export**: File → Export Data as CSV/MAT
- **Summary Box**: Parameters and results overview

## ⚙️ Backend Setup

### Python Requirements
The GUI uses the proven `emgun_simulate.m` backend which requires:
- **Python** 3.7+ with packages: `numpy`, `scipy`, `matplotlib`
- **Project Structure**:
  ```
  project_root/
  ├── matlab_gui/           # GUI files
  ├── matlab_wrappers/      # Backend interfaces  
  ├── matlab_simple/        # Simple interface
  └── src/                  # Python simulation engine
  ```

### Path Setup
The `start_gui()` function automatically adds required paths:
- `matlab_gui/` - GUI components
- `matlab_wrappers/` - Backend interface (`emgun_simulate.m`)
- `matlab_simple/` - Simple interface (`emgun.m`)

### Testing Backend
```matlab
% Test the backend connection
result = emgun_simulate('voltage', 400, 'stages', 6);
fprintf('Final velocity: %.3f m/s\n', result.final_velocity);
```

## 🎯 Usage Examples

### Example 1: Basic Simulation
```matlab
start_gui()
% Use default parameters: 400V, 6 stages, 1.0kg
% Click "Run Simulation"
% Expected result: ~0.008 m/s final velocity
```

### Example 2: High Performance Configuration
```matlab
start_gui()
% Set: 800V, 8 stages, 0.8kg, 1.0m tube, 0.02s time
% Click "Run Simulation"
% Expected result: Significantly higher velocity
```

### Example 3: Parameter Study
```matlab
% Run multiple simulations with different voltages
start_gui()
% Test voltages: 200V, 400V, 600V, 800V
% Observe how final velocity scales with voltage
```

### Example 4: Data Export Workflow
```matlab
start_gui()
% Run simulation with desired parameters
% Click "Show Plots" to verify results
% Use File → Export Data to save time series
% Use File → Export Plot to save visualization
```

## 🔧 Troubleshooting

### Common Issues

#### "emgun_simulate function not found"
**Solution**: Run `start_gui()` instead of `emgun_gui()` directly
```matlab
start_gui()  % This sets up paths automatically
```

#### "Python simulation failed"
**Causes**:
- Python not installed or not in PATH
- Missing Python packages (numpy, scipy)
- Project directory structure incorrect

**Solution**:
```matlab
% Test Python backend directly
cd('project_root')
system('python -m src.matlab.matlab_runner --help')
```

#### "Simulation takes too long"
**Cause**: Max time too large or complex parameter combination
**Solution**: 
- Reduce max time to 0.01s for initial tests
- Use fewer stages (3-6) for faster execution
- Lower voltage for stability

#### GUI doesn't respond
**Cause**: MATLAB version too old or insufficient memory
**Solution**:
- Use MATLAB R2015b or later
- Close other applications to free memory
- Restart MATLAB and try again

### Error Messages

#### "Parameters out of range"
- Check parameter limits in GUI
- Voltage: 100-1000V
- Stages: 3-12
- Mass: 0.5-5.0kg
- Tube: 0.3-2.0m
- Time: 0.005-0.1s

#### "Simulation numerically unstable"
- Reduce voltage for very light masses
- Increase simulation time for long tubes
- Use reasonable parameter combinations

## 📋 Technical Specifications

### GUI Framework
- **Platform**: MATLAB Figure-based GUI
- **Compatibility**: MATLAB R2015b or later
- **Components**: Sliders, edit fields, pushbuttons, popup menus
- **Layout**: Fixed 700×550 pixel window

### Backend Integration
- **Interface**: `emgun_simulate.m` function
- **Data Flow**: MATLAB → Python → JSON → MATLAB
- **Performance**: 1-3 seconds per simulation
- **Validation**: Automatic parameter bounds checking

### Visualization
- **Plotting**: Native MATLAB plotting with custom styling
- **Export**: PNG (300 DPI), PDF, EPS formats
- **Data Export**: CSV (time series) and MAT (full structure)
- **Features**: Annotations, grid, professional appearance

## 🚀 Advanced Features

### Parameter Validation
- Real-time bounds checking
- Physics-based validation warnings
- User-friendly error messages

### Export Capabilities
- **Plot Export**: High-resolution images (300 DPI)
- **Data Export**: CSV for analysis, MAT for MATLAB
- **Batch Processing**: Save multiple configurations

### Integration
- **Modular Design**: Easy to extend with new features
- **Backend Compatibility**: Works with existing simulation system
- **Cross-Platform**: Windows, macOS, Linux (via MATLAB)

## 📞 Support

### Getting Help
1. **Run diagnostics**: `start_gui()` shows system status
2. **Check documentation**: This README and function help
3. **Test backend**: Use `emgun_simulate()` directly
4. **Verify paths**: Ensure all directories are accessible

### Performance Tips
- **Start Simple**: Use default parameters first
- **Incremental Changes**: Adjust one parameter at a time
- **Save Configurations**: Export interesting results
- **Batch Analysis**: Use parameter sweeps for studies

The GUI provides an intuitive interface to the sophisticated electromagnetic gun simulation while maintaining full access to the proven Python backend system. 🎯