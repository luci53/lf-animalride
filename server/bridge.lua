-- =====================================================================
--  lf-animalride | Server-side framework + inventory bridge
-- ---------------------------------------------------------------------
--  Isolates every QBox / QBCore / ESX and ox/qb/esx-inventory
--  difference. The rest of the server only talks to this table.
-- =====================================================================

Bridge = {}

local Core
local frameworkName  -- 'qbx' | 'qb' | 'esx'
local inventoryName  -- 'ox'  | 'qb' | 'esx'
local usableHandlers = {} -- itemName -> function(src)

local function has(resource)
    return GetResourceState(resource) ~= 'missing'
end

-- --- detection --------------------------------------------------------

local function resolveFramework()
    local choice = Config.Framework
    if choice ~= 'auto' then return choice end
    if has('qbx_core') then return 'qbx' end
    if has('qb-core') then return 'qb' end
    if has('es_extended') then return 'esx' end
    error('[lf-animalride] No supported framework found (qbx_core / qb-core / es_extended).')
end

local function resolveInventory()
    local choice = Config.Inventory
    if choice ~= 'auto' then return choice end
    if has('ox_inventory') then return 'ox' end
    return frameworkName == 'esx' and 'esx' or 'qb'
end

-- True when the inventory consumes a "used" item by itself (ox_inventory).
-- Drives whether we refund (ox) or consume manually (qb/esx) on use.
function Bridge.AutoConsumes()
    return inventoryName == 'ox'
end

function Bridge.Framework() return frameworkName end
function Bridge.Ready() return Core ~= nil end

-- --- players ----------------------------------------------------------

function Bridge.GetPlayer(src)
    if not Core then return nil end
    if frameworkName == 'qbx' then return Core:GetPlayer(src) end
    if frameworkName == 'qb'  then return Core.Functions.GetPlayer(src) end
    if frameworkName == 'esx' then return Core.GetPlayerFromId(src) end
end

-- --- items ------------------------------------------------------------

function Bridge.GetItemCount(src, name)
    if inventoryName == 'ox' then
        return exports.ox_inventory:Search(src, 'count', name) or 0
    end
    local player = Bridge.GetPlayer(src)
    if not player then return 0 end
    if inventoryName == 'esx' then
        local item = player.getInventoryItem(name)
        return item and item.count or 0
    end
    local item = player.Functions.GetItemByName(name)
    return item and item.amount or 0
end

function Bridge.HasItem(src, name, amount)
    return Bridge.GetItemCount(src, name) >= (amount or 1)
end

function Bridge.RemoveItem(src, name, amount)
    amount = amount or 1
    if inventoryName == 'ox' then
        return exports.ox_inventory:RemoveItem(src, name, amount) and true or false
    end
    local player = Bridge.GetPlayer(src)
    if not player then return false end
    if inventoryName == 'esx' then
        if (Bridge.GetItemCount(src, name)) < amount then return false end
        player.removeInventoryItem(name, amount)
        return true
    end
    return player.Functions.RemoveItem(name, amount) and true or false
end

function Bridge.AddItem(src, name, amount)
    amount = amount or 1
    if inventoryName == 'ox' then
        return exports.ox_inventory:AddItem(src, name, amount) and true or false
    end
    local player = Bridge.GetPlayer(src)
    if not player then return false end
    if inventoryName == 'esx' then
        player.addInventoryItem(name, amount)
        return true
    end
    return player.Functions.AddItem(name, amount) and true or false
end

-- --- usable items -----------------------------------------------------

-- Register a callback for when `name` is used. Works the same regardless
-- of inventory: with ox_inventory we listen to ox_inventory:usedItem;
-- otherwise we use the framework's usable-item API.
function Bridge.RegisterUsableItem(name, cb)
    usableHandlers[name] = cb

    if inventoryName == 'ox' then
        return -- handled by the shared ox_inventory:usedItem listener below
    end
    if frameworkName == 'esx' then
        Core.RegisterUsableItem(name, function(source) cb(source) end)
    else -- qb / qbx native inventory
        Core.Functions.CreateUseableItem(name, function(source) cb(source) end)
    end
end

-- --- notify -----------------------------------------------------------

function Bridge.Notify(src, kind, message)
    TriggerClientEvent('lf-animalride:client:notify', src, kind, message)
end

-- --- boot -------------------------------------------------------------

CreateThread(function()
    frameworkName = resolveFramework()

    if frameworkName == 'qbx' then
        Core = exports.qbx_core
    elseif frameworkName == 'qb' then
        Core = exports['qb-core']:GetCoreObject()
    elseif frameworkName == 'esx' then
        Core = exports.es_extended:getSharedObject()
    end

    inventoryName = resolveInventory()

    -- Single ox_inventory listener that dispatches to our handlers.
    if inventoryName == 'ox' then
        AddEventHandler('ox_inventory:usedItem', function(source, itemName)
            local cb = usableHandlers[itemName]
            if cb then cb(source) end
        end)
    end

    if Config.Debug then
        print(('[lf-animalride] framework=%s inventory=%s'):format(frameworkName, inventoryName))
    end
end)
