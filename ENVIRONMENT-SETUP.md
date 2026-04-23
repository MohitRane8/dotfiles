# Environment Setup

## Table of Contents

- [Architecture & Features](#architecture--features)
- [Ubuntu OS Setup](#ubuntu-os-setup)
  - [Bootstrap Packages](#bootstrap-packages)
  - [Terminal Setup](#terminal-setup)
  - [Desktop Environment](#desktop-environment)
  - [Keyboard Modifications](#keyboard-modifications)
  - [Fonts](#fonts)
  - [Flatpaks](#flatpaks)
- [WSL Setup](#wsl-setup)
  - [Terminal Setup](#terminal-setup-1)
  - [Distribution Setup](#distribution-setup)
  - [DNS Fix](#dns-fix)
- [Nix Home Manager Setup (WSL & Ubuntu)](#nix-home-manager-setup-wsl--ubuntu)
- [Next Steps](#next-steps)
- [Enable Git Push (Owner Only)](#enable-git-push-owner-only)
- [Managing Packages](#managing-packages)
  - [Concepts](#concepts)
    - [How Home Manager Manages $PATH](#how-home-manager-manages-path)
    - [Nix Flakes and Git](#nix-flakes-and-git)
    - [Reproducibility (`flake.lock`)](#reproducibility-flakelock)
  - [Operations](#operations)
    - [Adding a Package](#adding-a-package)
    - [Removing a Package](#removing-a-package)
    - [Updating Package Versions](#updating-package-versions)
    - [Upgrading Home Manager Release](#upgrading-home-manager-release)
- [Tips](#tips)
  - [Ubuntu OS](#ubuntu-os)
  - [WSL](#wsl)
- [Backup & Restore](#backup--restore)
  - [WSL](#wsl-1)
- [Troubleshooting](#troubleshooting)
  - [General](#general)
  - [WSL](#wsl-2)

## Architecture & Features

### Philosophy

The core philosophy of this setup is to achieve a stable, maintainable, and deterministic environment that behaves identically across Windows WSL and native Ubuntu OS. By combining **Nix Home Manager** for reproducible package management and **GNU Stow** for fast, symlink-based dotfile management, this setup guarantees cross-platform consistency without sacrificing developer experience.

### Features

This setup uses **Nix Home Manager** exclusively to manage *packages* and global tools, while keeping GNU **Stow** for managing the *dotfiles* configurations (`.zshrc`, `.tmux.conf`, etc.).

- **`flake.nix`**: Defines inputs (package versions, home-manager version) and outputs (system configurations like WSL or native Ubuntu).
- **`home.nix`**: The list of installed packages, including optional dependencies based on the environment (e.g., WSL vs Ubuntu).
- **Portability:** The exact same environment across WSL and Ubuntu, utilizing the exact same dotfiles repo.
- **Global `PATH`:** Tools are permanently installed globally. IDEs and background services see them instantly without needing `nix develop`.
- **Hybrid Approach:** Home Manager handles the binaries, and Stow handles the config files, maintaining fast iteration.

## Ubuntu OS Setup

### Bootstrap Packages

A fresh Ubuntu 24.04 install is missing a couple of tools needed to run the rest of this guide (notably the Nix installer and the dotfiles clone). Install them via apt before doing anything else:
```bash
sudo apt update
sudo apt install -y git curl
```

> **Note:** These are the only apt packages you need to install by hand for the bootstrap. Once Home Manager is up, it provides its own `git` and `curl` (and they win on `$PATH` since `~/.nix-profile/bin` is prepended). It is recommended to **leave the apt versions in place** — they're tiny, and system services and root-run scripts that don't see your Nix profile may still rely on them.

### Terminal Setup

1. **Install [WezTerm](https://wezterm.org/install/linux.html#__tabbed_1_3)** via the official apt repository. apt is preferred over Home Manager here because the apt package handles desktop integration (`.desktop` entry, MIME types, font discovery) out of the box.

The `wezterm.lua` config is symlinked into place by Stow during the Nix Home Manager Setup steps below — no manual copy needed on Ubuntu.

### Desktop Environment

Install GNOME Tweaks for fine-grained desktop and shell customization:
```bash
sudo apt install -y gnome-tweaks
```

### Keyboard Modifications

#### Caps Lock / Escape Remap (keyd)

[keyd](https://github.com/rvaiya/keyd) is a low-level key remapping daemon that runs as a systemd service, so the remaps work uniformly across X11, Wayland, the TTY, and the login screen.

1. **Install keyd** from the maintainer's PPA:
   ```bash
   sudo add-apt-repository -y ppa:keyd-team/ppa
   sudo apt update
   sudo apt install -y keyd
   sudo systemctl enable --now keyd
   ```

2. **Deploy the config**
   The reference config lives in this repo at `keyd/etc/keyd/default.conf` (Caps Lock acts as Escape when tapped and Ctrl when held; Escape becomes Caps Lock). It is intentionally **not** stowed because `/etc/keyd/` is root-owned. Copy it manually and reload the daemon:
   ```bash
   sudo cp ~/dotfiles/keyd/etc/keyd/default.conf /etc/keyd/default.conf
   sudo keyd reload
   ```
   Re-run both commands whenever the reference file changes.

#### Key Repeat Rate

Speed up GNOME's keyboard repeat (lower `delay` and `repeat-interval` than the defaults expose in Settings):
```bash
gsettings set org.gnome.desktop.peripherals.keyboard delay 180
gsettings set org.gnome.desktop.peripherals.keyboard repeat-interval 20
```
These values are stored per-user in dconf and persist across reboots.

### Fonts

Install [Mononoki Nerd Font](https://github.com/ryanoasis/nerd-fonts/releases) (used by WezTerm — see `wezterm/.config/wezterm/wezterm.lua`) and [Inter Nerd Font](https://github.com/ryanoasis/nerd-fonts/releases) (used by GNOME / Tweaks):
```bash
mkdir -p ~/.local/share/fonts && cd ~/.local/share/fonts
curl -fLO https://github.com/ryanoasis/nerd-fonts/releases/latest/download/Mononoki.zip
curl -fLO https://github.com/ryanoasis/nerd-fonts/releases/latest/download/Inter.zip
unzip -o Mononoki.zip -d Mononoki
unzip -o Inter.zip -d Inter
rm Mononoki.zip Inter.zip
fc-cache -fv
```
Verify the fonts are registered:
```bash
fc-list | grep -iE 'mononoki|inter'
```

### Flatpaks

Flatpak is an ideal package manager for installing sandboxed GUI applications. It is generally not recommended for terminal-based tools or packages that require deep system integration, as the sandbox can prevent them from accessing necessary system resources.

#### Installation

```text-plain
sudo apt install flatpak
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
```

#### Useful Commands

##### Finding and Installing

- Search for an app: `flatpak search [app-name]` (or use [Flathub](https://flathub.org/en) to find the install command via the **Install** dropdown)
- Install an app: `flatpak install flathub [app-id]`
- Run an app from terminal: `flatpak run [app-id]`

##### Managing Your Apps

- List all installed apps and runtimes: `flatpak list`
- List only the apps you manually installed: `flatpak list --app`
- Update all Flatpaks and runtimes: `flatpak update`
- Uninstall an app: `flatpak uninstall [app-id]`

##### System Maintenance

- Remove "leftover" runtimes no longer used by any app: `flatpak uninstall --unused`
- Fix broken installations or mismatched metadata: `flatpak repair`
- Check information about an app (version, permissions, etc.): `flatpak info [app-id]`

#### Apps

The following are some useful GUI applications that can be installed on the system via Flatpak:

```text-plain
flatpak install flathub org.mozilla.firefox
flatpak install flathub org.vscodium.codium
flatpak install flathub com.github.tchx84.Flatseal
flatpak install flathub com.mattjakeman.ExtensionManager
flatpak install flathub com.valvesoftware.Steam
flatpak install flathub com.discordapp.Discord
flatpak install flathub org.localsend.localsend_app
```

## WSL Setup

### Terminal Setup

1. **Download and install [WezTerm](https://wezfurlong.org/wezterm/installation.html)** on Windows.

2. **Install the [mononoki Nerd Font](https://github.com/ryanoasis/nerd-fonts/releases)** on Windows. Download `Mononoki.zip` from the latest Nerd Fonts release, extract, and install the font files (right-click → Install for all users). The WezTerm config references this font.

3. **Configure the WezTerm shortcut to launch WSL**
   A shortcut is created automatically during installation. Open its properties and modify the Target:
   ```
   "C:\path\wezterm-gui.exe" --config default_cwd='\\\\wsl$' start -- wsl
   ```
   Replace `C:\path\wezterm-gui.exe` with the actual install path.

4. **Open WezTerm**, confirm WSL starts automatically, and pin it to the taskbar.

The `wezterm.lua` config file is copied to the Windows home directory in setup step 10.

### Distribution Setup

1. **Install the WSL distribution** from Windows CMD:
   ```
   wsl --install Ubuntu-24.04 --name Nixbuntu
   ```
   Set a username and password when prompted. WSL will start automatically after installation.

2. **Enable systemd** (required before installing Nix):
   ```bash
   sudo vim /etc/wsl.conf
   ```
   Ensure the file contains:
   ```ini
   [boot]
   systemd=true
   ```
   If the file was modified, restart WSL from Windows CMD and relaunch:
   ```
   wsl --shutdown
   wsl -d Nixbuntu
   ```

3. **Set the default directory to home** so the shell always opens in `~` instead of the Windows mount:
   ```bash
   echo 'cd ~' >> ~/.bashrc
   ```

4. **Verify network connectivity** before proceeding to the Nix installation:
   ```bash
   ping -c 1 google.com
   ```

### DNS Fix

> **When to use:** Only required when WSL is behind a network where DNS resolution is slow or broken. Symptoms include Nix commands or `git clone` failing with `Resolving timed out` while `ping` works fine.

WSL2 auto-generates `/etc/resolv.conf` pointing to its internal DNS relay (`10.255.255.254`), which forwards queries to the Windows host's DNS server. On some networks, this relay can add 20+ seconds of latency per DNS query, causing timeouts in tools like Nix, curl, and git. The fix is to bypass the relay by pointing directly at the actual DNS server.

1. **Get the DNS server IP**
   In **Windows Command Prompt** (not WSL), run:
   ```
   nslookup google.com
   ```
   Note the DNS server IP address (e.g., `10.x.x.x`). This is the actual DNS server that the WSL2 relay forwards to.

2. **Disable WSL auto-generated DNS config**
   Append to `/etc/wsl.conf` (same file edited in WSL Setup step 2):
   ```bash
   sudo tee -a /etc/wsl.conf > /dev/null <<'EOF'

   [network]
   generateResolvConf = false
   EOF
   ```

3. **Replace resolv.conf with the DNS server**
   Replace the WSL-managed symlink with a static file using the IP from step 1:
   ```bash
   sudo rm /etc/resolv.conf && \
   sudo tee /etc/resolv.conf > /dev/null <<'EOF'
   nameserver <DNS_SERVER_IP>
   EOF
   ```

4. **Verify** DNS resolution works:
   ```bash
   curl -sS -o /dev/null -w "%{http_code} in %{time_total}s\n" \
       https://api.github.com/repos/NixOS/nixpkgs/commits/nixpkgs-unstable
   ```
   This should complete in under a second. If it still times out, the DNS server IP may have changed -- repeat step 1 to get the current one.

> **Note:** The DNS server IP may change when switching between networks. If connectivity breaks after a network change, repeat step 1 to get the updated IP and rewrite `/etc/resolv.conf`.

## Nix Home Manager Setup (WSL & Ubuntu)

1. **Install Nix**
   ```bash
   sh <(curl -L https://nixos.org/nix/install) --daemon
   ```
   
   **Important:** After the installation finishes, reload the shell to make the `nix` command available:
   ```bash
   source /etc/profile
   ```

2. **Enable Nix Flakes**
   ```bash
   mkdir -p ~/.config/nix && echo "experimental-features = nix-command flakes" > ~/.config/nix/nix.conf
   ```

3. **Clone Dotfiles**
   ```bash
   git clone https://github.com/MohitRane8/dotfiles ~/dotfiles
   cd ~/dotfiles
   git submodule update --init --recursive
   ```

4. **Update Username Configuration**
   Update the username in `flake.nix` (the single source of truth for the username):
   ```bash
   sed -i 's/username = "mrane"/username = "'$USER'"/' home-manager/.config/home-manager/flake.nix
   ```

5. **Stow Configurations**
   Use Nix to ephemerally run Stow and link the dotfiles:
   ```bash
   cd ~/dotfiles
   nix shell nixpkgs\#stow -c stow home-manager zsh tmux lf nvim htop
   ```

   On **Ubuntu OS**, also stow `wezterm` so the WezTerm config is picked up from `~/.config/wezterm/wezterm.lua`:
   ```bash
   nix shell nixpkgs\#stow -c stow wezterm
   ```
   On WSL, the WezTerm config lives on the Windows side instead and is copied over manually in step 10.

6. **Verify Release Version**
   Review the checklist at the top of `home-manager/.config/home-manager/flake.nix` and ensure `nixpkgs.url`, `home-manager.url`, and `stateVersion` reflect the latest stable Home Manager release. The `nix run` command in the next step must also reference the same release branch. If any values were updated, stage the changes before proceeding:
   ```bash
   cd ~/dotfiles && git add -A
   ```

7. **Build Environment**
   Run Home Manager to install all packages. Replace `release-25.11` with the release branch from `flake.nix` if it was updated in step 6.
   - For **WSL**:
     ```bash
     nix run home-manager/release-25.11 -- switch --flake ~/.config/home-manager\#$USER-wsl
     ```
   - For **Ubuntu OS**:
     ```bash
     nix run home-manager/release-25.11 -- switch --flake ~/.config/home-manager\#$USER-ubuntu
     ```

   After this completes, `home-manager` is globally available. Subsequent updates use `home-manager switch` directly instead of `nix run`.

8. **Set Zsh as Default Shell**
   The Nix-installed zsh must be added to `/etc/shells` before `chsh` will accept it:
   ```bash
   echo "$HOME/.nix-profile/bin/zsh" | sudo tee -a /etc/shells
   chsh -s $(which zsh)
   ```
   Restart WSL (or log out and back in on Ubuntu) for the change to take effect.

9. **Create wslview symlink (WSL only)**
   The `wv` shell alias in `zsh-aliases` covers terminal usage, but programs like Neovim can't see shell aliases. Create a symlink so they can find `wslview` as `wv`:
   ```bash
   mkdir -p $HOME/.local/bin && ln -s $(which wslview) $HOME/.local/bin/wv
   ```

10. **Copy Windows-side configs (WSL only)**
    `.wslconfig` and the WezTerm config must live in the Windows user home directory. The WezTerm config is checked in at `wezterm/.config/wezterm/wezterm.lua` (so that `stow wezterm` works on native Ubuntu); on Windows it is copied to `~/.wezterm.lua`, which WezTerm reads from the Windows user home:
    ```bash
    cp ~/dotfiles/wsl/.wslconfig /mnt/c/Users/$WINUSERNAME/
    cp ~/dotfiles/wezterm/.config/wezterm/wezterm.lua /mnt/c/Users/$WINUSERNAME/.wezterm.lua
    ```
    Re-run these after modifying either file. Restart WSL (`wsl --shutdown`) for `.wslconfig` changes to take effect.

    > **Note:** Review `wsl/.wslconfig` before copying — `memory` limits how much RAM the WSL2 VM can use and `swap` sets the swap file size. The checked-in values (20GB memory, 8GB swap) suit a 32GB machine; adjust based on total system RAM.

11. **Commit `flake.lock` (Owner only)**
    The first `home-manager switch` generates `flake.lock`. Commit it along with any version changes made in step 6:
    ```bash
    cd ~/dotfiles && git add -A && git commit -m "Initial home-manager setup"
    ```

## Next Steps

The environment is ready to use. The following sections are optional:

- [Enable Git Push (Owner Only)](#enable-git-push-owner-only) — set up SSH keys for pushing to this repo
- [Custom CA Certificates](#custom-ca-certificates) — required if the network performs TLS inspection (under Troubleshooting)
- [Tips](#tips) — WSL-specific workflows such as mounting network drives and WSL utilities

## Enable Git Push (Owner Only)

1. **Set Git Identity**
   Required before any commit will succeed. Use the same email that's attached to your GitHub account so commits are attributed correctly:
   ```bash
   git config --global user.email "you@example.com"
   git config --global user.name  "Your Name"
   ```

2. **Generate SSH Key**
   ```bash
   ssh-keygen -t ed25519 -C "you@example.com"
   ```
   *Add the contents of `~/.ssh/id_ed25519.pub` to GitHub: Settings → SSH and GPG keys.*

3. **Add Key to SSH Agent (Optional)**
   If a passphrase is set and shouldn't be typed every time a push happens, add the key to the agent. *(Note: The agent resets when WSL/Ubuntu restarts; this can be automated later in `.zshrc` if desired.)*
   ```bash
   eval "$(ssh-agent -s)"
   ssh-add ~/.ssh/id_ed25519
   ```

4. **Switch Remotes to SSH**
   ```bash
   # Main dotfiles repo
   git -C ~/dotfiles remote set-url origin git@github.com:MohitRane8/dotfiles.git

   # Neovim submodule
   git -C ~/dotfiles/nvim/.config/nvim remote set-url origin git@github.com:MohitRane8/nvim-basic-ide.git
   ```

## Managing Packages

### Concepts

#### How Home Manager Manages $PATH

Home Manager automatically adds `~/.nix-profile/bin` to the system's `$PATH`. Because of this, existing stow configurations (like a Tmux config calling `rg` or Neovim calling `rust-analyzer`) will naturally find the Nix-installed binaries without any changes.

When `git` or `less` are specified in `home.nix`, Home Manager simply places the Nix version of the binary at the very front of the `$PATH`. When typing `git`, it safely intercepts the command and uses the Nix version instead of the system version, without breaking the host system.

Whenever a command is typed in the terminal (or a program tries to run a command), the operating system looks for it by scanning a list of folders defined in an environment variable called `$PATH`. It scans these folders from left to right, and stops at the very first match it finds.

When Home Manager is installed, it automatically prepends its own folder to the very front of the `$PATH`: `~/.nix-profile/bin:/usr/local/bin:/usr/bin:/bin`

#### Nix Flakes and Git

Nix flakes only see files that are **tracked by git**. Committed and staged files are visible; unstaged or untracked changes are silently ignored. This means any edit to `home.nix` or `flake.nix` must be staged before running `home-manager switch`, otherwise Nix evaluates the old version without warning.

The day-to-day workflow after any change:
```bash
cd ~/dotfiles && git add -A && \
home-manager switch --flake ~/.config/home-manager\#$USER-wsl
```
Replace `wsl` with `ubuntu` on native Ubuntu.

#### Reproducibility (`flake.lock`)

The `flake.lock` file pins every input in `flake.nix` to an exact git commit. It is shared between the WSL and Ubuntu configurations because both draw packages from the same set of inputs. The WSL-only and Ubuntu-only packages (e.g., `wslu` vs `wl-clipboard`) all come from the same pinned `nixpkgs` commit -- they are just conditionally *selected* at evaluation time by the `isWSL` flag in `home.nix`.

- **`flake.lock`** answers: *which version* of the nixpkgs catalog are we using?
- **`home.nix`** answers: *which packages* from that catalog do we install?

After the first `home-manager switch`, commit `flake.lock` to the repo. To update all inputs later, run `nix flake update` and then `home-manager switch`.

### Operations

#### Adding a Package
1. Open `home-manager/.config/home-manager/home.nix`.
2. Add the package name to the common list, or to the WSL/Ubuntu specific lists at the bottom.
3. Stage and apply:
   ```bash
   cd ~/dotfiles && git add -A && home-manager switch --flake ~/.config/home-manager\#$USER-wsl
   ```

#### Removing a Package
1. Delete the line from `home.nix`.
2. Stage and apply with the same command. Home Manager will unlink the removed package from the profile.

#### Updating Package Versions

`flake.nix` has two kinds of inputs:

- **Branch-based** (e.g., `nixos-25.11`): These branches receive backported fixes and security patches over time, but `flake.lock` pins them to the exact commit that was resolved on first run. Packages like `git`, `ripgrep`, `curl`, etc. come from this input.
- **Commit-pinned** (e.g., `neovim`, `tmux`): These point to specific commit hashes in `flake.nix` and never change unless you manually edit the hash. Only packages whose configs are sensitive to version changes are pinned.

`nix flake update` re-resolves all branch-based inputs to their latest commits and rewrites `flake.lock`. Commit-pinned packages are unaffected.

```bash
cd ~/dotfiles/home-manager/.config/home-manager && \
nix flake update && \
cd ~/dotfiles && git add -A && \
home-manager switch --flake ~/.config/home-manager\#$USER-wsl
```
Commit `flake.lock` afterwards to share the updated versions across machines.

#### Upgrading Home Manager Release

When a new stable release comes out (e.g., 26.05), update these two lines in `flake.nix`:

- `nixpkgs.url` — change `nixos-25.11` to `nixos-26.05`
- `home-manager.url` — change `release-25.11` to `release-26.05`

Then apply:
```bash
cd ~/dotfiles && git add -A && \
home-manager switch --flake ~/.config/home-manager\#$USER-wsl
```

`home.nix` does not need release-related changes. `stateVersion` in `flake.nix` is a compatibility flag — on an existing machine, leave it as-is. On a fresh install, set it to match the new release. The first-time setup command in step 7 also references `release-25.11`, but that command is only used once and does not affect subsequent `home-manager switch` calls.

## Tips

### Ubuntu OS

#### Inspecting Manually-Installed apt Packages

After running through Ubuntu OS Setup, the `git`, `curl`, `wezterm`, `gnome-tweaks`, `keyd`, `flatpak`, etc. packages are the only things installed via apt — everything else comes from Home Manager. Two commands help audit what's actually on the system:

- **`apt-mark showmanual`** — lists every package marked as manually installed (i.e., not pulled in only as a dependency). It includes packages that ship preinstalled on the Ubuntu image, so the list is longer than what you personally installed.
- **`grep "Commandline: apt install" /var/log/apt/history.log`** — replays only the `apt install` commands you actually typed (along with their flags). Useful for reconstructing what was installed by hand, especially after a long-lived install. Older entries roll into rotated logs (`/var/log/apt/history.log.*.gz`) — use `zgrep` to include those:
  ```bash
  zgrep "Commandline: apt install" /var/log/apt/history.log*
  ```

### WSL

#### Keyboard Modifications

**Key repeat rate** — Windows caps the repeat rate in Control Panel. To go beyond the limit, modify the registry values under `HKEY_CURRENT_USER\Control Panel\Accessibility\Keyboard Response`. See [this SuperUser answer](https://superuser.com/questions/1058474/increase-keyboard-repeat-rate-beyond-control-panel-limits-in-windows-10) for details. Original values:
```
"AutoRepeatDelay"="1000"
"AutoRepeatRate"="500"
"BounceTime"="0"
"DelayBeforeAcceptance"="1000"
"Flags"="126"
```
Faster values:
```
"AutoRepeatDelay"="200"
"AutoRepeatRate"="6"
"BounceTime"="0"
"DelayBeforeAcceptance"="0"
"Flags"="59"
```
Reboot for the changes to take effect.

**Key remapping** — [dual-key-remap](https://github.com/ililim/dual-key-remap) enables dual-purpose keys on Windows. After installing, create `config.txt` with:
```
remap_key=CAPSLOCK
when_alone=ESCAPE
with_other=CTRL

remap_key=ESCAPE
when_alone=CAPSLOCK
with_other=CAPSLOCK
```
This makes Caps Lock act as Escape when tapped alone and Ctrl when held with another key. Escape becomes Caps Lock for the rare occasions it is needed.

#### Check Disk Space

Scan the WSL filesystem excluding Windows mounts:
```bash
sudo ncdu / --exclude /mnt
```
The disk space used by the distro can also be confirmed on Windows under Settings → Apps → Installed apps by scrolling to the distribution.

#### Compact the VHDX

WSL2 stores the filesystem in a `.vhdx` virtual disk that grows as files are added but does not automatically shrink when files are deleted. To reclaim the free space, compact the VHDX from Windows CMD:
```
wsl --shutdown
diskpart
select vdisk file="C:\Users\<User>\AppData\Local\Packages\<DistroFolder>\LocalState\ext4.vhdx"
attach vdisk readonly
compact vdisk
detach vdisk
exit
```

#### Keep Projects in the WSL Filesystem

Although WSL2 can access Windows directories (`/mnt/c/...`), cross-filesystem access is significantly slower. Commands like `git status` that scan entire project trees become unusable on the Windows mount. Keep active projects in the native WSL filesystem (e.g., `~/Work/`).

[Reference](https://github.com/microsoft/WSL/issues/4197#issuecomment-604592340)

#### Mounting Windows Network Drives

Map the network drive in Windows first (search "Map network drive" → select drive letter → enter network path → check "Reconnect at sign-in").

Then in WSL, use `wslact auto-mount` (part of `wslu`) or manually add to `/etc/fstab` (replace `Z:` and `/mnt/z` with your drive letter and mount point):
```
Z: /mnt/z drvfs defaults 0 0
```
Then run `sudo mount -a`. To unmount later, run `sudo umount /mnt/z/`. Access speeds are slow but usable for occasional file transfers.

#### WSL Utilities Reference

[`wslu`](https://wslutiliti.es/wslu/) is installed via Home Manager. A `wv` shell alias is configured in `zsh-aliases`, and a symlink for non-shell programs is created in setup step 9.

**wslview** — open files, directories, and URLs in Windows:
- `wslview <file>` — open in the default Windows program
- `wslview <directory>` — open in Windows File Explorer
- `wslview -r $(wslpath -au 'C:\Program Files\Mozilla Firefox\firefox.exe')` — register a browser for link opening

**wslvar** — read Windows environment variables:
- `wslvar --getsys` — print all system environment variables
- `wslvar --sys <name>` — print a specific system variable
- `wslvar --getshell` — print all folder environment variables
- `wslvar --shell <name>` — print a specific folder variable

**wslpath** — convert paths between WSL and Windows (not part of wslu, built into WSL):
- `wslpath -w <linux_path>` — Linux to Windows path
- `wslpath -u <windows_path>` — Windows to Linux path

**Other utilities:**
- `wslsys` — print essential WSL specs
- `wslact auto-mount` — auto-mount mapped Windows network drives

There are other subcommands and options not covered here. See the [wslu documentation](https://wslutiliti.es/wslu/) and the [related Python library](https://github.com/wslutilities/wslpy).

#### Windows Executables from WSL

Windows binaries are accessible from WSL but require the `.exe` suffix. For example, `7z` calls the Linux binary while `7z.exe` calls the Windows-installed version.

When a tool is only installed on the Windows side (no Linux equivalent), WSL can call it directly via `.exe`. For scripts that need to work on both WSL and native Ubuntu, detect the environment and append the suffix:
```bash
if [[ -n "$WSL_DISTRO_NAME" ]]; then
    EXE_SUFFIX=".exe"
else
    EXE_SUFFIX=""
fi
```

When both versions are available, prefer the Linux binary -- calling `.exe` from WSL crosses the interop boundary and adds noticeable latency.

## Backup & Restore

### WSL

#### Backing Up

1. List installed distributions from Windows CMD:
   ```
   wsl -l -v
   ```
2. Shut down WSL to ensure a clean, consistent export:
   ```
   wsl --shutdown
   ```
3. Export the distribution:
   ```
   wsl --export <distro_name> <backup_path>\<distro_name>_<YYYY-MM-DD>.tar
   ```
   Optionally, compress with zstd and verify. `-19` sets high compression; `--rm` removes the original TAR after compression:
   ```
   zstd -19 --rm <backup_path>\<distro_name>_<YYYY-MM-DD>.tar
   zstd -t <backup_path>\<distro_name>_<YYYY-MM-DD>.tar.zst
   ```

[Reference](https://www.youtube.com/watch?v=sSC9Nag7djM)

#### Restoring

1. Remove the existing distribution before restoring (if replacing it):
   ```
   wsl --unregister <distro_name>
   ```
2. Import the backed up distribution. From an uncompressed TAR:
   ```
   wsl --import <distro_name> <install_path> <backup_path>\<distro_name>_<YYYY-MM-DD>.tar
   ```
   Or from a zstd-compressed archive via streaming decompression (avoids extracting a temp TAR to disk):
   ```
   zstd -dc <backup_path>\<distro_name>_<YYYY-MM-DD>.tar.zst | wsl --import <distro_name> <install_path> -
   ```
3. Confirm the distribution was imported:
   ```
   wsl -l -v
   ```
4. Start WSL and check if it starts with the intended user name. TAR imports default to root because the original user metadata is not preserved. If the user is wrong, add the following to `/etc/wsl.conf`:
   ```ini
   [user]
   default=<username_used_for_backed_up_distro>
   ```
   Restart WSL (`wsl --shutdown`) for the change to take effect.

> **Note:** zstd must be installed on Windows for the compression steps (e.g., `winget install Facebook.Zstandard`). `wsl --import` does not accept compressed archives directly, which is why streaming decompression is used.

## Troubleshooting

### General

#### Tmux Resurrect Session Restore

If tmux-resurrect fails to restore a session:

1. Navigate to the resurrect data directory:
   ```bash
   cd ~/.local/share/tmux/resurrect
   ```
2. Find the latest non-empty restore file and relink:
   ```bash
   ls -lt *.txt | head -5
   ln -sf <latest_non_empty_file> last
   ```
3. Launch tmux and restore the session normally.

[Reference](https://github.com/tmux-plugins/tmux-resurrect/issues/122)

### WSL

#### WSL2 Hangs

When WSL2 hangs, check the `Vmmem` process in Windows Task Manager for CPU/memory consumption. Common causes:
- Insufficient memory allocation in `.wslconfig` — ensure adequate RAM is configured
- Waking from Windows Hibernate can leave the VM in a bad state

To force-kill WSL, try these commands in order from Windows CMD (stop once it recovers):
```
wsl --shutdown
taskkill /f /im wslservice.exe
```
If that doesn't work, find and kill the LxssManager service host:
```
tasklist /svc /fi "imagename eq svchost.exe" | findstr LxssManager
taskkill /f /pid <PID>
```
If none of the above work, disable and re-enable the WSL feature and reboot:
```
dism.exe /online /disable-feature /featurename:Microsoft-Windows-Subsystem-Linux
dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux
```

#### Custom CA Certificates

> **When to use:** Required when the network performs TLS inspection or uses a self-signed root CA. Symptoms include Copilot, curl, or Node.js failing with certificate verification errors.

Networks that intercept HTTPS traffic inject their own root CA certificate into the TLS chain. WSL does not inherit the Windows certificate store, so these certificates must be installed manually.

1. **Export the certificate from Windows**

   Windows Menu → Manage User Certificates → Trusted Root Certification Authorities → Certificates → select the relevant certificate → double-click → Details tab → Copy to File → Base-64 encoded X.509 (.CER) → save to a WSL-accessible path.

2. **Convert and install in WSL**
   ```bash
   openssl x509 -inform PEM -in <sourcefile.cer> -out <sourcefile.crt>
   sudo cp <sourcefile.crt> /usr/local/share/ca-certificates/
   sudo chmod 755 /usr/local/share/ca-certificates/<sourcefile.crt>
   sudo update-ca-certificates
   ```

3. **Export the CA path for Node.js**

   This is already configured in `zsh/.config/zsh/zsh-exports`:
   ```bash
   export NODE_EXTRA_CA_CERTS="/usr/local/share/ca-certificates/<sourcefile.crt>"
   ```
   Update the filename if your certificate differs.

References:
- [Converting certificates from Windows to Linux](https://phumipatc.medium.com/how-to-convert-certificate-file-from-windows-to-linux-and-how-to-import-certificate-file-on-linux-4ae78a9740e2)
- [Copilot self-signed cert fix](https://sidd.io/2023/01/github-copilot-self-signed-cert-issue/)
- [windows-certs-2-wsl](https://github.com/bayaro/windows-certs-2-wsl) — script to bulk-export all Windows CA certificates into WSL (alternative to manual export)

> **Note:** Neovim's GitHub Copilot plugin is disabled by default. If enabled (`nvim/.config/nvim/lua/user/copilot.lua`), complete this section first so Copilot can verify TLS certificates.
