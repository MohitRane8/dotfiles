$ErrorActionPreference = "Stop"

$distroName         = "Nixbuntu"
$tarballUrl         = "https://cdimage.ubuntu.com/ubuntu-base/releases/noble/release/ubuntu-base-24.04.2-base-amd64.tar.gz"
$importDestination  = "C:\WSL\Ubuntu24"

$tempDir            = [System.IO.Path]::GetTempPath()
$tarballPath        = Join-Path $tempDir ([System.IO.Path]::GetFileName($tarballUrl))
$setupScriptPath    = Join-Path $tempDir "setup-nixbuntu.sh"
$flakePath          = Join-Path $tempDir "flake.nix"

# WSL-friendly paths
$setupScriptPathWSL = ($setupScriptPath -replace '\\','/' -replace '^([A-Za-z]):','/mnt/$1').ToLower()
$flakePathWSL       = ($flakePath -replace '\\','/' -replace '^([A-Za-z]):','/mnt/$1').ToLower()

$totalSteps = 5
function Show-Step {
    param ([int]$step, [string]$msg)
    Write-Host "`n[$step/$totalSteps] $msg" -ForegroundColor Cyan
}

Show-Step 1 "Creating directory for WSL..."
New-Item -ItemType Directory -Path $importDestination -Force | Out-Null

Show-Step 2 "Downloading Ubuntu rootfs..."
if (-not (Test-Path $tarballPath)) {
    Invoke-WebRequest $tarballUrl -OutFile $tarballPath -UseBasicParsing
} else {
    Write-Host "Tarball already exists. Skipping download." -ForegroundColor Yellow
}

Show-Step 3 "Importing Ubuntu rootfs..."
wsl --import $distroName $importDestination $tarballPath --version 2

Show-Step 4 "Running $distroName setup script..."
Invoke-WebRequest "https://raw.githubusercontent.com/MohitRane8/dotfiles/main/wsl/setup-nixbuntu.sh" -OutFile $setupScriptPath
wsl -d $distroName -- bash -c "bash '$setupScriptPathWSL'"
wsl -t $distroName

Show-Step 5 "Installing Nix packages..."
Invoke-WebRequest "https://raw.githubusercontent.com/MohitRane8/dotfiles/main/wsl/flake.nix" -OutFile $flakePath
wsl -d $distroName -- bash -c "mkdir -p ~/.config/nix && mv '$flakePathWSL' ~/.config/nix/"
wsl -d $distroName -- bash -c "sudo /nix/var/nix/profiles/default/bin/nix-daemon & disown; until pgrep -x nix-daemon > /dev/null; do sleep 0.5; done; source /etc/profile; EXIT_AFTER_HOOK=true nix develop ~/.config/nix"

# Final output
Write-Host "`n`n>>> $distroName bootstrapped. You’re officially in dev mode. <<<" -ForegroundColor Green
Write-Host "------------------------------------------------------------" -ForegroundColor Yellow
Write-Host "To set it as your default WSL distro:" -ForegroundColor Yellow
Write-Host "  wsl --set-default $distroName" -ForegroundColor Cyan
Write-Host ""
Write-Host "To enter the distro if it's NOT the default:" -ForegroundColor Yellow
Write-Host "  wsl -d $distroName" -ForegroundColor Cyan
Write-Host ""
Write-Host "To enter the distro if it IS the default:" -ForegroundColor Yellow
Write-Host "  wsl" -ForegroundColor Cyan
Write-Host ""
Write-Host "Inside the distro, to enter your Nix environment:" -ForegroundColor Yellow
Write-Host "  nix develop ~/.config/nix" -ForegroundColor Cyan
Write-Host "------------------------------------------------------------`n" -ForegroundColor Yellow
