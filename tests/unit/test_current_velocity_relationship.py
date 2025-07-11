"""
Tests for current vs velocity relationship in electromagnetic gun simulation.

Validates that higher stage currents lead to higher final velocities.
"""

import pytest
import sys
import os
import numpy as np

# Add src to path for imports
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', '..', 'src'))

from src.core.capsule import Capsule
from src.core.acceleration_stage import AccelerationStage
from src.services.simulation_service import SimulationService


class TestCurrentVelocityRelationship:
    """Test current vs velocity relationship for electromagnetic gun physics."""
    
    @pytest.fixture
    def base_simulation_setup(self):
        """Create base simulation setup for current testing."""
        # Create capsule starting close to first stage
        capsule = Capsule(mass=1.0, diameter=0.083, length=0.02)
        capsule.update_position(0.02)  # Start 2cm from beginning
        
        return capsule
    
    def create_simulation_with_voltage(self, voltage: float):
        """Create simulation with specified stage voltage (affects current)."""
        capsule = Capsule(mass=1.0, diameter=0.083, length=0.02)
        capsule.update_position(0.02)  # Start close to first stage
        
        # Create single stage with specified voltage
        stage = AccelerationStage(
            stage_id=0,
            position=0.05,  # 5cm position
            turns=100,
            diameter=0.09,
            length=0.05,
            capacitance=1000e-6,  # 1000µF
            voltage=voltage  # Variable voltage affects current
        )
        
        return SimulationService(capsule, [stage], tube_length=0.2, dt=1e-5)
    
    def test_higher_voltage_gives_higher_velocity(self):
        """Test that higher stage voltage (current) leads to higher final velocity."""
        voltages = [200.0, 400.0, 800.0]  # Increasing voltage levels
        final_velocities = []
        max_forces = []
        
        for voltage in voltages:
            service = self.create_simulation_with_voltage(voltage)
            result = service.run(max_time=5.0)
            
            final_velocities.append(result.final_velocity)
            max_forces.append(result.max_force)
            
            print(f"Voltage: {voltage}V -> Final Velocity: {result.final_velocity:.4f} m/s, Max Force: {result.max_force:.2f} N")
        
        # Verify increasing trend
        assert final_velocities[1] > final_velocities[0], f"400V velocity {final_velocities[1]} should be > 200V velocity {final_velocities[0]}"
        assert final_velocities[2] > final_velocities[1], f"800V velocity {final_velocities[2]} should be > 400V velocity {final_velocities[1]}"
        
        # Verify force also increases
        assert max_forces[1] > max_forces[0], f"400V force {max_forces[1]} should be > 200V force {max_forces[0]}"
        assert max_forces[2] > max_forces[1], f"800V force {max_forces[2]} should be > 400V force {max_forces[1]}"
    
    def test_current_scaling_with_voltage(self):
        """Test that stage current scales properly with voltage."""
        voltages = [100.0, 200.0, 400.0]
        stage_currents = []
        
        for voltage in voltages:
            # Create single stage with voltage
            stage = AccelerationStage(
                stage_id=0,
                position=0.05,
                turns=100,
                diameter=0.09,
                length=0.05,
                capacitance=1000e-6,
                voltage=voltage
            )
            
            # Activate and measure current at peak (early time)
            stage.activate(0.0)
            current_at_peak = stage.get_current(0.0005)  # 0.5ms after activation
            stage_currents.append(current_at_peak)
            
            print(f"Voltage: {voltage}V -> Peak Current: {current_at_peak:.1f} A")
        
        # Current should scale with voltage (approximately linear for RLC circuit)
        current_ratio_1 = stage_currents[1] / stage_currents[0]  # 200V/100V
        current_ratio_2 = stage_currents[2] / stage_currents[1]  # 400V/200V
        
        # Should be approximately 2x scaling
        assert 1.5 < current_ratio_1 < 2.5, f"Current ratio {current_ratio_1} should be ~2"
        assert 1.5 < current_ratio_2 < 2.5, f"Current ratio {current_ratio_2} should be ~2"
    
    def test_multiple_stages_cumulative_effect(self):
        """Test that multiple stages provide cumulative acceleration."""
        # Test with 1, 2, and 3 stages
        stage_counts = [1, 2, 3]
        final_velocities = []
        
        for num_stages in stage_counts:
            capsule = Capsule(mass=1.0, diameter=0.083, length=0.02)
            capsule.update_position(0.02)
            
            stages = []
            for i in range(num_stages):
                stage = AccelerationStage(
                    stage_id=i,
                    position=0.05 + (i * 0.08),  # 5cm, 13cm, 21cm
                    turns=100,
                    diameter=0.09,
                    length=0.05,
                    capacitance=1000e-6,
                    voltage=400.0
                )
                stages.append(stage)
            
            service = SimulationService(capsule, stages, tube_length=0.4, dt=1e-5)
            result = service.run(max_time=0.02)  # Longer time for multiple stages
            
            final_velocities.append(result.final_velocity)
            print(f"{num_stages} stages -> Final Velocity: {result.final_velocity:.4f} m/s")
        
        # More stages should give higher velocity (cumulative effect)
        assert final_velocities[1] >= final_velocities[0], "2 stages should be >= 1 stage"
        assert final_velocities[2] >= final_velocities[1], "3 stages should be >= 2 stages"
    
    def test_energy_conservation_with_different_currents(self):
        """Test energy conservation principle with different current levels."""
        voltages = [200.0, 400.0]
        energy_efficiencies = []
        
        for voltage in voltages:
            service = self.create_simulation_with_voltage(voltage)
            result = service.run(max_time=0.01)
            
            energy_efficiencies.append(result.energy_efficiency)
            
            # Energy efficiency should be reasonable (0-100%)
            assert 0 <= result.energy_efficiency <= 1.0, f"Energy efficiency {result.energy_efficiency} should be 0-100%"
            
            print(f"Voltage: {voltage}V -> Energy Efficiency: {result.energy_efficiency:.1%}")
        
        # Higher voltage might have different efficiency, but should be reasonable
        for efficiency in energy_efficiencies:
            assert efficiency >= 0, "Energy efficiency should be non-negative"
    
    def test_simulation_termination_conditions(self):
        """Test that simulation properly terminates on time or position limits."""
        # Test 1: Time limit termination
        service = self.create_simulation_with_voltage(400.0)
        result = service.run(max_time=0.001)  # Very short time
        
        assert result.total_time <= 0.001, "Should terminate on time limit"
        
        # Test 2: Position limit termination (capsule leaves tube)
        capsule = Capsule(mass=0.1, diameter=0.083, length=0.02)  # Lighter capsule
        capsule.update_position(0.15)  # Start near end of short tube
        
        stage = AccelerationStage(
            stage_id=0,
            position=0.16,
            turns=100,
            diameter=0.09,
            length=0.05,
            capacitance=1000e-6,
            voltage=800.0  # High voltage for quick acceleration
        )
        
        service = SimulationService(capsule, [stage], tube_length=0.2, dt=1e-5)  # Short tube
        result = service.run(max_time=1.0)  # Long time limit
        
        # Should terminate when capsule leaves tube, not on time
        assert result.final_position >= 0.2, "Capsule should have left the tube"
        assert result.total_time < 1.0, "Should terminate on position, not time"
        
        print(f"Capsule exit: Position={result.final_position:.3f}m, Time={result.total_time*1000:.1f}ms")


if __name__ == "__main__":
    # Run individual test
    test = TestCurrentVelocityRelationship()
    test.test_higher_voltage_gives_higher_velocity()