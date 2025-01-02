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
    rev = "468bb6a9fe74fad93cef83b0b4c0d8d605d974d9";
    hash = "sha256-1oidZOvD8InHDgduzyHVLfGg6Pjm7GRzn3dIVp1pzqA=";
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
