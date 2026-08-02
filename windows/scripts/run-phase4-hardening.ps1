#Requires -RunAsAdministrator

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$Output,
    [Parameter(Mandatory = $true)]
    [string]$RunId,
    [Parameter(Mandatory = $true)]
    [string]$DeviceAlias,
    [switch]$AcknowledgeDisposableVm,
    [string]$ServiceName = 'GamblockAIProtection',
    [ValidateRange(5, 120)]
    [int]$RecoveryTimeoutSeconds = 45
)

$ErrorActionPreference = 'Stop'
if (-not $AcknowledgeDisposableVm) {
    throw 'Use only on an approved disposable VM and pass -AcknowledgeDisposableVm.'
}
if ($RunId -notmatch '^[A-Za-z0-9_-]{1,64}$' -or
    $DeviceAlias -notmatch '^[A-Za-z0-9_-]{1,64}$' -or
    $ServiceName -notmatch '^[A-Za-z0-9_-]{1,128}$') {
    throw 'RunId, DeviceAlias, and ServiceName must be opaque safe labels.'
}

$Service = Get-CimInstance Win32_Service -Filter "Name='$ServiceName'"
if ($null -eq $Service) {
    throw "Service $ServiceName is not installed."
}
if ($Service.State -ne 'Running' -or [int]$Service.ProcessId -le 0) {
    throw "Service $ServiceName must be running before the scenario."
}

$InitialProcessId = [int]$Service.ProcessId
$Stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
Stop-Process -Id $InitialProcessId -Force

$Recovered = $false
$ReplacementProcessObserved = $false
do {
    Start-Sleep -Seconds 1
    $Current = Get-CimInstance Win32_Service -Filter "Name='$ServiceName'"
    if ($null -ne $Current -and $Current.State -eq 'Running' -and
        [int]$Current.ProcessId -gt 0) {
        $ReplacementProcessObserved = [int]$Current.ProcessId -ne $InitialProcessId
        if ($ReplacementProcessObserved) {
            $Recovered = $true
            break
        }
    }
} while ($Stopwatch.Elapsed.TotalSeconds -lt $RecoveryTimeoutSeconds)
$Stopwatch.Stop()

$Report = [ordered]@{
    schema_version = 1
    report_kind = 'phase4_resilience_run'
    platform = 'windows'
    run_id = $RunId
    device_alias = $DeviceAlias
    host_identifier_emitted = $false
    unsafe_critical_process_api_used = $false
    scenario_results = @(
        [ordered]@{
            scenario = 'ordinary_process_kill'
            attempted = $true
            passed = $Recovered
            device_recoverable = $true
            protection_recovered = $Recovered
            unsafe_behavior_observed = $false
            evidence_reference = 'windows_process_kill'
            recovery_within_seconds = [math]::Round($Stopwatch.Elapsed.TotalSeconds, 3)
        }
    )
    review = [ordered]@{
        approved = $false
        reviewer = $null
        reviewed_at = $null
    }
}

$Parent = Split-Path -Parent $Output
if ($Parent) {
    New-Item -ItemType Directory -Path $Parent -Force | Out-Null
}
$Report | ConvertTo-Json -Depth 5 | Set-Content -Path $Output -Encoding utf8
Write-Host "Windows resilience evidence written to $Output."
if (-not $Recovered) {
    exit 3
}
