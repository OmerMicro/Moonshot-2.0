"""
SimulationService for electromagnetic gun simulation.

Main orchestrator that coordinates all components and manages
the complete electromagnetic gun simulation process.
"""

from typing import List, Optional
import numpy as np

from src.core.capsule import Capsule
from src.core.acceleration_stage import AccelerationStage
from src.physics.physics_engine import PhysicsEngine
from src.services.data_service import DataService


class SimulationResult:
    """
    Result object containing complete simulation data and analysis.
    
    Provides access to simulation outcomes and performance metrics.
    """
    
    def __init__(self, final_velocity: float, final_position: float, 
                 total_time: float, initial_energy: float, 
                 history: List[dict]):
        """
        Initialize simulation result.
        
        Args:
            final_velocity: Final capsule velocity (m/s)
            final_position: Final capsule position (m)
            total_time: Total simulation time (s)
            initial_energy: Initial stored energy (J)
            history: Complete simulation history
        """
        self.final_velocity = final_velocity
        self.final_position = final_position
        self.total_time = total_time
        self.initial_energy = initial_energy
        self.history = history
    
    @property
    def final_kinetic_energy(self) -> float:
        """Calculate final kinetic energy from last history record."""
        if self.history:
            return self.history[-1]['kinetic_energy']
        return 0.0
    
    @property
    def max_force(self) -> float:
        """Calculate maximum force during simulation."""
        if self.history:
            return max(record['force'] for record in self.history)
        return 0.0
    
    @property
    def energy_efficiency(self) -> float:
        """Calculate energy transfer efficiency (kinetic/initial)."""
        if self.initial_energy > 0:
            return self.final_kinetic_energy / self.initial_energy
        return 0.0
    
    def to_dict(self) -> dict:
        """Export result as dictionary for serialization."""
        return {
            'final_velocity': self.final_velocity,
            'final_position': self.final_position,
            'total_time': self.total_time,
            'initial_energy': self.initial_energy,
            'final_kinetic_energy': self.final_kinetic_energy,
            'max_force': self.max_force,
            'energy_efficiency': self.energy_efficiency,
            'history': self.history
        }
    
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


class SimulationService:
    """
    Main simulation orchestrator following Single Responsibility Principle.
    
    Coordinates all simulation components and manages the complete
    electromagnetic gun simulation process with time stepping.
    """
    
    def __init__(self, capsule: Capsule, stages: List[AccelerationStage], 
                 tube_length: float, dt: float = 1e-5):
        """
        Initialize simulation service.
        
        Args:
            capsule: Projectile capsule to simulate
            stages: List of acceleration stages
            tube_length: Total tube length (m)
            dt: Time step for integration (s)
        """
        self.capsule = capsule
        self.stages = stages
        self.tube_length = tube_length
        self.dt = dt
        
        # Initialize physics engine and data service
        self.physics = PhysicsEngine()
        self.data = DataService()
        
        # Simulation state
        self.time = 0.0
        
        # Store initial conditions for reset
        self._initial_capsule_state = {
            'position': capsule.position,
            'velocity': capsule.velocity,
            'current': capsule.current
        }
    
    def run(self, max_time: float = 0.01) -> SimulationResult:
        """
        Run the complete simulation.
        
        Args:
            max_time: Maximum simulation time (s)
            
        Returns:
            SimulationResult with complete simulation data
        """
        # Set initial energy for efficiency calculations
        initial_energy = sum(stage.stored_energy for stage in self.stages)
        self.data.set_initial_energy(initial_energy)
        
        # Main simulation loop
        while self.time < max_time and self.capsule.position < self.tube_length:
            self._step()
            self.time += self.dt
        
        # Generate and return results
        return self.data.get_results()
    
    def _step(self) -> None:
        """
        Execute single simulation time step.
        
        This method orchestrates:
        1. Stage activation logic
        2. Current calculations
        3. Force calculations
        4. Kinematics updates
        5. Data recording
        """
        # Check for stage activations based on capsule position
        self._check_stage_activations()
        
        # Update induced current in capsule from moving through magnetic fields
        self._update_capsule_current()
        
        # Calculate total electromagnetic force from all active stages
        total_force = self._calculate_total_force()
        
        # Update capsule kinematics using physics engine
        self.physics.update_kinematics(self.capsule, total_force, self.dt)
        
        # Record current state for analysis
        self.data.record(self.time, self.capsule, self.stages, total_force)
    
    def _check_stage_activations(self) -> None:
        """
        Check and activate stages when capsule approaches.
        
        Stages activate when capsule is within one coil length distance.
        """
        for stage in self.stages:
            if not stage.is_active:
                distance_to_stage = abs(self.capsule.position - stage.properties.position)
                
                # Activate when capsule is within coil length (or very close)
                activation_distance = max(stage.properties.length, 0.01)  # At least 1cm activation distance
                
                if distance_to_stage <= activation_distance:
                    stage.activate(self.time)
    
    def _update_capsule_current(self) -> None:
        """
        Update induced current in capsule due to changing magnetic flux.
        
        Current is induced by motion through magnetic fields and
        changing currents in nearby stages.
        """
        total_induced_emf = 0.0
        
        # Calculate EMF from all active stages
        for stage in self.stages:
            if stage.is_active:
                distance = max(0.001, abs(self.capsule.position - stage.properties.position))  # Minimum 1mm
                stage_current = stage.get_current(self.time)
                
                # Mutual inductance between stage and capsule
                mutual_inductance = self.physics.calculate_mutual_inductance(
                    stage, self.capsule, distance
                )
                
                # EMF from changing stage current (dI/dt)
                stage_current_rate = stage.get_current_derivative(self.time)
                induced_emf = mutual_inductance * stage_current_rate
                
                # EMF from capsule motion (v * dM/dx)
                dm_dx = self._calculate_mutual_inductance_gradient(stage, distance)
                motional_emf = self.capsule.velocity * stage_current * dm_dx
                
                total_induced_emf += induced_emf + motional_emf
        
        # Update capsule current using Ohm's law
        # I = EMF / R (with some damping for numerical stability)
        if self.capsule.properties.resistance > 0:
            induced_current = total_induced_emf / self.capsule.properties.resistance
            
            # Simple exponential approach to steady state
            damping_factor = 0.1
            self.capsule.current += damping_factor * (induced_current - self.capsule.current)
    
    def _calculate_total_force(self) -> float:
        """
        Calculate total electromagnetic force on capsule.
        
        Uses proper electromagnetic force physics without arbitrary scaling.
        Force direction determined by physics calculations, not position logic.
        
        Returns:
            Total force in Newtons (positive = acceleration direction)
        """
        total_force = 0.0
        
        for stage in self.stages:
            if stage.is_active:
                stage_current = stage.get_current(self.time)
                distance = max(0.001, abs(self.capsule.position - stage.properties.position))  # Minimum 1mm
                
                # Calculate force if currents are significant enough
                if abs(stage_current) > 0.1 and abs(self.capsule.current) > 0.001:
                    # Calculate electromagnetic force using physics engine
                    # Force direction is inherently determined by current directions
                    # and mutual inductance gradient
                    force = self.physics.calculate_force(
                        stage, self.capsule, distance,
                        stage_current, self.capsule.current
                    )
                    
                    # Apply force direction based on physics, not arbitrary rules
                    # The physics engine already accounts for attractive/repulsive forces
                    # based on current directions and mutual inductance gradient
                    
                    # For electromagnetic gun timing, we expect:
                    # - Attractive force when capsule approaches (proper timing)
                    # - Reduced or opposing force when capsule passes (late timing)
                    
                    position_relative = self.capsule.position - stage.properties.position
                    
                    if position_relative < 0:
                        # Capsule approaching stage - use full calculated force
                        total_force += force
                    else:
                        # Capsule past stage - use physics-calculated force
                        # This naturally accounts for timing and current direction
                        # No arbitrary scaling - let physics determine the result
                        total_force += force
                        
                    # Add back-EMF opposition for velocity-dependent losses
                    # This provides realistic velocity-dependent drag
                    if abs(self.capsule.velocity) > 0.01:  # Only for significant velocities (1 cm/s)
                        back_emf_force = -0.001 * self.capsule.velocity  # Much smaller drag coefficient
                        total_force += back_emf_force
        
        return total_force
    
    def _calculate_mutual_inductance_gradient(self, stage: AccelerationStage,
                                            distance: float) -> float:
        """
        Calculate gradient of mutual inductance for motional EMF.
        
        Args:
            stage: Acceleration stage
            distance: Distance between stage and capsule
            
        Returns:
            dM/dx in H/m
        """
        dx = 0.001  # 1mm numerical differentiation step
        
        # Ensure distances are always positive
        dist_plus = max(0.001, distance + dx/2)  # Minimum 1mm distance
        dist_minus = max(0.001, distance - dx/2)  # Minimum 1mm distance
        
        m_plus = self.physics.calculate_mutual_inductance(
            stage, self.capsule, dist_plus
        )
        m_minus = self.physics.calculate_mutual_inductance(
            stage, self.capsule, dist_minus
        )
        
        return (m_plus - m_minus) / dx
    
    def reset(self) -> None:
        """
        Reset simulation to initial state.
        
        Restores capsule position, velocity, and stage states.
        Clears all collected data.
        """
        # Reset time
        self.time = 0.0
        
        # Reset capsule state
        self.capsule.position = self._initial_capsule_state['position']
        self.capsule.velocity = self._initial_capsule_state['velocity']
        self.capsule.current = self._initial_capsule_state['current']
        
        # Reset all stages
        for stage in self.stages:
            stage.is_active = False
            stage.activation_time = None
        
        # Reset data collection
        self.data.reset()
    
    @classmethod
    def from_config(cls, config) -> 'SimulationService':
        """
        Create SimulationService from configuration object.
        
        Args:
            config: SimulationConfig with all parameters
            
        Returns:
            Configured SimulationService ready to run
        """
        # Create capsule
        capsule = Capsule(
            mass=config.capsule_mass,
            diameter=config.capsule_diameter,
            length=config.capsule_length
        )
        
        # Create stages
        stages = []
        stage_spacing = config.tube_length / config.num_stages
        
        for i in range(config.num_stages):
            stage = AccelerationStage(
                stage_id=i,
                position=i * stage_spacing,
                turns=config.stage_turns,
                diameter=config.tube_diameter,
                length=stage_spacing * 0.6,  # 60% of spacing for coil length
                capacitance=config.stage_capacitance,
                voltage=config.stage_voltage
            )
            stages.append(stage)
        
        # Create service
        return cls(
            capsule=capsule,
            stages=stages,
            tube_length=config.tube_length,
            dt=config.time_step
        )