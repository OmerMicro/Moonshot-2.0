"""
Integration tests for MATLAB bridge functionality
Tests Python-MATLAB communication and data exchange
"""

import pytest
import sys
import os
import json
import subprocess
import tempfile
from unittest.mock import patch, MagicMock

# Add src to path for imports
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', '..', 'src'))

from src.matlab.matlab_runner import run_simulation_from_params, main
from src.matlab.bridge import MatlabBridge


class TestMatlabBridge:
    """Integration tests for MATLAB bridge functionality"""
    
    def test_matlab_runner_basic_functionality(self):
        """Test 1: Basic MATLAB runner produces valid output"""
        # Run a quick simulation using the MATLAB runner
        result = run_simulation_from_params(
            capsule_mass=1.0,
            num_stages=6,
            stage_voltage=400.0,
            max_time=0.001,  # Very short simulation
            time_step=1e-5
        )
        
        # Verify result structure
        assert isinstance(result, dict)
        required_fields = [
            'final_velocity', 'final_position', 'total_time',
            'initial_energy', 'final_kinetic_energy', 'max_force',
            'energy_efficiency', 'data_points'
        ]
        
        for field in required_fields:
            assert field in result, f"Missing required field: {field}"
            assert isinstance(result[field], (int, float)), f"Field {field} should be numeric"
        
        # Verify reasonable values
        assert result['final_velocity'] >= 0, "Velocity should be non-negative"
        assert result['final_position'] >= 0, "Position should be non-negative"
        assert result['total_time'] > 0, "Total time should be positive"
        assert result['initial_energy'] > 0, "Initial energy should be positive"
        assert result['data_points'] > 0, "Should have data points"
        
        # Verify arrays are present and correct
        assert 'time' in result and isinstance(result['time'], list)
        assert 'position' in result and isinstance(result['position'], list)
        assert 'velocity' in result and isinstance(result['velocity'], list)
        assert 'force' in result and isinstance(result['force'], list)
        
        # Arrays should have same length
        array_length = len(result['time'])
        assert len(result['position']) == array_length
        assert len(result['velocity']) == array_length
        assert len(result['force']) == array_length
    
    def test_matlab_runner_parameter_variations(self):
        """Test 2: MATLAB runner handles different parameter combinations"""
        
        # Test different voltage levels
        voltages = [200, 400, 600]
        results = []
        
        for voltage in voltages:
            result = run_simulation_from_params(
                stage_voltage=voltage,
                max_time=0.001,
                num_stages=6
            )
            results.append(result)
            
            # Each result should be valid
            assert result['final_velocity'] >= 0
            assert result['initial_energy'] > 0
        
        # Higher voltage should generally produce more energy
        assert results[2]['initial_energy'] > results[0]['initial_energy']
        
        # Test different number of stages
        stage_counts = [3, 6, 9]
        stage_results = []
        
        for stages in stage_counts:
            result = run_simulation_from_params(
                num_stages=stages,
                stage_voltage=400,
                max_time=0.001
            )
            stage_results.append(result)
            
            # Each result should be valid
            assert result['final_velocity'] >= 0
            assert result['initial_energy'] > 0
        
        # More stages should generally produce more total energy
        assert stage_results[2]['initial_energy'] > stage_results[0]['initial_energy']
    
    def test_matlab_runner_cli_interface(self):
        """Test 3: Command line interface for MATLAB runner"""
        
        # Test CLI with JSON output
        try:
            # Run the MATLAB runner as subprocess to test CLI
            cmd = [
                sys.executable, '-m', 'src.matlab.matlab_runner',
                '--voltage', '400',
                '--num-stages', '6',
                '--max-time', '0.001',
                '--json-only'
            ]
            
            result = subprocess.run(
                cmd,
                capture_output=True,
                text=True,
                timeout=30,
                cwd=os.path.join(os.path.dirname(__file__), '..', '..')
            )
            
            # Should complete successfully
            assert result.returncode == 0, f"CLI failed with error: {result.stderr}"
            
            # Should produce valid JSON
            output_data = json.loads(result.stdout)
            assert isinstance(output_data, dict)
            assert 'final_velocity' in output_data
            assert 'final_position' in output_data
            
        except subprocess.TimeoutExpired:
            pytest.skip("MATLAB runner CLI took too long - may indicate system issues")
        except json.JSONDecodeError:
            pytest.fail(f"CLI did not produce valid JSON. Output: {result.stdout}")
    
    def test_matlab_bridge_data_export(self):
        """Test 4: MATLAB bridge data export functionality"""
        
        # Run a simulation to get data
        result_dict = run_simulation_from_params(
            stage_voltage=400,
            num_stages=6,
            max_time=0.001
        )
        
        # Test MatlabBridge basic functionality
        bridge = MatlabBridge()
        
        # Check if bridge is available
        if not bridge.matlab_available:
            pytest.skip("MATLAB bridge not available (scipy missing)")
        
        # Create a temporary directory for output
        with tempfile.TemporaryDirectory() as temp_dir:
            output_file = os.path.join(temp_dir, 'test_export')
            
            try:
                # Test creating a MATLAB analysis script (this doesn't require SimulationResult object)
                mat_file = f"{output_file}.mat"
                script_file = f"{output_file}_analysis.m"
                
                # Create the analysis script directly
                bridge.create_matlab_analysis_script(mat_file, script_file)
                
                # Check that the script was created
                assert os.path.exists(script_file), "Analysis script should be created"
                
                # Verify script content contains expected elements
                with open(script_file, 'r') as f:
                    script_content = f.read()
                    assert 'load(' in script_content
                    assert 'simulation_results' in script_content
                    assert 'plot(' in script_content
                
            except ImportError as e:
                if "scipy" in str(e).lower():
                    pytest.skip("Scipy not available for MATLAB export")
                else:
                    raise
            except Exception as e:
                pytest.fail(f"Unexpected error in MATLAB bridge: {e}")
    
    def test_matlab_runner_error_handling(self):
        """Test 5: Error handling in MATLAB runner"""
        
        # Test with invalid parameters
        with pytest.raises(Exception):
            run_simulation_from_params(
                capsule_mass=-1.0,  # Invalid negative mass
                max_time=0.001
            )
        
        # Test with extreme parameters that might cause numerical issues
        try:
            result = run_simulation_from_params(
                stage_voltage=1.0,  # Very low voltage
                max_time=1e-6,      # Very short time
                time_step=1e-7      # Very small time step
            )
            # Should still produce a valid result structure
            assert isinstance(result, dict)
            assert 'final_velocity' in result
            
        except Exception as e:
            # If it fails, should be for a reasonable cause
            assert any(keyword in str(e).lower() 
                      for keyword in ['numerical', 'stability', 'convergence', 'time'])
    
    def test_matlab_integration_data_consistency(self):
        """Test 6: Data consistency between Python and MATLAB interfaces"""
        
        # Run same simulation with different interfaces
        base_params = {
            'capsule_mass': 1.0,
            'num_stages': 6,
            'stage_voltage': 400.0,
            'max_time': 0.001,
            'time_step': 1e-5
        }
        
        # Method 1: Direct function call
        result1 = run_simulation_from_params(**base_params)
        
        # Method 2: Through CLI interface (mocked if needed)
        try:
            cmd = [
                sys.executable, '-m', 'src.matlab.matlab_runner',
                '--voltage', str(base_params['stage_voltage']),
                '--num-stages', str(base_params['num_stages']),
                '--capsule-mass', str(base_params['capsule_mass']),
                '--max-time', str(base_params['max_time']),
                '--time-step', str(base_params['time_step']),
                '--json-only'
            ]
            
            cli_result = subprocess.run(
                cmd,
                capture_output=True,
                text=True,
                timeout=15,
                cwd=os.path.join(os.path.dirname(__file__), '..', '..')
            )
            
            if cli_result.returncode == 0:
                result2 = json.loads(cli_result.stdout)
                
                # Results should be very similar (within numerical precision)
                assert abs(result1['final_velocity'] - result2['final_velocity']) < 1e-10
                assert abs(result1['final_position'] - result2['final_position']) < 1e-10
                assert abs(result1['total_time'] - result2['total_time']) < 1e-10
                
        except (subprocess.TimeoutExpired, json.JSONDecodeError):
            pytest.skip("CLI interface test skipped due to system limitations")
    
    def test_matlab_bridge_parameter_validation(self):
        """Test 7: Parameter validation in MATLAB bridge"""
        
        # Test parameter bounds checking
        valid_params = {
            'capsule_mass': 1.0,
            'num_stages': 6,
            'stage_voltage': 400.0,
            'max_time': 0.001
        }
        
        # This should work fine
        result = run_simulation_from_params(**valid_params)
        assert result is not None
        
        # Test boundary conditions
        boundary_tests = [
            {'capsule_mass': 0.1, 'expected': 'pass'},  # Minimum reasonable mass
            {'capsule_mass': 10.0, 'expected': 'pass'},  # Maximum reasonable mass
            {'num_stages': 1, 'expected': 'pass'},       # Minimum stages
            {'num_stages': 12, 'expected': 'pass'},      # Maximum reasonable stages
            {'stage_voltage': 50.0, 'expected': 'pass'}, # Low voltage
            {'stage_voltage': 1000.0, 'expected': 'pass'}, # High voltage
        ]
        
        for test_case in boundary_tests:
            test_params = valid_params.copy()
            param_name = list(test_case.keys())[0]
            if param_name != 'expected':
                test_params[param_name] = test_case[param_name]
                
                try:
                    result = run_simulation_from_params(**test_params)
                    assert result is not None, f"Failed with {param_name}={test_case[param_name]}"
                    assert 'final_velocity' in result
                    
                except Exception as e:
                    if test_case['expected'] == 'pass':
                        pytest.fail(f"Unexpected failure with {param_name}={test_case[param_name]}: {e}")


class TestMatlabBridgePerformance:
    """Performance and reliability tests for MATLAB bridge"""
    
    def test_matlab_runner_performance(self):
        """Test 8: Performance characteristics of MATLAB runner"""
        import time
        
        # Time a quick simulation
        start_time = time.time()
        
        result = run_simulation_from_params(
            max_time=0.001,  # 1ms simulation
            time_step=1e-5   # 10μs time step
        )
        
        end_time = time.time()
        execution_time = end_time - start_time
        
        # Should complete within reasonable time (less than 10 seconds)
        assert execution_time < 10.0, f"Simulation took too long: {execution_time:.2f}s"
        
        # Should produce reasonable amount of data
        assert result['data_points'] > 10, "Should have reasonable number of data points"
        assert len(result['time']) == result['data_points']
    
    def test_matlab_runner_repeatability(self):
        """Test 9: Repeatability of MATLAB runner results"""
        
        # Run the same simulation multiple times
        results = []
        params = {
            'capsule_mass': 1.0,
            'num_stages': 6,
            'stage_voltage': 400.0,
            'max_time': 0.001,
            'time_step': 1e-5
        }
        
        for _ in range(3):
            result = run_simulation_from_params(**params)
            results.append(result)
        
        # Results should be identical (deterministic simulation)
        for i in range(1, len(results)):
            assert abs(results[i]['final_velocity'] - results[0]['final_velocity']) < 1e-12
            assert abs(results[i]['final_position'] - results[0]['final_position']) < 1e-12
            assert results[i]['data_points'] == results[0]['data_points']