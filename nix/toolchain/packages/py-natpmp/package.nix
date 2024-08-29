{
  lib,
  fetchFromGitHub,
  python3Packages,
}:
python3Packages.buildPythonApplication rec {
  pname = "py-natpmp";
  version = "unstable-2024-03-03";

  src = fetchFromGitHub {
    owner = "yimingliu";
    repo = pname;
    rev = "efa90f4f63bf495d293b13de614b07f94260d832";
    hash = "sha256-A8XMAHC5+7Vv6C7iZ5y9aj4R0YN8t5DrvYKhuPmSP1E=";
  };

  build-system = with python3Packages; [ setuptools ];
}
