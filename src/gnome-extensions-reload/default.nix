{
  stdenvNoCC,
  pkgs,
}:

stdenvNoCC.mkDerivation {
  pname = "gnome-extensions-reload";
  version = "0.1.1";

  src = ./.;

  doCheck = true;
  checkInputs = with pkgs; [
    shellcheck
  ];
  checkPhase = ''
    shellcheck ./script.sh
  '';

  installPhase = ''
    patchShebangs .
    install -Dm755 ./script.sh $out/bin/gnome-extensions-reload
  '';
}
