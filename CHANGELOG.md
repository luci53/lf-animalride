# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/).

## [2.0.0] - 2026-06-10

> **Breaking:** the resource was restructured into `client/` and `server/`
> folders and `config.lua` was reorganized (`Config.Animals`, `Config.Movement`,
> `Config.Buffs`, etc.). Review your config after updating.

### Security
- **Critical fix — removed the item duplication / spawning exploit.** The old
  client-triggered events `returnSpawnItem`, `returnSaddle` and `removeItem`
  let any player add arbitrary items to their inventory or hand themselves free
  saddles. All item add/remove is now server-authoritative and bounded by
  server-tracked animal ownership, so a refund can never exceed what was spent.
- Taming now consumes the saddle through an `lib.callback`, so the item is only
  removed after the server confirms — the client can no longer fake it.

### Added
- **Multi-framework support** — QBox (`qbx_core`), QBCore and ESX, auto-detected,
  with an inventory bridge for `ox_inventory`, qb and esx inventories.
- **Stamina system** — sprinting drains stamina and regenerates while resting,
  with an optional on-screen bar (`Config.Stamina`).
- **Call companion** — a command + keybind (default `G`) recalls your animal,
  teleporting it to you if it's too far away (`Config.Call`).
- **Configurable roster** — define animals, summon items and per-animal mount
  seating in `Config.Animals`, plus extra saddle-tameable models.
- Safe-spawn ground check, animal **death detection**, and proper ped cleanup on
  release and resource stop.
- MIT `LICENSE`, this `CHANGELOG`, a rewritten README and an automated GitHub
  release workflow.

### Changed
- Rewrote the resource into modular `client/` + `server/` files behind a single
  framework/inventory bridge.
- The client is now framework-agnostic (ox_lib + ox_target only); it requests
  actions and the server decides.

### Fixed
- `CreatePed` was being called with a `vector3` where it expects separate
  `x, y, z` arguments — animals now spawn at the correct, on-ground position.
- The client loop spun at `Wait(0)` whenever you had no animal, wasting CPU; it
  now sleeps when idle.
- The README claimed horse support that the config never provided; the roster is
  now explicit and configurable (base GTA V has no horse ped).

## [1.0.0]

### Added
- Initial release: QBCore animal riding with saddle taming, whistle summons,
  ox_target interactions, speed/invincibility buffs and follow-on-dismount.
