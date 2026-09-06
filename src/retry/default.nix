{
  stdenvNoCC,
  lib,
  pkgs,
}:

stdenvNoCC.mkDerivation {
  pname = "retry";
  version = "0.1.0";

  src = ./.;
  nativeBuildInputs = with pkgs; [
    installShellFiles
    makeUtilitiesWrapper
  ];

  doCheck = true;
  checkInputs = with pkgs; [ shellcheck ];
  checkPhase = ''
    shellcheck ${./script.sh}
  '';

  installPhase = ''
    patchShebangs .
    install -Dm755 ${./script.sh} $out/bin/retry
    wrapProgram $out/bin/retry \
      --prefix PATH : ${
        lib.makeBinPath [
          pkgs.bc
          pkgs.coreutils
          pkgs.util-linux
        ]
      }
  '';
}
