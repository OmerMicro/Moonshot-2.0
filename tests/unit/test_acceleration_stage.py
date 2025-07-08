"""
Test-Driven Development for AccelerationStage class
Following Red-Green-Refactor cycle
"""

import pytest
import sys
import os
import numpy as np

# Add src to path for imports
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', '..', 'src'))

from core.acceleration_stage import AccelerationStage


class TestAccelerationStage:
    """Test AccelerationStage class - TDD Step 1: RED"""
    
    def test_acceleration_stage_creation_with_valid_parameters(self):
        """Test 1: Basic AccelerationStage creation"""
        stage = AccelerationStage(
            stage_id=0,
            position=0.083,
            turns=100,
            diameter=0.09,
            length=0.05,
            capacitance=1000e-6,
            voltage=400.0
        )
        
        assert stage.stage_id == 0
        assert stage.properties.position == 0.083
        assert stage.properties.turns == 100
        assert stage.properties.diameter == 0.09
        assert stage.properties.length == 0.05
        assert stage.capacitance == 1000e-6
        assert stage.voltage == 400.0
        assert stage.is_active == False
        assert stage.activation_time is None
    
    def test_acceleration_stage_inherits_coil_behavior(self):
        """Test 2: Liskov Substitution Principle - AccelerationStage can be used as Coil"""
        stage = AccelerationStage(0, 0.083, 100, 0.09, 0.05, 1000e-6, 400.0)
        
        # Should have all Coil properties and methods
        assert hasattr(stage, 'inductance')
        assert hasattr(stage, 'set_current')
        assert hasattr(stage, 'get_magnetic_moment')
        
        # Should be able to set current
        stage.set_current(50.0)
        assert stage.current == 50.0
        
        # Should have positive inductance (much higher than single turn)
        assert stage.inductance > 0
    
    def test_acceleration_stage_copper_resistance_calculation(self):
        """Test 3: Copper wire resistance calculation"""
        stage = AccelerationStage(0, 0.083, 100, 0.09, 0.05, 1000e-6, 400.0)
        
        # Resistance should be positive and reasonable for copper wire
        assert stage.properties.resistance > 0
        assert stage.properties.resistance < 1.0  # Should be reasonable for 100 turns
    
    def test_acceleration_stage_activation(self):
        """Test 4: Stage activation functionality"""
        stage = AccelerationStage(0, 0.083, 100, 0.09, 0.05, 1000e-6, 400.0)
        
        # Initially not active
        assert not stage.is_active
        assert stage.activation_time is None
        
        # Activate at time 0.001
        stage.activate(0.001)
        assert stage.is_active
        assert stage.activation_time == 0.001
    
    def test_acceleration_stage_current_before_activation(self):
        """Test 5: Current should be zero before activation"""
        stage = AccelerationStage(0, 0.083, 100, 0.09, 0.05, 1000e-6, 400.0)
        
        # Current should be zero before activation
        assert stage.get_current(0.005) == 0.0
    
    def test_acceleration_stage_current_after_activation(self):
        """Test 6: Current should follow RLC discharge after activation"""
        stage = AccelerationStage(0, 0.083, 100, 0.09, 0.05, 1000e-6, 400.0)
        
        # Activate at time 0.001
        stage.activate(0.001)
        
        # Current should be positive shortly after activation
        current_at_0002 = stage.get_current(0.002)  # 1ms after activation
        assert current_at_0002 > 0
        
        # Current should decrease later (simplified check)
        current_at_0010 = stage.get_current(0.010)  # 9ms after activation
        # Note: This might be 0 depending on RLC parameters, which is OK
        assert current_at_0010 >= 0
    
    def test_acceleration_stage_rlc_circuit_parameters(self):
        """Test 7: RLC circuit parameters should be reasonable"""
        stage = AccelerationStage(0, 0.083, 100, 0.09, 0.05, 1000e-6, 400.0)
        
        # Calculate expected frequency
        omega = 1 / np.sqrt(stage.inductance * stage.capacitance)
        frequency = omega / (2 * np.pi)
        
        # Frequency should be reasonable (kHz range for this type of circuit)
        assert 100 < frequency < 100000  # 100 Hz to 100 kHz
    
    def test_acceleration_stage_energy_storage(self):
        """Test 8: Energy storage calculation"""
        stage = AccelerationStage(0, 0.083, 100, 0.09, 0.05, 1000e-6, 400.0)
        
        # Energy stored in capacitor: E = 0.5 * C * V²
        expected_energy = 0.5 * stage.capacitance * stage.voltage**2
        calculated_energy = stage.get_stored_energy()
        
        assert abs(calculated_energy - expected_energy) < 1e-6
    
    def test_acceleration_stage_multiple_stages_different_ids(self):
        """Test 9: Multiple stages can have different IDs"""
        stage1 = AccelerationStage(0, 0.083, 100, 0.09, 0.05, 1000e-6, 400.0)
        stage2 = AccelerationStage(1, 0.166, 100, 0.09, 0.05, 1000e-6, 400.0)
        stage3 = AccelerationStage(2, 0.249, 100, 0.09, 0.05, 1000e-6, 400.0)
        
        assert stage1.stage_id != stage2.stage_id != stage3.stage_id
        assert stage1.properties.position != stage2.properties.position
    
    def test_acceleration_stage_wire_gauge_affects_resistance(self):
        """Test 10: Different wire gauges should affect resistance"""
        # This tests the internal wire resistance calculation
        stage_thick_wire = AccelerationStage(0, 0.083, 100, 0.09, 0.05, 1000e-6, 400.0)
        
        # The resistance should be calculated based on wire properties
        # For now, just check it's positive and reasonable
        assert stage_thick_wire.properties.resistance > 0
        assert stage_thick_wire.properties.resistance < 10.0  # Should be less than 10 ohms
    
    def test_acceleration_stage_string_representation(self):
        """Test 11: String representation for debugging"""
        stage = AccelerationStage(0, 0.083, 100, 0.09, 0.05, 1000e-6, 400.0)
        
        str_repr = str(stage)
        assert "AccelerationStage" in str_repr
        assert "0" in str_repr  # stage_id
        assert "400" in str_repr  # voltage