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
    rev = "8ddb7d270adf444e5b437d827bb391dfbfdc5b99";
    hash = "sha256-/wfqftnxw+juPObw46iue0XnT/IG3A777+lsXRphNls=";
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
