{ sources ? import ./nix/sources.nix
, pkgs ? import sources.nixpkgs {}
}@args:

with import ./. args;
pkgs.mkShell {
  nativeBuildInputs = [
    pkgs.niv
    rust
    crate2nix
    pkgs.asciidoctor
  ];
}
