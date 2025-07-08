# Electromagnetic Gun Simulation - Quick Start Guide

## 🚀 Command Line Examples

### Basic Windows Command Line Usage

```cmd
# Run basic simulation with defaults
run_simulation.bat

# Run simulation for 20 milliseconds
run_simulation.bat --max-time 0.02

# Run simulation and save results to file
run_simulation.bat --max-time 0.01 --output results.json

# Run simulation with custom capsule mass (2kg instead of 1kg)
run_simulation.bat --max-time 0.01 --capsule-mass 2.0

# Run simulation and create plot
run_simulation.bat --max-time 0.01 --plot --plot-output simulation_plot.png

# Longer simulation with different tube length
run_simulation.bat --max-time 0.05 --tube-length 1.0 --output long_run.json
```

### Python Module Usage (Alternative)

```cmd
# If you prefer using Python directly
python -m src.cli.main --max-time 0.01
python -m src.cli.main --max-time 0.02 --plot
python -m src.cli.main --help
```

### Quick Test Commands

```cmd
# Very fast test (5ms)
run_simulation.bat --max-time 0.005

# Standard simulation (10ms) 
run_simulation.bat --max-time 0.01

# Longer simulation (50ms)
run_simulation.bat --max-time 0.05

# Save everything for analysis
run_simulation.bat --max-time 0.02 --output full_simulation.json --plot --plot-output analysis.png
```

## 📊 Expected Output

When you run a simulation, you'll see:

```
Setting up electromagnetic gun simulation...
Capsule mass: 1.0kg
Tube length: 0.5m
Stages: 6
Time step: 0.01ms

Running simulation...

==================================================
ELECTROMAGNETIC GUN SIMULATION RESULTS
==================================================
Final Velocity:    X.XX m/s
Final Position:    XXX.X mm
Total Time:        XX.XX ms
Max Force:         XXX.X N
Initial Energy:    480.0 J
Final KE:          X.XX J
Energy Efficiency: X.X%
Data Points:       XXXX
==================================================
```

## 🛠️ Setup Requirements

1. **Install dependencies:**
   ```cmd
   pip install -r requirements.txt
   ```

2. **Run tests to verify:**
   ```cmd
   python -m pytest tests/ -v
   ```

3. **Ready to simulate!**
   ```cmd
   run_simulation.bat
   ```

## 🔧 Quick Parameter Guide

| Parameter | Description | Default | Example |
|-----------|-------------|---------|---------|
| `--max-time` | Simulation duration (seconds) | 0.01 | `--max-time 0.02` |
| `--tube-length` | Gun tube length (meters) | 0.5 | `--tube-length 1.0` |
| `--capsule-mass` | Projectile mass (kg) | 1.0 | `--capsule-mass 2.0` |
| `--time-step` | Integration step (seconds) | 1e-5 | `--time-step 5e-6` |
| `--output` | Save results to JSON | None | `--output results.json` |
| `--plot` | Create visualization | False | `--plot` |
| `--plot-output` | Save plot file | None | `--plot-output graph.png` |

## 🎯 Real Examples to Try

### 1. Quick Performance Test
```cmd
run_simulation.bat --max-time 0.001
```

### 2. Full Analysis Run
```cmd
run_simulation.bat --max-time 0.02 --output detailed_results.json --plot --plot-output detailed_plot.png
```

### 3. Heavy Projectile Test
```cmd
run_simulation.bat --max-time 0.03 --capsule-mass 5.0 --output heavy_projectile.json
```

### 4. Long Barrel Test
```cmd
run_simulation.bat --max-time 0.05 --tube-length 1.5 --output long_barrel.json
```

## ⚠️ Known Issues (See IMPLEMENTATION_GAPS.md)

1. **Positioning**: Capsule may not always activate stages properly
2. **Plotting**: Requires matplotlib, may need display setup
3. **Performance**: Not optimized for very long simulations
4. **Configuration**: Limited parameter customization

## 🔄 Next Steps

1. **Test the system** with basic commands
2. **Review IMPLEMENTATION_GAPS.md** for improvement areas
3. **Implement MATLAB bridge** for advanced analysis
4. **Add configuration file support** for complex simulations

## 📝 Quick Tips

- Start with short simulations (0.01s) to verify setup
- Use `--plot` to visualize results immediately
- Save important runs with `--output filename.json`
- Check IMPLEMENTATION_GAPS.md for known limitations