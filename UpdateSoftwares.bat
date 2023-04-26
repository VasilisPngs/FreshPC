@echo off
setlocal EnableDelayedExpansion

REM Set log file path
set LOGFILE=%~dp0\result.log

REM Check if running with elevated privileges
net session >nul 2>&1
if %errorLevel% == 0 (
    echo Running with elevated privileges.
) else (
    echo Script requires elevated privileges to run. Please run as an administrator.
    echo Script aborted. >> %LOGFILE%
    exit /b 1
)

REM Check if PowerShell is installed
where powershell >nul 2>&1
if %errorLevel% == 0 (
    echo PowerShell is already installed.
) else (
    echo PowerShell is not installed. Installing...
    powershell.exe -Command "Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iwr -useb https://aka.ms/install-powershell.ps1 | iex"
    if %errorLevel% == 0 (
        echo PowerShell installed successfully.
    ) else (
        echo Failed to install PowerShell.
        echo Script aborted. >> %LOGFILE%
        exit /b 1
    )
)

REM Check if Winget is installed
where winget >nul 2>&1
if %errorLevel% == 0 (
    echo Winget is already installed.
) else (
    echo Winget is not installed. Installing...
    powershell.exe -Command "Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iwr -useb https://aka.ms/install-winget | iex"
    if %errorLevel% == 0 (
        echo Winget installed successfully.
    ) else (
        echo Failed to install Winget.
        echo Failed to install Winget. >> %LOGFILE%
    )
)

REM Check if Chocolatey is installed
where choco >nul 2>&1
if %errorLevel% == 0 (
    echo Chocolatey is already installed.
) else (
    echo Chocolatey is not installed. Installing...
    powershell.exe -Command "Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iwr -useb https://chocolatey.org/install.ps1 | iex"
    if %errorLevel% == 0 (
        echo Chocolatey installed successfully.
    ) else (
        echo Failed to install Chocolatey.
        echo Failed to install Chocolatey. >> %LOGFILE%
    )
)

REM Check for updates using Winget and Chocolatey
set count=0
for %%i in (winget choco) do (
    echo Checking for updates from %%i...
    %%i outdated > "%%i_updates.txt"
    REM Increment count for each package that needs to be updated
    for /f "tokens=*" %%j in ("%%i_updates.txt") do (
        set /a count+=1
    )
    REM Upgrade all packages
    if "%%i"=="choco" (
        %%i upgrade all -y || (
            echo Failed to update with %%i.
            echo Failed to update with %%i. >> %LOGFILE%
        )
    ) else (
        %%i upgrade --all || (
            echo Failed to update with %%i.
            echo Failed to update with %%i. >> %LOGFILE%
        )
    )
    del "%%i_updates.txt"
)

REM Check if any updates are available
if %count%==0 (
    echo No updates available.
    echo Script completed successfully. >> %LOGFILE%
) else (
    echo %count% updates available. Updating...
    echo Script completed with updates. >> %LOGFILE%
)

REM Clean up temporary files
echo Script complete. Exiting in 3 seconds...
timeout 3