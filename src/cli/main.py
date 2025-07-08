"""
Simple CLI for electromagnetic gun simulation.

Quick implementation to get the system working end-to-end.
"""

import argparse
import sys
import os

# Add src to path
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..'))

from src.core.capsule import Capsule
from src.core.acceleration_stage import AccelerationStage
from src.services.simulation_service import SimulationService
from src.visualization.plotting import PlottingService
from src.matlab.bridge import MatlabBridge


def create_default_simulation():
    """Create a default simulation setup."""
    # Default capsule (1kg, 83mm diameter) - start at 2cm to be close to first stage
    capsule = Capsule(mass=1.0, diameter=0.083, length=0.02)
    capsule.update_position(0.02)  # Start 2cm from beginning, close to first stage
    
    # Default 6 stages - position them starting at 5cm
    stages = []
    for i in range(6):
        stage = AccelerationStage(
            stage_id=i,
            position=0.05 + (i * 0.08),  # Start at 5cm, 8cm spacing
            turns=100,
            diameter=0.09,
            length=0.05,
            capacitance=1000e-6,  # 1000µF
            voltage=400.0
        )
        stages.append(stage)
    
    return SimulationService(capsule, stages, tube_length=0.5)


def print_results(result):
    """Print simulation results."""
    print("\n" + "="*50)
    print("ELECTROMAGNETIC GUN SIMULATION RESULTS")
    print("="*50)
    print(f"Final Velocity:    {result.final_velocity:.2f} m/s")
    print(f"Final Position:    {result.final_position:.3f} m") 
    print(f"Total Time:        {result.total_time*1000:.2f} ms")
    print(f"Max Force:         {result.max_force:.1f} N")
    print(f"Initial Energy:    {result.initial_energy:.1f} J")
    print(f"Final KE:          {result.final_kinetic_energy:.2f} J")
    print(f"Energy Efficiency: {result.energy_efficiency:.1%}")
    print(f"Data Points:       {len(result.history)}")
    print("="*50)


def run_simulation(args):
    """Run the simulation with given parameters."""
    print("Setting up electromagnetic gun simulation...")
    
    # Create simulation
    service = create_default_simulation()
    
    # Override with command line parameters if provided
    if args.tube_length:
        service.tube_length = args.tube_length
    if args.time_step:
        service.dt = args.time_step
    if args.capsule_mass:
        service.capsule.mass = args.capsule_mass
    
    print(f"Capsule mass: {service.capsule.mass}kg")
    print(f"Tube length: {service.tube_length}m")
    print(f"Stages: {len(service.stages)}")
    print(f"Time step: {service.dt*1000}ms")
    
    # Run simulation
    print("\nRunning simulation...")
    result = service.run(max_time=args.max_time)
    
    # Show results
    print_results(result)
    
    # Save data if requested
    if args.output:
        save_data(result, args.output)
    
    # Create plot if requested
    if args.plot:
        create_plot(result, args.plot_output)
    
    # Export to MATLAB if requested
    if args.matlab:
        export_to_matlab_analysis(result, args.matlab)
    
    return result


def save_data(result, filename):
    """Save simulation data to file."""
    import json
    
    try:
        data = result.to_dict()
        with open(filename, 'w') as f:
            json.dump(data, f, indent=2)
        print(f"\nData saved to: {filename}")
    except Exception as e:
        print(f"Error saving data: {e}")


def create_plot(result, filename=None):
    """Create visualization plot."""
    try:
        plotter = PlottingService()
        plotter.plot_simulation_results(result, save_path=filename, show=False)
        if filename:
            print(f"Plot saved to: {filename}")
    except Exception as e:
        print(f"Error creating plot: {e}")


def export_to_matlab_analysis(result, base_filename):
    """Export simulation results for MATLAB analysis."""
    try:
        bridge = MatlabBridge()
        bridge.export_for_matlab_analysis(result, base_filename)
    except Exception as e:
        print(f"Error exporting to MATLAB: {e}")


def main():
    """Main CLI entry point."""
    parser = argparse.ArgumentParser(
        description="Electromagnetic Gun Simulation",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  python -m src.cli.main                    # Run with defaults
  python -m src.cli.main --max-time 0.02    # Run for 20ms
  python -m src.cli.main --output results.json  # Save results
        """
    )
    
    # Simulation parameters
    parser.add_argument('--max-time', type=float, default=0.01,
                        help='Maximum simulation time in seconds (default: 0.01)')
    parser.add_argument('--tube-length', type=float, 
                        help='Tube length in meters (default: 0.5)')
    parser.add_argument('--time-step', type=float,
                        help='Time step in seconds (default: 1e-5)')
    parser.add_argument('--capsule-mass', type=float,
                        help='Capsule mass in kg (default: 1.0)')
    
    # Output options
    parser.add_argument('--output', '-o', type=str,
                        help='Save results to JSON file')
    parser.add_argument('--plot', action='store_true',
                        help='Create visualization plot')
    parser.add_argument('--plot-output', type=str,
                        help='Save plot to file (PNG/PDF)')
    parser.add_argument('--matlab', type=str,
                        help='Export to MATLAB (.mat + analysis script)')
    parser.add_argument('--quiet', '-q', action='store_true',
                        help='Suppress output except results')
    
    args = parser.parse_args()
    
    try:
        result = run_simulation(args)
        return 0
    except Exception as e:
        print(f"Error: {e}")
        return 1


if __name__ == "__main__":
    sys.exit(main())