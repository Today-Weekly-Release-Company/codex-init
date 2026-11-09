$ErrorActionPreference = 'Stop'

$projectDir = Split-Path -Parent $PSScriptRoot
$testRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("codex-init-test-{0}" -f [guid]::NewGuid().ToString('N'))
$codexDir = Join-Path $testRoot '.codex'
$stubDir = Join-Path $testRoot 'bin'
$originalCodexHome = $env:CODEX_HOME
$originalPath = $env:PATH
$utf8 = [System.Text.UTF8Encoding]::new($false)
$isNativeWindows = [System.Environment]::OSVersion.Platform -eq [System.PlatformID]::Win32NT

try {
    [System.IO.Directory]::CreateDirectory($codexDir) | Out-Null
    [System.IO.Directory]::CreateDirectory($stubDir) | Out-Null
    $env:CODEX_HOME = $codexDir
    $env:PATH = "$stubDir$([System.IO.Path]::PathSeparator)$originalPath"

    $agentsPath = Join-Path $codexDir 'AGENTS.md'
    $originalAgents = @'
# 用户已有规则

<!-- AI_DEV_KIT_START -->
旧内容
<!-- AI_DEV_KIT_END -->

<!-- OTHER_TOOL_START -->
保留其他工具托管内容
<!-- OTHER_TOOL_END -->
'@
    [System.IO.File]::WriteAllText($agentsPath, ($originalAgents -replace "`r?`n", "`r`n"), $utf8)

    & (Join-Path $projectDir 'scripts/sync-agents.ps1') | Out-Null
    $firstSync = [System.IO.File]::ReadAllText($agentsPath)
    & (Join-Path $projectDir 'scripts/sync-agents.ps1') | Out-Null
    $secondSync = [System.IO.File]::ReadAllText($agentsPath)
    if ($firstSync -ne $secondSync -or
        [regex]::IsMatch($secondSync, '(?<!\r)\n') -or
        [regex]::Matches($secondSync, '(?m)^<!-- AI_DEV_KIT_START -->\r?$').Count -ne 1 -or
        -not $secondSync.Contains('# 用户已有规则') -or
        -not $secondSync.Contains('保留其他工具托管内容') -or
        -not $secondSync.Contains('# codex-init 全局开发规则') -or
        -not (Test-Path -LiteralPath "$agentsPath.ai-dev-kit.bak")) {
        throw '全局 AGENTS.md 同步未通过幂等与保留检查。'
    }

    if ($isNativeWindows) {
        [System.IO.File]::WriteAllText((Join-Path $stubDir 'rtk.cmd'), "@echo off`r`nexit /b 0`r`n", $utf8)
    } else {
        $path = Join-Path $stubDir 'rtk'
        [System.IO.File]::WriteAllText($path, "#!/bin/sh`nexit 0`n", $utf8)
        & chmod +x $path
    }

    & (Join-Path $projectDir 'scripts/verify.ps1')
    if ($isNativeWindows) {
        & (Join-Path $projectDir 'install.ps1') | Out-Null
    }

    $brokenDir = Join-Path $testRoot 'broken'
    [System.IO.Directory]::CreateDirectory($brokenDir) | Out-Null
    [System.IO.File]::WriteAllText((Join-Path $brokenDir 'AGENTS.md'), "<!-- AI_DEV_KIT_END -->`n<!-- AI_DEV_KIT_START -->`n", $utf8)
    $env:CODEX_HOME = $brokenDir
    $rejected = $false
    try { & (Join-Path $projectDir 'scripts/sync-agents.ps1') | Out-Null } catch { $rejected = $true }
    if (-not $rejected) { throw 'sync-agents.ps1 应拒绝顺序错误的标记。' }

    $env:CODEX_HOME = $codexDir
    [System.IO.File]::WriteAllText((Join-Path $codexDir 'AGENTS.override.md'), '覆盖规则', $utf8)
    $rejected = $false
    try { & (Join-Path $projectDir 'scripts/verify.ps1') | Out-Null } catch { $rejected = $true }
    if (-not $rejected) { throw 'verify.ps1 应在全局规则被 override 遮蔽时失败。' }

    Write-Output 'scripts_test.ps1: passed'
} finally {
    $env:CODEX_HOME = $originalCodexHome
    $env:PATH = $originalPath
    if (Test-Path -LiteralPath $testRoot) {
        Remove-Item -LiteralPath $testRoot -Recurse -Force
    }
}
