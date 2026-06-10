-- =====================================================================
--  lf-animalride | Server
-- ---------------------------------------------------------------------
--  Authoritative owner of the item economy and animal ownership. The
--  client cannot add or remove items directly anymore; it can only ask,
--  and the server decides. State is tracked per player so refunds are
--  always bounded (one item out for one item in).
-- =====================================================================

-- animals[src] = { source = 'item'|'saddle', pending = bool,
--                  speedUntil = epoch, invincUntil = epoch }
local animals = {}

local function now() return os.time() end

-- Consume on use (qb/esx) or refund on invalid use (ox auto-consumed).
-- Returns true only when the player has effectively paid for the action.
local function settleUse(src, item, proceed)
    if proceed then
        if Bridge.AutoConsumes() then return true end
        return Bridge.RemoveItem(src, item, 1)
    end
    if Bridge.AutoConsumes() then Bridge.AddItem(src, item, 1) end
    return false
end

-- --- spawn (summon) ---------------------------------------------------

local function onUseSpawnItem(src, animalKey)
    local animal = Config.Animals[animalKey]
    if not animal then return end

    if animals[src] then
        settleUse(src, animal.spawnItem, false)
        Bridge.Notify(src, 'error', Config.Locale.already_have_animal)
        return
    end
    if not settleUse(src, animal.spawnItem, true) then
        Bridge.Notify(src, 'error', Config.Locale.no_active_animal)
        return
    end

    animals[src] = { source = 'item', pending = true, spawnItem = animal.spawnItem }
    TriggerClientEvent('lf-animalride:client:spawnAnimal', src, animalKey)
end

RegisterNetEvent('lf-animalride:server:spawnConfirmed', function()
    local data = animals[source]
    if data then data.pending = nil end
end)

RegisterNetEvent('lf-animalride:server:spawnFailed', function()
    local src = source
    local data = animals[src]
    if data and data.pending and data.spawnItem then
        -- the summon item was consumed; refund it (bounded by `pending`)
        Bridge.AddItem(src, data.spawnItem, 1)
        animals[src] = nil
        Bridge.Notify(src, 'error', Config.Locale.spawn_failed)
    end
end)

-- --- taming (saddle) --------------------------------------------------

lib.callback.register('lf-animalride:tame', function(src)
    if animals[src] then
        return false, Config.Locale.already_have_animal
    end
    if not Bridge.RemoveItem(src, Config.SaddleItem, 1) then
        return false, Config.Locale.no_saddle
    end
    animals[src] = { source = 'saddle' }
    return true
end)

-- --- release ----------------------------------------------------------

RegisterNetEvent('lf-animalride:server:release', function()
    local src = source
    local data = animals[src]
    if not data then return end

    if data.source == 'saddle' then
        Bridge.AddItem(src, Config.SaddleItem, 1)
        Bridge.Notify(src, 'inform', Config.Locale.saddle_returned)
    end
    animals[src] = nil
end)

RegisterNetEvent('lf-animalride:server:animalDied', function()
    animals[source] = nil -- no refund on death
end)

-- --- buffs ------------------------------------------------------------

local function onUseSpeed(src)
    local data = animals[src]
    if not data then
        settleUse(src, Config.Buffs.speed.item, false)
        return Bridge.Notify(src, 'error', Config.Locale.no_active_animal)
    end
    if (data.speedUntil or 0) > now() then
        settleUse(src, Config.Buffs.speed.item, false)
        return Bridge.Notify(src, 'error', Config.Locale.buff_already_active)
    end
    if not settleUse(src, Config.Buffs.speed.item, true) then return end

    data.speedUntil = now() + Config.Buffs.speed.duration
    TriggerClientEvent('lf-animalride:client:applySpeedBoost', src, Config.Buffs.speed.duration)
end

local function onUseInvincibility(src)
    local data = animals[src]
    if not data then
        settleUse(src, Config.Buffs.invincibility.item, false)
        return Bridge.Notify(src, 'error', Config.Locale.no_active_animal)
    end
    if (data.invincUntil or 0) > now() then
        settleUse(src, Config.Buffs.invincibility.item, false)
        return Bridge.Notify(src, 'error', Config.Locale.buff_already_active)
    end
    if not settleUse(src, Config.Buffs.invincibility.item, true) then return end

    data.invincUntil = now() + Config.Buffs.invincibility.duration
    TriggerClientEvent('lf-animalride:client:applyInvincibility', src, Config.Buffs.invincibility.duration)
end

-- --- cleanup ----------------------------------------------------------

AddEventHandler('playerDropped', function()
    animals[source] = nil
end)

-- --- register usable items (after the bridge resolves the framework) --

CreateThread(function()
    while not Bridge.Ready() do Wait(50) end

    for key, animal in pairs(Config.Animals) do
        if animal.spawnItem then
            Bridge.RegisterUsableItem(animal.spawnItem, function(src) onUseSpawnItem(src, key) end)
        end
    end
    Bridge.RegisterUsableItem(Config.Buffs.speed.item, onUseSpeed)
    Bridge.RegisterUsableItem(Config.Buffs.invincibility.item, onUseInvincibility)
end)
