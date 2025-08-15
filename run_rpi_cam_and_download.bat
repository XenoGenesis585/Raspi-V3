@echo off
chcp 65001 >nul
setlocal ENABLEDELAYEDEXPANSION

rem ===== 連線資訊 =====
set "PI_USER=raspberrypi"
set "PI_HOST=172.21.84.18"
set "PI_HOME=/home/raspberrypi"
set "PI_PATH=%PI_HOME%/rpi_cam_once.py"
set "PI_MARK=%PI_HOME%/last_saved.txt"

rem [1/3] 上傳腳本
echo [1/3] 上傳 rpi_cam_once.py 到樹莓派...
scp "rpi_cam_once.py" %PI_USER%@%PI_HOST%:"%PI_PATH%" || (echo 上傳失敗 & pause & exit /b 1)

rem [2/3] 同窗互動執行
echo.
echo [2/3] 透過 SSH 執行腳本（依提示輸入參數）...
ssh %PI_USER%@%PI_HOST% "python3 %PI_PATH%" || (echo 執行失敗 & pause & exit /b 1)

rem 讀取結果路徑（不使用重導，避免轉義問題）
set "REMOTE_SAVED="
for /f "usebackq delims=" %%L in (`ssh %PI_USER%@%PI_HOST% "if [ -f '%PI_MARK%' ]; then cat '%PI_MARK%'; else echo FAILED; fi"`) do (
  set "REMOTE_SAVED=%%L"
)

if not defined REMOTE_SAVED  (
  echo [!] 取不到結果。請檢查 Pi 端。
  pause & exit /b 1
)
if /I "%REMOTE_SAVED%"=="FAILED" (
  echo [!] Pi 回報失敗。請重試。
  pause & exit /b 1
)

rem [3/3] 下載到批次檔所在資料夾（用 . 避免尾隨 \ 的引號問題）
echo.
echo [3/3] 從樹莓派下載：%REMOTE_SAVED%
pushd "%~dp0"
scp %PI_USER%@%PI_HOST%:"%REMOTE_SAVED%" .
popd || (echo 下載完成，但返回路徑失敗 & rem 可忽略)

echo.
echo ✅ 完成！檔案已下載到：%~dp0
pause
