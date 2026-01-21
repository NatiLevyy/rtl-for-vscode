Set WshShell = CreateObject("WScript.Shell")
WshShell.Run "powershell.exe -ExecutionPolicy Bypass -WindowStyle Hidden -File """ & WshShell.ExpandEnvironmentStrings("%USERPROFILE%") & "\vscode-custom\rtl-auto-inject.ps1""", 0, False
