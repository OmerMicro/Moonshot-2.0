@echo off
echo Setting up Electromagnetic Gun Simulation for MATLAB...

REM Install Python dependencies
python -m pip install -r requirements.txt

REM Test the simulation
echo Testing simulation...
python -m src.matlab.matlab_runner --voltage 400 --num-stages 6 --json-only

echo.
echo Setup complete!
echo.
echo From MATLAB, run:
echo   addpath('matlab_simple');
echo   result = emgun(400, 6);
echo.
pause