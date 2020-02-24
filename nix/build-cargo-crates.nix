{ callPackage
, buildRustCrate
, generatedCargoNix
}:

args:
let
  cargoNix = generatedCargoNix args;
  cargo = callPackage cargoNix { inherit buildRustCrate; };
in
  # TODO: fix‐up srcs here automatically (see package.nix)
cargo.workspaceMembers
