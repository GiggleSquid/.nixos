{
  stdenv,
  fetchFromGitHub,
  hugo,
}:
stdenv.mkDerivation {
  name = "hugo-website-thatferretblog";
  src = fetchFromGitHub {
    fetchSubmodules = true;
    owner = "GiggleSquid";
    repo = "thatferretblog";
    rev = "76d88773e2445b1c6750771bf064cc2cfa355110";
    hash = "sha256-QrJxgALJct9AVWxxML3G29TAeI4MLWDf18Tb3rhT/ik=";
  };
  nativeBuildInputs = [ hugo ];
  phases = [
    "unpackPhase"
    "buildPhase"
  ];
  buildPhase = ''
    hugo build --minify -s . -d "$out"
  '';
}
