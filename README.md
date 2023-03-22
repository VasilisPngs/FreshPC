**Run this CMD commands scripts and see the magic. Cheers.**


* **Open them as administrator.**



**FreshPC:** This script clears temporary files and queue list in memory which helps to speed up perfomance the system.



**UpdateSoftwares:** This script checks for updates of installed applications on Windows using two package managers: Winget and Chocolatey.

**NOTE:** 1. If you do not have winget installed on your computer you will be asked if you want to install it. Press Y for yes.

**NOTE:** 2. Install the Chocolatey package to find updates from their database.

**Install Chocolatey package:** Open cmd as administrator and paste this: @"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "[System.Net.ServicePointManager]::SecurityProtocol = 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))" && SET "PATH=%PATH%;%ALLUSERSPROFILE%\chocolatey\bin"
