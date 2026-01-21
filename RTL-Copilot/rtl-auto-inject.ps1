# RTL Auto-Injector for GitHub Copilot Chat
# This script PREPENDS RTL support to the beginning of JS files
# Runs silently and handles all versions

$ErrorActionPreference = "SilentlyContinue"

# Log file for debugging
$LogFile = "$env:USERPROFILE\vscode-custom\rtl-copilot-inject.log"

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
Write-Log "Starting Copilot RTL injection..."

$CopilotRtlScript = "$env:USERPROFILE\vscode-custom\copilot-rtl-prepend.js"

if (-not (Test-Path $CopilotRtlScript)) {
    Write-Log "Copilot RTL script not found at $CopilotRtlScript"
    Write-Log "=========================================="
    exit
}

$CopilotRtlContent = Get-Content $CopilotRtlScript -Raw

# ==========================================
# GitHub Copilot Chat Extensions
# ==========================================
$VSCodeExtensionsPath = "$env:USERPROFILE\.vscode\extensions"

# Find all Copilot Chat extensions
$CopilotExtensions = Get-ChildItem -Path $VSCodeExtensionsPath -Filter "github.copilot-chat-*" -Directory -ErrorAction SilentlyContinue

foreach ($ext in $CopilotExtensions) {
    # Inject to extension.js (main extension file)
    $ExtensionJs = Join-Path $ext.FullName "dist\extension.js"
    Inject-RTL $ExtensionJs $CopilotRtlContent "Copilot Chat extension.js ($($ext.Name))"

    # Inject to suggestionsPanelWebview.js (webview file)
    $SuggestionsJs = Join-Path $ext.FullName "dist\suggestionsPanelWebview.js"
    Inject-RTL $SuggestionsJs $CopilotRtlContent "Copilot Chat suggestionsPanelWebview.js ($($ext.Name))"
}

Write-Log "Copilot RTL injection completed"
Write-Log "=========================================="
