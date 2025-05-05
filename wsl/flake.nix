{
  description = "Dev shell with Neovim 0.10";

  inputs = {
    # Main nixpkgs
    #nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # Search packages at https://www.nixhub.io/

    # Pin nixpkgs with Neovim 0.10
    neovimPkgs.url = "github:nixos/nixpkgs/b60793b86201040d9dee019a05089a9150d08b5b"; # commit where neovim 0.10 is available

    # Use flake-utils to support multiple systems (optional but nice)
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, neovimPkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        p = import nixpkgs { inherit system; };
        neovim = import neovimPkgs { inherit system; };

        lfWithDeps = p.symlinkJoin {
          name = "lf-with-deps";
          paths = [
            p.lf
            p.unzip
            p.trashy
            p.fzf
            p.ripgrep
            p.wslu
            p.hexyl
            p.bat
          ];
        };

        tmuxWithDeps = p.symlinkJoin {
          name = "tmux-with-deps";
          paths = [
            p.tmux
            p.tmuxPlugins.tpm
            p.tmuxPlugins.resurrect
          ];
        };
      in {
        devShells.default = p.mkShell {
          packages = [
            # apt overrides
            p.sudo
            p.vim
            p.wget
            p.xz
            p.openssh

            # essentials
            p.git
            p.less
            p.curl
            p.dos2unix
            p.stdenv.cc
            p.perl
            p.fd
            p.openssl
            p.eza
            p.htop

            # dotfiles manager
            p.stow

            # shell
      # zsh plugins managed by dotfiles repo submodules
            p.zsh

            # terminal manager
      # tmux plugins managed by dotfiles repo submodules
            p.tmux

            # file manager
            lfWithDeps

            # editor
            neovim.neovim

            # languages - python
            p.python311
            p.python311Packages.flake8
            p.black
            # p.python311Packages.cryptography

            # languages - rust
            p.rustc
            p.cargo             # TODO: disable cargo install

            # languages - c++
            # p.clang-tools

            # languages - javascript
            p.nodejs
            p.nodePackages.npm

            # languages - lua
            p.lua
            p.luarocks

            # extras
            # p.ffmpeg
          ];

          shellHook = ''
            DOTFILES_DIR="$HOME/dotfiles"
            if [ ! -d "$DOTFILES_DIR" ]; then
              echo "Cloning dotfiles..."

              if [ "$${WITH_GIT_PUSH:-false}" = "true" ]; then
                echo "[WITH_GIT_PUSH=true] Cloning via SSH..."

                if [ ! -f ~/.ssh/id_ed25519 ]; then
                  echo "SSH key not found at ~/.ssh/id_ed25519."
                  echo "Generate SSH key locally and register it on GitHub."
                  echo "Exiting nix develop shell."
                  return 1
                fi

                if ! pgrep -u "$USER" ssh-agent > /dev/null; then
                  eval "$(ssh-agent -s)"
                fi
                ssh-add ~/.ssh/id_ed25519

                # Clone dotfiles repo recursively with SSH
                git clone --recurse-submodules git@github.com:MohitRane8/dotfiles "$DOTFILES_DIR"
              else
                echo "[WITH_GIT_PUSH=false] Cloning via HTTPS..."

                # Clone dotfiles repo with HTTPS
                git clone https://github.com/MohitRane8/dotfiles "$DOTFILES_DIR"

                # Set SSH to HTTPS override in local git config of dotfiles repo
                # This will translate submodule init/update from
                # git@github.com:username/repo.git to https://github.com/username/repo.git
                cd "$DOTFILES_DIR"
                git config url."https://github.com/".insteadOf git@github.com:

                # Fetch and initialize submodules
                git submodule update --init --recursive
              fi

              # Run stow
              cd "$DOTFILES_DIR"
              for dir in zsh tmux lf nvim htop; do
                echo "Stowing $dir..."
                stow "$dir"
              done
            fi

            # Set ZSH as default shell
            export SHELL="${p.zsh}/bin/zsh"
            if [[ "$?" -eq 0 && "$_" != "$SHELL" ]]; then
              exec ${p.zsh}/bin/zsh -il
            fi
          '';
        };
      });
}
