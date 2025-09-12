{
  description = "lean";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  inputs.flake-utils.url = "github:numtide/flake-utils";
  
  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
        };
      in {
        # dev
        devShell = pkgs.mkShell {
          packages = with pkgs; [
            elan

            graphviz
          ]; 
        };
        # build
        packages.default = pkgs.stdenv.mkDerivation {        
          pname = "my-lean-project";
          version = "0.1.0";

          src = src/.;

          nativeBuildInputs = with pkgs; [ lean4 ];

          buildPhase = ''
            lake build
          '';

          installPhase = ''
            mkdir -p $out/bin
            find .lake/build/bin -maxdepth 1 -type f -executable -exec cp {} $out/bin/ \;
          '';
        };
      }
    );
}