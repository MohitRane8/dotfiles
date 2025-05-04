#!/bin/bash
set -e

# Prompt for username
read -p "Enter new username: " USERNAME

# Prompt silently for password
read -s -p "Enter password for $USERNAME: " PASSWORD
echo

# Create user and configure WSL default user
useradd -m -s /bin/bash "$USERNAME"
echo "$USERNAME:$PASSWORD" | chpasswd
usermod -aG adm,cdrom,sudo,dip,plugdev "$USERNAME"

# Set default WSL user
echo "[user]
default=$USERNAME" > /etc/wsl.conf

# Install Nix
echo "Installing Nix (daemon mode)"
wget -qO- https://nixos.org/nix/install | bash -s -- --daemon

# Add nix-daemon autostart script
cat << 'EOF' > /etc/profile.d/nix-autostart.sh
if ! pgrep -x nix-daemon > /dev/null; then
    sudo /nix/var/nix/profiles/default/bin/nix-daemon &
fi
EOF
chmod +x /etc/profile.d/nix-autostart.sh

# Update sudoers to run nix-daemon without password
echo "$USERNAME ALL=(ALL) NOPASSWD: /nix/var/nix/profiles/default/bin/nix-daemon" | tee /etc/sudoers.d/nix-daemon
chmod 440 /etc/sudoers.d/nix-daemon

# Enable flakes
mkdir -p /etc/nix
echo "experimental-features = nix-command flakes" >> /etc/nix/nix.conf

# Get flake.nix
mkdir -p ~/.config/nix
wget -O ~/.config/nix/flake.nix https://raw.githubusercontent.com/MohitRane8/dotfiles/main/wsl/flake.nix

echo
echo "Setup complete. Exit WSL and re-enter with: wsl -d <distro-name> --user $USERNAME"
