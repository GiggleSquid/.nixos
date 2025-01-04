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
    rev = "82fa14efa06394e911b54f34c3bc98e75eb30d69";
    hash = "sha256-hTJZE3PY+KVyQXSUddXdStrBI5Rob+4B0wZKfjXpHlg=";
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
