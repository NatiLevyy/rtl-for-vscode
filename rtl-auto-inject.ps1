# RTL Auto-Injector for Claude Code AND Google Antigravity
# This script PREPENDS RTL support to the beginning of JS files
# Runs silently and handles all versions and all locations

$ErrorActionPreference = "SilentlyContinue"

# Log file for debugging
$LogFile = "$env:USERPROFILE\vscode-custom\rtl-inject.log"

function Write-Log($msg) {
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Add-Content -Path $LogFile -Value "$timestamp - $msg"
}

function Inject-RTL($JsFile, $RtlContent, $Name) {
    if (Test-Path $JsFile) {
        $Content = Get-Content $JsFile -Raw -ErrorAction SilentlyContinue

        # Check if already injected (look at the very beginning)
        if ($Content -and ($Content.Substring(0, [Math]::Min(50, $Content.Length)) -notmatch "RTL Support")) {
            Write-Log "Injecting RTL to $Name"

            # Backup original (only if no backup exists)
            $BackupPath = "$JsFile.original"
            if (-not (Test-Path $BackupPath)) {
                Copy-Item $JsFile $BackupPath -Force
                Write-Log "Backup created: $BackupPath"
            }

            # PREPEND RTL (put it at the very beginning)
            $NewContent = $RtlContent + "`r`n" + $Content
            [System.IO.File]::WriteAllText($JsFile, $NewContent)
            Write-Log "RTL injected successfully to $Name"
        } else {
            Write-Log "RTL already present in $Name"
        }
    } else {
        Write-Log "File not found: $JsFile"
    }
}

Write-Log "=========================================="
Write-Log "Starting RTL injection..."

$ClaudeRtlScript = "$env:USERPROFILE\vscode-custom\claude-code-rtl-prepend.js"
$AntigravityRtlScript = "$env:USERPROFILE\vscode-custom\antigravity-rtl-prepend.js"

# ==========================================
# PART 1: Claude Code in VS Code
# ==========================================
$VSCodeExtensionsPath = "$env:USERPROFILE\.vscode\extensions"

if (Test-Path $ClaudeRtlScript) {
    $ClaudeRtlContent = Get-Content $ClaudeRtlScript -Raw

    $ClaudeExtensions = Get-ChildItem -Path $VSCodeExtensionsPath -Filter "anthropic.claude-code-*" -Directory -ErrorAction SilentlyContinue

    foreach ($ext in $ClaudeExtensions) {
        $IndexJs = Join-Path $ext.FullName "webview\index.js"
        Inject-RTL $IndexJs $ClaudeRtlContent "Claude Code VS Code ($($ext.Name))"
    }
} else {
    Write-Log "Claude RTL script not found"
}

# ==========================================
# PART 2: Claude Code in Antigravity (user extensions)
# ==========================================
$AntigravityUserExtensionsPath = "$env:USERPROFILE\.antigravity\extensions"

if ((Test-Path $ClaudeRtlScript) -and (Test-Path $AntigravityUserExtensionsPath)) {
    $ClaudeRtlContent = Get-Content $ClaudeRtlScript -Raw

    $ClaudeExtensionsInAntigravity = Get-ChildItem -Path $AntigravityUserExtensionsPath -Filter "anthropic.claude-code-*" -Directory -ErrorAction SilentlyContinue

    foreach ($ext in $ClaudeExtensionsInAntigravity) {
        $IndexJs = Join-Path $ext.FullName "webview\index.js"
        Inject-RTL $IndexJs $ClaudeRtlContent "Claude Code Antigravity ($($ext.Name))"
    }
}

# ==========================================
# PART 3: Google Antigravity native chat
# ==========================================
$AntigravityPath = "$env:LOCALAPPDATA\Programs\Antigravity"
$AntigravityChatJs = "$AntigravityPath\resources\app\extensions\antigravity\out\media\chat.js"

if (Test-Path $AntigravityRtlScript) {
    $AntigravityRtlContent = Get-Content $AntigravityRtlScript -Raw
    Inject-RTL $AntigravityChatJs $AntigravityRtlContent "Google Antigravity Native"
} else {
    Write-Log "Antigravity RTL script not found"
}

Write-Log "RTL injection completed"
Write-Log "=========================================="
