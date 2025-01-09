{
  buildNpmPackage,
  fetchFromGitHub,
  nodejs_22,
  git,
  hugo,
}:
buildNpmPackage {
  name = "hugo-website-thatferretblog";

  src = fetchFromGitHub {
    fetchSubmodules = true;
    deepClone = true;
    owner = "GiggleSquid";
    repo = "thatferretblog";
    rev = "95dd238df39101a1673f7b2d5053fb955e8ed7b8";
    hash = "sha256-4sImC8HkxaiKXzH+63Hrn53oXVw52UDgo7fNNEurSJc=";
  };

  npmDepsHash = "sha256-ZK1sY7m593lzz/idO2Twcao3klwd611UDFBiALyOW2M=";

  dontNpmInstall = true;

  nodejs = nodejs_22;

  nativeBuildInputs = [
    hugo
    git
  ];

  buildPhase = ''
    # Needs fix
    # We run hugo first to generate the hugo_stats.json.
    # Not entirely sure why this is needed or if there's a better method.
    # AFAIK the second invocation should handle it just fine on its own.
    hugo
    hugo --minify -s . -d "$out"
  '';
}
