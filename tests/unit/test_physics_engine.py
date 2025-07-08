"""
Test-Driven Development for PhysicsEngine class
Following Red-Green-Refactor cycle
"""

import pytest
import sys
import os
import numpy as np

# Add src to path for imports
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', '..', 'src'))

from physics.physics_engine import PhysicsEngine
from core.coil import CoilProperties, Coil
from core.capsule import Capsule
from core.acceleration_stage import AccelerationStage


class TestPhysicsEngine:
    """Test PhysicsEngine class - TDD Step 1: RED"""
    
    @pytest.fixture
    def physics_engine(self):
        """Create physics engine for testing"""
        return PhysicsEngine()
    
    @pytest.fixture
    def capsule(self):
        """Create test capsule"""
        return Capsule(mass=1.0, diameter=0.083, length=0.02)
    
    @pytest.fixture
    def stage(self):
        """Create test acceleration stage"""
        return AccelerationStage(
            stage_id=0, position=0.083, turns=100,
            diameter=0.09, length=0.05, capacitance=1000e-6, voltage=400
        )
    
    def test_physics_engine_creation(self, physics_engine):
        """Test 1: PhysicsEngine creation and constants"""
        assert physics_engine is not None
        # Check that permeability constant is correct
        expected_mu_0 = 4 * np.pi * 1e-7
        assert abs(physics_engine.mu_0 - expected_mu_0) < 1e-12
    
    def test_mutual_inductance_units_and_magnitude(self, physics_engine, capsule, stage):
        """Test 2: Mutual inductance has correct units (Henries) and reasonable magnitude"""
        mutual_inductance = physics_engine.calculate_mutual_inductance(
            capsule, stage, distance=0.01)
        
        # Should be positive and reasonable magnitude
        assert mutual_inductance > 0
        assert mutual_inductance < 1e-3  # Less than 1mH for small coils
    
    def test_mutual_inductance_decreases_with_distance(self, physics_engine, capsule, stage):
        """Test 3: Physics behavior - inductance decreases with distance"""
        distance_near = 0.01
        distance_far = 0.1
        
        inductance_near = physics_engine.calculate_mutual_inductance(
            capsule, stage, distance_near)
        inductance_far = physics_engine.calculate_mutual_inductance(
            capsule, stage, distance_far)
        
        assert inductance_near > inductance_far
        assert inductance_near > 0
        assert inductance_far > 0
    
    def test_mutual_inductance_overlapping_case(self, physics_engine, capsule, stage):
        """Test 4: Overlapping case when capsule is inside coil"""
        # Distance less than coil length should use overlapping formula
        distance_inside = 0.02  # Less than stage length (0.05m)
        
        inductance = physics_engine.calculate_mutual_inductance(
            capsule, stage, distance_inside)
        
        assert inductance > 0
        # Should be larger than far-field case
        far_distance = 0.2
        inductance_far = physics_engine.calculate_mutual_inductance(
            capsule, stage, far_distance)
        assert inductance > inductance_far
    
    def test_force_calculation_with_currents(self, physics_engine, capsule, stage):
        """Test 5: Force calculation between coils with currents"""
        distance = 0.05
        current1, current2 = 100.0, 50.0
        
        force = physics_engine.calculate_force(
            capsule, stage, distance, current1, current2)
        
        # Force should be finite and reasonable
        assert np.isfinite(force)
        # For our setup, force should be positive (attractive)
        assert force != 0  # Should have some force
    
    def test_force_symmetry(self, physics_engine, capsule, stage):
        """Test 6: Force calculation should be symmetric"""
        distance = 0.01
        current1, current2 = 100.0, 50.0
        
        force1 = physics_engine.calculate_force(
            capsule, stage, distance, current1, current2)
        force2 = physics_engine.calculate_force(
            stage, capsule, distance, current2, current1)
        
        # Forces should be equal (within numerical precision)
        assert abs(force1 - force2) < 1e-10
    
    def test_force_proportional_to_currents(self, physics_engine, capsule, stage):
        """Test 7: Force should be proportional to product of currents"""
        distance = 0.05
        
        # Test with different current combinations
        force1 = physics_engine.calculate_force(capsule, stage, distance, 10.0, 20.0)
        force2 = physics_engine.calculate_force(capsule, stage, distance, 20.0, 40.0)
        
        # Second force should be 4x larger (2x * 2x)
        ratio = force2 / force1 if force1 != 0 else 0
        assert abs(ratio - 4.0) < 0.1  # Within 10% due to numerical precision
    
    def test_force_zero_with_zero_current(self, physics_engine, capsule, stage):
        """Test 8: Force should be zero if either current is zero"""
        distance = 0.05
        
        force1 = physics_engine.calculate_force(capsule, stage, distance, 0.0, 100.0)
        force2 = physics_engine.calculate_force(capsule, stage, distance, 100.0, 0.0)
        force3 = physics_engine.calculate_force(capsule, stage, distance, 0.0, 0.0)
        
        assert force1 == 0.0
        assert force2 == 0.0
        assert force3 == 0.0
    
    def test_kinematics_update_basic(self, physics_engine, capsule):
        """Test 9: Basic kinematics update"""
        initial_position = capsule.position
        initial_velocity = capsule.velocity
        force = 10.0  # 10 Newton force
        dt = 0.001  # 1ms time step
        
        physics_engine.update_kinematics(capsule, force, dt)
        
        # Position and velocity should have changed
        assert capsule.position != initial_position
        assert capsule.velocity != initial_velocity
        
        # Velocity should increase (force in positive direction)
        assert capsule.velocity > initial_velocity
    
    def test_kinematics_acceleration_calculation(self, physics_engine, capsule):
        """Test 10: Acceleration calculation F=ma"""
        force = 5.0  # 5 Newton force
        dt = 0.001
        initial_velocity = capsule.velocity
        
        physics_engine.update_kinematics(capsule, force, dt)
        
        # Expected acceleration: a = F/m = 5/1 = 5 m/s²
        expected_acceleration = force / capsule.mass
        velocity_change = capsule.velocity - initial_velocity
        calculated_acceleration = velocity_change / dt
        
        assert abs(calculated_acceleration - expected_acceleration) < 1e-10
    
    def test_kinematics_conservation_laws(self, physics_engine, capsule):
        """Test 11: Energy and momentum conservation in kinematics"""
        initial_ke = capsule.get_kinetic_energy()
        initial_momentum = capsule.get_momentum()
        
        force = 8.0
        dt = 0.001
        
        physics_engine.update_kinematics(capsule, force, dt)
        
        # Energy should increase due to work done by force
        final_ke = capsule.get_kinetic_energy()
        assert final_ke > initial_ke
        
        # Momentum should change due to impulse
        final_momentum = capsule.get_momentum()
        momentum_change = final_momentum - initial_momentum
        expected_impulse = force * dt
        
        assert abs(momentum_change - expected_impulse) < 1e-10
    
    def test_physics_engine_error_handling(self, physics_engine):
        """Test 12: Error handling for invalid inputs"""
        capsule = Capsule(1.0, 0.083, 0.02)
        stage = AccelerationStage(0, 0.083, 100, 0.09, 0.05, 1000e-6, 400)
        
        # Test with negative distance (should handle gracefully)
        with pytest.raises(ValueError):
            physics_engine.calculate_mutual_inductance(capsule, stage, -0.01)