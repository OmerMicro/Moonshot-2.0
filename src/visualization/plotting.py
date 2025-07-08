o i"""
Simple plotting service for electromagnetic gun simulation.

Quick implementation for basic visualization.
"""

import matplotlib.pyplot as plt
import numpy as np


class PlottingService:
    """Basic plotting service for simulation results."""
    
    def __init__(self):
        """Initialize plotting service."""
        self.fig_size = (12, 8)
        self.dpi = 100
    
    def plot_simulation_results(self, result, save_path=None, show=True):
        """
        Create comprehensive plot of simulation results.
        
        Args:
            result: SimulationResult object
            save_path: Optional path to save plot
            show: Whether to display plot
        """
        # Create figure with subplots
        fig, ((ax1, ax2), (ax3, ax4)) = plt.subplots(2, 2, figsize=self.fig_size, dpi=self.dpi)
        fig.suptitle('Electromagnetic Gun Simulation Results', fontsize=16)
        
        # Get data arrays
        times = result.get_time_array() * 1000  # Convert to ms
        positions = result.get_position_array() * 1000  # Convert to mm
        velocities = result.get_velocity_array()
        forces = result.get_force_array()
        energies = result.get_energy_array()
        
        # Plot 1: Position vs Time
        ax1.plot(times, positions, 'b-', linewidth=2, label='Position')
        ax1.set_xlabel('Time (ms)')
        ax1.set_ylabel('Position (mm)')
        ax1.set_title('Capsule Position')
        ax1.grid(True, alpha=0.3)
        ax1.legend()
        
        # Plot 2: Velocity vs Time
        ax2.plot(times, velocities, 'r-', linewidth=2, label='Velocity')
        ax2.set_xlabel('Time (ms)')
        ax2.set_ylabel('Velocity (m/s)')
        ax2.set_title('Capsule Velocity')
        ax2.grid(True, alpha=0.3)
        ax2.legend()
        
        # Plot 3: Force vs Time
        ax3.plot(times, forces, 'g-', linewidth=2, label='Force')
        ax3.set_xlabel('Time (ms)')
        ax3.set_ylabel('Force (N)')
        ax3.set_title('Electromagnetic Force')
        ax3.grid(True, alpha=0.3)
        ax3.legend()
        
        # Plot 4: Energy vs Time
        ax4.plot(times, energies, 'm-', linewidth=2, label='Kinetic Energy')
        ax4.set_xlabel('Time (ms)')
        ax4.set_ylabel('Energy (J)')
        ax4.set_title('Kinetic Energy')
        ax4.grid(True, alpha=0.3)
        ax4.legend()
        
        # Add summary text
        summary_text = (f"Final Velocity: {result.final_velocity:.2f} m/s\n"
                       f"Final Position: {result.final_position*1000:.1f} mm\n"
                       f"Max Force: {result.max_force:.1f} N\n"
                       f"Efficiency: {result.energy_efficiency:.1%}")
        
        fig.text(0.02, 0.02, summary_text, fontsize=10, 
                bbox=dict(boxstyle="round,pad=0.3", facecolor="lightgray"))
        
        plt.tight_layout()
        
        # Save if requested
        if save_path:
            plt.savefig(save_path, dpi=300, bbox_inches='tight')
            print(f"Plot saved to: {save_path}")
        
        # Show if requested
        if show:
            plt.show()
        
        return fig
    
    def plot_simple_trajectory(self, result, save_path=None, show=True):
        """
        Simple trajectory plot.
        
        Args:
            result: SimulationResult object
            save_path: Optional path to save plot
            show: Whether to display plot
        """
        plt.figure(figsize=(10, 6))
        
        times = result.get_time_array() * 1000
        positions = result.get_position_array() * 1000
        
        plt.plot(times, positions, 'b-', linewidth=3, label='Capsule Position')
        plt.xlabel('Time (ms)', fontsize=12)
        plt.ylabel('Position (mm)', fontsize=12)
        plt.title('Electromagnetic Gun - Capsule Trajectory', fontsize=14)
        plt.grid(True, alpha=0.3)
        plt.legend(fontsize=12)
        
        # Add final velocity annotation
        plt.text(0.02, 0.98, f"Final Velocity: {result.final_velocity:.2f} m/s", 
                transform=plt.gca().transAxes, fontsize=12,
                bbox=dict(boxstyle="round,pad=0.3", facecolor="yellow", alpha=0.7),
                verticalalignment='top')
        
        plt.tight_layout()
        
        if save_path:
            plt.savefig(save_path, dpi=300, bbox_inches='tight')
        if show:
            plt.show()
    
    def plot_stage_analysis(self, result, stages, save_path=None, show=True):
        """
        Plot stage activation and current analysis.
        
        Args:
            result: SimulationResult object  
            stages: List of acceleration stages
            save_path: Optional path to save plot
            show: Whether to display plot
        """
        fig, (ax1, ax2) = plt.subplots(2, 1, figsize=(12, 8))
        
        times = result.get_time_array() * 1000
        
        # Plot 1: Stage positions and capsule trajectory
        positions = result.get_position_array() * 1000
        ax1.plot(times, positions, 'b-', linewidth=3, label='Capsule Position')
        
        # Add stage positions as horizontal lines
        for i, stage in enumerate(stages):
            stage_pos = stage.properties.position * 1000
            ax1.axhline(y=stage_pos, color='red', linestyle='--', alpha=0.7, 
                       label=f'Stage {i+1}' if i == 0 else '')
            ax1.text(max(times) * 0.8, stage_pos + 5, f'S{i+1}', 
                    fontsize=10, color='red')
        
        ax1.set_xlabel('Time (ms)')
        ax1.set_ylabel('Position (mm)')
        ax1.set_title('Capsule Movement Through Stages')
        ax1.grid(True, alpha=0.3)
        ax1.legend()
        
        # Plot 2: Force and current analysis
        forces = result.get_force_array()
        ax2.plot(times, forces, 'g-', linewidth=2, label='Total Force')
        ax2.set_xlabel('Time (ms)')
        ax2.set_ylabel('Force (N)')
        ax2.set_title('Electromagnetic Force Profile')
        ax2.grid(True, alpha=0.3)
        ax2.legend()
        
        plt.tight_layout()
        
        if save_path:
            plt.savefig(save_path, dpi=300, bbox_inches='tight')
        if show:
            plt.show()
        
        return fig


def quick_plot(result, title="Simulation Results"):
    """Quick plotting function for immediate visualization."""
    plotting = PlottingService()
    plotting.plot_simple_trajectory(result)