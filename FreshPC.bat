@echo off
setlocal EnableExtensions DisableDelayedExpansion

>nul 2>&1 net session
if %errorlevel% neq 0 (
    powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "Start-Process -FilePath 'cmd.exe' -ArgumentList '/c ""%~f0""' -Verb RunAs"
    exit /b
)

del /q /f /s "%temp%\*" 2>nul
for /d %%x in ("%temp%\*") do rd /s /q "%%x" 2>nul

del /q /f /s "%SystemRoot%\temp\*" 2>nul
for /d %%x in ("%SystemRoot%\temp\*") do rd /s /q "%%x" 2>nul

del /q /f /s "%SystemRoot%\SystemTemp\*" 2>nul
for /d %%x in ("%SystemRoot%\SystemTemp\*") do rd /s /q "%%x" 2>nul

del /f /s /q "%SystemRoot%\Minidump\*.dmp" 2>nul
del /f /s /q "%SystemRoot%\Memory.dmp" 2>nul
del /f /s /q "%SystemRoot%\LiveKernelReports\*.dmp" 2>nul
del /f /s /q "%LocalAppData%\CrashDumps\*" 2>nul

del /f /s /q "%SystemRoot%\Panther\*.log" 2>nul
del /f /s /q "%SystemRoot%\Panther\*.xml" 2>nul
del /f /q "%SystemRoot%\Logs\WindowsUpdate\*.etl" 2>nul
del /f /q "%SystemRoot%\Logs\CBS\*.log" 2>nul
del /f /q "%SystemRoot%\Logs\CBS\*.cab" 2>nul

del /q /f /s "%SystemRoot%\Logs\Setup\*.log" 2>nul
rd /s /q "%systemdrive%\$WINDOWS.~BT" 2>nul
rd /s /q "%systemdrive%\$WINDOWS.~WS" 2>nul

del /q /f "%systemdrive%\*.chk" 2>nul

del /q /f /s "%SystemRoot%\Downloaded Program Files\*" 2>nul

del /q /f /s "%ProgramData%\Microsoft\Windows Defender\Scans\History\Service\*" 2>nul
del /q /f /s "%ProgramData%\Microsoft\Windows Defender\Scans\History\Store\*" 2>nul

del /q /f /s "%SystemRoot%\ServiceProfiles\NetworkService\AppData\Local\Microsoft\Windows\DeliveryOptimization\Cache\*" 2>nul
for /d %%x in ("%SystemRoot%\ServiceProfiles\NetworkService\AppData\Local\Microsoft\Windows\DeliveryOptimization\Cache\*") do rd /s /q "%%x" 2>nul

del /f /s /q "%ProgramData%\Microsoft\Windows\WER\ReportArchive\*" 2>nul
del /f /s /q "%ProgramData%\Microsoft\Windows\WER\ReportQueue\*" 2>nul
del /f /s /q "%LocalAppData%\Microsoft\Windows\WER\*" 2>nul

del /q /f /s "%AppData%\Microsoft\Windows\Recent\*" 2>nul

rd /s /q "%ProgramData%\Microsoft\Windows\RetailDemo\OfflineContent" 2>nul

del /q /f /s "%ProgramData%\Microsoft\Diagnosis\ETLLogs\*" 2>nul
del /q /f /s "%ProgramData%\Microsoft\Diagnosis\FeedbackArchive\*" 2>nul

netsh branchcache flush >nul 2>&1

DISM /Online /Cleanup-Image /StartComponentCleanup /ResetBase

defrag /C /O
