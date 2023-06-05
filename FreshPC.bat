@echo off
setlocal

REM  --> Check for permissions
>nul 2>&1 icacls %windir%\system32\config\system

REM --> If error flag set, we do not have admin.
if '%errorlevel%' NEQ '0' (
   echo Requesting administrative privileges...
   goto UACPrompt
) else ( goto gotAdmin )

:UACPrompt
   echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
   set params = %*:"=""
   echo UAC.ShellExecute "cmd.exe", "/c %~s0 %params%", "", "runas", 1 >> "%temp%\getadmin.vbs"

   "%temp%\getadmin.vbs"
   del "%temp%\getadmin.vbs"
   exit /B

:gotAdmin

REM Set frequently used paths as variables
set "temp_folder=%USERPROFILE%\AppData\Local\Temp"
set "emptyStandbyList=%temp_folder%\emptyStandbyList.bat"
set "flushStandbyList=%temp_folder%\flushStandbyList.bat"
set "emptyCombinedPageList=%temp_folder%\emptyCombinedPageList.bat"
set "emptyModifiedPageList=%temp_folder%\emptyModifiedPageList.bat"

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

:: Remove .dmp files from the current user's profile and all subfolders
del /f /s /q "%USERPROFILE%\*.dmp"

:: Remove .old files from the current user's profile and all subfolders
del /f /s /q "%USERPROFILE%\*.old"

:: Remove .dmp files from Program Files and Program Files (x86)
for /r "%ProgramFiles%" %%a in (*.dmp) do del /f /q "%%a"
for /r "%ProgramFiles(x86)%" %%a in (*.dmp) do del /f /q "%%a"

:: Remove .old files from Program Files and Program Files (x86)
for /r "%ProgramFiles%" %%a in (*.old) do del /f /q "%%a"
for /r "%ProgramFiles(x86)%" %%a in (*.old) do del /f /q "%%a"

:: Remove .old files from ProgramData and all subfolders
for /r "%ProgramData%" %%a in (*.old) do del /f /s /q "%%a"

:: Remove .old files from %USERPROFILE%\AppData\Local\
del /s /q /f /a:h "C:\Users\Vasilis\AppData\Local\*.old"

:: Remove .tmp files from %USERPROFILE%\AppData\Local\
del /s /q /f "C:\Users\Vasilis\AppData\Local\*.tmp"

:: Remove .dmp files from C:\Windows\LiveKernelReports\WATCHDOG\
del /f /s /q "C:\Windows\LiveKernelReports\WATCHDOG\*.dmp"

:: Remove .dmp files from C:\Windows\Minidump\
del /f /s /q "C:\Windows\Minidump\*.dmp"

:: Remove .tmp files from C:\Windows\System32\DriverStore\Temp\
del /f /s /q "C:\Windows\System32\DriverStore\Temp\*.tmp"

:: Remove .tmp files from Windows temp directories
del /f /s /q "C:\Windows\Temp\*.tmp"
del /f /s /q "C:\Windows\System32\config\systemprofile\AppData\Local\Temp\*.tmp"
del /f /s /q "C:\Windows\Panther\*.tmp"

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
    for /f "skip=1" %%a in ('wmic process get processid') do wmic process where "processid=%%a" CALL
EmptyWorkingSet

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