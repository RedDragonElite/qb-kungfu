QBCore = exports['qb-core']:GetCoreObject()

-- Initialize Database
MySQL.query([[
    CREATE TABLE IF NOT EXISTS kungfu_stats (
        identifier VARCHAR(60) PRIMARY KEY,
        kicks_performed INT DEFAULT 0,
        hits_landed INT DEFAULT 0,
        damage_dealt INT DEFAULT 0,
        last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
    )
]])

-- Hit Registration Event
RegisterNetEvent('qb-kungfu:server:hitRegistered', function(targetNetId)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local Target = QBCore.Functions.GetPlayer(NetworkGetEntityOwner(targetNetId))

    if Player and Target then
        -- Update attacker stats
        MySQL.update('INSERT INTO kungfu_stats (identifier, kicks_performed, hits_landed, damage_dealt) VALUES (?, 1, 1, 25) ON DUPLICATE KEY UPDATE kicks_performed = kicks_performed + 1, hits_landed = hits_landed + 1, damage_dealt = damage_dealt + 25', {
            Player.PlayerData.citizenid
        })

        -- Notify target
        TriggerClientEvent('QBCore:Notify', Target.PlayerData.source, 'You were hit by a Kung Fu attack!', 'error')

        -- Log the hit (optional)
        print(string.format("[Kung Fu System] Player %s landed a hit on %s", src, Target.PlayerData.source))
    end
end)

-- Stats Command
QBCore.Commands.Add('kungfustats', 'Check your Kung Fu statistics', {}, false, function(source)
    local Player = QBCore.Functions.GetPlayer(source)

    if Player then
        MySQL.query('SELECT * FROM kungfu_stats WHERE identifier = ?', {
            Player.PlayerData.citizenid
        }, function(results)
            if results[1] then
                local stats = results[1]
                TriggerClientEvent('QBCore:Notify', source, string.format(
                    'Kung Fu Stats:\nKicks: %d\nHits: %d\nDamage: %d',
                    stats.kicks_performed,
                    stats.hits_landed,
                    stats.damage_dealt
                ))
            else
                TriggerClientEvent('QBCore:Notify', source, 'No Kung Fu statistics found!', 'error')
            end
        end)
    end
end)

-- Vehicle impact detection
AddEventHandler('gameEventTriggered', function(name, args)
    if name == 'CEventNetworkEntityDamage' then
        local victim = args[1]
        local attacker = args[2]
        local isDead = args[4] == 1

        -- Check if it's a vehicle being damaged by a ped that was kicked
        if victim and DoesEntityExist(victim) and IsEntityAVehicle(victim) then
            if attacker and DoesEntityExist(attacker) and IsPedRagdoll(attacker) then
                -- Create more dramatic effect for vehicle impact
                local vehicleCoords = GetEntityCoords(victim)
                local pedCoords = GetEntityCoords(attacker)

                -- Additional sound effect
                PlaySoundFromCoord(-1, "ScreenFlash", pedCoords.x, pedCoords.y, pedCoords.z, "WastedSounds", true, 5, false)

                -- More damage to vehicle at impact point
                local damageAmount = 1000
                SetVehicleDamage(victim,
                    pedCoords.x - vehicleCoords.x,
                    pedCoords.y - vehicleCoords.y,
                    pedCoords.z - vehicleCoords.z,
                    damageAmount, 10.0, true)

                -- Random chance to break window
                if math.random() < 0.3 then
                    SmashVehicleWindow(victim, math.random(0, 7))
                end
            end
        end
    end
end)
