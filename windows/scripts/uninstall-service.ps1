#Requires -RunAsAdministrator
$ErrorActionPreference = "Stop"

$bundleRoot = Split-Path -Parent $PSScriptRoot
$serviceBinary = Join-Path $bundleRoot "gamblock_ai_service.exe"

if (-not (Test-Path $serviceBinary)) {
    throw "gamblock_ai_service.exe was not found next to the installed client bundle."
}

& $serviceBinary --admin-uninstall
if ($LASTEXITCODE -ne 0) {
    throw "Administrator service removal failed."
}

Write-Host "Gamblock AI protection service removed through the administrator break-glass path."
