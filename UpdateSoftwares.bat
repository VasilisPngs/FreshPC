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
echo Checking for updates from winget...
winget outdated > "winget_updates.txt"
REM Increment count for each package that needs to be updated
for /f "tokens=*" %%j in ("winget_updates.txt") do (
    set /a count+=1
)

REM Upgrade all packages
echo Upgrading all packages...
winget upgrade --all || echo Failed to update with winget.

REM Check if any updates are available
if %count%==0 (
    echo No updates available.
) else (
    echo %count% updates available. Updating...
)

REM Clean up temporary files
del "winget_updates.txt"
echo Script complete. Exiting in 3 seconds...
timeout 3
