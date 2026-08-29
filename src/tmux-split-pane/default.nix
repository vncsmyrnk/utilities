{
  stdenvNoCC,
  lib,
  pkgs,
}:

stdenvNoCC.mkDerivation {
  pname = "tmux-split-pane";
  version = "0.1.0";

  src = ./.;
  nativeBuildInputs = with pkgs; [
    installShellFiles
    makeWrapper
  ];

  doCheck = true;
  checkInputs = with pkgs; [ shellcheck ];
  checkPhase = ''
    shellcheck ${./script.sh}
  '';

  installPhase = ''
    patchShebangs .
    install -Dm755 ${./script.sh} $out/bin/tmux-split-pane
    wrapProgram $out/bin/tmux-split-pane \
      --set PATH ${
        lib.makeBinPath [
          pkgs.tmux
        ]
      }
  '';
}
