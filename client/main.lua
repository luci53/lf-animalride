local QBCore = exports['qb-core']:GetCoreObject()

local myAnimalPed = nil
local wasAnimalFromItem = false
local isRiding = false
local isSpeedBoosted = false
local isInvincible = false

local function hasSaddle()
    return QBCore.Functions.HasItem(Config.SaddleItem)
end

local function dismountAnimal()
    if not isRiding then return end
    local playerPed = PlayerPedId()
    DetachEntity(playerPed, true, false)
    ClearPedTasksImmediately(playerPed)
    isRiding = false
end

local function releaseAnimal()
    if isRiding then dismountAnimal() end
    if not wasAnimalFromItem then TriggerServerEvent('lf-animalride:server:returnSaddle') end
    DeleteEntity(myAnimalPed)
    myAnimalPed = nil
    wasAnimalFromItem = false
    isSpeedBoosted = false
    isInvincible = false
    exports.ox_lib:notify({ type = 'info', title = 'Released', description = Config.Locale.animal_released })
end

RegisterNetEvent('lf-animalride:client:spawnAnimal', function(model, itemName)
    if myAnimalPed then
        exports.ox_lib:notify({ type = 'error', title = 'Error', description = Config.Locale.already_have_animal })
        return
    end
    TriggerServerEvent('lf-animalride:server:removeItem', itemName)
    local playerPed = PlayerPedId()
    local spawnCoords = GetOffsetFromEntityInWorldCoords(playerPed, 0.0, 2.0, 0.0)
    RequestModel(model)
    while not HasModelLoaded(model) do Wait(100) end
    myAnimalPed = CreatePed(0, model, spawnCoords, GetEntityHeading(playerPed), true, true)
    SetModelAsNoLongerNeeded(model)
    SetEntityAsMissionEntity(myAnimalPed, true, true)
    wasAnimalFromItem = true
    exports.ox_lib:notify({ type = 'success', title = 'Success', description = Config.Locale.spawn_success })
end)


RegisterNetEvent('lf-animalride:client:applySpeedBoost', function()
    if not myAnimalPed then
        return exports.ox_lib:notify({ type = 'error', description = Config.Locale.no_animal_to_buff })
    end
    if isSpeedBoosted then
        return exports.ox_lib:notify({ type = 'error', description = Config.Locale.buff_already_active })
    end

    TriggerServerEvent('lf-animalride:server:removeItem', 'animal_stimulant')
    isSpeedBoosted = true
    exports.ox_lib:notify({ type = 'success', description = Config.Locale.speed_buff_applied })

    SetTimeout(Config.BuffItems.SpeedBoostDuration, function()
        isSpeedBoosted = false
        exports.ox_lib:notify({ type = 'info', description = Config.Locale.speed_buff_worn_off })
    end)
end)

RegisterNetEvent('lf-animalride:client:applyInvincibility', function()
    if not myAnimalPed then
        return exports.ox_lib:notify({ type = 'error', description = Config.Locale.no_animal_to_buff })
    end
    if isInvincible then
        return exports.ox_lib:notify({ type = 'error', description = Config.Locale.buff_already_active })
    end

    TriggerServerEvent('lf-animalride:server:removeItem', 'ironhide_apple')
    isInvincible = true
    SetEntityInvincible(myAnimalPed, true)
    exports.ox_lib:notify({ type = 'success', description = Config.Locale.invincibility_applied })

    SetTimeout(Config.BuffItems.InvincibilityDuration, function()
        isInvincible = false
        if DoesEntityExist(myAnimalPed) then SetEntityInvincible(myAnimalPed, false) end
        exports.ox_lib:notify({ type = 'info', description = Config.Locale.invincibility_worn_off })
    end)
end)

exports.ox_target:addModel(Config.RidablePeds, {
    {
        name = 'animalriding:saddle',
        label = Config.Locale.saddle_animal,
        icon = 'fas fa-horse-head',
        canInteract = function(entity)
            return not IsPedInAnyVehicle(PlayerPedId()) and not IsEntityAMissionEntity(entity) and not myAnimalPed
        end,
        onSelect = function(data)
            if not hasSaddle() then
                return exports.ox_lib:notify({ type = 'error', title = 'Inventory', description = Config.Locale.no_saddle })
            end
            local progress = exports.ox_lib:progressBar({
                duration = Config.SaddleTime,
                label = Config.Locale.saddling_progress,
                canCancel = true,
                disable = { move = true, car = true },
            })
            if progress.completed then
                TriggerServerEvent('lf-animalride:server:useSaddle')
                myAnimalPed = data.entity
                SetEntityAsMissionEntity(myAnimalPed, true, true)
                wasAnimalFromItem = false
                exports.ox_lib:notify({ type = 'success', title = 'Success', description = Config.Locale.saddled_success })
            else
                exports.ox_lib:notify({ type = 'error', title = 'Cancelled', description = Config.Locale.saddling_cancelled })
            end
        end
    },
    {
        name = 'animalriding:mount',
        label = Config.Locale.mount_animal,
        icon = 'fas fa-arrow-up-from-bracket',
        canInteract = function(entity)
            return entity == myAnimalPed and not isRiding
        end,
        onSelect = function(data)
            local playerPed = PlayerPedId()
            if IsPedInAnyVehicle(playerPed, false) then return end
            local animDict = "amb@prop_human_seat_chair@male@generic@base"
            RequestAnimDict(animDict)
            while not HasAnimDictLoaded(animDict) do Wait(100) end
            AttachEntityToEntity(playerPed, myAnimalPed, GetPedBoneIndex(myAnimalPed, 24816), 0.0, 0.0, 0.2, 0.0, 0.0, -90.0, false, false, false, true, 2, true)
            TaskPlayAnim(playerPed, animDict, "base", 8.0, 1, -1, 1, 1.0, false, false, false)
            isRiding = true
        end
    },
    {
        name = 'animalriding:release',
        label = Config.Locale.release_animal,
        icon = 'fas fa-times-circle',
        color = 'red',
        canInteract = function(entity)
            return entity == myAnimalPed
        end,
        onSelect = function(data)
            releaseAnimal()
        end
    }
})

CreateThread(function()
    while true do
        Wait(0)
        if myAnimalPed then
            local playerPed = PlayerPedId()
            if isRiding then
                DisableControlAction(0, 75, true) 
                if IsDisabledControlJustReleased(0, 75) then dismountAnimal() end
                
               
                local speed = Config.AnimalBaseSpeed
                if IsControlPressed(0, 21) then speed = Config.AnimalRunSpeed end
                if isSpeedBoosted then speed = speed * Config.BuffItems.SpeedMultiplier end

                local leftAxisX = GetControlNormal(2, 218)
                local leftAxisY = GetControlNormal(2, 219) * -1.0
                if leftAxisX ~= 0.0 or leftAxisY ~= 0.0 then
                    local heading = GetEntityHeading(myAnimalPed)
                    local newHeading = heading - leftAxisX * 2.0
                    SetEntityHeading(myAnimalPed, newHeading)
                    local forwardCoords = GetOffsetFromEntityInWorldCoords(myAnimalPed, 0.0, leftAxisY * speed, 0.0)
                    TaskGoStraightToCoord(myAnimalPed, forwardCoords.x, forwardCoords.y, forwardCoords.z, speed, -1, newHeading, 0.1)
                end
            else
                Wait(500)
                local distance = #(GetEntityCoords(playerPed) - GetEntityCoords(myAnimalPed))
                if distance > 3.0 and distance < 25.0 then
                    TaskFollowToOffsetOfEntity(myAnimalPed, playerPed, 1.5, 1.0, -1, 10.0, true)
                elseif distance >= 25.0 then
                    TaskGoToEntity(myAnimalPed, playerPed, -1, 3.0, 5.0, 1073741824, 0)
                end
            end
        end
    end
end)