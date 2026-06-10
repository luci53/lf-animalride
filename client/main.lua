-- =====================================================================
--  lf-animalride | Client
-- ---------------------------------------------------------------------
--  Handles targeting, riding controls, stamina, buffs and the companion
--  call. All item/economy decisions are made on the server; the client
--  only requests actions and reacts to events.
-- =====================================================================

local myAnimalPed   = nil
local myAnimalModel = nil
local isRiding      = false
local isSpeedBoosted = false
local isInvincible   = false
local stamina        = Config.Stamina.max
local staminaWarned  = false

-- --- helpers ----------------------------------------------------------

local function notify(kind, message)
    lib.notify({ type = kind, description = message })
end

RegisterNetEvent('lf-animalride:client:notify', function(kind, message)
    notify(kind, message)
end)

local function seatForModel(model)
    for _, animal in pairs(Config.Animals) do
        if animal.model == model then
            return animal.seat or Config.DefaultSeat
        end
    end
    return Config.DefaultSeat
end

-- A reasonable, on-ground spot just in front of the player.
local function safeSpawnCoords()
    local ped = PlayerPedId()
    local fwd = GetOffsetFromEntityInWorldCoords(ped, 0.0, 2.0, 0.0)
    local found, groundZ = GetGroundZFor_3dCoord(fwd.x, fwd.y, fwd.z + 1.0, false)
    local z = found and groundZ or GetEntityCoords(ped).z
    return vec3(fwd.x, fwd.y, z), GetEntityHeading(ped)
end

local function clearAnimalState()
    myAnimalPed = nil
    myAnimalModel = nil
    isRiding = false
    isSpeedBoosted = false
    isInvincible = false
end

-- --- riding -----------------------------------------------------------

local function dismount()
    if not isRiding then return end
    local ped = PlayerPedId()
    DetachEntity(ped, true, false)
    ClearPedTasksImmediately(ped)
    isRiding = false
end

local function mount()
    local ped = PlayerPedId()
    if IsPedInAnyVehicle(ped, false) or not myAnimalPed then return end

    local seat = seatForModel(myAnimalModel)
    local dict = seat.anim and seat.anim.dict
    if dict then
        RequestAnimDict(dict)
        local t = 0
        while not HasAnimDictLoaded(dict) and t < 2000 do Wait(10); t = t + 10 end
    end

    AttachEntityToEntity(ped, myAnimalPed, GetPedBoneIndex(myAnimalPed, seat.bone),
        seat.x, seat.y, seat.z, 0.0, 0.0, seat.heading, false, false, false, true, 2, true)
    if dict and HasAnimDictLoaded(dict) then
        TaskPlayAnim(ped, dict, seat.anim.name, 8.0, 1.0, -1, 1, 1.0, false, false, false)
    end
    isRiding = true
end

local function releaseAnimal()
    dismount()
    if myAnimalPed and DoesEntityExist(myAnimalPed) then
        SetEntityAsMissionEntity(myAnimalPed, true, true)
        DeleteEntity(myAnimalPed)
    end
    TriggerServerEvent('lf-animalride:server:release')
    clearAnimalState()
    notify('inform', Config.Locale.animal_released)
end

local function handleAnimalDeath()
    dismount()
    if myAnimalPed and DoesEntityExist(myAnimalPed) then
        SetEntityAsNoLongerNeeded(myAnimalPed)
    end
    TriggerServerEvent('lf-animalride:server:animalDied')
    clearAnimalState()
    notify('error', Config.Locale.animal_died)
end

-- --- buffs ------------------------------------------------------------

RegisterNetEvent('lf-animalride:client:applySpeedBoost', function(duration)
    if not myAnimalPed then return end
    isSpeedBoosted = true
    notify('success', Config.Locale.speed_buff_applied)
    SetTimeout(duration * 1000, function()
        isSpeedBoosted = false
        notify('inform', Config.Locale.speed_buff_worn_off)
    end)
end)

RegisterNetEvent('lf-animalride:client:applyInvincibility', function(duration)
    if not myAnimalPed then return end
    isInvincible = true
    SetEntityInvincible(myAnimalPed, true)
    notify('success', Config.Locale.invincibility_applied)
    SetTimeout(duration * 1000, function()
        isInvincible = false
        if DoesEntityExist(myAnimalPed) then SetEntityInvincible(myAnimalPed, false) end
        notify('inform', Config.Locale.invincibility_worn_off)
    end)
end)

-- --- spawning (summon item) -------------------------------------------

RegisterNetEvent('lf-animalride:client:spawnAnimal', function(animalKey)
    local animal = Config.Animals[animalKey]
    if not animal then return TriggerServerEvent('lf-animalride:server:spawnFailed') end
    if myAnimalPed and DoesEntityExist(myAnimalPed) then
        return TriggerServerEvent('lf-animalride:server:spawnFailed')
    end

    local model = animal.model
    RequestModel(model)
    local t = 0
    while not HasModelLoaded(model) and t < 5000 do Wait(10); t = t + 10 end
    if not HasModelLoaded(model) then
        return TriggerServerEvent('lf-animalride:server:spawnFailed')
    end

    local coords, heading = safeSpawnCoords()
    local ped = CreatePed(0, model, coords.x, coords.y, coords.z, heading, true, true)
    SetModelAsNoLongerNeeded(model)
    if not DoesEntityExist(ped) then
        return TriggerServerEvent('lf-animalride:server:spawnFailed')
    end

    SetEntityAsMissionEntity(ped, true, true)
    myAnimalPed = ped
    myAnimalModel = model
    TriggerServerEvent('lf-animalride:server:spawnConfirmed')
    notify('success', Config.Locale.spawn_success)
end)

-- --- call companion ---------------------------------------------------

local function callAnimal()
    if not myAnimalPed or not DoesEntityExist(myAnimalPed) then
        return notify('error', Config.Locale.no_active_animal)
    end
    if isRiding then return end

    local ped = PlayerPedId()
    local dist = #(GetEntityCoords(ped) - GetEntityCoords(myAnimalPed))
    if dist > Config.Call.teleportDistance then
        local coords = safeSpawnCoords()
        SetEntityCoords(myAnimalPed, coords.x, coords.y, coords.z, false, false, false, false)
        notify('success', Config.Locale.animal_recalled)
    else
        TaskGoToEntity(myAnimalPed, ped, -1, 2.0, 5.0, 1073741824, 0)
        notify('inform', Config.Locale.animal_coming)
    end
end

if Config.Call.enabled then
    RegisterCommand(Config.Call.command, callAnimal, false)
    RegisterKeyMapping(Config.Call.command, 'Call your animal companion', 'keyboard', Config.Call.key)
end

-- --- targeting --------------------------------------------------------

local function tameableModels()
    local list = {}
    for _, animal in pairs(Config.Animals) do list[#list + 1] = animal.model end
    for _, model in ipairs(Config.ExtraTameable) do list[#list + 1] = model end
    return list
end

exports.ox_target:addModel(tameableModels(), {
    {
        name = 'lf-animalride:saddle',
        label = Config.Locale.saddle_animal,
        icon = 'fas fa-horse-head',
        canInteract = function(entity)
            return not IsPedInAnyVehicle(PlayerPedId(), false)
                and not IsEntityAMissionEntity(entity)
                and myAnimalPed == nil
        end,
        onSelect = function(data)
            local progress = lib.progressBar({
                duration = Config.SaddleTime,
                label = Config.Locale.saddling_progress,
                canCancel = true,
                disable = { move = true, car = true, combat = true },
            })
            if not progress then
                return notify('error', Config.Locale.saddling_cancelled)
            end
            local ok, reason = lib.callback.await('lf-animalride:tame', false)
            if ok then
                myAnimalPed = data.entity
                myAnimalModel = GetEntityModel(data.entity)
                SetEntityAsMissionEntity(myAnimalPed, true, true)
                notify('success', Config.Locale.saddled_success)
            else
                notify('error', reason or Config.Locale.no_saddle)
            end
        end,
    },
    {
        name = 'lf-animalride:mount',
        label = Config.Locale.mount_animal,
        icon = 'fas fa-arrow-up-from-bracket',
        canInteract = function(entity)
            return entity == myAnimalPed and not isRiding
        end,
        onSelect = mount,
    },
    {
        name = 'lf-animalride:release',
        label = Config.Locale.release_animal,
        icon = 'fas fa-circle-xmark',
        color = 'red',
        canInteract = function(entity)
            return entity == myAnimalPed
        end,
        onSelect = releaseAnimal,
    },
})

-- --- main loop --------------------------------------------------------

local function drawStaminaBar()
    local pct = math.max(0.0, stamina / Config.Stamina.max)
    DrawRect(0.5, 0.95, 0.20, 0.022, 0, 0, 0, 150)
    DrawRect(0.405 + 0.095 * pct, 0.95, 0.19 * pct, 0.016, 120, 200, 120, 200)
end

CreateThread(function()
    while true do
        local sleep = 1000

        if myAnimalPed and DoesEntityExist(myAnimalPed) then
            if IsEntityDead(myAnimalPed) then
                handleAnimalDeath()
            elseif isRiding then
                sleep = 0
                local ped = PlayerPedId()

                DisableControlAction(0, 75, true) -- veh exit
                if IsDisabledControlJustReleased(0, 75) then dismount() end

                local wantsSprint = IsControlPressed(0, 21) -- left shift
                local canSprint = true

                if Config.Stamina.enabled then
                    local dt = GetFrameTime()
                    if wantsSprint and stamina > 0.0 then
                        stamina = stamina - Config.Stamina.drain * dt
                        if stamina <= 0.0 then
                            stamina = 0.0
                            canSprint = false
                            if not staminaWarned then
                                notify('inform', Config.Locale.stamina_depleted)
                                staminaWarned = true
                            end
                        end
                    else
                        stamina = math.min(Config.Stamina.max, stamina + Config.Stamina.regen * dt)
                        if stamina > Config.Stamina.max * 0.3 then staminaWarned = false end
                        if wantsSprint then canSprint = false end
                    end
                    if Config.Stamina.showBar then drawStaminaBar() end
                end

                local speed = Config.Movement.baseSpeed
                if wantsSprint and canSprint then speed = Config.Movement.runSpeed end
                if isSpeedBoosted then speed = speed * Config.Buffs.speed.multiplier end

                local axisX = GetControlNormal(2, 218)
                local axisY = GetControlNormal(2, 219) * -1.0
                if axisX ~= 0.0 or axisY ~= 0.0 then
                    local heading = GetEntityHeading(myAnimalPed) - axisX * Config.Movement.turnSpeed
                    SetEntityHeading(myAnimalPed, heading)
                    local target = GetOffsetFromEntityInWorldCoords(myAnimalPed, 0.0, axisY * speed, 0.0)
                    TaskGoStraightToCoord(myAnimalPed, target.x, target.y, target.z, speed, -1, heading, 0.1)
                end
            else
                sleep = 500
                if Config.Stamina.enabled then
                    stamina = math.min(Config.Stamina.max, stamina + Config.Stamina.regen * 0.5)
                end
                local ped = PlayerPedId()
                local dist = #(GetEntityCoords(ped) - GetEntityCoords(myAnimalPed))
                if dist > 3.0 and dist < 25.0 then
                    TaskFollowToOffsetOfEntity(myAnimalPed, ped, 1.5, 1.0, -1, 10.0, true)
                elseif dist >= 25.0 then
                    TaskGoToEntity(myAnimalPed, ped, -1, 3.0, 5.0, 1073741824, 0)
                end
            end
        end

        Wait(sleep)
    end
end)

-- --- cleanup ----------------------------------------------------------

AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    if myAnimalPed and DoesEntityExist(myAnimalPed) then
        SetEntityAsMissionEntity(myAnimalPed, true, true)
        DeleteEntity(myAnimalPed)
    end
end)
