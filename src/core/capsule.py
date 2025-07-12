"""
Capsule class - Inherits from Coil (Open/Closed Principle)
Represents the conductive projectile being accelerated
"""

import numpy as np
from .coil import Coil, CoilProperties


class Capsule(Coil):
    """
    Capsule class representing the projectile being accelerated
    
    Follows SOLID principles:
    - Single Responsibility: Manages capsule-specific behavior (motion + electromagnetic properties)
    - Open/Closed: Extends Coil without modifying it
    - Liskov Substitution: Can be used anywhere a Coil is expected
    """
    
    def __init__(self, mass: float, diameter: float, length: float):
        """
        Initialize capsule with mass and geometric properties
        
        Args:
            mass: Mass of capsule in kg
            diameter: Diameter in meters
            length: Length in meters
            
        Raises:
            ValueError: If mass is not positive
        """
        # Business rule validation
        if mass <= 0:
            raise ValueError("Mass must be positive")
        
        # Calculate resistance for aluminum cylinder
        resistance = self._calculate_resistance(diameter, length)
        
        # Create properties for single-turn conductor
        props = CoilProperties(
            turns=1,  # Single turn conductive loop
            diameter=diameter,
            length=length,
            resistance=resistance,
            position=0.0
        )
        
        # Initialize parent Coil
        super().__init__(props)
        
        # Capsule-specific properties
        self.mass = mass
        self.position = 0.0
        self.velocity = 0.0
    
    def _calculate_resistance(self, diameter: float, length: float) -> float:
        """
        Calculate resistance of aluminum cylinder
        
        Uses simplified model:
        R = ρ * L / A
        where:
        - ρ = resistivity of aluminum (2.65e-8 Ω⋅m)
        - L = current path length (approximated as circumference)
        - A = effective cross-sectional area for current flow
        
        Args:
            diameter: Cylinder diameter in meters
            length: Cylinder length in meters
            
        Returns:
            Resistance in ohms
        """
        rho_aluminum = 2.65e-8  # Ω⋅m
        
        # Simplified model: current flows around circumference
        current_path = np.pi * diameter  # Circumference
        
        # Effective area for current flow (wall thickness approximation)
        wall_thickness = 0.01  # 1cm wall thickness for more realistic induced current
        effective_area = np.pi * diameter * wall_thickness
        
        resistance = rho_aluminum * current_path / effective_area
        return resistance
    
    def update_position(self, new_position: float):
        """
        Update capsule position
        
        Args:
            new_position: New position in meters
        """
        self.position = new_position
        self.properties = CoilProperties(
            turns=self.properties.turns,
            diameter=self.properties.diameter,
            length=self.properties.length,
            resistance=self.properties.resistance,
            position=new_position
        )
    
    def update_velocity(self, new_velocity: float):
        """
        Update capsule velocity
        
        Args:
            new_velocity: New velocity in m/s
        """
        self.velocity = new_velocity
    
    def get_kinetic_energy(self) -> float:
        """
        Calculate kinetic energy of capsule
        
        Returns:
            Kinetic energy in Joules (KE = 0.5 * m * v²)
        """
        return 0.5 * self.mass * self.velocity**2
    
    def get_momentum(self) -> float:
        """
        Calculate momentum of capsule
        
        Returns:
            Momentum in kg⋅m/s (p = m * v)
        """
        return self.mass * self.velocity
    
    def apply_force(self, force: float, time_step: float):
        """
        Apply force for given time step using basic kinematics
        
        Args:
            force: Applied force in Newtons
            time_step: Time step in seconds
        """
        # F = ma, so a = F/m
        acceleration = force / self.mass
        
        # Update velocity: v = v₀ + at
        self.velocity += acceleration * time_step
        
        # Update position: x = x₀ + v₀t + 0.5at²
        self.position += self.velocity * time_step + 0.5 * acceleration * time_step**2
        
        # Update properties position
        self.update_position(self.position)
    
    def __str__(self) -> str:
        """String representation for debugging"""
        return (f"Capsule(mass={self.mass:.3f}kg, "
                f"diameter={self.properties.diameter:.3f}m, "
                f"length={self.properties.length:.3f}m, "
                f"position={self.position:.3f}m, "
                f"velocity={self.velocity:.1f}m/s)")
    
    def __repr__(self) -> str:
        """Detailed representation for debugging"""
        return (f"Capsule(mass={self.mass}, "
                f"properties={self.properties}, "
                f"position={self.position}, "
                f"velocity={self.velocity}, "
                f"kinetic_energy={self.get_kinetic_energy():.3f}J)")