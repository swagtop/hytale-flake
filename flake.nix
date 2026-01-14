{
  description = "A simple flake for the Hytale launcher.";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs =
    { self, nixpkgs }:
    let
      inherit (nixpkgs.lib)
        optionals
        ;
      systems = [
        "x86_64-linux"
        "aarch64-darwin"
      ];
      forEachSupportedSystem = nixpkgs.lib.genAttrs systems;

      mkSourceUrl =
        system: version:
        let
          systemSpecific =
            {
              x86_64-linux = {
                path = "linux/amd64";
                extension = "flatpak";
              };
              aarch64-darwin = {
                path = "darwin/arm64";
                extension = "dmg";
              };
            }
            .${system};
        in
          "https://launcher.hytale.com/builds/release/${systemSpecific.path}"
          + "/hytale-launcher-${version}.${systemSpecific.extension}";
    in
    {
      packages = forEachSupportedSystem (
        system:
        let
          pkgs = import nixpkgs {
            inherit system;
            config.allowUnfree = true;
          };
          hashes = import ./hashes.nix;

          hytale-launcher = pkgs.stdenvNoCC.mkDerivation (finalAttrs: {
            inherit (hashes) version;

            name = "hytale-launcher";

            src = pkgs.fetchurl {
              url = mkSourceUrl system finalAttrs.version;
              sha256 = hashes.${system};
            };

            nativeBuildInputs =
              optionals pkgs.stdenv.isLinux [
                pkgs.ostree
                pkgs.autoPatchelfHook
              ]
              ++ optionals pkgs.stdenv.isDarwin [
                pkgs.undmg
              ];

            buildInputs = optionals pkgs.stdenvNoCC.isLinux [
              pkgs.webkitgtk_4_1
            ];

            dontUnpack = true;

            installPhase =
              if pkgs.stdenv.isLinux then
                # https://github.com/flatpak/flatpak/issues/126#issuecomment-227068860
                ''
                  mkdir $out
                  ostree init --repo=repo --mode=archive-z2
                  ostree static-delta apply-offline --repo=repo $src
                  ostree checkout --repo=repo -U $(basename $(echo repo/objects/*/*.commit | cut -d/ -f3- --output-delimiter= ) .commit) outdir
                  cp -r outdir/files/* $out/

                  # Get rid of the 'hytale-launcher-wrapper' functionality. We don't
                  # need any auto-updating or flatpak shenanigans going on.
                  printf "#!/bin/sh\nexec $out/bin/hytale-launcher" > $out/bin/hytale-launcher-wrapper
                ''
              else if pkgs.stdenv.isDarwin then
                ''
                  mkdir $out/{Applications,bin}
                  undmg $src
                  cp ./"Hytale Launcher.app" $out/Applications/
                  cp ./"Hytale Launcher.app"/Contents/MacOS/hytale-launcher $out/bin/
                ''
              else
                throw "Unsupported system.";

            meta = {
              description = "The Hytale launcher.";
              homepage = "https//hytale.com";
              license = pkgs.lib.licenses.unfreeRedistributable;
              mainProgram = "hytale-launcher";
              platforms = systems;
              sourceProvenance = [ pkgs.lib.sourceTypes.binaryNativeCode ];
            };
          });
        in
        {
          inherit hytale-launcher;
          default = hytale-launcher;
        }
      );

      formatter = forEachSupportedSystem (system: nixpkgs.legacyPackages.${system}.nixfmt-tree);

      lib = { inherit mkSourceUrl; };
    };
}
