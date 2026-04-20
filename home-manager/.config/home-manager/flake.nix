{
  description = "Home Manager configuration";

  # =========================================================================
  # FRESH INSTALL CHECKLIST — update before the first `home-manager switch`:
  #   1. nixpkgs.url              → latest stable branch   (e.g., nixos-25.11)
  #   2. home-manager.url         → matching release branch (e.g., release-25.11)
  #   3. wsl/ubuntuStateVersion   → set the NEW machine's value to the release
  #   4. username                 → your Linux username
  #   5. nix run home-manager/release-25.11 — match the branch in step 2
  # =========================================================================

  inputs = {
    # Main nixpkgs (stable, matching Home Manager release)
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";

    # Home Manager
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Pinned nixpkgs - search versions at https://www.nixhub.io/
    neovimPkgs.url = "github:nixos/nixpkgs/dd613136ee91f67e5dba3f3f41ac99ae89c5406b"; # neovim 0.10.4
    tmuxPkgs.url   = "github:nixos/nixpkgs/09061f748ee21f68a089cd5d91ec1859cd93d0be"; # tmux 3.6a
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs:
  let
    username = "mrane";
    system = "x86_64-linux";
    # Set per-machine on first install; never bump on an existing machine.
    # Fresh install: use the current stable release (e.g., "25.11").
    wslStateVersion = "25.11";
    ubuntuStateVersion = "25.11";
    mkHome = { isWSL, stateVersion }: home-manager.lib.homeManagerConfiguration {
      pkgs = nixpkgs.legacyPackages.${system};
      extraSpecialArgs = { inherit inputs isWSL username stateVersion; };
      modules = [ ./home.nix ];
    };
  in {
    homeConfigurations."${username}-wsl" = mkHome { isWSL = true; stateVersion = wslStateVersion; };
    homeConfigurations."${username}-ubuntu" = mkHome { isWSL = false; stateVersion = ubuntuStateVersion; };
  };
}
