local mushrooms = {
    green = {},
    red = {}
} -- entity list

local function PickMushroom(area, index, mushroom)
    local ped = PlayerPedId()
    local dict = 'amb@world_human_gardener_plant@male@base'
    local anim = 'base'

    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do Wait(0) end
    
    TaskTurnPedToFaceEntity(ped, mushroom, 1000)
    Wait(1000)
    FreezeEntityPosition(ped, true)
    TaskPlayAnim(ped, dict, anim, 1.2, 1.2, -1, 1, 0.0, false, false, false)

    lib.progressBar({
        duration = 3000,
        label = 'Picking Mushroom',
        useWhileDead = false,
        canCancel = true,
        disable = {
            move = true,
            combat = true,
            car = true
        }
    })
    
    FreezeEntityPosition(ped, false)
    ClearPedTasks(ped)
    
    TriggerServerEvent('mushroom_hunting:pick', area, index)
end

RegisterNetEvent('mushroom_hunting:spawn', function (area, index, model)
    local coords = Config[area].spawnLocations[index]

    RequestModel(model)
    while not HasModelLoaded(model) do Wait(0) end --praxxis enligt CahtGPT
    
    local config = Config[area]
    local spawnHeightOffset = math.random() * (config.spawnHeight.max - config.spawnHeight.min) + config.spawnHeight.min
    local mushroom = CreateObject(model, coords.x, coords.y, coords.z - spawnHeightOffset, false, false, false)
    FreezeEntityPosition(mushroom, true)
    SetEntityInvincible(mushroom, true)
    SetEntityAsMissionEntity(mushroom, true, true)

    mushrooms[area][index] = mushroom

    exports.ox_target:addLocalEntity(mushroom, {
        {
            name = 'pick_mushroom',
            label = 'Pick Mushroom',
            icon = 'fa-solid fa-seedling',
            distance = 1.3,
            onSelect = function()
                PickMushroom(area, index, mushroom)
            end
        }
    })
end)

RegisterNetEvent('mushroom_hunting:despawn', function (area, index)
    local mushroom = mushrooms[area][index]
    if mushroom and DoesEntityExist(mushroom) then
        DeleteObject(mushroom)
        mushrooms[area][index] = nil
    end
end)

AddEventHandler('onClientResourceStart', function(resource)
    if resource == GetCurrentResourceName() then
        TriggerServerEvent('mushroom_hunting:requestSync')
    end
end)