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
    rev = "b3dc0bc16e75662635691eea74e2ccb2cb07f0d7";
    hash = "sha256-FU0Kodrd0+asNn2eWg0chMwHdxPAug3LBM/OU1khtVE=";
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
