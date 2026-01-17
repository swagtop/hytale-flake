# hytale-flake

This is just a little flake where I'm messing around with the Hytale launcher.

Currently it fetches the flatpak or dmg download for Linux and MacOS
respectively, an upacks them to put them in the store. On Linux it patches the
dependencies needed for the launcher itself, and then runs the launcher through
steam-run. The game works and everything seems to be alright.

The flatpak version is awesome, since it lets us bring over the .desktop entry,
and get the icons and such.

The hashes are updated roughly once an hour through GitHub actions, thanks to
a PR by [istudyatuni](https://github.com/istudyatuni).
