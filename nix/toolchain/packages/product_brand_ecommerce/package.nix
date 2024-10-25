{ stdenv, lib }:
let
  sourceFiles = ././product_brand_ecommerce;
in
stdenv.mkDerivation {
  name = "product_brand_ecommerce";
  src = lib.fileset.toSource {
    root = ./.;
    fileset = sourceFiles;
  };
  postInstall = ''
    mkdir $out
    cp -rv . $out
  '';
}
