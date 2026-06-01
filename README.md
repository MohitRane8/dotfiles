# dotfiles

Personal configuration files for WSL and Ubuntu, managed with **Nix Home Manager** (packages) and **GNU Stow** (config symlinks).

## Quick Start

See [ENVIRONMENT-SETUP.md](ENVIRONMENT-SETUP.md) for full installation and usage instructions.

## Philosophy

The core philosophy of this setup is to achieve a stable, maintainable, and deterministic environment that behaves identically across Windows WSL and native Ubuntu OS. By combining **Nix Home Manager** for reproducible package management and **GNU Stow** for fast, symlink-based dotfile management, this setup guarantees cross-platform consistency without sacrificing developer experience.

## How It Works

- **Nix Home Manager** installs and manages all CLI tools (`flake.nix` + `home.nix`)
- **GNU Stow** symlinks config directories into `$HOME` (e.g., `stow zsh tmux nvim`)
- Same dotfiles repo works identically on WSL and native Ubuntu

## Repository Layout

```
dotfiles/
├── home-manager/   # Nix flake & package list (stow target)
├── zsh/            # Zsh config (.zshenv, zshrc, aliases, plugins)
├── nvim/           # Neovim config (git submodule)
├── tmux/           # Tmux config + TPM plugins (submodule)
├── lf/             # lf file manager config
├── lazygit/        # Lazygit config
├── htop/           # htop config
├── wezterm/        # WezTerm terminal config
├── firefox/        # Firefox config
├── wsl/            # WSL configuration (.wslconfig)
├── ENVIRONMENT-SETUP.md # Full setup & usage guide
└── README.md
```

Each top-level directory mirrors the XDG structure so that `stow <dir>` symlinks it correctly into `~`.
