"""
DataService for electromagnetic gun simulation.

Handles data collection, storage, and analysis during simulation runs.
Provides real-time data tracking and export capabilities.
"""

from typing import List, Dict, Any, Optional
import numpy as np


class DataService:
    """
    Service for collecting and managing simulation data.
    
    Follows Single Responsibility Principle - focused only on data operations.
    """
    
    def __init__(self):
        """Initialize empty data service."""
        self.history: List[Dict[str, float]] = []
        self.metadata: Dict[str, Any] = {}
    
    def record(self, time: float, capsule, stages: List, force: float) -> None:
        """
        Record simulation state at current time step.
        
        Args:
            time: Current simulation time
            capsule: Capsule object with current state
            stages: List of acceleration stages
            force: Total electromagnetic force
        """
        # Calculate derived quantities
        kinetic_energy = 0.5 * capsule.mass * capsule.velocity ** 2
        acceleration = force / capsule.mass
        
        # Active stages count
        active_stages = sum(1 for stage in stages if stage.is_active)
        
        # Total current in active stages
        total_stage_current = sum(
            stage.get_current(time) for stage in stages if stage.is_active
        )
        
        # Record complete state
        record = {
            'time': time,
            'position': capsule.position,
            'velocity': capsule.velocity,
            'acceleration': acceleration,
            'force': force,
            'kinetic_energy': kinetic_energy,
            'capsule_current': capsule.current,
            'active_stages': active_stages,
            'total_stage_current': total_stage_current
        }
        
        self.history.append(record)
    
    def get_results(self) -> 'SimulationResult':
        """
        Generate SimulationResult object from collected data.
        
        Returns:
            SimulationResult with complete simulation data and analysis
        """
        if not self.history:
            raise ValueError("No data collected - cannot generate results")
        
        # Extract final state
        final_record = self.history[-1]
        final_velocity = final_record['velocity']
        final_position = final_record['position']
        total_time = final_record['time']
        
        # Calculate initial energy (from metadata)
        initial_energy = self.metadata.get('initial_energy', 0.0)
        
        # Import here to avoid circular imports
        from src.services.simulation_service import SimulationResult
        
        return SimulationResult(
            final_velocity=final_velocity,
            final_position=final_position,
            total_time=total_time,
            initial_energy=initial_energy,
            history=self.history.copy()
        )
    
    def reset(self) -> None:
        """Reset data service to initial state."""
        self.history.clear()
        self.metadata.clear()
    
    def set_initial_energy(self, energy: float) -> None:
        """Set initial energy for energy efficiency calculations."""
        self.metadata['initial_energy'] = energy
    
    def get_time_array(self) -> np.ndarray:
        """Get time values as numpy array for plotting."""
        return np.array([record['time'] for record in self.history])
    
    def get_position_array(self) -> np.ndarray:
        """Get position values as numpy array for plotting."""
        return np.array([record['position'] for record in self.history])
    
    def get_velocity_array(self) -> np.ndarray:
        """Get velocity values as numpy array for plotting."""
        return np.array([record['velocity'] for record in self.history])
    
    def get_force_array(self) -> np.ndarray:
        """Get force values as numpy array for plotting."""
        return np.array([record['force'] for record in self.history])
    
    def get_energy_array(self) -> np.ndarray:
        """Get kinetic energy values as numpy array for plotting."""
        return np.array([record['kinetic_energy'] for record in self.history])