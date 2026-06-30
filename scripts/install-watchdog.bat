@echo off
setlocal
chcp 65001 >nul
title Install Recorder Upload Watchdog

set "WORKDIR=C:\RecorderUpload"
set "TASK1=RecorderUploadWatchdog"
set "TASK2=RecorderUploadWatchdogLogon"

if not exist "%WORKDIR%" mkdir "%WORKDIR%"

if not exist "%~dp0upload-recordings.ps1" (
    echo ERROR: upload-recordings.ps1 must be in the same folder as install-watchdog.bat
    echo Put all package files in one folder and run install-watchdog.bat again.
    pause
    exit /b 1
)

if not exist "%~dp0watchdog.ps1" (
    echo ERROR: watchdog.ps1 must be in the same folder as install-watchdog.bat
    pause
    exit /b 1
)

if not exist "%~dp0watchdog-hidden.vbs" (
    echo ERROR: watchdog-hidden.vbs must be in the same folder as install-watchdog.bat
    pause
    exit /b 1
)

copy /Y "%~dp0upload-recordings.ps1" "%WORKDIR%\upload-recordings.ps1" >nul
copy /Y "%~dp0watchdog.ps1" "%WORKDIR%\watchdog.ps1" >nul
copy /Y "%~dp0watchdog-hidden.vbs" "%WORKDIR%\watchdog-hidden.vbs" >nul

if exist "%~dp0start-upload.bat" copy /Y "%~dp0start-upload.bat" "%WORKDIR%\start-upload.bat" >nul
if exist "%~dp0stop-upload.bat" copy /Y "%~dp0stop-upload.bat" "%WORKDIR%\stop-upload.bat" >nul
if exist "%~dp0restart-upload.bat" copy /Y "%~dp0restart-upload.bat" "%WORKDIR%\restart-upload.bat" >nul

wmic process where "CommandLine like '%%upload-recordings.ps1%%'" call terminate >nul 2>&1

schtasks /delete /tn "%TASK1%" /f >nul 2>&1
schtasks /delete /tn "%TASK2%" /f >nul 2>&1
schtasks /delete /tn "RecorderUploadHidden" /f >nul 2>&1

schtasks /create /tn "%TASK1%" /tr "wscript.exe ""%WORKDIR%\watchdog-hidden.vbs""" /sc minute /mo 5 /f >nul
if errorlevel 1 (
    echo ERROR: failed to create scheduled task %TASK1%.
    echo Run this installer as Administrator.
    pause
    exit /b 1
)

schtasks /create /tn "%TASK2%" /tr "wscript.exe ""%WORKDIR%\watchdog-hidden.vbs""" /sc onlogon /f >nul
if errorlevel 1 (
    echo ERROR: failed to create scheduled task %TASK2%.
    echo Run this installer as Administrator.
    pause
    exit /b 1
)

schtasks /run /tn "%TASK1%" >nul 2>&1

echo.
echo ================================
echo INSTALLED OK
echo Folder: %WORKDIR%
echo Task every 5 min: %TASK1%
echo Startup task: %TASK2%
echo Silent mode: enabled via wscript
echo ================================
echo.
echo Check logs:
echo type C:\RecorderUpload\watchdog.log
echo type C:\RecorderUpload\upload.log
echo.
pause
