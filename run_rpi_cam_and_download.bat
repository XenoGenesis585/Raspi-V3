@echo off
chcp 65001 >nul
setlocal ENABLEDELAYEDEXPANSION

REM ===== 使用者請修改這兩行 =====
set "PI_USER=raspberrypi"
set "PI_HOST=192.168.x.x"   REM ← 改成你的樹莓派 IP

REM ===== 其他設定 =====
set "PI_HOME=/home/raspberrypi"
set "PI_PATH=%PI_HOME%/rpi_cam_once.py"
set "PI_MARK=%PI_HOME%/last_saved.txt"

REM [1/3] 上傳腳本
echo [1/3] 上傳 rpi_cam_once.py 到樹莓派...
scp "rpi_cam_once.py" %PI_USER%@%PI_HOST%:"%PI_PATH%" || (echo 上傳失敗 & pause & exit /b 1)

REM [2/3] 同窗互動執行
echo.
echo [2/3] 透過 SSH 執行腳本（依提示輸入參數）...
ssh %PI_USER%@%PI_HOST% "python3 %PI_PATH%" || (echo 執行失敗 & pause & exit /b 1)

REM 讀取結果路徑
set "REMOTE_SAVED="
for /f "usebackq delims=" %%L in (`
  ssh %PI_USER%@%PI_HOST% "if [ -f '%PI_MARK%' ]; then cat '%PI_MARK%'; else echo FAILED; fi"
`) do (
  set "REMOTE_SAVED=%%L"
)
if not defined REMOTE_SAVED  (echo [!] 取不到結果。 & pause & exit /b 1)
if /I "%REMOTE_SAVED%"=="FAILED" (echo [!] Pi 回報失敗。 & pause & exit /b 1)

REM [3/3] 下載到與 .bat 同資料夾
echo.
echo [3/3] 從樹莓派下載：%REMOTE_SAVED%
pushd "%~dp0"
scp %PI_USER%@%PI_HOST%:"%REMOTE_SAVED%" .
for %%F in ("%REMOTE_SAVED%") do set "BASENAME=%%~nxF"
start "" "%CD%\%BASENAME%"
popd

echo.
echo ✅ 完成！檔案已下載到：%~dp0
pause


