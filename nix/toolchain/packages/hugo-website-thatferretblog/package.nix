{
  stdenv,
  fetchFromGitHub,
  git,
  hugo,
}:
stdenv.mkDerivation {
  name = "hugo-website-thatferretblog";
  src = fetchFromGitHub {
    fetchSubmodules = true;
    deepClone = true;
    owner = "GiggleSquid";
    repo = "thatferretblog";
    rev = "7730f2689d4b8eb512393a0a97ab838ce4fb0c7f";
    hash = "sha256-P+UV8NlWST1DTkPIFGCNUlMOoFvpMU3fbwovo9t0nOs=";
  };
  nativeBuildInputs = [
    hugo
    git
  ];
  phases = [
    "unpackPhase"
    "buildPhase"
  ];

  buildPhase = ''
    hugo build --minify -s . -d "$out"
  '';
}
