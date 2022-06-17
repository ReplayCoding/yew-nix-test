{
  inputs = {
    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-utils.url = "github:numtide/flake-utils";
    naersk = {
      url = "github:nmattia/naersk";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = { self, fenix, flake-utils, naersk, nixpkgs }:
    flake-utils.lib.eachDefaultSystem (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          target = "wasm32-unknown-unknown";
          toolchain = with fenix.packages.${system};
            combine [
              latest.rustc
              latest.cargo
              targets.${target}.latest.rust-std
            ];
        in
      {
        defaultPackage =
          (naersk.lib.${system}.override {
            cargo = toolchain;
            rustc = toolchain;
          }).buildPackage {
            src = ./.;
          };
          devShell = pkgs.mkShell {
            nativeBuildInputs = with pkgs; [ toolchain trunk ];
          };
      });
}
