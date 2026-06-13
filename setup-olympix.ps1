# Olympix CLI installer for Windows
# Downloads the CLI, verifies SHA-256, and runs login.
# Usage:
#   1. Right-click this file -> "Run with PowerShell"
#      or from a PowerShell prompt:  .\setup-olympix.ps1
#   2. Enter your email when prompted (defaults to the one below).

param(
    [string]$Email = "ashutoshkumarsingh0x@gmail.com",
    [string]$Version = "v0.11.83",
    [string]$InstallDir = $PSScriptRoot
)

$ErrorActionPreference = "Stop"

# --- Detect architecture --------------------------------------------------
$arch = if ($env:PROCESSOR_ARCHITECTURE -eq "ARM64") { "win-arm64" } else { "win-x64" }
Write-Host "Detected architecture: $arch" -ForegroundColor Cyan

# Published SHA-256 hashes (from https://olympix.github.io/installation/)
$expectedHashes = @{
    "win-x64"   = "57c3728f2ed4db03adc5b30054efc40517e51f6626885e9a347d255fbf62bead"
    "win-arm64" = "f317fa66cdd429dcbc843c5f032c64d39fdec6efd20fcf9291ac8cc9552e23bc"
}
$expected = $expectedHashes[$arch]

# --- Download -------------------------------------------------------------
$url    = "https://olympix-download.s3.amazonaws.com/cli/$Version/$arch/olympix.exe"
$target = Join-Path $InstallDir "olympix.exe"

Write-Host "Downloading $url" -ForegroundColor Cyan
Invoke-WebRequest -Uri $url -OutFile $target -UseBasicParsing

# --- Verify SHA-256 -------------------------------------------------------
$actual = (Get-FileHash $target -Algorithm SHA256).Hash.ToLower()
if ($actual -ne $expected) {
    Write-Host "SHA-256 mismatch!" -ForegroundColor Red
    Write-Host "  expected: $expected"
    Write-Host "  actual:   $actual"
    Remove-Item $target -Force
    exit 1
}
Write-Host "SHA-256 verified." -ForegroundColor Green

# --- Add to PATH for this session ----------------------------------------
$env:Path = "$InstallDir;$env:Path"

# Offer to add to user PATH permanently
$userPath = [Environment]::GetEnvironmentVariable("Path", "User")
if ($userPath -notlike "*$InstallDir*") {
    $answer = Read-Host "Add $InstallDir to your user PATH permanently? [Y/n]"
    if ($answer -eq "" -or $answer -match "^[Yy]") {
        [Environment]::SetEnvironmentVariable("Path", "$userPath;$InstallDir", "User")
        Write-Host "Added to user PATH (open a new terminal to pick it up)." -ForegroundColor Green
    }
}

# --- Login ----------------------------------------------------------------
Write-Host ""
Write-Host "Starting login for $Email" -ForegroundColor Cyan
Write-Host "Check your inbox for a one-time code, then paste it into the prompt below."
Write-Host ""
& $target login -e $Email

Write-Host ""
Write-Host "Done. Try:  olympix analyze" -ForegroundColor Green
Write-Host "Token is saved at ~/.opix/config.json"
