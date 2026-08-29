{
  stdenvNoCC,
  lib,
  pkgs,
}:

stdenvNoCC.mkDerivation {
  pname = "cryptsetup-stow";
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
    install -Dm755 ./script.sh $out/bin/cryptsetup-stow
    wrapProgram $out/bin/cryptsetup-stow \
      --run 'export CONFIG_PATH="''${CONFIG_PATH:-$HOME/.config/utilities/cryptsetup}"' \
      --set-default UTILITIES_CRYPTSETUP_PREFIX "utilities-" \
      --set PATH ${
        lib.makeBinPath [
          pkgs.cryptsetup
          pkgs.jq
          pkgs.coreutils
          pkgs.stow
          pkgs.gettext
          pkgs.util-linux
          pkgs.gnugrep
        ]
      }
  '';
}
