$ErrorActionPreference = "Stop"

$destination = "C:\WSL\Ubuntu24"
$tarballName = "ubuntu-base-24.04.2-base-amd64.tar.gz"
$tarballPath = "$destination\$tarballName"
$distroName = "nixbuntu"
$tempScript = "$env:TEMP\first-run.sh"

# Step 1: Create WSL rootfs directory
Write-Host "`n[1/8] Creating WSL rootfs directory at $destination..." -ForegroundColor Cyan
New-Item -ItemType Directory -Path $destination -Force | Out-Null

# Step 2: Download Ubuntu base rootfs
Write-Host "[2/8] Downloading Ubuntu base rootfs..." -ForegroundColor Cyan
Invoke-WebRequest `
  -Uri "https://cdimage.ubuntu.com/ubuntu-base/releases/noble/release/$tarballName" `
  -OutFile $tarballPath `
  -UseBasicParsing

# Step 3: Download WSL first-run setup script to a temp location
Write-Host "[3/8] Downloading first-run WSL setup script..." -ForegroundColor Cyan
Invoke-WebRequest `
  -Uri "https://raw.githubusercontent.com/MohitRane8/dotfiles/main/wsl/setup-nixbuntu.sh" `
  -OutFile $tempScript

# Step 4: Import WSL and set it as default
Write-Host "[4/8] Importing WSL distro '$distroName' using downloaded rootfs..." -ForegroundColor Cyan
wsl --import $distroName $destination $tarballPath --version 2
wsl --set-default $distroName


# Step 5: Copy the first-run script inside the new WSL instance
Write-Host "[5/8] Copying first-run script into WSL and executing it..." -ForegroundColor Cyan
Get-Content $tempScript | wsl -d $distroName -- bash -c "cat > /first-run.sh"
wsl -d $distroName -- chmod +x /first-run.sh
wsl -d $distroName -- bash /first-run.sh

# Step 6: Clean up first-run script
Write-Host "[6/8] Cleaning up /first-run.sh..." -ForegroundColor Cyan
wsl -d $distroName --exec rm -f /first-run.sh

# Step 6: Read the created WSL username
Write-Host "[7/8] Reading created WSL username..." -ForegroundColor Cyan
$username = wsl -d $distroName --exec cat /root/.nixbuntu-user

# Step 7: Re-enter WSL with newly created username
Write-Host "[8/8] Re-entering WSL as $username..." -ForegroundColor Cyan
Write-Host "(Next step inside WSL) Run 'nix develop ~/.config/nix' to enter your Nix environment." -ForegroundColor Yellow
wsl -d $distroName --user $username
