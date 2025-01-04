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
    rev = "316a53a782bda98bedf536d8a6d1651f63800c7e";
    hash = "sha256-KysbwvCxlDVqadCWWGAEWaTL8EgJBosA2FwmTi7gQUY=";
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
