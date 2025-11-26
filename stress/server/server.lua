exports('getStress', function(source)
    local player = Ox.GetPlayer(source)
    local stress = player.getStatus('stress') or StressConfig.stress.default
    
    return stress or StressConfig.stress.default
end)

exports('setStress', function(source, amount)
    local player = Ox.GetPlayer(source)
    local new = math.min(StressConfig.stress.max, math.max(StressConfig.stress.min, amount))
    player.setStatus('stress', new)
    TriggerClientEvent('stress:updateEffects', source, new)
end)

exports('changeStress', function(source, change)
    local player = Ox.GetPlayer(source)
    local currentStress = player.getStatus('stress') or StressConfig.stress.default
    local newStress = math.min(StressConfig.stress.max, math.max(StressConfig.stress.min, currentStress + change))
    player.setStatus('stress', newStress)
    TriggerClientEvent('stress:updateEffects', source, newStress)
end)

exports('getStressConfig', function()
    return StressConfig
end)

AddEventHandler('ox:playerLoaded', function(source)
    local player = Ox.GetPlayer(source)
    local stress = player.getStatus('stress') or StressConfig.stress.default
    TriggerClientEvent('stress:updateEffects', player.source, stress)
end)

lib.addCommand('stress', {
    help = 'Show your current stress level'
}, function(source)
    local player = Ox.GetPlayer(source)
    if not player then return end

    local stress = player.getStatus('stress') or 0
    TriggerClientEvent('chat:addMessage', source, {
        args = { '^3Stress', 'Your stress level is: ^2' .. stress }
    })
end)

lib.addCommand('set_stress', {
    help = 'Show your current stress level',
    params = {
        {
            name = 'target',
            type = 'number',
            help = 'Target players ID',
        },
        {
            name = 'amount',
            type = 'number',
            help = 'Stress amount to set',
        }
    },
    restricted = 'group.admin'
}, function(source, args)
    local player = Ox.GetPlayer(args.target)
    if not player then return end

    player.setStatus('stress', args.amount)
    TriggerClientEvent('stress:updateEffects', args.target, args.amount)

    local stress = player.getStatus('stress') or 0
    TriggerClientEvent('chat:addMessage', source, {
        args = { '^3Stress', 'Your stress level is: ^2' .. stress }
    })
end)

