# ===========================================
# RTL Support Installer for GitHub Copilot Chat
# ===========================================
# Run this script as:
#   powershell -ExecutionPolicy Bypass -File install.ps1
# ===========================================

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "   RTL Support Installer" -ForegroundColor Cyan
Write-Host "   For GitHub Copilot Chat" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$TargetDir = "$env:USERPROFILE\vscode-custom"

# Create target directory
if (-not (Test-Path $TargetDir)) {
    New-Item -ItemType Directory -Path $TargetDir -Force | Out-Null
    Write-Host "[OK] Created folder: $TargetDir" -ForegroundColor Green
} else {
    Write-Host "[OK] Folder exists: $TargetDir" -ForegroundColor Green
}

# Copy RTL scripts
Write-Host ""
Write-Host "Copying RTL scripts..." -ForegroundColor Yellow

$FilesToCopy = @(
    "copilot-rtl-prepend.js",
    "rtl-auto-inject.ps1",
    "rtl-auto-inject.vbs"
)

foreach ($file in $FilesToCopy) {
    $source = Join-Path $ScriptDir $file
    $dest = Join-Path $TargetDir $file
    if (Test-Path $source) {
        Copy-Item $source $dest -Force
        Write-Host "   [OK] $file" -ForegroundColor Green
    } else {
        Write-Host "   [WARN] $file not found (may not be needed)" -ForegroundColor Yellow
    }
}

# Add to Windows Startup
Write-Host ""
Write-Host "Setting up auto-start..." -ForegroundColor Yellow

$StartupFolder = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup"
$StartupScript = Join-Path $StartupFolder "rtl-copilot-injector.vbs"

$VbsContent = @"
Set WshShell = CreateObject("WScript.Shell")
WshShell.Run "powershell.exe -ExecutionPolicy Bypass -WindowStyle Hidden -File """ & WshShell.ExpandEnvironmentStrings("%USERPROFILE%") & "\vscode-custom\rtl-auto-inject.ps1""", 0, False
"@

Set-Content -Path $StartupScript -Value $VbsContent
Write-Host "   [OK] Added to Windows Startup" -ForegroundColor Green

# Add Registry key for extra reliability
try {
    New-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Run' -Name 'RTLCopilotInjector' -Value "wscript.exe `"$TargetDir\rtl-auto-inject.vbs`"" -PropertyType String -Force | Out-Null
    Write-Host "   [OK] Added Registry startup key" -ForegroundColor Green
} catch {
    Write-Host "   [WARN] Could not add Registry key (not critical)" -ForegroundColor Yellow
}

# Disable VS Code extension auto-updates
Write-Host ""
Write-Host "Configuring VS Code settings..." -ForegroundColor Yellow

$VSCodeSettingsPath = "$env:APPDATA\Code\User\settings.json"
if (Test-Path $VSCodeSettingsPath) {
    $settings = Get-Content $VSCodeSettingsPath -Raw | ConvertFrom-Json

    $settings | Add-Member -NotePropertyName "extensions.autoUpdate" -NotePropertyValue $false -Force
    $settings | Add-Member -NotePropertyName "extensions.autoCheckUpdates" -NotePropertyValue $false -Force

    $settings | ConvertTo-Json -Depth 10 | Set-Content $VSCodeSettingsPath
    Write-Host "   [OK] Disabled extension auto-updates" -ForegroundColor Green
} else {
    Write-Host "   [WARN] VS Code settings not found (install VS Code first)" -ForegroundColor Yellow
}

# Run initial injection
Write-Host ""
Write-Host "Running initial RTL injection..." -ForegroundColor Yellow

& powershell -ExecutionPolicy Bypass -File (Join-Path $ScriptDir "rtl-auto-inject.ps1")
Write-Host "   [OK] RTL injected!" -ForegroundColor Green

# Show results
Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "   Installation Complete!" -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "What was installed:" -ForegroundColor White
Write-Host "  - RTL scripts in: $TargetDir" -ForegroundColor Gray
Write-Host "  - Auto-start on Windows login" -ForegroundColor Gray
Write-Host "  - Disabled VS Code extension auto-updates" -ForegroundColor Gray
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "  1. Close VS Code completely" -ForegroundColor White
Write-Host "  2. Open VS Code again" -ForegroundColor White
Write-Host "  3. Open Copilot Chat and write in Hebrew!" -ForegroundColor White
Write-Host ""
Write-Host "If RTL stops working after an update, run:" -ForegroundColor Yellow
Write-Host "  $TargetDir\rtl-auto-inject.ps1" -ForegroundColor Cyan
Write-Host ""

Read-Host "Press Enter to exit"
