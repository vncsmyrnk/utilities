{
  stdenvNoCC,
  lib,
  pkgs,
  rbackup,
}:

stdenvNoCC.mkDerivation {
  pname = "gpg-key-backup";
  version = "0.1.0";

  src = ./.;
  nativeBuildInputs = with pkgs; [
    makeUtilitiesWrapper
  ];

  doCheck = true;
  checkInputs = with pkgs; [
    shellcheck
  ];
  checkPhase = ''
    shellcheck ${./script.sh}
  '';

  installPhase = ''
    patchShebangs .
    install -Dm755 ${./script.sh} $out/bin/gpg-key-backup
    wrapProgram $out/bin/gpg-key-backup \
      --set PATH ${
        lib.makeBinPath [
          rbackup
          pkgs.gnupg
          pkgs.findutils
          pkgs.coreutils
        ]
      }
  '';
}
