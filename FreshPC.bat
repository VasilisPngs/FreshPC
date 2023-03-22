@echo off

REM Check for administrator rights
NET FILE >NUL 2>&1
IF NOT '%ERRORLEVEL%' == '0' (
  echo This script must be run as an Administrator
  pause>nul
  exit
)

echo Cleaning temporary files...
echo.

:: Remove temporary files from the current user's profile
del /f /s /q "%USERPROFILE%\AppData\Local\Temp\*.*"
del /f /s /q "%USERPROFILE%\AppData\Local\Microsoft\Windows\INetCache\*.*"

:: Remove temporary files from all user profiles
del /f /s /q "%SystemDrive%\Users\*\AppData\Local\Temp\*.*"
del /f /s /q "%SystemDrive%\Users\*\AppData\Local\Microsoft\Windows\INetCache\*.*"

echo.
echo Temporary files have been cleaned.

REM Clear standby list
echo.
echo Clearing standby list...
typeperf "\Memory\Standby Cache Reserve Bytes" -sc 1 | findstr /r "[0-9]" > nul
if %errorlevel% EQU 0 (
    echo Purging standby list...
    echo. > "%temp%\emptyStandbyList.txt"
    type "%temp%\emptyStandbyList.txt" > "%temp%\emptyStandbyList.bat"
    start /min "%temp%\emptyStandbyList.bat"
) else (
    echo Standby list is empty.
)

echo.
echo Standby list cleared.
timeout /t 3 > nul
