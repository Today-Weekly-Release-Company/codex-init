$ErrorActionPreference = 'Stop'

if ([System.Environment]::OSVersion.Platform -ne [System.PlatformID]::Win32NT) {
    throw 'install.ps1 适用于 Windows 原生 PowerShell；macOS、Linux 和 WSL 请运行 install.sh。'
}

$rtk = Get-Command rtk -ErrorAction SilentlyContinue
if (-not $rtk) {
    $winget = Get-Command winget -ErrorAction SilentlyContinue
    if (-not $winget) {
        throw '缺少 RTK 和 winget。请按 INSTALL.md 的 Windows 指引安装 RTK。'
    }
    & winget install --id rtk-ai.rtk --exact --accept-package-agreements --accept-source-agreements
    if ($LASTEXITCODE -ne 0) { throw 'RTK 安装失败。' }
    $rtk = Get-Command rtk -ErrorAction SilentlyContinue
    if (-not $rtk) {
        throw 'RTK 已安装；请重新打开 PowerShell，再次运行 install.ps1 以刷新 PATH。'
    }
}
& rtk gain *> $null
if ($LASTEXITCODE -ne 0) { throw '检测到同名的非 Rust Token Killer rtk。' }
& rtk init --global --codex
if ($LASTEXITCODE -ne 0) { throw 'RTK Codex 全局集成失败。' }

& (Join-Path $PSScriptRoot 'scripts/sync-agents.ps1')
& (Join-Path $PSScriptRoot 'scripts/verify.ps1')
Write-Output '安装完成。请重启 Codex 或新建会话。'
