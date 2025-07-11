# Electromagnetic Gun Simulation

A complete 1D electromagnetic gun simulation implementing a tubular capsule acceleration system with both Python backend and MATLAB GUI interface.

## 📋 Project Documentation

### Original Requirements & Design
- **Task Specification**: [`SW Engineer_ Tube-Capsule Model OOP and MATLAB.pdf`](SW%20Engineer_%20Tube-Capsule%20Model%20OOP%20and%20MATLAB.pdf) - Original project requirements and specifications
- **Design Document**: [`Moonshot.docx`](Moonshot.docx) - **Author's original design and implementation approach** (human-authored, not AI-generated)

### Technical Specification
- **Implementation Details**: [`Tube-Capsule Model in OOP and.md`](Tube-Capsule%20Model%20in%20OOP%20and.md) - Complete technical specification

## 🎯 Project Overview

This project simulates a **1kg tubular capsule** (83mm diameter) accelerated through **6 discrete electromagnetic stages** in a **0.5m acceleration tube**. The simulation uses realistic physics calculations including mutual inductance, RLC circuits, and electromagnetic force modeling.

### Key Features

- ✅ **Complete Physics Engine**: Mutual inductance, force calculations, energy transfer
- ✅ **Python Backend**: Object-oriented design following SOLID principles
- ✅ **MATLAB Integration**: GUI interface and visualization tools
- ✅ **Comprehensive Testing**: 42 unit tests + integration tests (100% Python core)
- ✅ **Multiple Interfaces**: Command line, Python API, and MATLAB GUI
- ✅ **Visualization**: Plots for velocity, force, position, and energy

## 🛠️ Setup

### Requirements
- **Python 3.7+**
- **MATLAB R2019b+** (for GUI)
- **Git**

### Installation
```bash
# Clone and install
git clone <repository-url>
cd electromagnetic-gun-simulation

# Option A: Using Make (Linux/macOS/WSL)
make install

# Option B: Direct pip installation
pip install -r requirements.txt

# Verify installation
python -m pytest tests/ -v
```

### MATLAB Setup
```matlab
% Method 1: Right-click run_gui.m in MATLAB and select "Run"
% Method 2: In MATLAB Command Window, navigate to project folder and type:
run_gui
```

## 🚀 Usage

### Python CLI
```bash
# Quick simulation
python -m src.cli.main --max-time 0.001 --quiet

# With visualization
python -m src.cli.main --max-time 0.01 --plot

# Full help
python -m src.cli.main --help
```

### MATLAB GUI
```matlab
run_gui  % Interactive interface with parameter controls
```

### Build Automation
```bash
# Using Makefile (Linux/macOS/WSL)
make install test run

# Direct commands (Windows)
pip install -r requirements.txt
python -m pytest tests/ -v
python -m src.cli.main
```

## 📊 Simulation Parameters

| Parameter | Default | Range | Description |
|-----------|---------|-------|-------------|
| `--max-time` | 5.0 | 0.001-10.0 | Simulation time (seconds) |
| `--tube-length` | 0.5 | 0.3-2.0 | Gun tube length (meters) |
| `--capsule-mass` | 1.0 | 0.5-5.0 | Projectile mass (kg) |
| `--time-step` | 1e-5 | 1e-6-1e-4 | Integration step (seconds) |

## 🔬 Physics Model

- **Capsule**: 1kg, 83mm diameter aluminum projectile
- **Stages**: 6 electromagnetic coils, 100 turns each
- **Energy**: 1000µF capacitors at 400V (480J total)
- **Physics**: Mutual inductance, RLC circuits, F = I₁ × I₂ × dM/dx

## 📁 Project Structure

```
src/
├── core/           # Physics classes (Coil, Capsule)
├── physics/        # Physics engine
├── services/       # Simulation services
├── matlab/         # MATLAB bridge
└── cli/           # Command line interface

tests/             # Test suite (65 tests)
matlab_gui/        # MATLAB GUI (4 files)
matlab_simple/     # Simple MATLAB interface
```

## 🧪 Testing

```bash
# All tests
python -m pytest tests/ -v

# Unit tests only
python -m pytest tests/unit/ -v

# With coverage
python -m pytest tests/ --cov=src --cov-report=html
```

## 📈 Expected Results

- **Final Velocity**: ~0.008 m/s (400V, 6 stages, 5s)
- **Energy Efficiency**: ~0.1% (capacitor → kinetic energy)
- **Force Range**: 0.01-0.05 N electromagnetic forces

## 🔧 Troubleshooting

### Python Issues
```bash
# Module not found
export PYTHONPATH="${PYTHONPATH}:$(pwd)/src"  # Linux/macOS
set PYTHONPATH=%PYTHONPATH%;%cd%\src           # Windows
```

### MATLAB Issues
```bash
# MATLAB not in PATH (add to system PATH):
# Windows: C:\Program Files\MATLAB\R2021a\bin
# macOS: /Applications/MATLAB_R2021a.app/bin

# Test Python-MATLAB bridge
python -m src.matlab.matlab_runner --help
```

## 🚨 Limitations

1. **1D Model**: Axial motion only
2. **Linear Response**: No magnetic saturation
3. **Ideal Components**: Perfect capacitors/inductors
4. **Simple Activation**: Position-based stage triggers

---

**Complete electromagnetic gun simulation with Python backend and MATLAB GUI interface.**