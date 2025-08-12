# Advanced Animal Riding for QBCore

A comprehensive animal companion script for QBCore servers, built with modern tools like `ox_target` and `ox_lib`. This script allows players to acquire, ride, and interact with various ground-based animals, adding a new layer of immersion to your server.

This script uses a direct-attachment method, where the player sits on the animal's back and controls its movement through a custom, non-vehicle control scheme for a realistic feel.

## Features

* **Rideable Ground Animals:** Natively supports riding horses, cows, and boars. Easily extendable to other peds.
* **Modern Targeting:** Uses `ox_target` for all interactions, providing a clean and intuitive user experience.
* **Two Acquisition Methods:**
    * **Taming:** Find an animal in the wild and use a `saddle` item to tame it.
    * **Spawning:** Use special items like a `cow_whistle` to spawn a personal animal companion instantly.
* **Custom Controls:**
    * Use standard movement keys (`W`, `A`, S`, `D`) to guide the animal.
    * Hold **Shift** to make it run faster.
    * Press the **F** key to dismount without releasing the animal.
* **Follow Companion:** When you dismount, your active animal will follow you.
* **Consumable Buffs:**
    * **Speed Boost:** Use an `animal_stimulant` to make your animal run significantly faster for a short period.
    * **Invincibility:** Use an `ironhide_apple` to make your animal temporarily invincible to all damage.
* **Highly Configurable:** Easily change animal speeds, buff durations, multipliers, and add new animals via the `config.lua` file.

## Dependencies

You must have the following resources installed and started **before** `lf-animalride`.

* [qb-core](https://github.com/qbcore-framework/qb-core)
* [ox_lib](https://github.com/overextended/ox_lib)
* [ox_inventory](https://github.com/overextended/ox_inventory)
* [ox_target](https://github.com/overextended/ox_target)

## Installation



1.  **Add Item Definitions to QBCore:**
    * Open `qb-core/shared/items.lua` and add the following code to your items list:
    ```lua
    ['saddle'] = {
        ['name'] = 'saddle', ['label'] = 'Saddle', ['weight'] = 3000, ['type'] = 'item',
        ['image'] = 'saddle.png', ['unique'] = false, ['usable'] = false, ['shouldClose'] = false,
        ['description'] = 'A leather saddle for riding animals.'
    },
    ['cow_whistle'] = {
        ['name'] = 'cow_whistle', ['label'] = 'Cow Whistle', ['weight'] = 100, ['type'] = 'item',
        ['image'] = 'cow_whistle.png', ['unique'] = false, ['usable'] = true, ['shouldClose'] = true,
        ['description'] = 'A special whistle. I wonder what will answer the call?'
    },
    ['boar_caller'] = {
        ['name'] = 'boar_caller', ['label'] = 'Boar Caller', ['weight'] = 250, ['type'] = 'item',
        ['image'] = 'boar_caller.png', ['unique'] = false, ['usable'] = true, ['shouldClose'] = true,
        ['description'] = 'A horn that produces a deep grunt. Might attract something wild.'
    },
    ['animal_stimulant'] = {
        ['name'] = 'animal_stimulant', ['label'] = 'Animal Stimulant', ['weight'] = 200, ['type'] = 'item',
        ['image'] = 'animal_stimulant.png', ['unique'] = false, ['usable'] = true, ['shouldClose'] = true,
        ['description'] = 'A potent concoction that will make your animal companion run much faster for a short time.'
    },
    ['ironhide_apple'] = {
        ['name'] = 'ironhide_apple', ['label'] = 'Ironhide Apple', ['weight'] = 500, ['type'] = 'item',
        ['image'] = 'ironhide_apple.png', ['unique'] = false, ['usable'] = true, ['shouldClose'] = true,
        ['description'] = 'An enchanted apple that makes your animal companion temporarily invincible.'
    },
    ```

2.  **Add Item Definitions to ox_inventory:**
    * Open `ox_inventory/data/items.lua` and add the following code:
    ```lua
    ['saddle'] = { label = 'Saddle', weight = 3000, stack = true, close = false },
    ['cow_whistle'] = { label = 'Cow Whistle', weight = 100, stack = true, close = true },
    ['boar_caller'] = { label = 'Boar Caller', weight = 250, stack = true, close = true },
    ['animal_stimulant'] = { label = 'Animal Stimulant', weight = 200, stack = true, close = true },
    ['ironhide_apple'] = { label = 'Ironhide Apple', weight = 500, stack = true, close = true },
    ```

3.  **Add Item Images:**
    * Make sure you have all five required images (`saddle.png`, `cow_whistle.png`, `boar_caller.png`, `animal_stimulant.png`, `ironhide_apple.png`).
    * Place all of them inside the `ox_inventory/web/images/` folder.

4.  **Ensure the Resource:**
    * Add `ensure lf-animalride` to your `server.cfg` or `resources.cfg`.
    * **Important:** This line must be placed *after* the dependencies.

5.  **Restart Server:**
    * Restart your FiveM server for all changes to take effect.

## How to Use

1.  **Get an Animal:** Tame a wild animal with a `saddle` or use a spawn item (e.g., `cow_whistle`) from your inventory.
2.  **Riding:**
    * Use your target key on your animal to **Mount**.
    * Use `W,A,S,D` to control the animal and hold **Shift** to run.
    * Press **F** to dismount. The animal will then follow you.
3.  **Using Buffs:** While you have an active animal, "Use" the `animal_stimulant` or `ironhide_apple` from your inventory to apply the effect.
4.  **Releasing:** To permanently dismiss your animal, target it and select **Release Animal**.

