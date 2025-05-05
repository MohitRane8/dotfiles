#!/bin/bash
set -e

# Prompt for root password
echo "Set root password:"
read -s -p "Enter root password: " ROOT_PASS
echo
read -s -p "Confirm root password: " ROOT_PASS_CONFIRM
echo

if [[ "$ROOT_PASS" != "$ROOT_PASS_CONFIRM" ]]; then
    echo "Root passwords do not match. Exiting."
    exit 1
fi

# Set root password
echo "root:$ROOT_PASS" | chpasswd
echo "Root password set."

# Prompt for new local user
read -p "Enter new local username: " USERNAME
read -s -p "Enter password for $USERNAME: " PASSWORD
echo
read -s -p "Confirm password for $USERNAME: " PASSWORD_CONFIRM
echo

if [[ "$PASSWORD" != "$PASSWORD_CONFIRM" ]]; then
    echo "Passwords do not match. Exiting."
    exit 1
fi

# Set user and password
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
mkdir -p /home/$USERNAME/.config/nix
wget -O /home/$USERNAME/.config/nix/flake.nix https://raw.githubusercontent.com/MohitRane8/dotfiles/main/wsl/flake.nix
chown -R "$USERNAME:$USERNAME" "/home/$USERNAME/.config"
chmod -R u+w "/home/$USERNAME/.config"

echo
echo "Setup complete. Exit WSL and re-enter with: wsl -d $WSL_DISTRO_NAME --user $USERNAME"
