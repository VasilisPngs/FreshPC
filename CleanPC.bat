@echo off
REM Check for administrator rights
NET FILE >NUL 2>&1
IF NOT '%ERRORLEVEL%' == '0' (
  echo This script must be run as an Administrator
  pause>nul
  exit
)

setlocal enabledelayedexpansion

rem Clear Windows error reports
echo Clearing Windows error reports...
del /q /s "%LOCALAPPDATA%\Microsoft\Windows\WER\ReportQueue"
rd /s /q "%LOCALAPPDATA%\Microsoft\Windows\WER\ReportArchive"

rem Clear Windows logs
echo Clearing Windows logs...
for /f "tokens=*" %%a in ('wevtutil.exe el ^| findstr /i /c:"Application" /c:"System"') do (
  set logfile=%%a
  set logfile=!logfile: =!
  echo Clearing !logfile! log...
  wevtutil.exe cl !logfile! || echo Failed to clear !logfile! log.
)

rem Clear temporary files
echo Clearing temporary files...
del /q /s "%windir%\Temp\*.*"
del /q /s "%TEMP%\*.*"
if exist "%USERPROFILE%\AppData\Local\Microsoft\Windows\Temporary Internet Files\" (
  del /q /s "%USERPROFILE%\AppData\Local\Microsoft\Windows\Temporary Internet Files\*.*"
)
if exist "%USERPROFILE%\AppData\Local\Microsoft\Windows\INetCache\" (
  del /q /s "%USERPROFILE%\AppData\Local\Microsoft\Windows\INetCache\*.*"
)

rem Clear LiveId logs
echo Clearing LiveId logs...
for /f "tokens=*" %%a in ('wevtutil.exe el ^| findstr /i /c:"LiveId"') do (
  set logfile=%%a
  set logfile=!logfile: =!
  echo Clearing !logfile! log...
  wevtutil.exe cl !logfile! /force
)

rem Clear prefetch files
echo Clearing prefetch files...
del /q /s "%systemroot%\Prefetch\*.*"

rem Clear update cache
echo Clearing update cache...
net stop wuauserv
del /q /s "%windir%\SoftwareDistribution\Download\*.*"
net start wuauserv

rem Clear DNS cache
echo Clearing DNS cache...
ipconfig /flushdns

rem Clear system error memory dump files
echo Clearing system error memory dump files...
del /q /s "%systemroot%\MEMORY.DMP"

rem Clear system error minidump files
echo Clearing system error minidump files...
del /q /s "%systemroot%\Minidump\*.*"

rem Clear Windows error reporting files
echo Clearing Windows error reporting files...
del /q /s "%LOCALAPPDATA%\Microsoft\Windows\WER\*.wer"

rem Clear system archived Windows error reporting files
echo Clearing system archived Windows error reporting files...
del /q /s "%systemroot%\System32\winevt\Logs\*.evtx*"

rem Clear MUI cache
echo Clearing MUI cache...
for /f "tokens=*" %%a in ('dir /b /s %windir%\winsxs\*mui') do (
  takeown /f "%%a" && icacls "%%a" /grant administrators:F
  del /q "%%a"
)

rem Renew IP address
echo Renewing IP address...
ipconfig /release
ipconfig /renew

rem Delay before closing command prompt window
echo Done!
timeout /t 3 /nobreak >nul
exit
