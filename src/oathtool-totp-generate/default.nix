{
  stdenvNoCC,
  lib,
  pkgs,
}:

stdenvNoCC.mkDerivation {
  pname = "oathtool-totp-generate";
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
    install -Dm755 ${./script.sh} $out/bin/oathtool-totp-generate
    wrapProgram $out/bin/oathtool-totp-generate \
      --run 'export CONFIG_PATH="''${CONFIG_PATH:-$HOME/.config/utilities/oathtool/totp}"' \
      --set PATH ${
        lib.makeBinPath [
          pkgs.coreutils
          pkgs.oath-toolkit
          pkgs.gnupg
          pkgs.wl-clipboard
          pkgs.xclip
        ]
      }
    cp ${./completions.zsh} ./oathtool-totp-generate
    installShellCompletion --zsh ./oathtool-totp-generate
  '';
}
