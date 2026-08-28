#Requires -RunAsAdministrator

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true, Position = 0)]
    [ValidateSet('Enable', 'Disable', 'Clear', 'Export')]
    [string]$Action,
    [string]$RunId,
    [string]$DeviceAlias,
    [string]$Scenario,
    [string]$Output
)

$ErrorActionPreference = 'Stop'
$EvidenceDirectory = Join-Path $env:ProgramData 'GamblockAI\phase4-evidence'
$ConfigPath = Join-Path $EvidenceDirectory 'config.json'
$LatencyPath = Join-Path $EvidenceDirectory 'latency.jsonl'

function Assert-SafeLabel {
    param([string]$Name, [string]$Value)
    if ($Value -notmatch '^[A-Za-z0-9_-]{1,64}$') {
        throw "$Name must be an opaque 1-64 character label using A-Z, a-z, 0-9, _ or -."
    }
}

function Assert-Scenario {
    param([string]$Value)
    $allowed = @(
        'warm_foreground_online', 'warm_foreground_offline',
        'warm_background_online', 'warm_background_offline',
        'cold_foreground_online', 'cold_foreground_offline',
        'cold_background_online', 'cold_background_offline'
    )
    if ($Value -notin $allowed) {
        throw 'Scenario must combine warm/cold, foreground/background, and online/offline.'
    }
}

switch ($Action) {
    'Enable' {
        Assert-SafeLabel 'RunId' $RunId
        Assert-SafeLabel 'DeviceAlias' $DeviceAlias
        Assert-SafeLabel 'Scenario' $Scenario
        Assert-Scenario $Scenario
        New-Item -ItemType Directory -Path $EvidenceDirectory -Force | Out-Null
        @{
            run_id = $RunId
            device_alias = $DeviceAlias
            scenario = $Scenario
        } | ConvertTo-Json | Set-Content -Path $ConfigPath -Encoding utf8
        Write-Host "Windows Phase 4 evidence mode enabled for $Scenario."
    }
    'Disable' {
        Remove-Item -LiteralPath $ConfigPath -Force -ErrorAction SilentlyContinue
        Write-Host 'Windows Phase 4 evidence mode disabled.'
    }
    'Clear' {
        Remove-Item -LiteralPath $LatencyPath -Force -ErrorAction SilentlyContinue
        Write-Host 'Windows Phase 4 latency evidence cleared.'
    }
    'Export' {
        if ([string]::IsNullOrWhiteSpace($Output)) {
            throw 'Export requires -Output.'
        }
        if (-not (Test-Path -LiteralPath $LatencyPath -PathType Leaf)) {
            throw 'No Windows Phase 4 latency evidence exists.'
        }
        $Parent = Split-Path -Parent $Output
        if ($Parent) {
            New-Item -ItemType Directory -Path $Parent -Force | Out-Null
        }
        Copy-Item -LiteralPath $LatencyPath -Destination $Output -Force
        Write-Host "Windows Phase 4 evidence exported to $Output."
    }
}
