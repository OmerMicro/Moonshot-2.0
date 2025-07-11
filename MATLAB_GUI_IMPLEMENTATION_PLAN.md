# MATLAB GUI Implementation Plan - Electromagnetic Gun Simulation

## 🎯 Project Overview

Create a MATLAB GUI for the electromagnetic gun simulation with:
- **Parameter Control Interface** - Interactive input controls for simulation parameters
- **Post-Simulation Plotting** - Comprehensive visualization after simulation completion
- **Simple and Clean Design** - User-friendly interface following MATLAB best practices

## 📋 Current Project Understanding

### Physical System
- **Capsule**: 1kg tubular projectile, 83mm diameter
- **Tube**: 0.5m total length, 90mm outer diameter  
- **Stages**: 6 discrete electromagnetic acceleration stages
- **Goal**: Model 1D acceleration with user-configurable parameters

### Existing Implementation
- ✅ **Python Core**: Complete OOP simulation engine ([`SimulationService`](src/services/simulation_service.py))
- ✅ **MATLAB Bridge**: Working interface via [`emgun.m`](matlab_simple/emgun.m)
- ✅ **Plotting System**: Python visualization service with comprehensive plots
- 🎯 **Target**: MATLAB GUI with parameter controls and post-simulation visualization

## 🏗️ Simplified Architecture

```mermaid
graph LR
    A[MATLAB GUI] --> B[Parameter Input]
    B --> C[Run Simulation]
    C --> D[emgun.m Bridge]
    D --> E[Python Backend]
    E --> F[Results]
    F --> G[MATLAB Plotting]
    G --> H[Display Results]
```

## 📁 Folder Structure

```
matlab_gui/
├── emgun_gui.m                 # Main GUI application
├── emgun_gui.fig              # GUI layout file (if using GUIDE)
├── simulation_plotter.m        # Post-simulation plotting functions
├── parameter_validator.m       # Input validation functions
├── gui_callbacks.m            # Button and control callbacks
└── README_GUI.md              # User guide for the GUI
```

## 🎨 GUI Layout Design

### Main Window Layout
```
┌─────────────────────────────────────────────────────────┐
│ Electromagnetic Gun Simulation Control Panel           │
├─────────────────────────────────────────────────────────┤
│                                                         │
│ Simulation Parameters:                                  │
│                                                         │
│ Voltage per Stage:    [400] V     [Min: 100, Max: 1000]│
│ Number of Stages:     [6]         [Min: 3, Max: 12]    │
│ Capsule Mass:         [1.0] kg    [Min: 0.5, Max: 5.0] │
│ Tube Length:          [0.5] m     [Min: 0.3, Max: 2.0] │
│ Simulation Time:      [0.01] s    [Min: 0.005, Max: 0.1]│
│                                                         │
│ ┌─────────────────┐  ┌─────────────────┐  ┌───────────┐ │
│ │  Run Simulation │  │ Reset to Default│  │   Export  │ │
│ └─────────────────┘  └─────────────────┘  └───────────┘ │
│                                                         │
│ Results Summary:                                        │
│ • Final Velocity:     _____ m/s                        │
│ • Final Position:     _____ m                          │
│ • Max Force:          _____ N                          │
│ • Energy Efficiency:  _____ %                          │
│ • Simulation Time:    _____ ms                         │
│                                                         │
│ ┌─────────────────┐                                    │
│ │   Show Plots    │                                    │
│ └─────────────────┘                                    │
└─────────────────────────────────────────────────────────┘
```

## 🔧 Implementation Components

### 1. Main GUI File (`emgun_gui.m`)

```matlab
function emgun_gui()
    % EMGUN_GUI Main electromagnetic gun simulation GUI
    % 
    % Creates a user interface for controlling simulation parameters
    % and visualizing results from the electromagnetic gun simulation.
    
    % Create main figure
    fig = uifigure('Name', 'Electromagnetic Gun Simulation', ...
                   'Position', [100 100 600 500], ...
                   'Resize', 'off');
    
    % Initialize GUI components
    create_parameter_controls(fig);
    create_control_buttons(fig);
    create_results_display(fig);
    
    % Store default parameters
    setappdata(fig, 'default_params', get_default_parameters());
end
```

### 2. Parameter Controls

**Input Fields with Validation:**
- Voltage: 100V - 1000V (slider + numeric input)
- Stages: 3 - 12 (dropdown or spinner)
- Mass: 0.5kg - 5.0kg (slider + numeric input)
- Tube Length: 0.3m - 2.0m (slider + numeric input)
- Max Time: 0.005s - 0.1s (slider + numeric input)

### 3. Core Functions

```matlab
function run_simulation_callback(app, event)
    % Callback for Run Simulation button
    
    % Get parameters from GUI
    params = get_gui_parameters(app);
    
    % Validate parameters
    if ~validate_parameters(params)
        uialert(app.UIFigure, 'Invalid parameters', 'Error');
        return;
    end
    
    % Show progress
    d = uiprogressdlg(app.UIFigure, 'Title', 'Running Simulation...');
    
    try
        % Run simulation using existing emgun function
        result = emgun(params.voltage, params.num_stages, ...
                      'mass', params.mass, ...
                      'tube_length', params.tube_length, ...
                      'max_time', params.max_time);
        
        % Update results display
        update_results_display(app, result);
        
        % Store results for plotting
        setappdata(app.UIFigure, 'last_result', result);
        
    catch ME
        uialert(app.UIFigure, ME.message, 'Simulation Error');
    end
    
    close(d);
end
```

## 📊 Post-Simulation Plotting

### Plot Window Design
Create separate figure with 2x2 subplot layout:

```matlab
function show_plots_callback(app, event)
    % Display comprehensive simulation results
    
    result = getappdata(app.UIFigure, 'last_result');
    if isempty(result)
        uialert(app.UIFigure, 'No simulation results to plot', 'Warning');
        return;
    end
    
    % Create new figure for plots
    plot_fig = figure('Name', 'Simulation Results', ...
                      'Position', [200 200 1000 600]);
    
    % Plot 1: Position vs Time
    subplot(2,2,1);
    plot_position_vs_time(result);
    
    % Plot 2: Velocity vs Time  
    subplot(2,2,2);
    plot_velocity_vs_time(result);
    
    % Plot 3: Force vs Time
    subplot(2,2,3);
    plot_force_vs_time(result);
    
    % Plot 4: Energy vs Time
    subplot(2,2,4);
    plot_energy_vs_time(result);
    
    % Add overall title
    sgtitle('Electromagnetic Gun Simulation Results', 'FontSize', 16);
end
```

### Individual Plot Functions

```matlab
function plot_position_vs_time(result)
    time_ms = result.time * 1000;  % Convert to milliseconds
    position_mm = result.position * 1000;  % Convert to millimeters
    
    plot(time_ms, position_mm, 'b-', 'LineWidth', 2);
    xlabel('Time (ms)');
    ylabel('Position (mm)');
    title('Capsule Position');
    grid on;
    
    % Add final position annotation
    text(0.7, 0.9, sprintf('Final: %.1f mm', position_mm(end)), ...
         'Units', 'normalized', 'FontSize', 10, ...
         'BackgroundColor', 'yellow');
end

function plot_velocity_vs_time(result)
    time_ms = result.time * 1000;
    velocity = result.velocity;
    
    plot(time_ms, velocity, 'r-', 'LineWidth', 2);
    xlabel('Time (ms)');
    ylabel('Velocity (m/s)');
    title('Capsule Velocity');
    grid on;
    
    % Add final velocity annotation
    text(0.7, 0.9, sprintf('Final: %.3f m/s', velocity(end)), ...
         'Units', 'normalized', 'FontSize', 10, ...
         'BackgroundColor', 'yellow');
end

function plot_force_vs_time(result)
    time_ms = result.time * 1000;
    force = result.force;
    
    plot(time_ms, force, 'g-', 'LineWidth', 2);
    xlabel('Time (ms)');
    ylabel('Force (N)');
    title('Electromagnetic Force');
    grid on;
    
    % Add max force annotation
    max_force = max(force);
    text(0.7, 0.9, sprintf('Max: %.1f N', max_force), ...
         'Units', 'normalized', 'FontSize', 10, ...
         'BackgroundColor', 'yellow');
end

function plot_energy_vs_time(result)
    time_ms = result.time * 1000;
    energy = result.kinetic_energy;
    
    plot(time_ms, energy, 'm-', 'LineWidth', 2);
    xlabel('Time (ms)');
    ylabel('Kinetic Energy (J)');
    title('Kinetic Energy');
    grid on;
    
    % Add final energy annotation
    text(0.7, 0.9, sprintf('Final: %.3f J', energy(end)), ...
         'Units', 'normalized', 'FontSize', 10, ...
         'BackgroundColor', 'yellow');
end
```

## 🛠️ Implementation Steps

### Phase 1: Basic GUI Structure (Day 1)
1. **Create main figure** with proper layout
2. **Add parameter input controls** (sliders, edit fields)
3. **Implement validation functions** for parameter bounds
4. **Connect to existing emgun.m** function

### Phase 2: Results Display (Day 1-2)
1. **Create results summary panel** with key metrics
2. **Implement simulation runner** with error handling
3. **Add progress indication** during simulation
4. **Test basic functionality** with existing backend

### Phase 3: Plotting System (Day 2)
1. **Create plotting functions** for each result type
2. **Design plot layout** with proper styling
3. **Add annotations** and summary information
4. **Implement export capabilities** (save plots/data)

### Phase 4: Polish & Testing (Day 2)
1. **Add reset functionality** to restore defaults
2. **Improve error handling** and user feedback
3. **Test with various parameter combinations**
4. **Create user documentation**

## 📋 Key Features

### Parameter Controls
- **Voltage Slider**: 100V - 1000V with numeric display
- **Stage Count**: Dropdown menu (3-12 stages)
- **Mass Input**: Slider with precise numeric input
- **Tube Length**: Adjustable with live validation
- **Simulation Time**: Control simulation duration

### Results Display
- **Summary Metrics**: Final velocity, position, efficiency
- **Export Options**: Save data to MAT/CSV files
- **Plot Generation**: Create publication-quality figures
- **Error Handling**: Clear feedback on invalid inputs

### MATLAB Best Practices
- **Consistent Naming**: `camelCase` for functions, `snake_case` for variables
- **Modular Design**: Separate files for different functionalities
- **Error Handling**: Try-catch blocks with user-friendly messages
- **Documentation**: Complete function headers and comments
- **Validation**: Robust parameter checking and bounds enforcement

## 🔗 Integration Points

### Existing System Integration
- Uses current [`emgun.m`](matlab_simple/emgun.m) function as backend
- Leverages [`matlab_runner.py`](src/matlab/matlab_runner.py) for simulation
- Maintains compatibility with existing parameter structure
- Preserves all physics calculations and accuracy

### Extended Parameters Support
```matlab
% Enhanced emgun function call with additional parameters
result = emgun(voltage, num_stages, ...
              'mass', capsule_mass, ...
              'tube_length', tube_length, ...
              'max_time', max_time, ...
              'capacitance', capacitance, ...
              'turns', turns);
```

## 🎯 Success Criteria

1. **✅ User-Friendly Interface** - Easy parameter adjustment
2. **✅ Reliable Simulation** - Robust connection to Python backend  
3. **✅ Clear Visualization** - Informative post-simulation plots
4. **✅ Proper Validation** - Parameter bounds and error handling
5. **✅ Export Capability** - Save results and plots for analysis

## 📝 Usage Workflow

1. **Launch GUI** - Run `emgun_gui` in MATLAB
2. **Adjust Parameters** - Use sliders and inputs to set simulation parameters
3. **Run Simulation** - Click "Run Simulation" button
4. **Review Results** - Check summary metrics in GUI
5. **View Plots** - Click "Show Plots" for detailed visualization
6. **Export Data** - Save results for further analysis

This implementation provides a **simple yet comprehensive** MATLAB interface for the electromagnetic gun simulation, focusing on ease of use while maintaining full access to the sophisticated Python simulation engine.