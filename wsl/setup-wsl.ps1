$destination = "C:\WSL\Ubuntu24"
$tarballName = "ubuntu-base-24.04.2-base-amd64.tar.gz"
$tarballPath = "$destination\$tarballName"
$distroName = "nixbuntu"

# Create destination directory
New-Item -ItemType Directory -Path $destination -Force | Out-Null

# Download the Ubuntu base tarball
Invoke-WebRequest `
  -Uri "https://cdimage.ubuntu.com/ubuntu-base/releases/noble/release/$tarballName" `
  -OutFile $tarballPath `
  -UseBasicParsing -ErrorAction Stop

# Import the WSL distro
wsl --import $distroName $destination $tarballPath --version 2

# Set it as the default
wsl --set-default $distroName

Write-Host "WSL distro '$distroName' is set up and set as default." -ForegroundColor Green
