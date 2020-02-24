{ sources ? import ./nix/sources.nix
, pkgs ? import sources.nixpkgs {}
}:
let
  # TODO: is this really better than using it as an overlay?
  rust-overlay =
    import (sources.nixpkgs-mozilla + "/rust-overlay.nix") pkgs pkgs;

  crate2nix-tools = import (sources.crate2nix + "/tools.nix") { inherit pkgs; };

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

  buildCargoCrates = pkgs.callPackage ./nix/build-cargo-crates.nix {
    inherit buildRustCrate;
    inherit (crate2nix-tools) generatedCargoNix;
  };

  nixpkgs-fmt = (buildCargoCrates {
    name = "nixpkgs-fmt";
    # TODO: probably want to filter .gitignore or something
    src = sources.nixpkgs-fmt;
  }
  ).nixpkgs-fmt.build;
in
pkgs.callPackage ./package.nix { inherit buildCargoCrates; } // {
  inherit pkgs nixpkgs-fmt;
  rust = rustChannel.rust;
}
