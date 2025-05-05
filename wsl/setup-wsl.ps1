$ErrorActionPreference = "Stop"

$destination = "C:\WSL\Ubuntu24"
$tarballName = "ubuntu-base-24.04.2-base-amd64.tar.gz"
$tarballPath = "$destination\$tarballName"
$distroName = "nixbuntu"

# Step 1: Create WSL rootfs directory
Write-Host "`n[1/7] Creating WSL rootfs directory at $destination..." -ForegroundColor Cyan
New-Item -ItemType Directory -Path $destination -Force | Out-Null

# Step 2: Download Ubuntu base rootfs
Write-Host "[2/7] Downloading Ubuntu base rootfs..." -ForegroundColor Cyan
Invoke-WebRequest `
  -Uri "https://cdimage.ubuntu.com/ubuntu-base/releases/noble/release/$tarballName" `
  -OutFile $tarballPath `
  -UseBasicParsing

# Step 3: Download WSL first-run script into rootfs
Write-Host "[3/7] Downloading first-run WSL setup script..." -ForegroundColor Cyan
Invoke-WebRequest `
  -Uri "https://raw.githubusercontent.com/MohitRane8/dotfiles/main/wsl/setup-nixbuntu.sh" `
  -OutFile "$destination\first-run.sh"

# Step 4: Import WSL and set it as default
Write-Host "[4/7] Importing WSL distro '$distroName' using downloaded rootfs..." -ForegroundColor Cyan
wsl --import $distroName $destination $tarballPath --version 2
wsl --set-default $distroName

# Step 5: Launch WSL and run setup
Write-Host "[5/7] Running first-time WSL setup script inside '$distroName'..." -ForegroundColor Cyan
wsl -d $distroName --exec bash /first-run.sh

# Step 6: Read the created WSL username
Write-Host "[6/7] Reading created WSL username..." -ForegroundColor Cyan
$username = wsl -d $distroName --exec cat /root/.nixbuntu-user

# Step 7: Re-enter WSL with newly created username
Write-Host "[7/7] Re-entering WSL as $username..." -ForegroundColor Cyan
Write-Host "(Next step inside WSL) Run 'nix develop ~/.config/nix' to enter your Nix environment." -ForegroundColor Yellow
wsl -d $distroName --user $username
