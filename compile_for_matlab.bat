@echo off
REM Compile Python electromagnetic gun simulation for MATLAB use
REM This script sets up multiple ways to run the simulation from MATLAB

echo ====================================================
echo Electromagnetic Gun Simulation - MATLAB Compilation
echo ====================================================

REM Check if Python is available
python --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: Python not found in PATH
    echo Please install Python or add it to your PATH
    pause
    exit /b 1
)

echo.
echo [1/4] Installing Python dependencies...
python -m pip install --upgrade pip
python -m pip install -r requirements.txt

echo.
echo [2/4] Installing the package in development mode...
python -m pip install -e .

echo.
echo [3/4] Testing the MATLAB runner...
python -m src.matlab.matlab_runner --help

echo.
echo [4/4] Creating standalone executable with PyInstaller...
python -m pip install pyinstaller

REM Create standalone executable
pyinstaller --onefile ^
    --name emgun_simulator ^
    --add-data "src;src" ^
    --hidden-import numpy ^
    --hidden-import scipy ^
    --hidden-import matplotlib ^
    src/matlab/matlab_runner.py

echo.
echo ====================================================
echo Compilation Complete!
echo ====================================================
echo.
echo Available MATLAB interfaces:
echo.
echo 1. MATLAB Functions (matlab_wrappers/):
echo    - emgun_simulate() - Full parameter control
echo    - emgun_quick() - Quick simulations
echo.
echo 2. Python Module (requires Python):
echo    python -m src.matlab.matlab_runner [options]
echo.
echo 3. Standalone Executable (dist/):
echo    emgun_simulator.exe [options]
echo.
echo 4. Direct Python calls from MATLAB:
echo    system('python -m src.matlab.matlab_runner --json-only')
echo.
echo ====================================================
echo.
echo Quick test from MATLAB:
echo   result = emgun_quick(400, 6);
echo.
echo Full simulation from MATLAB:
echo   result = emgun_simulate('voltage', 500, 'stages', 8);
echo.
echo ====================================================

pause