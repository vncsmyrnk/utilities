{
  stdenvNoCC,
  pkgs,
}:

stdenvNoCC.mkDerivation {
  pname = "gnome-extensions-reload";
  version = "0.1.3";

  src = ./.;
  nativeBuildInputs = with pkgs; [
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
    install -Dm755 ./script.sh $out/bin/gnome-extensions-reload
    wrapProgram $out/bin/gnome-extensions-reload
  '';
}
