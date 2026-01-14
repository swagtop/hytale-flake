{
  description = "Hytale";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs =
    { self, nixpkgs }:
    {
    packages =
      let
        system = "x86_64-linux";
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };
        target = "linux/amd64";

        hytale-launcher = pkgs.stdenvNoCC.mkDerivation (finalAttrs: {
          name = "hytale-launcher";
          version = "2026.01.14-563c3d7";

          src = pkgs.fetchurl {
            url = "launcher.hytale.com/builds/release/${target}/hytale-launcher-${finalAttrs.version}.flatpak";
            sha256 = "sha256-LthZo0XOTYFlbeO8syxcaslNn0a0BLrRBCTAiIqJfOk=";
          };

          nativeBuildInputs = [
            pkgs.ostree
            pkgs.autoPatchelfHook
          ];

          buildInputs = pkgs.lib.optionals pkgs.stdenvNoCC.isLinux [
            pkgs.webkitgtk_4_1
          ];

          dontUnpack = true;

          # https://github.com/flatpak/flatpak/issues/126#issuecomment-227068860
          installPhase = ''
            mkdir $out
            ostree init --repo=repo --mode=archive-z2
            ostree static-delta apply-offline --repo=repo $src
            ostree checkout --repo=repo -U $(basename $(echo repo/objects/*/*.commit | cut -d/ -f3- --output-delimiter= ) .commit) outdir
            cp -r outdir/files/* $out/

            # Get rid of the 'hytale-launcher-wrapper' functionality. We don't
            # need any auto-updating or flatpak shenanigans going on.
            echo "exec $out/bin/hytale-launcher" > $out/bin/hytale-launcher-wrapper
          '';

          meta.mainProgram = "hytale-launcher";
        });
      in
      {
        ${system} = {
          inherit hytale-launcher;
          default = hytale-launcher;
        };
      };
  };
}
