"""
MATLAB-callable runner for electromagnetic gun simulation.
Provides simple interface for MATLAB to call Python simulation.
"""

import sys
import os
import json
import argparse
from typing import Dict, Any, Optional

# Add src to path
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..'))

from src.core.capsule import Capsule
from src.core.acceleration_stage import AccelerationStage
from src.services.simulation_service import SimulationService
from src.matlab.bridge import MatlabBridge


def run_simulation_from_params(
    capsule_mass: float = 1.0,
    capsule_diameter: float = 0.083,
    capsule_length: float = 0.02,
    tube_length: float = 0.5,
    num_stages: int = 6,
    stage_voltage: float = 400.0,
    stage_capacitance: float = 1000e-6,
    stage_turns: int = 100,
    stage_diameter: float = 0.09,
    stage_length: float = 0.05,
    max_time: float = 5.0,
    time_step: float = 1e-5,
    output_file: Optional[str] = None
) -> Dict[str, Any]:
    """
    Run electromagnetic gun simulation with specified parameters.
    
    This function is designed to be easily called from MATLAB.
    
    Args:
        capsule_mass: Capsule mass in kg
        capsule_diameter: Capsule diameter in m
        capsule_length: Capsule length in m
        tube_length: Total tube length in m
        num_stages: Number of acceleration stages
        stage_voltage: Voltage per stage in V
        stage_capacitance: Capacitance per stage in F
        stage_turns: Number of turns per stage
        stage_diameter: Stage coil diameter in m
        stage_length: Stage coil length in m
        max_time: Maximum simulation time in s
        time_step: Time step for simulation in s
        output_file: Optional output file base name
        
    Returns:
        Dictionary with simulation results
    """
    
    # Create capsule
    capsule = Capsule(mass=capsule_mass, diameter=capsule_diameter, length=capsule_length)
    capsule.update_position(0.02)  # Start 2cm from beginning
    
    # Create acceleration stages
    stages = []
    for i in range(num_stages):
        stage = AccelerationStage(
            stage_id=i,
            position=0.05 + (i * 0.08),  # Start at 5cm, 8cm spacing
            turns=stage_turns,
            diameter=stage_diameter,
            length=stage_length,
            capacitance=stage_capacitance,
            voltage=stage_voltage
        )
        stages.append(stage)
    
    # Create and run simulation
    service = SimulationService(capsule, stages, tube_length=tube_length)
    service.dt = time_step
    
    result = service.run(max_time=max_time)
    
    # Convert result to dictionary for easy MATLAB access
    result_dict = {
        'final_velocity': result.final_velocity,
        'final_position': result.final_position,
        'total_time': result.total_time,
        'initial_energy': result.initial_energy,
        'final_kinetic_energy': result.final_kinetic_energy,
        'max_force': result.max_force,
        'energy_efficiency': result.energy_efficiency,
        'data_points': len(result.history),
        
        # Time series data
        'time': result.get_time_array().tolist(),
        'position': result.get_position_array().tolist(),
        'velocity': result.get_velocity_array().tolist(),
        'force': result.get_force_array().tolist(),
        'kinetic_energy': result.get_energy_array().tolist(),
        
        # Input parameters for reference
        'parameters': {
            'capsule_mass': capsule_mass,
            'capsule_diameter': capsule_diameter,
            'tube_length': tube_length,
            'num_stages': num_stages,
            'stage_voltage': stage_voltage,
            'max_time': max_time,
            'time_step': time_step
        }
    }
    
    # Save to file if requested
    if output_file:
        # Save JSON
        json_file = f"{output_file}.json"
        with open(json_file, 'w') as f:
            json.dump(result_dict, f, indent=2)
        
        # Export MATLAB files
        try:
            bridge = MatlabBridge()
            bridge.export_for_matlab_analysis(result, output_file)
        except Exception as e:
            print(f"Warning: Could not export MATLAB files: {e}")
    
    return result_dict


def run_default_simulation(output_file: Optional[str] = None) -> Dict[str, Any]:
    """Run simulation with default parameters."""
    return run_simulation_from_params(output_file=output_file)


def main():
    """Command line interface for MATLAB runner."""
    parser = argparse.ArgumentParser(
    description="MATLAB-callable electromagnetic gun simulation",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  python -m src.matlab.matlab_runner                    # Default simulation
  python -m src.matlab.matlab_runner --output test      # Save to test.mat
  python -m src.matlab.matlab_runner --voltage 500      # 500V per stage
        """
    )
    
    # Physical parameters
    parser.add_argument('--capsule-mass', type=float, default=1.0,
                        help='Capsule mass in kg (default: 1.0)')
    parser.add_argument('--capsule-diameter', type=float, default=0.083,
                        help='Capsule diameter in m (default: 0.083)')
    parser.add_argument('--tube-length', type=float, default=0.5,
                        help='Tube length in m (default: 0.5)')
    parser.add_argument('--num-stages', type=int, default=6,
                        help='Number of stages (default: 6)')
    parser.add_argument('--voltage', type=float, default=400.0,
                        help='Stage voltage in V (default: 400)')
    parser.add_argument('--capacitance', type=float, default=1000e-6,
                        help='Stage capacitance in F (default: 1000e-6)')
    
    # Simulation parameters
    parser.add_argument('--max-time', type=float, default=5.0,
                        help='Max simulation time in s (default: 5.0)')
    parser.add_argument('--time-step', type=float, default=1e-5,
                        help='Time step in s (default: 1e-5)')
    
    # Output
    parser.add_argument('--output', '-o', type=str,
                        help='Output file base name (creates .json and .mat)')
    parser.add_argument('--json-only', action='store_true',
                        help='Print JSON result to stdout')
    
    args = parser.parse_args()
    
    try:
        # Run simulation
        result = run_simulation_from_params(
            capsule_mass=args.capsule_mass,
            capsule_diameter=args.capsule_diameter,
            tube_length=args.tube_length,
            num_stages=args.num_stages,
            stage_voltage=args.voltage,
            stage_capacitance=args.capacitance,
            max_time=args.max_time,
            time_step=args.time_step,
            output_file=args.output
        )
        
        if args.json_only:
            # Print JSON for MATLAB to parse
            print(json.dumps(result, indent=2))
        else:
            # Print summary
            print(f"Simulation completed successfully!")
            print(f"Final velocity: {result['final_velocity']:.3f} m/s")
            print(f"Final position: {result['final_position']:.3f} m")
            print(f"Total time: {result['total_time']*1000:.2f} ms")
            print(f"Energy efficiency: {result['energy_efficiency']:.1%}")
            
            if args.output:
                print(f"Results saved to: {args.output}.json and {args.output}.mat")
        
        return 0
        
    except Exception as e:
        print(f"Error: {e}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    sys.exit(main())