{ sources ? import ./nix/sources.nix
, pkgs ? import sources.nixpkgs {}
}:

let
  rust-overlay =
    import (sources.nixpkgs-mozilla + "/rust-overlay.nix") pkgs pkgs;

  crate2nix = import sources.crate2nix { inherit pkgs; };

  # check https://rust-lang.github.io/rustup-components-history/index.html
  # for rustfmt, clippy, rls, etc.
  rustChannel = rust-overlay.rustChannelOf {
    rustToolchain = ./rust-toolchain;
    sha256 = "08pnblrkz7ban3ykbik7pf5xb2ji9h4lv4ihkbxjm8lr5rvqza3z";
  };

  buildRustCrate = pkgs.buildRustCrate.override {
    inherit (rustChannel) rust;
    rustc = rustChannel.rust;
  };

  deps = { inherit buildRustCrate crate2nix; };
in
pkgs.callPackage ./package.nix deps // deps // {
  inherit pkgs;
  rust = rustChannel.rust;
}
