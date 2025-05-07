$ErrorActionPreference = "Stop"

$destination = "C:\WSL\Ubuntu24"
$tarballName = "ubuntu-base-24.04.2-base-amd64.tar.gz"
$tarballPath = "$destination\$tarballName"
$distroName = "nixbuntu"
$totalSteps = 6

function Show-StepProgress {
    param (
        [int]$step,
        [string]$activity,
        [string]$status
    )
    Write-Progress -Activity $activity -Status $status -PercentComplete (($step / $totalSteps) * 100)
    Write-Host "`n[$step/$totalSteps] $status" -ForegroundColor Cyan
}

Show-StepProgress 1 "Setting up WSL environment" "Creating WSL rootfs directory..."
New-Item -ItemType Directory -Path $destination -Force | Out-Null

Show-StepProgress 2 "Setting up WSL environment" "Downloading Ubuntu base rootfs..."
if (-Not (Test-Path $tarballPath)) {
    Invoke-WebRequest `
        -Uri "https://cdimage.ubuntu.com/ubuntu-base/releases/noble/release/$tarballName" `
        -OutFile $tarballPath `
        -UseBasicParsing
} else {
    Write-Host "Tarball already exists at $tarballPath. Skipping download." -ForegroundColor Yellow
}

Show-StepProgress 3 "Setting up WSL environment" "Importing WSL distro '$distroName'..."
wsl --import $distroName $destination $tarballPath --version 2
wsl --set-default $distroName

Show-StepProgress 4 "Setting up WSL environment" "Installing minimal apt packages..."
wsl -d $distroName -- bash -c "apt update && DEBIAN_FRONTEND=noninteractive apt install -y sudo vim wget xz-utils openssh-client ca-certificates"

Show-StepProgress 5 "Setting up WSL environment" "Running Nixbuntu setup script..."
wsl -d $distroName -- bash -c "wget https://raw.githubusercontent.com/MohitRane8/dotfiles/main/wsl/setup-nixbuntu.sh -O /first-run.sh"
wsl -d $distroName -- chmod +x /first-run.sh
wsl -d $distroName -- bash /first-run.sh
wsl -d $distroName -- rm -f /first-run.sh

Show-StepProgress 6 "Setting up WSL environment" "Installing Nix packages..."
wsl --shutdown
wsl -d $distroName -- bash -c "sudo /nix/var/nix/profiles/default/bin/nix-daemon & disown; until pgrep -x nix-daemon > /dev/null; do sleep 0.5; done; source /etc/profile; EXIT_AFTER_HOOK=1 nix develop ~/.config/nix"

Write-Progress -Activity "Setup Complete" -Status "Launching WSL..." -Completed
Write-Host ""
Write-Host "================================================================" -ForegroundColor Yellow
Write-Host ">>> NEXT STEP (INSIDE WSL):" -ForegroundColor Yellow
Write-Host ">>> Make sure to do the following to enter your Nix environment:" -ForegroundColor Yellow
Write-Host ">>>     nix develop ~/.config/nix" -ForegroundColor Yellow
Write-Host "================================================================" -ForegroundColor Yellow
Write-Host ""
wsl
