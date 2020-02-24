{ sources ? import ./nix/sources.nix
, pkgs ? import sources.nixpkgs {}
}@args:

with import ./. args;
pkgs.mkShell {
  nativeBuildInputs = [
    rust
    pkgs.asciidoctor
    pkgs.niv
    nixpkgs-fmt
  ];
}
