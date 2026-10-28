# PokeFields Switch Port

An unofficial Nintendo Switch homebrew port of [PokeFields](https://pokefields.com/), maintained by [LeagueEnjoyer64](https://github.com/LeagueEnjoyer64).

**Status:** Rev. 47 integration and the Switch updater are in development. There is no tested public release yet. A release will only appear here after verification; the source ZIP is not an installable Switch application.

## Install a tested release

These instructions apply when a tested release is available on the [Releases page](https://github.com/LeagueEnjoyer64/PokeFields-Switch-Port/releases).

1. Use a Switch already configured to run homebrew. This project does not include console modification instructions or console keys.
2. Download the install ZIP attached to a tested release. Do not download GitHub's automatically generated source ZIP.
3. Close PokeFields. If moving the SD card to your PC, power off the Switch before removing it.
4. Extract the install ZIP to the SD card root and merge its `switch` folder. The application belongs at `sdmc:/switch/PokeFields/PokeFields.nro`, with `PokeFields.pck` alongside it.
5. Supply your own supported ROMs: FireRed, Emerald, Platinum, HeartGold/SoulSilver and Black/White. Put them in `sdmc:/switch/PokeFields/roms/`, or select them in the application's ROM setup browser. The setup screen validates the files; consult the release notes for supported editions.
6. Launch hbmenu in full-memory mode by holding **R** while launching an installed game. Keep holding R until hbmenu appears. Launch PokeFields there.
7. Follow ROM setup, then sign in to your own PokeFields account. Do not share your password or account files.

## Updates and personal files

The planned Switch updater checks this repository's release feed, downloads application files, and checks their size and SHA-256 before staging them. Close the game and reopen it manually to apply an update. Automatic relaunch is avoided because it caused crashes during port testing. This behavior is still awaiting release verification.

For a manual update, close the application and replace only `PokeFields.nro` and `PokeFields.pck` with the tested release files. Back up your SD card first. Keep the existing `roms` and `dados` folders: these contain personal ROMs and application data and are not part of the public distribution.

No ROMs, account credentials, saved sessions, saves, console keys, private development keys, SD-card dumps or recordings belong in this repository or its release assets. Every player supplies their own ROMs and signs in independently.

## Credits and sources

- **PokeFields and its developers** — the original game, service, client behavior, world and features. Official site: [pokefields.com](https://pokefields.com/). The Rev. 47 client used for compatibility work came from the [official update service](https://update.pokefields.com/version?platform=windows). This is an unofficial port; credit does not imply endorsement or permission to redistribute upstream material.
- **Carlos Guilherme and godot-switch-nro contributors** — the Switch engine port this work builds upon: [calosguilherme/godot-switch-nro](https://github.com/calosguilherme/godot-switch-nro), MIT licensed. Its copyright and license must accompany distributions that include it.
- **Godot Engine contributors** — the underlying engine: [godotengine/godot](https://github.com/godotengine/godot), MIT licensed. Engine license and third-party notices must accompany engine distributions.
- **devkitPro and libnx contributors** — the Switch homebrew toolchain and platform libraries: [devkitPro](https://devkitpro.org/) and [libnx](https://github.com/switchbrew/libnx).
- **GDRE Tools contributors** — client recovery tooling used during compatibility investigation: [GDRETools/gdsdecomp](https://github.com/GDRETools/gdsdecomp). This is a development tool, not an included game dependency.
- **Nintendo, Game Freak and Creatures** — Pokémon and the original games referenced by this project belong to their respective rights holders. This project supplies no game ROMs.

Additional incorporated sources and their notices will be added before release. No blanket license is assigned to upstream game code or assets; their respective owners retain their rights. Only material with appropriate redistribution rights should be published.
