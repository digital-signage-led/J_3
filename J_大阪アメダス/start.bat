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
echo  データは気象庁へ直接取得します（このPC専用サーバは不要）
echo.
echo  確認用:
echo    http://127.0.0.1:8765/?preview=1
echo  LED本番:
echo    http://127.0.0.1:8765/?signage=1
echo.
echo  ※ HTMLをサイネージに置く場合も、ネット接続があれば動作します
echo.

start "" "http://127.0.0.1:8765/?preview=1"
node serve.js
pause
