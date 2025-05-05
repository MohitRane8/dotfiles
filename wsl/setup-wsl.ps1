$ErrorActionPreference = "Stop"

$destination = "C:\WSL\Ubuntu24"
$tarballName = "ubuntu-base-24.04.2-base-amd64.tar.gz"
$tarballPath = "$destination\$tarballName"
$distroName = "nixbuntu"
$tempScript = "$env:TEMP\first-run.sh"

# Step 1: Create WSL rootfs directory
Write-Host "`n[1/7] Creating WSL rootfs directory at $destination..." -ForegroundColor Cyan
New-Item -ItemType Directory -Path $destination -Force | Out-Null

# Step 2: Download Ubuntu base rootfs
Write-Host "[2/7] Downloading Ubuntu base rootfs..." -ForegroundColor Cyan
Invoke-WebRequest `
  -Uri "https://cdimage.ubuntu.com/ubuntu-base/releases/noble/release/$tarballName" `
  -OutFile $tarballPath `
  -UseBasicParsing

# Step 3: Import WSL and set it as default
Write-Host "[3/7] Importing WSL distro '$distroName' using downloaded rootfs..." -ForegroundColor Cyan
wsl --import $distroName $destination $tarballPath --version 2
wsl --set-default $distroName


# Step 4: Copy the first-run script inside the new WSL instance
Write-Host "[4/7] Copying first-run script into WSL and executing it..." -ForegroundColor Cyan
wsl -d $distroName -- bash -c "wget https://raw.githubusercontent.com/MohitRane8/dotfiles/main/wsl/setup-nixbuntu.sh -O /first-run.sh"
wsl -d $distroName -- chmod +x /first-run.sh
wsl -d $distroName -- bash /first-run.sh

# Step 5: Clean up first-run script
Write-Host "[5/7] Cleaning up /first-run.sh..." -ForegroundColor Cyan
wsl -d $distroName --exec rm -f /first-run.sh

# Step 6: Read the created WSL username
Write-Host "[6/7] Reading created WSL username..." -ForegroundColor Cyan
$username = wsl -d $distroName --exec cat /root/.nixbuntu-user

# Step 7: Re-enter WSL with newly created username
Write-Host "[7/7] Re-entering WSL as $username..." -ForegroundColor Cyan
Write-Host "(Next step inside WSL) Run 'nix develop ~/.config/nix' to enter your Nix environment." -ForegroundColor Yellow
wsl -d $distroName --user $username
