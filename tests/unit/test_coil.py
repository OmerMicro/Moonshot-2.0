"""
Test-Driven Development for Coil class
Following Red-Green-Refactor cycle
"""

import pytest
import sys
import os

# Add src to path for imports
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', '..', 'src'))

from core.coil import CoilProperties, Coil


class TestCoilProperties:
    """Test CoilProperties data class - TDD Step 1: RED"""
    
    def test_coil_properties_creation_with_valid_parameters(self):
        """Test 1: Basic CoilProperties creation"""
        props = CoilProperties(
            turns=100,
            diameter=0.09,
            length=0.05,
            resistance=0.05,
            position=0.0
        )
        
        assert props.turns == 100
        assert props.diameter == 0.09
        assert props.length == 0.05
        assert props.resistance == 0.05
        assert props.position == 0.0
    
    def test_coil_properties_validation_turns_positive(self):
        """Test 2: Business rule - turns must be positive"""
        with pytest.raises(ValueError, match="Turns must be positive"):
            CoilProperties(
                turns=0,
                diameter=0.09,
                length=0.05,
                resistance=0.05
            )
    
    def test_coil_properties_validation_diameter_positive(self):
        """Test 3: Business rule - diameter must be positive"""
        with pytest.raises(ValueError, match="Diameter must be positive"):
            CoilProperties(
                turns=100,
                diameter=0.0,
                length=0.05,
                resistance=0.05
            )
    
    def test_coil_properties_validation_length_positive(self):
        """Test 4: Business rule - length must be positive"""
        with pytest.raises(ValueError, match="Length must be positive"):
            CoilProperties(
                turns=100,
                diameter=0.09,
                length=-0.01,
                resistance=0.05
            )


class TestCoil:
    """Test Coil base class - TDD Step 1: RED"""
    
    def test_coil_creation_with_valid_properties(self):
        """Test 5: Basic Coil creation"""
        props = CoilProperties(100, 0.09, 0.05, 0.05, 0.0)
        coil = Coil(props)
        
        assert coil.properties == props
        assert coil.current == 0.0
    
    def test_coil_inductance_calculation(self):
        """Test 6: Inductance calculation (lazy loading)"""
        props = CoilProperties(100, 0.05, 0.1, 1.0)
        coil = Coil(props)
        
        # First access should calculate inductance
        inductance1 = coil.inductance
        assert inductance1 > 0
        
        # Second access should return cached value
        inductance2 = coil.inductance
        assert inductance1 == inductance2
    
    def test_coil_set_current_valid_value(self):
        """Test 7: Setting valid current"""
        props = CoilProperties(100, 0.09, 0.05, 0.05)
        coil = Coil(props)
        
        coil.set_current(50.0)
        assert coil.current == 50.0
    
    def test_coil_set_current_negative_value_raises_error(self):
        """Test 8: Business rule - current cannot be negative"""
        props = CoilProperties(100, 0.09, 0.05, 0.05)
        coil = Coil(props)
        
        with pytest.raises(ValueError, match="Current cannot be negative"):
            coil.set_current(-10.0)
    
    def test_coil_inductance_formula_validation(self):
        """Test 9: Validate inductance against known formula"""
        # Test with known values
        props = CoilProperties(turns=100, diameter=0.05, length=0.1, resistance=1.0)
        coil = Coil(props)
        
        # Expected inductance using solenoid formula
        # L = μ₀ * n² * A * l where n = N/l
        mu_0 = 4 * 3.14159 * 1e-7
        A = 3.14159 * (0.025)**2  # π * r²
        n = 100 / 0.1  # turns per unit length
        expected = mu_0 * n**2 * A * 0.1
        
        assert abs(coil.inductance - expected) / expected < 0.01  # Within 1%