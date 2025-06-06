{
  description = "Dev shell with Neovim 0.10.4";

  inputs = {
    # Main nixpkgs
    #nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # Search packages at https://www.nixhub.io/

    # Pin nixpkgs with Neovim 0.10.4
    neovimPkgs.url = "github:nixos/nixpkgs/dd613136ee91f67e5dba3f3f41ac99ae89c5406b";

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

        yaziWithDeps = p.symlinkJoin {
          name = "yazi-with-deps";
          paths = [
            p.yazi
            p.ffmpeg
            p.p7zip
            p.jq
            p.poppler_utils
            p.fd
            p.ripgrep
            p.fzf
            p.zoxide
            p.resvg
            p.imagemagick
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
            # lfWithDeps
            yaziWithDeps

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

              if [ "$WITH_GIT_PUSH" = "true" ]; then
                echo "[WITH_GIT_PUSH = true] Cloning via SSH..."

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
                ssh-keyscan github.com >> ~/.ssh/known_hosts

                # Clone dotfiles repo recursively with SSH
                git clone --recurse-submodules git@github.com:MohitRane8/dotfiles "$DOTFILES_DIR"
              else
                echo "[WITH_GIT_PUSH = false] Cloning via HTTPS..."

                # Clone dotfiles repo with HTTPS
                git clone https://github.com/MohitRane8/dotfiles "$DOTFILES_DIR"
                cd "$DOTFILES_DIR"

                # Rewrite .gitmodules entries from SSH to HTTPS
                sed -i 's|git@github.com:|https://github.com/|g' .gitmodules

                # Sync and init submodules
                git submodule sync
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

            # Enter zsh as long as exit hook isn't set
            if [ "$EXIT_AFTER_HOOK" == "true" ]; then
              # Exit out of bash shell
              exit
            else
              # Enter zsh shell
              exec ${p.zsh}/bin/zsh -il
            fi
          '';
        };
      });
}
