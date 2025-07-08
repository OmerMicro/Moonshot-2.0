"""
Core coil classes following SOLID principles
Implementation following TDD Red-Green-Refactor cycle
"""

import numpy as np
from dataclasses import dataclass
from abc import ABC


@dataclass
class CoilProperties:
    """
    Simple data class for coil properties - Single Responsibility Principle
    Immutable value object with validation
    """
    turns: int
    diameter: float  # meters
    length: float    # meters
    resistance: float  # ohms
    position: float = 0.0
    
    def __post_init__(self):
        """Input validation - Business rules enforcement"""
        if self.turns <= 0:
            raise ValueError("Turns must be positive")
        if self.diameter <= 0:
            raise ValueError("Diameter must be positive")
        if self.length <= 0:
            raise ValueError("Length must be positive")


class Coil:
    """
    Base coil class following Single Responsibility Principle
    Focused only on electromagnetic properties and basic coil behavior
    Open for extension (OCP) - can be inherited by Capsule and AccelerationStage
    """
    
    def __init__(self, properties: CoilProperties):
        """
        Initialize coil with validated properties
        
        Args:
            properties: CoilProperties object with validated parameters
        """
        self.properties = properties
        self.current = 0.0
        self._inductance = None  # Lazy calculation for performance
    
    @property
    def inductance(self) -> float:
        """
        Calculate inductance only when needed (lazy loading)
        Uses standard solenoid inductance formula
        
        Returns:
            Inductance in Henries
        """
        if self._inductance is None:
            self._inductance = self._calculate_inductance()
        return self._inductance
    
    def _calculate_inductance(self) -> float:
        """
        Calculate inductance using solenoid formula
        L = μ₀ * n² * A * l
        where:
        - μ₀ = permeability of free space (4π × 10⁻⁷ H/m)
        - n = turns per unit length (N/l)
        - A = cross-sectional area (π * r²)
        - l = length
        
        Returns:
            Inductance in Henries
        """
        mu_0 = 4 * np.pi * 1e-7  # Permeability of free space
        radius = self.properties.diameter / 2
        area = np.pi * radius**2
        turns_per_length = self.properties.turns / self.properties.length
        
        inductance = mu_0 * turns_per_length**2 * area * self.properties.length
        return inductance
    
    def set_current(self, current: float):
        """
        Set coil current with business rule validation
        
        Args:
            current: Current in Amperes
            
        Raises:
            ValueError: If current is negative
        """
        if current < 0:
            raise ValueError("Current cannot be negative")
        self.current = current
    
    def get_magnetic_moment(self) -> float:
        """
        Calculate magnetic moment of the coil
        M = N * I * A
        
        Returns:
            Magnetic moment in A⋅m²
        """
        radius = self.properties.diameter / 2
        area = np.pi * radius**2
        return self.properties.turns * self.current * area
    
    def __str__(self) -> str:
        """String representation for debugging"""
        return (f"Coil(turns={self.properties.turns}, "
                f"diameter={self.properties.diameter:.3f}m, "
                f"length={self.properties.length:.3f}m, "
                f"current={self.current:.1f}A)")
    
    def __repr__(self) -> str:
        """Detailed representation for debugging"""
        return (f"Coil(properties={self.properties}, "
                f"current={self.current}, "
                f"inductance={self.inductance:.6e}H)")