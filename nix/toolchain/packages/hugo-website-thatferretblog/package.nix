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
    rev = "23a064c5a0d584f51a8c5142416b9fd86a1dfb43";
    hash = "sha256-US4h4QIcqk42sPSwHfii17s+71/b9EeLsWrd4NujOxI=";
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
