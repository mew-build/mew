{ nixpkgs ? ./extern/nixpkgs
, nixpkgs-mozilla ? ./extern/nixpkgs-mozilla
, crate2nix ? ./extern/crate2nix
}@args:

let mew = import ./default.nix args;
in with mew;
pkgs.mkShell {
  nativeBuildInputs = [
    rust
    crate2nix
    pkgs.asciidoctor
  ];
}
