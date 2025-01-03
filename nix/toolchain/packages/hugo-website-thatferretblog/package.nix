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
    rev = "960bfc17adda99f90dcec6728e73a886f704e0b0";
    hash = "sha256-tVqNAW3g8zAXVo412vbI/k9ID6XeTskVCIQEd76PO8E=";
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
