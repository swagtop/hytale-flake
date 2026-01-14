# hytale-flake

This is just a little flake where I'm messing around with the Hytale launcher.
I'm probably going to delete this repo after I've messed around enough.

Currently it fetches the flatpak or dmg download for Linux and MacOS
respectively, an upacks them to put them in the store. On Linux it patches the
dependencies needed for the launcher itself. I can't check if the game itself
runs for now, since I do not own a copy.

The flatpak version is awesome, since it lets us bring over the .desktop entry,
and get the icons and such.

To update the source hashes, just run the 'update-hashes.sh' script. Fork it if
you wish to be doing this regularly on your own.
