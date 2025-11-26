local mushrooms = {
    green = {},
    red = {}
}
local cachedMushrooms = {
    green = {},
    red = {}
}

local function PickMushroom(area, index, mushroom, coords)
    local ped = PlayerPedId()
    local dict = 'amb@world_human_gardener_plant@male@base'
    local anim = 'base'
    
    TaskTurnPedToFaceEntity(ped, mushroom, 1000)
    Wait(1000)
    FreezeEntityPosition(ped, true)
    lib.playAnim(ped, dict, anim, 2.0, 2.0)
    
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

    local config = MushroomConfig[area]
    config.deStress = false
    config.isBroken = false

    if  config.deStressChance >= math.random(100) then

        config.deStress = true
        lib.requestNamedPtfxAsset("core", 3000)
        UseParticleFxAssetNextCall("core")
        StartNetworkedParticleFxNonLoopedAtCoord("bang_sand",
        coords.x, coords.y, coords.z -1, 0.0, 0.0, 0.0, 1.0, false, false, false)

    elseif config.breakChance >= math.random(100) then

        config.isBroken = true
        lib.requestNamedPtfxAsset("core", 3000)
        UseParticleFxAssetNextCall("core")
        StartNetworkedParticleFxNonLoopedAtCoord("ent_dst_polystyrene",
        coords.x, coords.y, coords.z -1, 0.0, 0.0, 0.0, 1.0, false, false, false)
    end
    
    RemoveNamedPtfxAsset("core")
    FreezeEntityPosition(ped, false)
    ClearPedTasks(ped)

    TriggerServerEvent('mushroom_hunting:pick', area, index, config.deStress, config.isBroken)
end

local function SpawnMushRoom(area, index, model, coords, zOffset)
    if mushrooms[area][index] then return end

    lib.requestModel(model)
    
    local mushroom = CreateObject(model, coords.x, coords.y, coords.z - zOffset, false, false, false)
    FreezeEntityPosition(mushroom, true)
    SetEntityInvincible(mushroom, true)
    SetEntityAsMissionEntity(mushroom, true, true)

    SetModelAsNoLongerNeeded(model)

    mushrooms[area][index] = mushroom

    exports.ox_target:addLocalEntity(mushroom, {
        {
            name = 'pick_mushroom',
            label = 'Pick Mushroom',
            icon = 'fa-solid fa-seedling',
            distance = 1.3,
            onSelect = function()
                PickMushroom(area, index, mushroom, coords)
            end
        }
    })
end

RegisterNetEvent('mushroom_hunting:spawn', function (area, index, model)
    local coords = MushroomConfig[area].spawnLocations[index]
    local config = MushroomConfig[area]
    local zOffset = math.random() *
        (config.spawnHeight.max - config.spawnHeight.min) + config.spawnHeight.min

    cachedMushrooms[area][index] = {
        area = area,
        index = index,
        model = model,
        coords = coords,
        zOffset = zOffset
    }

    if MushroomConfig[area].isInZone then
        SpawnMushRoom(area, index, model, coords, zOffset)
    end
end)

RegisterNetEvent('mushroom_hunting:despawn', function (area, index)
    cachedMushrooms[area][index] = nil
    
    local mushroom = mushrooms[area][index]
    if mushroom and DoesEntityExist(mushroom) then
        DeleteObject(mushroom)
        mushrooms[area][index] = nil
    end
end)

RegisterNetEvent('mushroom_hunting:applyStressDamage', function(damage)
    local ped = PlayerPedId()
    SetEntityHealth(ped, GetEntityHealth(ped) - damage)
end)

local function EnterZone(area)
    for index, data in pairs(cachedMushrooms[area]) do
        SpawnMushRoom(area, index, data.model, data.coords, data.zOffset)
    end
end

local function ExitZone(area)
    for index, obj in pairs(mushrooms[area]) do
        DeleteObject(obj)
        mushrooms[area][index] = nil
    end
end

local greenBox = lib.zones.box({
	name = "green",
	coords = vec3(771.0, -234.0, 66.0),
	size = vec3(150.0, 140, 10.0),
	rotation = 330.0,
    onEnter = function()
        MushroomConfig.green.isInZone = true
        EnterZone(MushroomConfig.green.name)
    end,
    onExit = function()
        MushroomConfig.green.isInZone = false
        ExitZone(MushroomConfig.green.name)
    end
})

local redBox = lib.zones.box({
	name = "red",
	coords = vec3(-1738.0, 161.0, 64.0),
	size = vec3(121.0, 250.0, 10.0),
	rotation = 30.0,
    onEnter = function()
        MushroomConfig.red.isInZone = true
        EnterZone("red")
    end,
    onExit = function()
        MushroomConfig.red.isInZone = false
        ExitZone("red")
    end
})
