#Requires -RunAsAdministrator
$ErrorActionPreference = "Stop"

$bundleRoot = Split-Path -Parent $PSScriptRoot
$serviceBinary = Join-Path $bundleRoot "gamblock_ai_service.exe"

if (-not (Test-Path $serviceBinary)) {
    throw "gamblock_ai_service.exe was not found next to the installed client bundle."
}

& $serviceBinary --install
if ($LASTEXITCODE -ne 0) {
    throw "Gamblock AI protection service installation failed."
}

Write-Host "Gamblock AI protection service installed with SCM recovery enabled."
