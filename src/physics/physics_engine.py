"""
PhysicsEngine class - Decoupled physics calculations
Follows Single Responsibility and Dependency Inversion principles
"""

import numpy as np
from typing import TYPE_CHECKING

if TYPE_CHECKING:
    from ..core.coil import Coil
    from ..core.capsule import Capsule


class PhysicsEngine:
    """
    Centralized physics engine for electromagnetic calculations
    
    Follows SOLID principles:
    - Single Responsibility: Only handles physics calculations
    - Dependency Inversion: Core classes depend on this abstraction
    - Interface Segregation: Focused on electromagnetic physics only
    """
    
    def __init__(self):
        """Initialize physics engine with fundamental constants"""
        self.mu_0 = 4 * np.pi * 1e-7  # Permeability of free space (H/m)
    
    def calculate_mutual_inductance(self, coil1: 'Coil', coil2: 'Coil', distance: float) -> float:
        """
        Calculate mutual inductance between two coils
        
        Uses simplified analytical approximations suitable for simulation:
        - Overlapping case: when coils are close together
        - Far-field case: when coils are well separated
        
        Args:
            coil1: First coil
            coil2: Second coil
            distance: Distance between coil centers in meters
            
        Returns:
            Mutual inductance in Henries
            
        Raises:
            ValueError: If distance is negative
        """
        if distance < 0:
            raise ValueError("Distance cannot be negative")
        
        # Get coil properties
        r1 = coil1.properties.diameter / 2
        r2 = coil2.properties.diameter / 2
        
        # Choose calculation method based on distance
        if distance < max(coil1.properties.length, coil2.properties.length):
            # Overlapping case - use overlap-based approximation
            return self._calculate_overlapping_inductance(coil1, coil2, distance)
        else:
            # Far-field case - use dipole approximation
            return self._calculate_far_field_inductance(coil1, coil2, distance)
    
    def _calculate_overlapping_inductance(self, coil1: 'Coil', coil2: 'Coil', distance: float) -> float:
        """
        Calculate mutual inductance for overlapping/close coils
        
        Uses overlap factor to estimate coupling strength
        """
        r1 = coil1.properties.diameter / 2
        r2 = coil2.properties.diameter / 2
        
        # Use the larger coil's length for overlap calculation
        reference_length = max(coil1.properties.length, coil2.properties.length)
        
        # Calculate overlap factor (1 = complete overlap, 0 = no overlap)
        overlap = max(0, 1 - distance / reference_length)
        
        # Mutual inductance approximation for close coils
        # M ≈ μ₀ * √(r₁ * r₂) * √(N₁ * N₂) * overlap_factor
        # This ensures symmetry in the calculation
        mutual_inductance = (self.mu_0 * np.sqrt(r1 * r2) * 
                           np.sqrt(coil1.properties.turns * coil2.properties.turns) * overlap)
        
        return mutual_inductance
    
    def _calculate_far_field_inductance(self, coil1: 'Coil', coil2: 'Coil', distance: float) -> float:
        """
        Calculate mutual inductance for separated coils using dipole approximation
        
        Symmetric far-field approximation: M ≈ μ₀ * π * r₁² * r₂² * √(N₁ * N₂) / d³
        """
        r1 = coil1.properties.diameter / 2
        r2 = coil2.properties.diameter / 2
        
        # Symmetric far-field mutual inductance
        mutual_inductance = (self.mu_0 * np.pi * r1**2 * r2**2 * 
                           np.sqrt(coil1.properties.turns * coil2.properties.turns)) / (distance**3)
        
        return mutual_inductance
    
    def calculate_force(self, coil1: 'Coil', coil2: 'Coil', distance: float, 
                       current1: float, current2: float) -> float:
        """
        Calculate electromagnetic force between two current-carrying coils
        
        Uses the formula: F = I₁ * I₂ * dM/dx
        where dM/dx is the gradient of mutual inductance
        
        The force is calculated symmetrically to ensure F₁₂ = F₂₁
        
        Args:
            coil1: First coil
            coil2: Second coil  
            distance: Distance between coils in meters
            current1: Current in first coil in Amperes
            current2: Current in second coil in Amperes
            
        Returns:
            Force in Newtons (positive = attractive)
        """
        # Handle zero current cases
        if current1 == 0.0 or current2 == 0.0:
            return 0.0
        
        # Calculate gradient of mutual inductance using numerical differentiation
        dx = 0.001  # 1mm displacement for gradient calculation
        
        # Calculate mutual inductance at x + dx/2 and x - dx/2
        # Note: mutual inductance is symmetric, so we use the same calculation
        # regardless of coil order
        m_plus = self.calculate_mutual_inductance(coil1, coil2, distance + dx/2)
        m_minus = self.calculate_mutual_inductance(coil1, coil2, distance - dx/2)
        
        # Calculate gradient: dM/dx
        dm_dx = (m_plus - m_minus) / dx
        
        # Calculate force: F = I₁ * I₂ * dM/dx
        # This formula is inherently symmetric in I₁ and I₂
        # For electromagnetic gun, force should be attractive (negative gradient)
        # Invert sign to ensure proper force direction
        force = -current1 * current2 * dm_dx
        
        return force
    
    def update_kinematics(self, capsule: 'Capsule', force: float, dt: float):
        """
        Update capsule kinematics using Verlet integration
        
        Verlet integration is more stable than Euler method for dynamics
        
        Args:
            capsule: Capsule object to update
            force: Applied force in Newtons
            dt: Time step in seconds
        """
        # Calculate acceleration from Newton's second law: F = ma
        acceleration = force / capsule.mass
        
        # Verlet integration for better numerical stability
        # x(t+dt) = x(t) + v(t)*dt + 0.5*a*dt²
        new_position = capsule.position + capsule.velocity * dt + 0.5 * acceleration * dt**2
        
        # v(t+dt) = v(t) + a*dt
        new_velocity = capsule.velocity + acceleration * dt
        
        # Update capsule state
        capsule.update_position(new_position)
        capsule.update_velocity(new_velocity)
    
    def calculate_energy_transfer(self, coil1: 'Coil', coil2: 'Coil', 
                                 current1: float, current2: float, 
                                 current1_rate: float, current2_rate: float,
                                 time_step: float) -> float:
        """
        Calculate energy transfer between coils due to mutual inductance
        
        Uses proper electromagnetic energy transfer physics:
        P = I₁ * (M * dI₂/dt) + I₂ * (M * dI₁/dt)
        Energy = P * dt
        
        Args:
            coil1: First coil
            coil2: Second coil
            current1: Current in first coil (A)
            current2: Current in second coil (A)
            current1_rate: Time derivative of current1 (A/s)
            current2_rate: Time derivative of current2 (A/s)
            time_step: Time step for calculation (s)
            
        Returns:
            Energy transfer in Joules
        """
        if abs(current1) < 1e-6 and abs(current2) < 1e-6:
            return 0.0
            
        # Calculate mutual inductance between coils
        distance = abs(coil1.properties.position - coil2.properties.position)
        mutual_inductance = self.calculate_mutual_inductance(coil1, coil2, distance)
        
        # Power transfer due to mutual inductance coupling
        # P = I₁ * (M * dI₂/dt) + I₂ * (M * dI₁/dt)
        # This represents the power exchanged due to changing magnetic flux
        power_12 = current1 * mutual_inductance * current2_rate  # Power from coil2 affecting coil1
        power_21 = current2 * mutual_inductance * current1_rate  # Power from coil1 affecting coil2
        
        total_power = power_12 + power_21
        
        # Energy transfer over time step
        energy_transfer = abs(total_power * time_step)
        
        return energy_transfer
    
    def validate_physics_constants(self) -> bool:
        """
        Validate that physics constants are correct
        
        Returns:
            True if constants are valid
        """
        # Check permeability of free space
        expected_mu_0 = 4 * np.pi * 1e-7
        return abs(self.mu_0 - expected_mu_0) < 1e-12
    
    def __str__(self) -> str:
        """String representation for debugging"""
        return f"PhysicsEngine(μ₀={self.mu_0:.6e} H/m)"
    
    def __repr__(self) -> str:
        """Detailed representation for debugging"""
        return f"PhysicsEngine(mu_0={self.mu_0})"