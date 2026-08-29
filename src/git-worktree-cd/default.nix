{
  stdenvNoCC,
  lib,
  pkgs,
}:

stdenvNoCC.mkDerivation {
  pname = "git-worktree-cd";
  version = "0.1.0";

  src = ./.;
  nativeBuildInputs = with pkgs; [
    installShellFiles
    utilsWrapHook
  ];

  doCheck = true;
  checkInputs = with pkgs; [ shellcheck ];
  checkPhase = ''
    shellcheck ${./script.sh}
  '';

  installPhase = ''
    patchShebangs .
    install -Dm755 ${./script.sh} $out/bin/git-worktree-cd
    wrapProgram $out/bin/git-worktree-cd \
      --set PATH ${
        lib.makeBinPath [
          pkgs.git
          pkgs.fzf
          pkgs.coreutils
          pkgs.gawk
        ]
      }
  '';
}
