@echo off
setlocal

REM Check if running with elevated privileges
net session >nul 2>&1
if %errorLevel% == 0 (
    echo Running with elevated privileges.
) else (
    echo Script requires elevated privileges to run. Please run as an administrator.
    exit /b 1
)

REM Check for updates using Winget
echo Checking for updates using Winget...
winget outdated > winget_updates.txt

REM Check for updates using Chocolatey
echo Checking for updates using Chocolatey...
powershell -Command "Start-Process cmd -ArgumentList '/c choco outdated --source=https://chocolatey.org/api/v2/ > choco_updates.txt' -Verb RunAs"

REM Set counter variable to 0
set /a count=0

REM Increment count for each package that needs to be updated in Winget
for /f "tokens=*" %%i in (winget_updates.txt) do (
    set /a count+=1
)

REM If choco_updates.txt exists, increment count for each package that needs to be updated in Chocolatey
if exist choco_updates.txt (
    for /f "tokens=*" %%i in (choco_updates.txt) do (
        set /a count+=1
    )
)

REM Check if any updates are available
if %count%==0 (
    echo No updates available.
) else (
    echo %count% updates available. Updating...

    REM Upgrade all packages with Winget
    winget upgrade --all --include-unknown || echo Failed to update with Winget.

    REM Upgrade all packages with Chocolatey
    powershell -Command "Start-Process cmd -ArgumentList '/c choco upgrade all --source=https://chocolatey.org/api/v2/' -Verb RunAs" || echo Failed to update with Chocolatey.
)

REM Clean up temporary files
del winget_updates.txt
del choco_updates.txt

echo Script complete. Exiting in 5 seconds...
timeout 5

REM Warn user of potential issues
echo Please note that this script requires elevated privileges to run and depends on third-party package managers, Winget and Chocolatey, which may not be installed or functioning properly on your system. Additionally, blindly updating all packages could potentially cause issues if some packages have compatibility issues with newer versions or require additional configuration before updating. Please use this script with caution and ensure that you have backups or system restore points in place before running.
