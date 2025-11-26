local function UpdateStressEffects(level)
    local stress = StressConfig.stress
    if level >= stress.levels.high then
        stress.activeLevel = stress.levelValues.high
        AnimpostfxStopAll()
        StopGameplayCamShaking(true)

        ShakeGameplayCam("SMALL_EXPLOSION_SHAKE", 0.3)
        AnimpostfxPlay("DrugsTrevorClownsFight", 2000, true)

    elseif level >= stress.levels.medium then
        stress.activeLevel = stress.levelValues.medium
        AnimpostfxStopAll()
        StopGameplayCamShaking(true)

        ShakeGameplayCam("SMALL_EXPLOSION_SHAKE", 0.1)
        AnimpostfxPlay("MinigameTransitionIn", 1500, true)

    elseif level >= stress.levels.low then
        stress.activeLevel = stress.levelValues.low
        AnimpostfxStopAll()
        StopGameplayCamShaking(true)

        AnimpostfxPlay("PPFilter", 1000, true)
    else
        stress.activeLevel = nil
        AnimpostfxStopAll()
        StopGameplayCamShaking(true)
    end
end

RegisterNetEvent('stress:updateEffects', function(level)
    UpdateStressEffects(level)
end)

AddEventHandler('ox:statusTick', function(source)
    local player = Ox.GetPlayer(source)
    local stress = player.getStatus('stress')
    local levels = StressConfig.stress.levels
    local activeLevel = StressConfig.stress.activeLevel
    local levelValues = StressConfig.stress.levelValues

    if stress >= levels.high and activeLevel ~= levelValues.high then
        StressConfig.stress.activeLevel = levelValues.high
        UpdateStressEffects(stress)
    elseif stress >= levels.medium and stress < levels.high and activeLevel ~= levelValues.medium then
        StressConfig.stress.activeLevel = levelValues.medium
        UpdateStressEffects(stress)
    elseif stress >= levels.low and stress < levels.medium and activeLevel ~= levelValues.low then
        StressConfig.stress.activeLevel = levelValues.low
        UpdateStressEffects(stress)
    elseif stress < levels.low and activeLevel ~= nil then
        StressConfig.stress.activeLevel = nil
        AnimpostfxStopAll()
        StopGameplayCamShaking(true)
    else
        if stress % StressConfig.stress.effectTick == 0 and stress ~= 0 then
            UpdateStressEffects(stress)
        end
    end
end)