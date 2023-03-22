# FreshPC
Run this CMD commands scripts and see the magic. Cheers.


NOTE: Open them as administrator.



FreshPC: This script that automates the process of cleaning temporary files and clearing the standby list in memory.



UpdateSoftwares: This script checks for updates of installed applications on Windows using two package managers: Winget and Chocolatey.



NOTE: Install the Chocolatey package to find updates from their database.

Open cmd as administrator and paste this: @"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "[System.Net.ServicePointManager]::SecurityProtocol = 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))" && SET "PATH=%PATH%;%ALLUSERSPROFILE%\chocolatey\bin"



Yes, my friend, it is free of viruses. Check it out without fear.
