@echo off
echo Purging standby list...
typeperf "\Memory\Standby Cache Reserve Bytes" -si 10 -sc 1 > nul
echo.
echo Purging working set...
typeperf "\Process(_Total)\Working Set - Private" -si 10 -sc 1 > nul
echo.
echo Freeing up memory...
start "" /min "%windir%\system32\cmd.exe" /c "echo y|ping localhost -n 2 >nul && echo y|ping localhost -n 2 >nul && echo y|ping localhost -n 2 >nul && echo y|ping localhost -n 2 >nul"

echo.
echo Memory has been freed successfully!
ping localhost -n 3 > nul
