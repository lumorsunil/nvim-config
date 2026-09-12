{
  description = "An idiomatic Nix developer environment for my project";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    utils.url = "github:numtide/flake-utils"; # Simplifies setting up multiple system architectures
  };

  outputs = { self, nixpkgs, utils }:
    utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            zig
            lua-language-server
            stylua
            tree-sitter
            tmux
          ];

          shellHook = ''
            echo "nvim-config"
          '';
        };
      }
    );
}
