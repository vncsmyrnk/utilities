{
  description = "A simple collection of useful shell scripts and wrappers.";

  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  inputs.rbackup.url = "github:vncsmyrnk/rbackup";

  outputs =
    {
      self,
      nixpkgs,
      rbackup,
    }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        overlays = [
          (final: prev: {
            sudo = final.callPackage ./src/sudo { };

            cryptsetup = final.sudo prev.cryptsetup;
            mount = final.sudo prev.mount;
            umount = final.sudo prev.umount;

            makeUtilitiesWrapper =
              final.makeSetupHook
                {
                  name = "wrap-hook";
                  propagatedBuildInputs = [ final.makeWrapper ];
                }
                (
                  final.writeText "wrap-hook.sh" ''
                    overrideWrapProgram() {
                      eval "_orig_$(declare -f wrapProgram)"
                      wrapProgram() {
                        local versionCommand=""
                        printf -v versionCommand \
                          'case "''${1-}" in -V|--version) printf "%%s %%s\n" %q %q; exit 0 ;; esac' \
                          "$pname" "$version"

                        _orig_wrapProgram "$1" \
                          --run 'export CURRENT_PATH="$PATH"' \
                          ''${versionCommand:+--run "$versionCommand"} \
                          "''${@:2}"
                      }
                    }
                    postHooks+=(overrideWrapProgram)
                  ''
                );

            wrapUseCurrentPath =
              pkg:
              final.runCommand "${pkg.pname or pkg.name}-current-path"
                {
                  nativeBuildInputs = [ final.makeWrapper ];
                }
                ''
                  mkdir -p $out/bin
                  for bin in ${final.lib.getBin pkg}/bin/*; do
                    makeWrapper "$bin" "$out/bin/$(basename "$bin")" \
                      --run 'export PATH="''${CURRENT_PATH:-$PATH}"'
                  done
                '';

            sops = final.wrapUseCurrentPath prev.sops;
          })
        ];
      };

      sopsExecEnv = pkgs.callPackage ./src/sops-exec-env { };
      sopsEdit = pkgs.callPackage ./src/sops-edit { };
      tmuxJobRun = pkgs.callPackage ./src/tmux-job-run { };
      tmuxJobList = pkgs.callPackage ./src/tmux-job-list { };
      tmuxJobKill = pkgs.callPackage ./src/tmux-job-kill { };
      tmuxJobKillAll = pkgs.callPackage ./src/tmux-job-kill-all { };
      tmuxSplitPane = pkgs.callPackage ./src/tmux-split-pane { };
      oathtoolTotpGenerate = pkgs.callPackage ./src/oathtool-totp-generate { };
      oathtoolTotpList = pkgs.callPackage ./src/oathtool-totp-list { };
      cryptsetupMount = pkgs.callPackage ./src/cryptsetup-mount { };
      cryptsetupUmount = pkgs.callPackage ./src/cryptsetup-umount { };
      cryptsetupStow = pkgs.callPackage ./src/cryptsetup-stow { };
      gpgKeyBackup = pkgs.callPackage ./src/gpg-key-backup {
        rbackup = rbackup.packages.${system}.default;
      };

      utilitiesWrapperFixture = pkgs.stdenvNoCC.mkDerivation {
        pname = "utilities-wrapper-fixture";
        version = "1.2.3";
        dontUnpack = true;
        nativeBuildInputs = [ pkgs.makeUtilitiesWrapper ];
        installPhase = ''
          install -Dm755 ${pkgs.writeShellScript "utilities-wrapper-fixture" ''
            printf '%s\n' "$CURRENT_PATH"
          ''} $out/bin/utilities-wrapper-fixture
          wrapProgram $out/bin/utilities-wrapper-fixture
        '';
      };

      currentPathFixture = pkgs.wrapUseCurrentPath (
        pkgs.writeShellScriptBin "current-path-fixture" ''
          printf '%s\n' "$PATH"
        ''
      );

      utilities = pkgs.symlinkJoin {
        name = "utilities-collection";
        paths = [
          sopsExecEnv
          sopsEdit
          tmuxJobRun
          tmuxJobList
          tmuxJobKill
          tmuxJobKillAll
          tmuxSplitPane
          oathtoolTotpGenerate
          oathtoolTotpList
          cryptsetupMount
          cryptsetupUmount
          cryptsetupStow
          gpgKeyBackup
        ];
      };

      devShell = pkgs.mkShell {
        packages = with pkgs; [
          coreutils
          wl-clipboard
          zsh
          bats
          utilities
        ];
      };
    in
    {
      packages.${system}.default = utilities;
      devShells.${system}.default = devShell;
      checks.${system} = {
        makeUtilitiesWrapper = pkgs.runCommand "make-utilities-wrapper-check" { } ''
          test "$(${utilitiesWrapperFixture}/bin/utilities-wrapper-fixture -V)" = \
            "utilities-wrapper-fixture 1.2.3"
          test "$(${utilitiesWrapperFixture}/bin/utilities-wrapper-fixture --version)" = \
            "utilities-wrapper-fixture 1.2.3"
          test "$(PATH=/test/current-path \
            ${utilitiesWrapperFixture}/bin/utilities-wrapper-fixture)" = \
            "/test/current-path"
          touch "$out"
        '';

        wrapUseCurrentPath = pkgs.runCommand "wrap-use-current-path-check" { } ''
          test "$(CURRENT_PATH=/test/current-path \
            ${currentPathFixture}/bin/current-path-fixture)" = "/test/current-path"
          touch "$out"
        '';
      };
    };
}
