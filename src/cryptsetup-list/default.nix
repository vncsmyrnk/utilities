{
  stdenvNoCC,
  lib,
  pkgs,
}:

stdenvNoCC.mkDerivation {
  pname = "cryptsetup-list";
  version = "0.1.0";

  src = ./.;
  nativeBuildInputs = with pkgs; [
    installShellFiles
    makeUtilitiesWrapper
  ];

  doCheck = true;
  checkInputs = with pkgs; [
    shellcheck
  ];
  checkPhase = ''
    shellcheck ./script.sh
  '';

  installPhase = ''
    patchShebangs .
    install -Dm755 ./script.sh $out/bin/cryptsetup-list
    wrapProgram $out/bin/cryptsetup-list \
      --set-default UTILITIES_CRYPTSETUP_PREFIX "utilities-" \
      --set PATH ${
        lib.makeBinPath [
          pkgs.coreutils
          pkgs.util-linux
        ]
      }
  '';
}
