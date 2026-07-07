#!/usr/bin/env sh

# dependencies: jq, curl, nix-command

VERSION=$(curl -s https://launcher.hytale.com/version/release/launcher.json | jq -r .version)

if [ -z "$VERSION" ]; then
  echo "Version is empty, something went wrong, aborting."
  exit 1
fi

LINUX_HASH=$(nix store prefetch-file "https://launcher.hytale.com/builds/release/linux/amd64/hytale-launcher-$VERSION.flatpak" --json | jq -r .hash)
MACOS_HASH=$(nix store prefetch-file "https://launcher.hytale.com/builds/release/darwin/arm64/hytale-launcher-$VERSION.dmg" --json | jq -r .hash)

echo "$VERSION" > .version
echo "\
{
  version = \"$VERSION\";
  x86_64-linux = \"$LINUX_HASH\";
  aarch64-darwin = \"$MACOS_HASH\";
}" > hashes.nix
