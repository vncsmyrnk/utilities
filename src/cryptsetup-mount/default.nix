{
  stdenvNoCC,
  lib,
  pkgs,
}:

stdenvNoCC.mkDerivation {
  pname = "cryptsetup-mount";
  version = "0.1.0";

  src = ./.;
  nativeBuildInputs = with pkgs; [
    installShellFiles
    makeUtilitiesWrapper
  ];

  doCheck = true;
  checkInputs = with pkgs; [
    shellcheck
    bats
  ];
  checkPhase = ''
    shellcheck ./script.sh
    bats ./test.bats
  '';

  installPhase = ''
    patchShebangs .
    install -Dm755 ./script.sh $out/bin/cryptsetup-mount
    wrapProgram $out/bin/cryptsetup-mount \
      --run 'export DATA_PATH="''${CONFIG_PATH:-$HOME/.local/share/utilities/cryptsetup}"' \
      --run 'export CONFIG_PATH="''${CONFIG_PATH:-$HOME/.config/utilities/cryptsetup}"' \
      --set-default MAPPER_PATH "/dev/mapper" \
      --set-default UTILITIES_CRYPTSETUP_PREFIX "utilities-" \
      --set PATH ${
        lib.makeBinPath [
          pkgs.cryptsetup
          pkgs.mount
          pkgs.jq
          pkgs.coreutils
          pkgs.gettext
        ]
      }
    cp ./completions.zsh ./cryptsetup-mount
    installShellCompletion --zsh ./cryptsetup-mount
  '';
}
