{
  stdenvNoCC,
  lib,
  pkgs,
}:

stdenvNoCC.mkDerivation {
  pname = "oathtool-totp-list";
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
    install -Dm755 ${./script.sh} $out/bin/oathtool-totp-list
    wrapProgram $out/bin/oathtool-totp-list \
      --run 'export CONFIG_PATH="''${CONFIG_PATH:-$HOME/.config/utilities/oathtool/totp}"' \
      --set PATH ${
        lib.makeBinPath [
          pkgs.coreutils
          pkgs.util-linux
        ]
      }
  '';
}
