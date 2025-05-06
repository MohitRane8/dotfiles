$ErrorActionPreference = "Stop"

$destination = "C:\WSL\Ubuntu24"
$tarballName = "ubuntu-base-24.04.2-base-amd64.tar.gz"
$tarballPath = "$destination\$tarballName"
$distroName = "nixbuntu"
$tempScript = "$env:TEMP\first-run.sh"

# Step 1: Create WSL rootfs directory
Write-Host "`n[1/6] Creating WSL rootfs directory at $destination..." -ForegroundColor Cyan
New-Item -ItemType Directory -Path $destination -Force | Out-Null

# Step 2: Download Ubuntu base rootfs
Write-Host "[2/6] Downloading Ubuntu base rootfs..." -ForegroundColor Cyan
Invoke-WebRequest `
  -Uri "https://cdimage.ubuntu.com/ubuntu-base/releases/noble/release/$tarballName" `
  -OutFile $tarballPath `
  -UseBasicParsing

# Step 3: Import WSL and set it as default
Write-Host "[3/6] Importing WSL distro '$distroName' using downloaded rootfs..." -ForegroundColor Cyan
wsl --import $distroName $destination $tarballPath --version 2
wsl --set-default $distroName

# Step 4: Install minimal apt packages
Write-Host "[4/6] Installing minimal apt packages..." -ForegroundColor Cyan
wsl -d $distroName -- bash -c "apt update && DEBIAN_FRONTEND=noninteractive apt install -y sudo vim wget xz-utils openssh-client ca-certificates"

# Step 5: Run Nixbuntu setup script
Write-Host "[5/6] Running Nixbuntu setup..." -ForegroundColor Cyan
wsl -d $distroName -- bash -c "wget https://raw.githubusercontent.com/MohitRane8/dotfiles/main/wsl/setup-nixbuntu.sh -O /first-run.sh"
wsl -d $distroName -- chmod +x /first-run.sh
wsl -d $distroName -- bash /first-run.sh
wsl -d $distroName -- rm -f /first-run.sh

# Step 6: Re-enter WSL with newly created username
Write-Host "[6/6] Re-entering WSL as $username..." -ForegroundColor Cyan
$username = wsl -d $distroName -- cat /root/.nixbuntu-user
Write-Host ""
Write-Host "============================================================" -ForegroundColor Yellow
Write-Host ">>> NEXT STEP (INSIDE WSL):" -ForegroundColor Yellow
Write-Host ">>> Run the following to enter your Nix environment:" -ForegroundColor Yellow
Write-Host ">>>     nix develop ~/.config/nix" -ForegroundColor Yellow
Write-Host "============================================================" -ForegroundColor Yellow
Write-Host ""
wsl -d $distroName --user $username
