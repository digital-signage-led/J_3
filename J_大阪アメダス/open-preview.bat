@echo off
cd /d "%~dp0"
set "PORT=8765"
set "URL=http://127.0.0.1:%PORT%/?preview=1"

where node >nul 2>nul
if errorlevel 1 (
  echo ERROR: Node.js is required.
  pause
  exit /b 1
)

for /f "tokens=5" %%p in ('netstat -ano 2^>nul ^| findstr ":%PORT% " ^| findstr "LISTENING"') do (
  taskkill /F /PID %%p >nul 2>nul
)

start "OsakaRainRadarServe" /MIN node "%~dp0serve.js"
ping -n 3 127.0.0.1 >nul
start "" "%URL%"
