$ErrorActionPreference = 'Stop'

$codexDir = if ($env:CODEX_HOME) { $env:CODEX_HOME } else { Join-Path $HOME '.codex' }
$agentsPath = Join-Path $codexDir 'AGENTS.md'
$failed = $false

function Report([bool]$success, [string]$message) {
    if ($success) {
        Write-Output "PASS  $message"
    } else {
        Write-Output "FAIL  $message"
        $script:failed = $true
    }
}

$rtk = Get-Command rtk -ErrorAction SilentlyContinue
$rtkReady = $false
if ($rtk) {
    & rtk gain *> $null
    $rtkReady = $LASTEXITCODE -eq 0
}
Report $rtkReady 'RTK 可用且为 Rust Token Killer'

$agents = if (Test-Path -LiteralPath $agentsPath -PathType Leaf) {
    [System.IO.File]::ReadAllText($agentsPath)
} else { '' }
Report ($agents.Contains('<!-- AI_DEV_KIT_START -->') -and $agents.Contains('<!-- AI_DEV_KIT_END -->')) '全局 AGENTS.md 已同步'

$overridePath = Join-Path $codexDir 'AGENTS.override.md'
$overrideActive = (Test-Path -LiteralPath $overridePath -PathType Leaf) -and
    ([System.IO.File]::ReadAllText($overridePath).Trim().Length -gt 0)
Report (-not $overrideActive) '全局 AGENTS.md 未被 override 文件遮蔽'

if ($failed) {
    throw '安装验证失败；请根据 FAIL 项检查当前环境。'
}
