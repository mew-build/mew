{ nixpkgs ? ./extern/nixpkgs
, nixpkgs-mozilla ? ./extern/nixpkgs-mozilla
, crate2nix ? ./extern/crate2nix
}:

let
  pkgs = import nixpkgs {
    overlays = [ (import (nixpkgs-mozilla + "/rust-overlay.nix")) ];
  };

  # check https://rust-lang.github.io/rustup-components-history/index.html
  # for rustfmt, clippy, rls, etc.
  rustChannel = pkgs.rustChannelOf {
    rustToolchain = ./rust-toolchain;
    sha256 = "08pnblrkz7ban3ykbik7pf5xb2ji9h4lv4ihkbxjm8lr5rvqza3z";
  };

  buildRustCrate = pkgs.buildRustCrate.override {
    inherit (rustChannel) rust;
    rustc = rustChannel.rust;
  };

  crate2nixPkg = import crate2nix { inherit pkgs; };
in
pkgs.callPackage ./package.nix {
  inherit buildRustCrate;
  crate2nix = crate2nixPkg;
} // {
  inherit pkgs buildRustCrate;
  rust = rustChannel.rust;
  crate2nix = crate2nixPkg;
}
