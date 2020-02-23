{ stdenvNoCC
, lib
, runCommand
, callPackage
, nix-gitignore
, buildRustCrate
, crate2nix
, asciidoctor
}:

let
  pname = "mew";
  src = nix-gitignore.gitignoreSource ["/.git" ./.ignore] ./.;

  cargoNix =
    runCommand "Cargo-${pname}.nix" {
      inherit src;
      nativeBuildInputs = [ crate2nix ];
    } ''
      cd $src
      crate2nix generate \
        --nixpkgs-path ./extern/nixpkgs \
        --output $out
    '';

  cargo = callPackage cargoNix { inherit buildRustCrate; };
  crates = cargo.workspaceMembers;
  mew = crates.mew.build.overrideAttrs (_: { inherit src; });

  doc-html = stdenvNoCC.mkDerivation {
    name = "${pname}-doc-html";
    inherit src;
    nativeBuildInputs = [ asciidoctor ];
    postPatch = ''patchShebangs tools'';
    buildPhase = ''tools/build-doc $out'';
    installPhase = ''true'';
  };
in
stdenvNoCC.mkDerivation {
  # TODO: version
  name = pname;

  inherit src;

  passthru = { inherit doc-html; };

  installPhase = ''
    # crate contains bin/mew.d...
    install -Dt $out/bin -m 555 ${mew}/bin/${pname}
    doc=$out/share/doc/${pname}
    install -Dt $doc/adoc -m 444 *.adoc doc/*.adoc doc/meta/*.{png,gif,jpg}
    cp -R ${doc-html} $doc/html
  '';

  meta = {
    homepage = "https://mew.build/";
    description = "a next‐generation free software build system";
    license = with lib.licenses; [ asl20 mit ];
    platforms = lib.platforms.all;
    maintainers = with lib.maintainers; [ emily ];
  };
}
