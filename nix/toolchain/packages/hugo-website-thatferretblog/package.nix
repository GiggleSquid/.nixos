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
    rev = "0b3c422a48937ce08ab1d6ecaa67a96e4c5bb534";
    hash = "sha256-SuaYynceba5A+IYRzKGtk8J6rtQc043BQo2EtJS0nQg=";
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
