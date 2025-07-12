# Electromagnetic Gun Simulation - Makefile
# Cross-platform build automation and task runner

# Python interpreter
PYTHON := python
PIP := pip

# Project directories
SRC_DIR := src
TEST_DIR := tests
MATLAB_DIR := matlab_gui
DIST_DIR := dist

# Virtual environment
VENV_DIR := venv
VENV_ACTIVATE := $(VENV_DIR)/bin/activate
ifeq ($(OS),Windows_NT)
	VENV_ACTIVATE := $(VENV_DIR)/Scripts/activate
endif

.PHONY: help install build test clean run run-matlab run-quick lint format check dist docker-build docker-run

# Default target
all: install build test

# Display help information
help:
	@echo "Electromagnetic Gun Simulation - Make Targets"
	@echo "============================================="
	@echo ""
	@echo "Setup & Installation:"
	@echo "  install      Install Python dependencies"
	@echo "  venv         Create virtual environment"
	@echo ""
	@echo "Build & Package:"
	@echo "  build        Build the Python package"
	@echo "  dist         Create distribution packages"
	@echo ""
	@echo "Testing:"
	@echo "  test         Run all tests"
	@echo "  test-unit    Run unit tests only"
	@echo "  test-integration  Run integration tests only"
	@echo "  coverage     Run tests with coverage report"
	@echo ""
	@echo "Execution:"
	@echo "  run          Run simulation with default parameters"
	@echo "  run-quick    Run quick simulation (1ms)"
	@echo "  run-plot     Run simulation with visualization"
	@echo "  run-matlab   Launch MATLAB GUI"
	@echo ""
	@echo "Code Quality:"
	@echo "  lint         Run code linting (flake8)"
	@echo "  format       Format code (black)"
	@echo "  check        Run all code quality checks"
	@echo ""
	@echo "Cleanup:"
	@echo "  clean        Remove build artifacts"
	@echo "  clean-all    Remove all generated files"
	@echo ""
	@echo "Docker (if available):"
	@echo "  docker-build Build Docker image"
	@echo "  docker-run   Run in Docker container"

# Install dependencies
install:
	@echo "Installing Python dependencies..."
	$(PIP) install -r requirements.txt
	@echo "Dependencies installed successfully!"

# Create virtual environment
venv:
	@echo "Creating virtual environment..."
	$(PYTHON) -m venv $(VENV_DIR)
	@echo "Virtual environment created at $(VENV_DIR)"
	@echo "Activate with: source $(VENV_ACTIVATE)"

# Build the package
build:
	@echo "Building Python package..."
	$(PYTHON) setup.py build
	@echo "Package built successfully!"

# Create distribution packages
dist: clean
	@echo "Creating distribution packages..."
	$(PYTHON) setup.py sdist bdist_wheel
	@echo "Distribution packages created in $(DIST_DIR)/"

# Run all tests
test:
	@echo "Running all tests..."
	$(PYTHON) -m pytest $(TEST_DIR)/ -v
	@echo "All tests completed!"

# Run unit tests only
test-unit:
	@echo "Running unit tests..."
	$(PYTHON) -m pytest $(TEST_DIR)/unit/ -v

# Run integration tests only
test-integration:
	@echo "Running integration tests..."
	$(PYTHON) -m pytest $(TEST_DIR)/integration/ -v

# Run tests with coverage
coverage:
	@echo "Running tests with coverage..."
	$(PYTHON) -m pytest $(TEST_DIR)/ --cov=$(SRC_DIR) --cov-report=html --cov-report=term
	@echo "Coverage report generated in htmlcov/"

# Run simulation with default parameters
run:
	@echo "Running electromagnetic gun simulation..."
	$(PYTHON) -m $(SRC_DIR).cli.main

# Run quick simulation (1ms)
run-quick:
	@echo "Running quick simulation (1ms)..."
	$(PYTHON) -m $(SRC_DIR).cli.main --max-time 0.001 --quiet

# Run simulation with plotting
run-plot:
	@echo "Running simulation with visualization..."
	$(PYTHON) -m $(SRC_DIR).cli.main --max-time 5.0 --plot

# Launch MATLAB GUI
run-matlab:
	@echo "Launching MATLAB GUI..."
	@echo "Make sure MATLAB is installed and in PATH"
	matlab -r "run_gui; exit"

# Run code linting
lint:
	@echo "Running code linting..."
	$(PYTHON) -m flake8 $(SRC_DIR) $(TEST_DIR) --max-line-length=100 --exclude=__pycache__

# Format code
format:
	@echo "Formatting code with black..."
	$(PYTHON) -m black $(SRC_DIR) $(TEST_DIR) --line-length=100

# Run all code quality checks
check: lint
	@echo "Running type checking..."
	$(PYTHON) -m mypy $(SRC_DIR) --ignore-missing-imports
	@echo "All code quality checks passed!"

# Clean build artifacts
clean:
	@echo "Cleaning build artifacts..."
	rm -rf build/
	rm -rf $(DIST_DIR)/
	rm -rf *.egg-info/
	rm -rf __pycache__/
	find . -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true
	find . -type f -name "*.pyc" -delete 2>/dev/null || true
	find . -type f -name "*.pyo" -delete 2>/dev/null || true
	@echo "Build artifacts cleaned!"

# Clean all generated files
clean-all: clean
	@echo "Cleaning all generated files..."
	rm -rf $(VENV_DIR)/
	rm -rf htmlcov/
	rm -rf .coverage
	rm -rf .pytest_cache/
	rm -rf .mypy_cache/
	@echo "All generated files cleaned!"

# Docker build (optional)
docker-build:
	@echo "Building Docker image..."
	@if command -v docker >/dev/null 2>&1; then \
		docker build -t emgun-simulation .; \
		echo "Docker image built successfully!"; \
	else \
		echo "Docker not found. Please install Docker to use this target."; \
	fi

# Docker run (optional)
docker-run:
	@echo "Running in Docker container..."
	@if command -v docker >/dev/null 2>&1; then \
		docker run -it --rm emgun-simulation; \
	else \
		echo "Docker not found. Please install Docker to use this target."; \
	fi

# Development setup - install in development mode
dev-install: venv
	@echo "Setting up development environment..."
	. $(VENV_ACTIVATE) && pip install -e .
	. $(VENV_ACTIVATE) && pip install -r requirements.txt
	@echo "Development environment ready!"

# Performance benchmark
benchmark:
	@echo "Running performance benchmark..."
	$(PYTHON) -m $(SRC_DIR).cli.main --max-time 0.001 --quiet --output benchmark.json
	@echo "Benchmark completed - results in benchmark.json"

# Quick health check
health-check: test-unit run-quick
	@echo "System health check passed!"