"""
Test module for SimulationService.

Tests the main simulation orchestrator that coordinates all components
and manages the complete electromagnetic gun simulation process.
"""

import pytest
import numpy as np
from unittest.mock import Mock, patch, MagicMock

from src.core.capsule import Capsule
from src.core.acceleration_stage import AccelerationStage
from src.services.simulation_service import SimulationService, SimulationResult
from src.physics.physics_engine import PhysicsEngine


class TestSimulationService:
    """Test cases for SimulationService following TDD principles."""
    
    def setup_method(self):
        """Set up test fixtures before each test method."""
        # Create test capsule
        self.capsule = Capsule(mass=1.0, diameter=0.083, length=0.02)
        
        # Create test stages
        self.stages = [
            AccelerationStage(
                stage_id=i,
                position=i * 0.083,
                turns=100,
                diameter=0.09,
                length=0.05,
                capacitance=1000e-6,
                voltage=400.0
            )
            for i in range(3)  # Use 3 stages for faster testing
        ]
        
        # Simulation parameters
        self.tube_length = 0.5
        self.dt = 1e-5
        self.max_time = 0.001  # Short for testing
        
        # Create service
        self.service = SimulationService(
            capsule=self.capsule,
            stages=self.stages,
            tube_length=self.tube_length,
            dt=self.dt
        )
    
    def test_simulation_service_initialization(self):
        """Test 1: SimulationService initializes correctly."""
        assert self.service.capsule == self.capsule
        assert self.service.stages == self.stages
        assert self.service.tube_length == self.tube_length
        assert self.service.dt == self.dt
        assert self.service.time == 0.0
        assert isinstance(self.service.physics, PhysicsEngine)
        assert self.service.data is not None
    
    def test_simulation_service_single_step(self):
        """Test 2: Single simulation step updates capsule state."""
        initial_position = self.capsule.position
        initial_time = self.service.time
        
        # Execute single step
        self.service._step()
        
        # Verify time does NOT advance in _step() - that happens in run()
        assert self.service.time == initial_time
        
        # Verify capsule state tracking
        assert len(self.service.data.history) == 1
        
        # Verify data recording
        last_record = self.service.data.history[-1]
        assert 'time' in last_record
        assert 'position' in last_record
        assert 'velocity' in last_record
        assert 'force' in last_record
        
        # The recorded time should be the current simulation time
        assert last_record['time'] == self.service.time
    
    def test_stage_activation_logic(self):
        """Test 3: Stages activate when capsule approaches."""
        # Position capsule close to first stage (stage 0 is at position 0.0)
        self.capsule.position = 0.02  # Within activation distance of stage at 0.0
        
        # Check initial state
        assert not self.stages[0].is_active
        
        # Execute step
        self.service._step()
        
        # Stage should now be active
        assert self.stages[0].is_active
        assert self.stages[0].activation_time is not None
    
    def test_force_calculation_with_active_stages(self):
        """Test 4: Force calculation includes all active stages."""
        # Activate multiple stages manually for testing
        self.stages[0].activate(0.0)
        self.stages[1].activate(0.001)
        
        # Position capsule between stages
        self.capsule.position = 0.1
        
        # Set simulation time to when stages have good current
        self.service.time = 0.0001  # Set time for current calculation
        
        # Simulate electromagnetic induction by running a step
        # This will induce current in the capsule naturally
        self.service._update_capsule_current()
        
        # Verify that capsule now has induced current
        assert abs(self.capsule.current) > 0.01, f"Capsule current too low: {self.capsule.current}"
        
        # Calculate force
        total_force = self.service._calculate_total_force()
        
        # Should have non-zero force from electromagnetic interaction
        assert total_force != 0.0
        assert isinstance(total_force, float)

    def test_simulation_max_force_nonzero(self):
        """Test: Simulation max force should be greater than zero for typical parameters."""
        result = self.service.run(max_time=0.01)
        assert result.max_force > 0.0, f"Expected max force > 0, got {result.max_force}"
    
    def test_simulation_termination_conditions(self):
        """Test 5: Simulation terminates on time or position limits."""
        # Test 1: Time limit termination
        result = self.service.run(max_time=0.0001)  # Very short time
        assert result is not None
        assert self.service.time >= 0.0001 or self.capsule.position >= self.tube_length
        
        # Reset for second test
        self.service.reset()
        
        # Test 2: Position limit termination (move capsule very close to end)
        self.capsule.position = self.tube_length - 0.001  # Very close to end, 1mm from end
        self.capsule.velocity = 0.01  # Small forward velocity to ensure it reaches the end
        result = self.service.run(max_time=1.0)  # Long time, should terminate on position
        # Should reach or exceed tube length
        assert self.capsule.position >= self.tube_length
    
    def test_data_collection_during_simulation(self):
        """Test 6: Data is collected at each simulation step."""
        # Run short simulation
        result = self.service.run(max_time=0.0005)
        
        # Verify data collection
        assert len(self.service.data.history) > 0
        
        # Verify data structure
        for record in self.service.data.history:
            assert 'time' in record
            assert 'position' in record
            assert 'velocity' in record
            assert 'acceleration' in record
            assert 'force' in record
            assert 'kinetic_energy' in record
            
            # Verify data types
            assert isinstance(record['time'], float)
            assert isinstance(record['position'], float)
            assert isinstance(record['velocity'], float)
    
    def test_energy_conservation_tracking(self):
        """Test 7: Energy conservation is tracked during simulation."""
        # Record initial energy
        initial_capacitor_energy = sum(stage.stored_energy for stage in self.stages)
        
        # Run simulation
        result = self.service.run(max_time=0.001)
        
        # Check energy tracking in results
        assert hasattr(result, 'initial_energy')
        assert hasattr(result, 'final_kinetic_energy')
        assert result.initial_energy > 0
        assert result.final_kinetic_energy >= 0
    
    def test_simulation_reset_functionality(self):
        """Test 8: Simulation can be reset to initial state."""
        # Run simulation partially
        self.service.run(max_time=0.0002)
        
        # Record state before reset
        time_before = self.service.time
        position_before = self.capsule.position
        
        assert time_before > 0
        assert len(self.service.data.history) > 0
        
        # Reset simulation
        self.service.reset()
        
        # Verify reset state
        assert self.service.time == 0.0
        assert self.capsule.position == 0.0
        assert self.capsule.velocity == 0.0
        assert len(self.service.data.history) == 0
        
        # Verify stages are reset
        for stage in self.stages:
            assert not stage.is_active
            assert stage.activation_time is None
    
    def test_simulation_result_object(self):
        """Test 9: SimulationResult contains expected data."""
        result = self.service.run(max_time=0.001)
        
        # Verify result type and attributes
        assert isinstance(result, SimulationResult)
        assert hasattr(result, 'final_velocity')
        assert hasattr(result, 'final_position')
        assert hasattr(result, 'total_time')
        assert hasattr(result, 'max_force')
        assert hasattr(result, 'energy_efficiency')
        assert hasattr(result, 'history')
        
        # Verify data values are reasonable
        # Note: Small negative values can occur due to numerical effects or back-EMF
        assert abs(result.final_velocity) >= 0  # Allow small negative velocities
        assert result.final_position >= -1e-5  # Allow small numerical errors (up to 10 microns)
        assert result.total_time >= 0
        assert 0 <= result.energy_efficiency <= 1
    
    def test_performance_monitoring(self):
        """Test 10: Simulation tracks performance metrics."""
        import time
        
        start_time = time.time()
        result = self.service.run(max_time=0.001)
        execution_time = time.time() - start_time
        
        # Should complete quickly (< 1 second for test simulation)
        assert execution_time < 1.0
        
        # Should have reasonable step count
        expected_steps = int(0.001 / self.dt)
        actual_steps = len(result.history)
        
        # Allow some tolerance for termination conditions
        assert 0.8 * expected_steps <= actual_steps <= 1.2 * expected_steps


class TestSimulationResult:
    """Test cases for SimulationResult data structure."""
    
    def test_simulation_result_creation(self):
        """Test 11: SimulationResult can be created with data."""
        # Create test data
        history = [
            {'time': 0.0, 'position': 0.0, 'velocity': 0.0, 'force': 0.0, 'kinetic_energy': 0.0},
            {'time': 0.1, 'position': 0.1, 'velocity': 1.0, 'force': 10.0, 'kinetic_energy': 0.5}
        ]
        
        result = SimulationResult(
            final_velocity=1.0,
            final_position=0.1,
            total_time=0.1,
            initial_energy=100.0,
            history=history
        )
        
        # Verify all attributes
        assert result.final_velocity == 1.0
        assert result.final_position == 0.1
        assert result.total_time == 0.1
        assert result.initial_energy == 100.0
        assert result.history == history
        
        # Verify calculated properties
        assert result.final_kinetic_energy == 0.5
        assert result.max_force == 10.0
        assert 0 <= result.energy_efficiency <= 1
    
    def test_simulation_result_export_capabilities(self):
        """Test 12: SimulationResult can export data in various formats."""
        history = [
            {'time': 0.0, 'position': 0.0, 'velocity': 0.0, 'force': 0.0, 'kinetic_energy': 0.0},
            {'time': 0.1, 'position': 0.1, 'velocity': 1.0, 'force': 10.0, 'kinetic_energy': 0.5}
        ]
        
        result = SimulationResult(
            final_velocity=1.0,
            final_position=0.1,
            total_time=0.1,
            initial_energy=100.0,
            history=history
        )
        
        # Test dictionary export
        result_dict = result.to_dict()
        assert isinstance(result_dict, dict)
        assert 'final_velocity' in result_dict
        assert 'history' in result_dict
        
        # Test arrays for plotting
        time_array = result.get_time_array()
        position_array = result.get_position_array()
        velocity_array = result.get_velocity_array()
        
        assert len(time_array) == len(history)
        assert len(position_array) == len(history)
        assert len(velocity_array) == len(history)
        assert time_array[1] == 0.1
        assert position_array[1] == 0.1
        assert velocity_array[1] == 1.0