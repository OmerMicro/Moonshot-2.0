"""
Test-Driven Development for Capsule class
Following Red-Green-Refactor cycle
"""

import pytest
import sys
import os

# Add src to path for imports
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', '..', 'src'))

from core.capsule import Capsule


class TestCapsule:
    """Test Capsule class - TDD Step 1: RED"""
    
    def test_capsule_creation_with_valid_parameters(self):
        """Test 1: Basic Capsule creation (inherits from Coil)"""
        capsule = Capsule(mass=1.0, diameter=0.083, length=0.02)
        
        assert capsule.mass == 1.0
        assert capsule.properties.diameter == 0.083
        assert capsule.properties.length == 0.02
        assert capsule.properties.turns == 1  # Single turn conductor
        assert capsule.position == 0.0
        assert capsule.velocity == 0.0
    
    def test_capsule_creation_with_invalid_mass_raises_error(self):
        """Test 2: Business rule - mass must be positive"""
        with pytest.raises(ValueError, match="Mass must be positive"):
            Capsule(mass=0.0, diameter=0.083, length=0.02)
        
        with pytest.raises(ValueError, match="Mass must be positive"):
            Capsule(mass=-1.0, diameter=0.083, length=0.02)
    
    def test_capsule_inherits_coil_behavior(self):
        """Test 3: Liskov Substitution Principle - Capsule can be used as Coil"""
        capsule = Capsule(mass=1.0, diameter=0.083, length=0.02)
        
        # Should have all Coil properties and methods
        assert hasattr(capsule, 'inductance')
        assert hasattr(capsule, 'set_current')
        assert hasattr(capsule, 'get_magnetic_moment')
        
        # Should be able to set current
        capsule.set_current(50.0)
        assert capsule.current == 50.0
        
        # Should have positive inductance
        assert capsule.inductance > 0
    
    def test_capsule_resistance_calculation(self):
        """Test 4: Aluminum resistance calculation"""
        capsule = Capsule(mass=1.0, diameter=0.083, length=0.02)
        
        # Resistance should be positive and reasonable for aluminum
        assert capsule.properties.resistance > 0
        assert capsule.properties.resistance < 1.0  # Should be small for good conductor
    
    def test_capsule_single_turn_inductance(self):
        """Test 5: Single turn inductance is smaller than multi-turn coil"""
        capsule = Capsule(mass=1.0, diameter=0.083, length=0.02)
        
        # Create equivalent multi-turn coil for comparison
        from core.coil import CoilProperties, Coil
        multi_turn_props = CoilProperties(
            turns=100,
            diameter=0.083,
            length=0.02,
            resistance=0.05
        )
        multi_turn_coil = Coil(multi_turn_props)
        
        # Single turn should have much lower inductance
        assert capsule.inductance < multi_turn_coil.inductance
    
    def test_capsule_update_position(self):
        """Test 6: Position update functionality"""
        capsule = Capsule(mass=1.0, diameter=0.083, length=0.02)
        
        # Update position
        capsule.update_position(0.05)
        assert capsule.position == 0.05
    
    def test_capsule_update_velocity(self):
        """Test 7: Velocity update functionality"""
        capsule = Capsule(mass=1.0, diameter=0.083, length=0.02)
        
        # Update velocity
        capsule.update_velocity(25.0)
        assert capsule.velocity == 25.0
    
    def test_capsule_kinetic_energy_calculation(self):
        """Test 8: Kinetic energy calculation"""
        capsule = Capsule(mass=1.0, diameter=0.083, length=0.02)
        capsule.update_velocity(10.0)
        
        # KE = 0.5 * m * v²
        expected_ke = 0.5 * 1.0 * 10.0**2
        assert capsule.get_kinetic_energy() == expected_ke
    
    def test_capsule_zero_velocity_zero_kinetic_energy(self):
        """Test 9: Zero velocity should give zero kinetic energy"""
        capsule = Capsule(mass=1.0, diameter=0.083, length=0.02)
        
        assert capsule.get_kinetic_energy() == 0.0
    
    def test_capsule_string_representation(self):
        """Test 10: String representation for debugging"""
        capsule = Capsule(mass=1.0, diameter=0.083, length=0.02)
        
        str_repr = str(capsule)
        assert "Capsule" in str_repr
        assert "1.0" in str_repr  # mass
        assert "0.083" in str_repr  # diameter