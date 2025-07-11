"""
Setup file for Electromagnetic Gun Simulation package.
Enables MATLAB integration and standalone compilation.
"""

from setuptools import setup, find_packages
import os

# Read README for long description
def read_readme():
    with open("README_QUICK_START.md", "r", encoding="utf-8") as f:
        return f.read()

# Read requirements
def read_requirements():
    with open("requirements.txt", "r", encoding="utf-8") as f:
        return [line.strip() for line in f if line.strip() and not line.startswith("#")]

setup(
    name="electromagnetic-gun-simulation",
    version="1.0.0",
    author="Moonshot AI Team",
    description="Electromagnetic gun simulation with MATLAB integration",
    long_description=read_readme(),
    long_description_content_type="text/markdown",
    
    packages=find_packages(),
    package_data={
        "src": ["**/*.py"],
    },
    include_package_data=True,
    
    install_requires=read_requirements(),
    
    entry_points={
        "console_scripts": [
            "emgun-sim=src.cli.main:main",
            "emgun-matlab=src.matlab.matlab_runner:main",
        ],
    },
    
    extras_require={
        "matlab": ["matlab.engine"],
        "dev": ["pytest", "pytest-cov", "black", "flake8", "mypy"],
        "standalone": ["pyinstaller>=4.0"],
    },
    
    python_requires=">=3.7",
    
    classifiers=[
        "Development Status :: 4 - Beta",
        "Intended Audience :: Science/Research",
        "License :: OSI Approved :: MIT License",
        "Programming Language :: Python :: 3",
        "Programming Language :: Python :: 3.7",
        "Programming Language :: Python :: 3.8",
        "Programming Language :: Python :: 3.9",
        "Programming Language :: Python :: 3.10",
        "Topic :: Scientific/Engineering :: Physics",
        "Topic :: Scientific/Engineering :: Visualization",
    ],
    
    keywords="electromagnetic simulation physics matlab engineering",
)