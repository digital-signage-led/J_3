@echo off
cd /d "%~dp0"
where node >nul 2>nul
if errorlevel 1 (
  echo Node.js が見つかりません。https://nodejs.org/ からインストールするか、
  echo 任意の静的 HTTP サーバでこのフォルダを配信してください。
  pause
  exit /b 1
)
echo Opening http://127.0.0.1:8766/?native640=1
start "" "http://127.0.0.1:8766/?native640=1"
node serve.js
