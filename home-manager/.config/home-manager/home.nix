{ config, pkgs, inputs, isWSL, username, stateVersion, ... }:

let
  # Import pinned packages using the system architecture
  system = pkgs.system;
  pinned = {
    neovim = inputs.neovimPkgs.legacyPackages.${system}.neovim;
    tmux   = inputs.tmuxPkgs.legacyPackages.${system}.tmux;
  };
in
{
  home.username = username;
  home.homeDirectory = "/home/${username}";
  home.stateVersion = stateVersion;

  home.packages = with pkgs; [
    # =========================================================================
    # PINNED PACKAGES
    # =========================================================================
    pinned.neovim                    # [PINNED 0.10.4] extensible text editor
    pinned.tmux                      # [PINNED 3.6a] terminal multiplexer

    # =========================================================================
    # ESSENTIALS
    # =========================================================================
    stow                             # symlink farm manager (dotfiles)
    zsh                              # Z shell
    zsh-completions                  # additional completions for zsh
    lf                               # terminal file manager
    atuin                            # shell history manager
    vim                              # fallback editor
    trashy                           # trash CLI (rm alternative)
    ripgrep                          # fast recursive grep
    fd                               # fast alternative to find
    fzf                              # fuzzy finder
    zoxide                           # smarter cd command
    tree                             # directory listing as a tree
    bat                              # cat with syntax highlighting
    eza                              # modern ls replacement
    less                             # terminal pager
    hexyl                            # hex viewer for binary files
    git                              # version control system
    delta                            # syntax-highlighted git diff
    curl                             # command line tool for transferring data
    wget                             # network downloader
    jq                               # JSON processor
    htop                             # interactive process viewer
    ncdu                             # disk usage analyzer
    dos2unix                         # line ending converter
    unzip                            # extract zip files
    p7zip                            # 7-zip archive tool
    openssl                          # SSL/TLS library
    perl                             # Perl interpreter (build scripts)

    # =========================================================================
    # LANGUAGES & BUILD TOOLS
    # =========================================================================

    # Python
    python311                        # Python 3.11 interpreter
    python311Packages.pip            # package installer
    python311Packages.virtualenv     # virtual environment creator
    python311Packages.pynvim         # neovim Python integration
    black                            # code formatter
    python311Packages.flake8         # linter

    # Rust
    # rustc                            # Rust compiler
    # cargo                            # Rust package manager
    # rustfmt                          # code formatter
    # clippy                           # linter
    # rust-analyzer                    # LSP server

    # Node.js
    nodejs                           # required by Copilot and CopilotChat

    # C/C++ & Tooling
    gcc                              # C compiler (tree-sitter parsers, telescope-fzf-native)
    gnumake                          # make (CopilotChat tiktoken build)
    cmake                            # build system (telescope-fzf-native)
    # clang-tools                      # clangd, clang-format, clang-tidy
    tree-sitter                      # parser generator for treesitter.nvim
    # gcc-arm-embedded                 # ARM GNU Toolchain (arm-none-eabi-*)
  ] ++ (if isWSL then [
    # =========================================================================
    # WSL ONLY PACKAGES
    # =========================================================================
    wslu                             # WSL utilities (wslview, wslpath)
  ] else [
    # =========================================================================
    # UBUNTU OS ONLY PACKAGES
    # =========================================================================
    wl-clipboard                     # Wayland clipboard tool
    xsel                             # X11 clipboard tool
    ffmpeg                           # Video and audio processing
  ]);

  programs.home-manager.enable = true;
}
