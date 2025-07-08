"""
AccelerationStage class - Inherits from Coil (Open/Closed Principle)
Represents electromagnetic coils that accelerate the capsule
"""

import numpy as np
from typing import Optional
from .coil import Coil, CoilProperties


class AccelerationStage(Coil):
    """
    AccelerationStage class representing electromagnetic acceleration coils
    
    Follows SOLID principles:
    - Single Responsibility: Manages electromagnetic coil behavior + timing/control
    - Open/Closed: Extends Coil without modifying it
    - Liskov Substitution: Can be used anywhere a Coil is expected
    """
    
    def __init__(self, stage_id: int, position: float, turns: int, 
                 diameter: float, length: float, capacitance: float, voltage: float):
        """
        Initialize acceleration stage with electromagnetic and electrical properties
        
        Args:
            stage_id: Unique identifier for this stage
            position: Position along the tube in meters
            turns: Number of wire turns in the coil
            diameter: Coil diameter in meters
            length: Coil length in meters
            capacitance: Capacitor capacitance in Farads
            voltage: Initial capacitor voltage in Volts
        """
        # Calculate copper wire resistance
        resistance = self._calculate_copper_resistance(turns, diameter, length)
        
        # Create coil properties
        props = CoilProperties(
            turns=turns,
            diameter=diameter,
            length=length,
            resistance=resistance,
            position=position
        )
        
        # Initialize parent Coil
        super().__init__(props)
        
        # AccelerationStage-specific properties
        self.stage_id = stage_id
        self.capacitance = capacitance
        self.voltage = voltage
        self.activation_time: Optional[float] = None
        self.is_active = False
    
    def _calculate_copper_resistance(self, turns: int, diameter: float, length: float) -> float:
        """
        Calculate resistance of copper wire in the coil
        
        Uses standard formula:
        R = ρ * L / A
        where:
        - ρ = resistivity of copper (1.68e-8 Ω⋅m)
        - L = total wire length
        - A = wire cross-sectional area
        
        Args:
            turns: Number of wire turns
            diameter: Coil diameter in meters
            length: Coil length in meters
            
        Returns:
            Wire resistance in ohms
        """
        # Copper properties
        rho_copper = 1.68e-8  # Ω⋅m
        
        # Assume reasonable wire gauge (e.g., 14 AWG)
        wire_diameter = 1.628e-3  # meters (14 AWG)
        wire_area = np.pi * (wire_diameter / 2)**2
        
        # Calculate total wire length
        # Approximate: each turn has circumference ≈ π * coil_diameter
        wire_length_per_turn = np.pi * diameter
        total_wire_length = turns * wire_length_per_turn
        
        # Calculate resistance
        resistance = rho_copper * total_wire_length / wire_area
        return resistance
    
    def activate(self, time: float):
        """
        Activate the acceleration stage at specified time
        
        Args:
            time: Activation time in seconds
        """
        self.activation_time = time
        self.is_active = True
    
    def get_current(self, time: float) -> float:
        """
        Calculate current based on RLC circuit discharge
        
        Args:
            time: Current time in seconds
            
        Returns:
            Current in Amperes
        """
        if not self.is_active or self.activation_time is None or time < self.activation_time:
            return 0.0
        
        # Time since activation
        dt = time - self.activation_time
        
        # RLC circuit parameters
        L = self.inductance
        C = self.capacitance
        R = self.properties.resistance
        
        # Calculate circuit characteristics
        omega_0 = 1 / np.sqrt(L * C)  # Natural frequency
        alpha = R / (2 * L)  # Damping coefficient
        
        # Determine circuit type and calculate current
        if alpha < omega_0:
            # Underdamped oscillation
            omega_d = np.sqrt(omega_0**2 - alpha**2)  # Damped frequency
            
            # Current in underdamped RLC: I(t) = (V₀/ωₐL) * e^(-αt) * sin(ωₐt)
            current = (self.voltage / (omega_d * L)) * np.exp(-alpha * dt) * np.sin(omega_d * dt)
        elif alpha == omega_0:
            # Critically damped
            current = (self.voltage / L) * dt * np.exp(-alpha * dt)
        else:
            # Overdamped - minimal oscillation
            current = 0.0
        
        # Ensure current is non-negative (simplified model)
        return max(0.0, current)
    
    def get_current_derivative(self, time: float) -> float:
        """
        Calculate time derivative of current (dI/dt) for EMF calculations
        
        Args:
            time: Current time in seconds
            
        Returns:
            Current derivative in Amperes per second
        """
        if not self.is_active or self.activation_time is None or time < self.activation_time:
            return 0.0
        
        # Time since activation
        dt = time - self.activation_time
        
        # RLC circuit parameters
        L = self.inductance
        C = self.capacitance
        R = self.properties.resistance
        
        # Calculate circuit characteristics
        omega_0 = 1 / np.sqrt(L * C)  # Natural frequency
        alpha = R / (2 * L)  # Damping coefficient
        
        # Determine circuit type and calculate current derivative
        if alpha < omega_0:
            # Underdamped oscillation
            omega_d = np.sqrt(omega_0**2 - alpha**2)  # Damped frequency
            
            # dI/dt for underdamped RLC
            # I(t) = (V₀/ωₐL) * e^(-αt) * sin(ωₐt)
            # dI/dt = (V₀/ωₐL) * e^(-αt) * [ωₐ*cos(ωₐt) - α*sin(ωₐt)]
            amplitude = self.voltage / (omega_d * L)
            exp_term = np.exp(-alpha * dt)
            cos_term = omega_d * np.cos(omega_d * dt)
            sin_term = alpha * np.sin(omega_d * dt)
            
            derivative = amplitude * exp_term * (cos_term - sin_term)
        elif alpha == omega_0:
            # Critically damped
            # I(t) = (V₀/L) * t * e^(-αt)
            # dI/dt = (V₀/L) * e^(-αt) * (1 - αt)
            derivative = (self.voltage / L) * np.exp(-alpha * dt) * (1 - alpha * dt)
        else:
            # Overdamped - minimal current change
            derivative = 0.0
        
        return derivative
    
    @property
    def stored_energy(self) -> float:
        """
        Calculate energy stored in the capacitor
        
        Returns:
            Stored energy in Joules (E = 0.5 * C * V²)
        """
        return 0.5 * self.capacitance * self.voltage**2
    
    def get_stored_energy(self) -> float:
        """
        Calculate energy stored in the capacitor (method version for compatibility)
        
        Returns:
            Stored energy in Joules (E = 0.5 * C * V²)
        """
        return self.stored_energy
    
    def get_energy_transferred(self, time: float) -> float:
        """
        Calculate energy transferred from capacitor up to given time
        
        Args:
            time: Time in seconds
            
        Returns:
            Energy transferred in Joules
        """
        if not self.is_active or self.activation_time is None or time < self.activation_time:
            return 0.0
        
        # Simplified calculation - in real system would integrate I²R losses
        # For now, assume exponential decay based on RC time constant
        dt = time - self.activation_time
        tau = self.properties.resistance * self.capacitance
        
        initial_energy = self.get_stored_energy()
        remaining_energy = initial_energy * np.exp(-dt / tau)
        
        return initial_energy - remaining_energy
    
    def reset(self):
        """Reset stage to initial state"""
        self.is_active = False
        self.activation_time = None
        self.current = 0.0
    
    def __str__(self) -> str:
        """String representation for debugging"""
        status = "Active" if self.is_active else "Inactive"
        return (f"AccelerationStage(id={self.stage_id}, "
                f"position={self.properties.position:.3f}m, "
                f"turns={self.properties.turns}, "
                f"voltage={self.voltage:.0f}V, "
                f"status={status})")
    
    def __repr__(self) -> str:
        """Detailed representation for debugging"""
        return (f"AccelerationStage(stage_id={self.stage_id}, "
                f"properties={self.properties}, "
                f"capacitance={self.capacitance}, "
                f"voltage={self.voltage}, "
                f"is_active={self.is_active}, "
                f"stored_energy={self.get_stored_energy():.3f}J)")