@echo off
cd /d "%~dp0"
where node >nul 2>nul
if errorlevel 1 (
  echo Node.js が見つかりません。https://nodejs.org/ からインストールしてください。
  pause
  exit /b 1
)

echo.
echo  === 大阪 雨雲レーダー 640x192 ===
echo  このウィンドウは閉じないでください（サーバ起動中）
echo.
echo  確認用（画面に拡大）:
echo    http://127.0.0.1:8765/?preview=1
echo.
echo  LED本番（原点固定 640x192）:
echo    http://127.0.0.1:8765/?signage=1
echo.

start "" "http://127.0.0.1:8765/?preview=1"
node serve.js
pause
