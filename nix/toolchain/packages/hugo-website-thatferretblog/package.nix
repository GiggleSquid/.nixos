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
    rev = "94bb67f8f3154fcc13e08662196aea5946cadb8b";
    hash = "sha256-YFlAzTEMsodcauv/M766tX8beQy4aX1YMKI4a1Hcxsg=";
  };

  npmDepsHash = "sha256-7K1Exxu6C3C9IImW9W+Kd1MrHEElF6/Tt5dF/2ndAVY=";

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
