{
  stdenvNoCC,
  lib,
  pkgs,
}:

stdenvNoCC.mkDerivation {
  pname = "cryptsetup-umount";
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
    shellcheck ${./script.sh}
  '';

  installPhase = ''
    patchShebangs .
    install -Dm755 ${./script.sh} $out/bin/cryptsetup-umount
    wrapProgram $out/bin/cryptsetup-umount \
      --run 'export DATA_PATH="''${CONFIG_PATH:-$HOME/.local/share/utilities/cryptsetup}"' \
      --set-default UTILITIES_CRYPTSETUP_PREFIX "utilities-" \
      --set PATH ${
        lib.makeBinPath [
          pkgs.cryptsetup
          pkgs.umount
          pkgs.coreutils
          pkgs.jq
          pkgs.psmisc
          pkgs.util-linux
        ]
      }
    cp ${./completions.zsh} ./cryptsetup-umount
    installShellCompletion --zsh ./cryptsetup-umount
  '';
}
