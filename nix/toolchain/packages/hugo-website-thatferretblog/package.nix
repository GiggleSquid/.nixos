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
    rev = "5ad9b8231c3a0170b6e437c54ff712b9c33ec885";
    hash = "sha256-2VxKCbz+EA8WBDvX//eyacSPNeiycirt1f6CjtNYJ+M=";
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
