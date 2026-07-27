@echo off
cd /d "%~dp0"

REM LED signage: 640x192 at screen (0,0). Capture that rectangle.
set "PORT=8765"
set "URL=http://127.0.0.1:%PORT%/?signage=1"
set "PROFILE=%LOCALAPPDATA%\OsakaRainRadarSignage"
set "EDGE86=%ProgramFiles(x86)%\Microsoft\Edge\Application\msedge.exe"
set "EDGE64=%ProgramFiles%\Microsoft\Edge\Application\msedge.exe"
set "CHROME=%ProgramFiles%\Google\Chrome\Application\chrome.exe"
set "CHROMEL=%LocalAppData%\Google\Chrome\Application\chrome.exe"
set "BROWSER="

if exist "%EDGE86%" set "BROWSER=%EDGE86%"
if not defined BROWSER if exist "%EDGE64%" set "BROWSER=%EDGE64%"
if not defined BROWSER if exist "%CHROME%" set "BROWSER=%CHROME%"
if not defined BROWSER if exist "%CHROMEL%" set "BROWSER=%CHROMEL%"

echo.
echo  === LED Signage 640x192 ===
echo  Capture: (0,0)-(640,192)
echo  %URL%
echo.

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

set /a n=0
:wait
set /a n+=1
powershell -NoProfile -Command "if ((Invoke-WebRequest -UseBasicParsing -TimeoutSec 1 '%URL%').StatusCode -eq 200) { exit 0 } else { exit 1 }" >nul 2>nul
if not errorlevel 1 goto open
if %n% GEQ 20 (
  echo ERROR: server did not start on port %PORT%
  pause
  exit /b 1
)
ping -n 2 127.0.0.1 >nul
goto wait

:open
if not defined BROWSER (
  start "" "%URL%"
  exit /b 0
)

REM Dedicated profile so DPI=1 flags always apply (shared Edge ignores them).
REM Oversize a bit for window chrome; page JS then locks inner size to 640x192.
start "" "%BROWSER%" ^
  --user-data-dir="%PROFILE%" ^
  --app="%URL%" ^
  --window-position=0,0 ^
  --window-size=640,220 ^
  --force-device-scale-factor=1 ^
  --high-dpi-support=1 ^
  --disable-features=TranslateUI ^
  --disable-session-crashed-bubble ^
  --no-first-run ^
  --disable-pinch ^
  --overscroll-history-navigation=0
exit /b 0
