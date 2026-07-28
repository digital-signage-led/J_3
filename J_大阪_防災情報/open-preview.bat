@echo off
cd /d "%~dp0"
set "PORT=8766"
where node >nul 2>nul
if errorlevel 1 (
  echo Node.js が必要です。
  pause
  exit /b 1
)
start "" "http://127.0.0.1:%PORT%/?preview=1"
node serve.js
