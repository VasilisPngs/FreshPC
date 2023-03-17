@echo off
setlocal

echo Checking for updates using Winget...
winget outdated > winget_updates.txt

echo Checking for updates using Chocolatey...
powershell -Command "Start-Process cmd -ArgumentList '/c choco outdated --source=https://chocolatey.org/api/v2/ > choco_updates.txt' -Verb RunAs"

set /a count=0
for /f "tokens=*" %%i in (winget_updates.txt) do (
    set /a count+=1
)

if exist choco_updates.txt (
    for /f "tokens=*" %%i in (choco_updates.txt) do (
        set /a count+=1
    )
)

if %count%==0 (
    echo No updates available.
) else (
    echo %count% updates available. Updating...
    winget upgrade --all || echo Failed to update with Winget.
    powershell -Command "Start-Process cmd -ArgumentList '/c choco upgrade all --source=https://chocolatey.org/api/v2/' -Verb RunAs" || echo Failed to update with Chocolatey.
)

del winget_updates.txt
del choco_updates.txt

echo Script complete. Exiting in 5 seconds...
timeout 5
