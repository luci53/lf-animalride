# lf-animalride — Rideable Animal Companions

![version](https://img.shields.io/github/v/release/luci53/lf-animalride?sort=semver)
![license](https://img.shields.io/github/license/luci53/lf-animalride)
![frameworks](https://img.shields.io/badge/framework-QBox%20%7C%20QBCore%20%7C%20ESX-blue)

Tame or summon rideable animals, ride them with a custom control scheme, buff
them, and have them follow you around. Framework-agnostic (QBox / QBCore / ESX)
with server-authoritative item handling.

> **Upgrading from v1?** v2 is a rewrite with a new config layout and folder
> structure — see the [CHANGELOG](CHANGELOG.md). It also closes a critical item
> duplication exploit, so updating is strongly recommended.

## Features

- **Multi-framework** — QBox (`qbx_core`), QBCore and ESX, auto-detected, with an
  inventory bridge for `ox_inventory`, qb and esx inventories.
- **Two ways to get an animal** — tame a wild one with a `saddle`, or summon a
  personal companion with an item (e.g. `cow_whistle`).
- **Custom riding** — `WASD` to steer, hold **Shift** to sprint, **F** to
  dismount. Your animal follows you when you're on foot.
- **Stamina** — sprinting drains stamina and regenerates while resting, with an
  optional on-screen bar.
- **Call companion** — a keybind (default **G**) recalls your animal, teleporting
  it to you if it's far away.
- **Buff items** — a speed stimulant and an invincibility apple.
- **Server-authoritative** — every item add/remove is validated server-side and
  bounded by ownership state. No client-trusted economy.

## Dependencies

| Resource | Required | Notes |
| --- | --- | --- |
| [ox_lib](https://github.com/communityox/ox_lib) | ✅ | Notifications, progress, callbacks |
| [ox_target](https://github.com/communityox/ox_target) | ✅ | Interacting with animals |
| A framework | ✅ | [qbx_core](https://github.com/Qbox-project/qbx_core) **or** [qb-core](https://github.com/qbcore-framework/qb-core) **or** [es_extended](https://github.com/esx-framework/esx_core) |
| [ox_inventory](https://github.com/communityox/ox_inventory) | Recommended | Used automatically when present (works with qb/esx inventories too) |

## Installation

1. Place `lf-animalride` in your `resources` folder.
2. Add the items below to your inventory, and the item images to
   `ox_inventory/web/images/` (the five PNGs ship in `item-images/`).
3. Add `ensure lf-animalride` to your `server.cfg`, **after** its dependencies.
4. Restart your server.

### Items

`items.lua` in this repo contains ready-to-paste definitions for both
**ox_inventory** (`data/items.lua`) and **QBCore** (`qb-core/shared/items.lua`).
The five items are: `saddle`, `cow_whistle`, `boar_caller`, `animal_stimulant`,
`ironhide_apple`.

> The summon/buff items use `consume = 1` in ox_inventory so the item is removed
> on use and the server reacts to the trusted `usedItem` event.

## How to use

| Action | How |
| --- | --- |
| **Tame** a wild animal | Target it and pick **Saddle Animal** (consumes a `saddle`) |
| **Summon** a companion | Use a summon item (e.g. `cow_whistle`) from your inventory |
| **Mount** | Target your animal → **Mount Animal** |
| **Ride** | `WASD` to steer, hold **Shift** to sprint |
| **Dismount** | Press **F** (the animal then follows you) |
| **Call** your animal | Press **G** (rebindable) or `/callanimal` |
| **Release** | Target your animal → **Release Animal** (saddle is returned if you tamed it) |
| **Buffs** | Use `animal_stimulant` (speed) or `ironhide_apple` (invincibility) while you have an animal |

## Configuration

All settings live in [`config.lua`](config.lua), fully commented. Highlights:

```lua
Config.Framework = 'auto'   -- 'auto' | 'qbx' | 'qb' | 'esx'
Config.Inventory = 'auto'   -- 'auto' | 'ox' | 'qb' | 'esx'

Config.Movement = { baseSpeed = 2.0, runSpeed = 5.0, turnSpeed = 2.0 }
Config.Stamina  = { enabled = true, max = 100.0, drain = 18.0, regen = 12.0, showBar = true }
Config.Call     = { enabled = true, command = 'callanimal', key = 'G', teleportDistance = 60.0 }
```

### Animals

Each animal defines its model, label, optional summon item and mount seating:

```lua
Config.Animals = {
    cow  = { model = `a_c_cow`,  label = 'Cow',  spawnItem = 'cow_whistle' },
    boar = { model = `a_c_boar`, label = 'Boar', spawnItem = 'boar_caller' },
    -- horse = { model = `a_c_horse`, label = 'Horse', spawnItem = 'horse_whistle' },
}
```

> Base GTA V has no horse ped. If you stream an addon horse model, add it here.
> Models with no `spawnItem` can still be tamed with a saddle.

## Security

Network events are untrusted, so the server owns the item economy:

- The client can no longer add or remove items. It only **requests** actions.
- Taming consumes the saddle through an `lib.callback`, validated server-side.
- Summon/buff use is driven by the inventory's trusted use event; refunds for an
  invalid use (no animal, already buffed, spawn failed) are bounded per use, so a
  player can never get back more than they spent.
- Animal ownership is tracked per player and cleared on release, death and
  disconnect.

## Releases

Pushing a version tag runs the [release workflow](.github/workflows/release.yml),
which builds a versioned zip and publishes a GitHub release with auto-generated
notes:

```bash
git tag v2.0.0
git push origin v2.0.0
```

## License

[MIT](LICENSE) © Lucifer (luci53)
