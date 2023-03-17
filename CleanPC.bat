@echo off
setlocal enabledelayedexpansion

rem Clear Windows error reports
echo Clearing Windows error reports...
del /q /s %LOCALAPPDATA%\Microsoft\Windows\WER\ReportQueue
rd /s /q %LOCALAPPDATA%\Microsoft\Windows\WER\ReportArchive

rem Clear Windows logs
echo Clearing Windows logs...
for /f "tokens=*" %%a in ('wevtutil.exe el') do (
  set logfile=%%a
  set logfile=!logfile: =!
  echo Clearing !logfile! log...
  wevtutil.exe cl !logfile!
)

rem Clear temporary files
echo Clearing temporary files...
del /q /s C:\Windows\Temp\*.*
del /q /s %TEMP%\*.*
if exist "C:\Users\%USERNAME%\AppData\Local\Microsoft\Windows\Temporary Internet Files\" (
  del /q /s "C:\Users\%USERNAME%\AppData\Local\Microsoft\Windows\Temporary Internet Files\*.*"
)
if exist "C:\Users\%USERNAME%\AppData\Local\Microsoft\Windows\INetCache\" (
  del /q /s "C:\Users\%USERNAME%\AppData\Local\Microsoft\Windows\INetCache\*.*"
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
del /q /s %systemroot%\Prefetch\*.*

rem Clear update cache
echo Clearing update cache...
net stop wuauserv
del /q /s %windir%\SoftwareDistribution\Download\*.*
net start wuauserv

rem Clear DNS cache
echo Clearing DNS cache...
ipconfig /flushdns

rem Clear Windows error reporting
echo Clearing Windows error reporting...
del /q /s %LOCALAPPDATA%\Microsoft\Windows\WER\ReportQueue\*.*
del /q /s %LOCALAPPDATA%\Microsoft\Windows\WER\ReportArchive\*.*

rem Clear MUI cache
echo Clearing MUI cache...
if exist %windir%\system32\MUI\*.* (
  rmdir /s /q %windir%\system32\MUI\*.*
)
if exist %windir%\winsxs\ManifestCache\*.* (
  del /q /s %windir%\winsxs\ManifestCache\*.*
)

rem Clear System archived Windows error reporting
echo Clearing System archived Windows error reporting...
del /q /s %systemdrive%\Windows.old\*.* /f /a:h /a:s /a:r /a:d
rd /s /q %systemdrive%\Windows.old\*.* /f /a:h /a:s /a:r /a:d

rem Renew IP address
echo Renewing IP address...
ipconfig /release
ipconfig /renew

echo Done!
timeout /t 3 /nobreak >nul
exit
