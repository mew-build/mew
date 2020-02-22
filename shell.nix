{ nixpkgs ? ./extern/nixpkgs
, nixpkgs-mozilla ? ./extern/nixpkgs-mozilla
}:

let
  pkgs = import nixpkgs {
    overlays = [ (import (nixpkgs-mozilla + "/rust-overlay.nix")) ];
  };

  # check https://rust-lang.github.io/rustup-components-history/index.html
  # for rustfmt, clippy, rls, etc.
  rust = (pkgs.rustChannelOf {
    rustToolchain = ./rust-toolchain;
    sha256 = "08pnblrkz7ban3ykbik7pf5xb2ji9h4lv4ihkbxjm8lr5rvqza3z";
  }).rust;
in
pkgs.mkShell {
  buildInputs = [ rust ];
}
