@echo off
setlocal EnableExtensions DisableDelayedExpansion

>nul 2>&1 net session
if %errorlevel% neq 0 (
    powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "Start-Process -FilePath 'cmd.exe' -ArgumentList '/c ""%~f0""' -Verb RunAs"
    exit /b
)

set "SCRIPT_PATH=%~f0"

powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "$path=$env:SCRIPT_PATH; $lines=Get-Content -LiteralPath $path; $marker=':POWERSHELL'; $index=[System.Array]::IndexOf($lines,$marker); if($index -lt 0){exit 1}; $code=$lines[($index+1)..($lines.Count-1)] -join [Environment]::NewLine; & ([scriptblock]::Create($code))"

exit /b

:POWERSHELL
$ErrorActionPreference = "Continue"

function Add-AvailableUpdates {
    param (
        [object]$Searcher,
        [object]$Updates,
        [hashtable]$Seen,
        [string]$Query
    )

    try {
        $results = $Searcher.Search($Query)
    } catch {
        return
    }

    foreach ($update in $results.Updates) {
        $key = "$($update.Identity.UpdateID)-$($update.Identity.RevisionNumber)"

        if ($Seen.ContainsKey($key)) {
            continue
        }

        if (-not $update.EulaAccepted) {
            try {
                $update.AcceptEula() | Out-Null
            } catch {
            }
        }

        $Updates.Add($update) | Out-Null
        $Seen[$key] = $true
    }
}

winget source update
winget upgrade --all --include-unknown --silent --disable-interactivity --accept-package-agreements --accept-source-agreements

Update-MpSignature -ErrorAction SilentlyContinue

$serviceManager = New-Object -ComObject Microsoft.Update.ServiceManager

try {
    $serviceManager.AddService2("7971f918-a847-4430-9279-4a52d1efe18d", 7, "") | Out-Null
} catch {
}

$session = New-Object -ComObject Microsoft.Update.Session
$searcher = $session.CreateUpdateSearcher()
$searcher.ServiceID = "7971f918-a847-4430-9279-4a52d1efe18d"
$searcher.ServerSelection = 3

$updates = New-Object -ComObject Microsoft.Update.UpdateColl
$seen = @{}

$queries = @(
    "IsInstalled=0 and Type='Software'",
    "IsInstalled=0 and Type='Software' and DeploymentAction='OptionalInstallation'",
    "IsInstalled=0 and Type='Driver'",
    "IsInstalled=0 and Type='Driver' and DeploymentAction='OptionalInstallation'"
)

foreach ($query in $queries) {
    Add-AvailableUpdates -Searcher $searcher -Updates $updates -Seen $seen -Query $query
}

if ($updates.Count -gt 0) {
    $downloader = $session.CreateUpdateDownloader()
    $downloader.Updates = $updates
    $downloader.Download() | Out-Null

    $installer = $session.CreateUpdateInstaller()
    $installer.Updates = $updates
    $installer.Install() | Out-Null
}

$tempPaths = @(
    $env:TEMP,
    $env:TMP,
    "$env:SystemRoot\Temp"
) | Where-Object {
    $_ -and (Test-Path -LiteralPath $_)
} | Select-Object -Unique

foreach ($tempPath in $tempPaths) {
    Get-ChildItem -LiteralPath $tempPath -Force -ErrorAction SilentlyContinue | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
}