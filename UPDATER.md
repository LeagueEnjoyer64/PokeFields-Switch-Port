# Switch updater integration

This component is implemented and under integration; no tested playable Rev. 47 release has been published yet.

## Runtime

Copy the `switch` directory into the port's Godot project and add `SwitchUpdater="*res://switch/switch_updater.gd"` under `[autoload]` in `project.godot`. Include `switch/*.pem` in the export. The component is inactive on desktop platforms.

The engine must support `PokeFields.pck.next` replacement at startup and `PokeFields.nro.next` replacement after the running file has closed. These hooks are specific to the engine fork used by this port. The keep-awake patch alone does not implement those update hooks. Never use this updater with an engine lacking them.

The updater checks after startup, asks before downloading, validates release URL, file size and SHA-256, then stages `.next` files. It does not touch `roms` or `dados`, and never automatically launches another NRO. The player closes the game and reopens it manually.

## Release feed

Attach `update.json`, `PokeFields.pck` and (when needed) `PokeFields.nro` to a tested, non-prerelease GitHub release in this repository. The feed is the release asset at `releases/latest/download/update.json`, not a file on the main branch.

Use schema 1 with these fields:

| Field | Meaning |
| --- | --- |
| `schema` | Integer `1` |
| `code` | Integer strictly greater than the previous release and the compiled client `PORT_CODE` |
| `version` | Display version |
| `engine_id` | Identifier of the required engine build |
| `pck` | Object with `url`, integer byte `size` and hex `sha256` |
| `nro` | Same object shape; required whenever the engine identifier changes |

Each asset URL must be `https://github.com/LeagueEnjoyer64/PokeFields-Switch-Port/releases/download/<tag>/PokeFields.pck` or its `.nro` counterpart. Generate hashes from the actual final files. Update the compiled constants for each release.

Before publishing, test the release, ensure the embedded engine and external PCK agree, and audit both binaries and source exports for ROMs, accounts, saves, logs and private keys. `.gitignore` does not sanitize binary packs. Never package a working player's SD directory or a private development export as a public release.

## Checks so far

- Local Godot test accepted the expected release URL and rejected foreign URLs, extra path components, traversal, invalid sizes and invalid SHA-256 strings.
- The Switch maintenance app connected to the repository over HTTPS using the bundled Mozilla roots with normal certificate verification. GitHub returned HTTP 404 because no release feed exists yet.
- The Switch accepted the engine keep-awake call and the maintenance app answered the private dev connection at 60 FPS.

End-to-end update download, staging, restart and playable Rev. 47 integration are still pending. Do not describe those as verified until they have been exercised on hardware.
