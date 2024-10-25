{ stdenv, lib }:
let
  sourceFiles = ././product_brand_sale;
in
stdenv.mkDerivation {
  name = "product_brand_sale";
  src = lib.fileset.toSource {
    root = ./.;
    fileset = sourceFiles;
  };
  postInstall = ''
    mkdir $out
    cp -rv . $out
  '';
}
