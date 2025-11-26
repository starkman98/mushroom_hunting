local active = {}
local cooldowns = {}

local function RandomFreeLocation(area)
    local config = MushroomConfig[area]
    local total = #config.spawnLocations

    local freeLocations = {}
    for i = 1, total do
        if not active[area][i] and not cooldowns[area][i] then
            freeLocations[#freeLocations+1] = i
        end
    end

    if #freeLocations == 0 then
        return nil
    end

    return freeLocations[math.random(1, #freeLocations)]
end

local function Spawn(area, index)
    local config = MushroomConfig[area]
    local model = config.model

    active[area][index] = true
    TriggerClientEvent('mushroom_hunting:spawn', -1, area, index, model)
end

local function StartCooldown(area, index)
    local config = MushroomConfig[area]
    local cooldownTime = math.random(config.cooldown.min, config.cooldown.max)

    cooldowns[area][index] = os.time() + cooldownTime
    SetTimeout(cooldownTime * 1000, function()
        cooldowns[area][index] = nil

        local newIndex = RandomFreeLocation(area)
        if newIndex then
        Spawn(area, newIndex)
        else
            Spawn(area, index)
        end
    end)
end

RegisterNetEvent('mushroom_hunting:pick', function(area, index, deStress, isBroken)
    local source = source
    local config = MushroomConfig[area]

    if not active[area][index] then return end
    active[area][index] = nil

    local stressConfig = exports.stress:getStressConfig()
    local stressLoss = stressConfig.stress.decrease.mushroomPick
    local stress = exports.stress:getStress(source)

    if deStress and stress <= config.minStressLevel then
        local damage = config.damageOnLowStress
        TriggerClientEvent('mushroom_hunting:applyStressDamage', source, damage)
    elseif deStress then
        exports.stress:changeStress(source, -stressLoss)
    end

    TriggerClientEvent('mushroom_hunting:despawn', -1, area, index)

    if not isBroken then
        exports.ox_inventory:AddItem(source, config.item, 1)
    end

    StartCooldown(area, index)
end)

RegisterNetEvent('mushroom_hunting:requestSync', function(playerId)
    for area, group in pairs(active) do
        for index, exists in pairs(group) do
            if exists then
                local cfg = MushroomConfig[area]
                TriggerClientEvent('mushroom_hunting:spawn', playerId, area, index, cfg.model)
            end
        end
    end
end)

RegisterNetEvent('mushroom_hunting:deleteAll', function()
    for area, group in pairs(active) do
        for index, _ in pairs(group) do
            active[area][index] = nil
            TriggerClientEvent('mushroom_hunting:despawn', -1, area, index)
        end
    end
end)

RegisterNetEvent('mushroom_hunting:despawnAll', function(playerId)
    for area, group in pairs(active) do
        for index, _ in pairs(group) do
            active[area][index] = nil
            TriggerClientEvent('mushroom_hunting:despawn', playerId, area, index)
        end
    end
end)

RegisterCommand('delmushrooms', function(src)
    TriggerEvent('mushroom_hunting:deleteAll')
end, true)

CreateThread(function()
    Wait(1000)
    for area, config in pairs(MushroomConfig) do
        if not active[area] then
            active[area] = {}
        end

        if not cooldowns[area] then
            cooldowns[area] = {}
        end

        for i = 1, config.maxSpawnedMushrooms do
            local index = RandomFreeLocation(area)
            if index then
                Spawn(area, index)
            end
        end
    end
end)
