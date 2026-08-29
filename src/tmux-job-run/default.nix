{
  stdenvNoCC,
  lib,
  pkgs,
}:

stdenvNoCC.mkDerivation {
  pname = "tmux-job-run";
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
    install -Dm755 ./script.sh $out/bin/tmux-job-run
    wrapProgram $out/bin/tmux-job-run \
      --run 'export CONFIG_PATH="''${CONFIG_PATH:-$HOME/.config/utilities/tmux/jobs}"' \
      --run 'export CURRENT_PATH="$PATH"' \
      --set-default UTILITIES_TMUX_JOB_SESSION_NAME "_jobs" \
      --set PATH ${
        lib.makeBinPath [
          pkgs.tmux
          pkgs.coreutils
        ]
      }
  '';
}
