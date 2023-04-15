@echo off

REM Set frequently used paths as variables
set "temp_folder=%USERPROFILE%\AppData\Local\Temp"
set "emptyStandbyList=%temp_folder%\emptyStandbyList.bat"
set "flushStandbyList=%temp_folder%\flushStandbyList.bat"
set "emptyCombinedPageList=%temp_folder%\emptyCombinedPageList.bat"
set "emptyModifiedPageList=%temp_folder%\emptyModifiedPageList.bat"

REM Check for administrator rights
NET FILE >NUL 2>&1
IF NOT "%ERRORLEVEL%" == "0" (
  echo This script must be run as an Administrator
  pause>nul
  exit
)

REM Check if temp folder exists and create it if it doesn't
if not exist "%temp_folder%" (
  echo Creating temporary folder...
  mkdir "%temp_folder%"
)

echo Cleaning temporary files, .dmp files, and .old files...
echo.

:: Remove temporary files and folders from the current user's profile
del /f /s /q "%temp_folder%\*.*"
RD /s /q "%temp_folder%\"

:: Remove temporary files and folders from all user profiles
pushd "%SystemDrive%\Users"
for /d %%a in (*) do (
    if exist "%%a\AppData\Local\Temp\" (
        del /f /s /q "%%a\AppData\Local\Temp\*.*"
        RD /s /q "%%a\AppData\Local\Temp\"
    )
)
popd

:: Remove .dmp files from the current user's profile
del /f /s /q "%USERPROFILE%\*.dmp"

:: Remove .old files from the current user's profile
del /f /s /q "%USERPROFILE%\*.old"

:: Remove .dmp files from Program Files and Program Files (x86)
del /f /s /q "%ProgramFiles%\*.dmp"
del /f /s /q "%ProgramFiles(x86)%\*.dmp"

:: Remove .old files from Program Files and Program Files (x86)
del /f /s /q "%ProgramFiles%\*.old"
del /f /s /q "%ProgramFiles(x86)%\*.old"

echo.
echo Temporary files, .dmp files, and .old files have been cleaned.

REM Clear standby list, combined page list, modified page list, and working set of all processes
echo.
echo Clearing standby list, combined page list, modified page list, and working set of all processes...

:: Purge standby list, combined page list, and modified page list
typeperf "\Memory\Standby Cache Reserve Bytes" -sc 1 | findstr /r "[0-9]" > nul
if %errorlevel% EQU 0 (
    echo Purging standby list, combined page list, and modified page list...
    echo. > "%emptyStandbyList%"
    type "%emptyStandbyList%" > "%emptyStandbyList%"
    start /min "%emptyStandbyList%"
    del /f /q "%emptyStandbyList%"

    echo.
    echo Flushing pages from the lowest-priority Standby list to the Free list...
    echo. > "%flushStandbyList%"
    type "%flushStandbyList%" > "%flushStandbyList%"
    start /low "%flushStandbyList%"
    del /f /q "%flushStandbyList%"

    echo.
    echo Clearing combined page list...
    echo. > "%emptyCombinedPageList%"
    type "%emptyCombinedPageList%" > "%emptyCombinedPageList%"
    start /min "%emptyCombinedPageList%"
    del /f /q "%emptyCombinedPageList%"

    echo.
    echo Clearing modified page list...
    echo. > "%emptyModifiedPageList%"
    type "%emptyModifiedPageList%" > "%emptyModifiedPageList%"
    start /min "%emptyModifiedPageList%"
    del /f /q "%emptyModifiedPageList%"

    echo.
    echo Clearing working set of all processes...
    for /f "skip=1" %%a in ('wmic process get processid') do wmic process where "processid=%%a" CALL EmptyWorkingSet

    echo.
    echo Clearing system working set...
    wmic os set ClearPageFileAtShutdown=True > nul

) else (
    echo Standby list is empty.
)

echo.
echo Standby list, combined page list, modified page list, and working set of all processes cleared.
echo System working set cleared.
timeout /t 3 > nul
