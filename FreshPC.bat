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

:: Remove temporary files and folders from the current user's profile
for /d %%a in ("%USERPROFILE%\AppData\Local\Temp\*") do (
    pushd "%%a"
    if exist *.* (
        del /f /s /q *.*
    )
    popd
    if exist "%%a" (
        rd /s /q "%%a"
    )
)
del /f /s /q "%USERPROFILE%\AppData\Local\Temp\*.*"

:: Remove temporary files and folders from all user profiles
for /d %%a in ("%SystemDrive%\Users\*") do (
    for /d %%b in ("%%a\AppData\Local\Temp\*") do (
        pushd "%%b"
        if exist *.* (
            del /f /s /q *.*
        )
        popd
        if exist "%%b" (
            rd /s /q "%%b"
        )
    )
    if exist "%%a\AppData\Local\Temp" (
        rd /s /q "%%a\AppData\Local\Temp"
    )
)

echo.
echo Temporary files and folders have been cleaned.

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
