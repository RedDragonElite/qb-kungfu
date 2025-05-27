-- Enhanced Kung Fu Combat Script for QB Core
-- Configuration
local isKungFuActive = false
local cooldown = false
local cooldownTime = 500 -- How fast you can kick after a kick
local kickForce = 30.0 -- Increased power of kick for more brutal impacts
local kickRange = 2.8 -- How near needs the ped to be
local punchDamageMultiplier = 4.0 -- Multiplier for punch damage when kung fu is active
local vehicleDamageOnImpact = true -- Enable vehicle damage when kicked peds hit vehicles
local impactDamageThreshold = 5.0 -- Minimum velocity for vehicle damage to occur
local ragdollTime = 3000 -- Extended ragdoll time for more dramatic effect
local environmentalImpactEffect = true -- Enable special effects on wall/vehicle impacts
local currentCombatStyle = 'Traditional' -- Default combat style

-- Sound effects
local sounds = {
    kick = "WEAPON_UNARMED",
    impact = "VEHICLES_HORNS_AMBULANCE_WARNING",
    bone_crack = "VEHICLES_HORNS_SIREN_1",
    realistic_impact = "PHYSICS_BOOM_CONCRETE", -- New realistic impact sound
    punch_whoosh = "WEAPON_SWITCH", -- New punch whoosh sound
    grapple_struggle = "WEAPON_BAT" -- New grapple struggle sound
}

-- Different kick animations for each style
local kickAnimations = {
    Traditional = {
        {dict = "melee@unarmed@streamed_core_fps", anim = "kick_close_a", waitTime = 750},
        {dict = "melee@unarmed@streamed_core_fps", anim = "kick_close_b", waitTime = 700}
    },
    Street = {
        {dict = "melee@unarmed@streamed_variations", anim = "plyr_takedown_front_slap", waitTime = 800},
        {dict = "melee@unarmed@streamed_variations", anim = "plyr_takedown_rear_lefthook", waitTime = 750}
    },
    Mixed = {
        {dict = "melee@unarmed@streamed_core_fps", anim = "kick_close_a", waitTime = 750},
        {dict = "melee@unarmed@streamed_variations", anim = "plyr_takedown_front_slap", waitTime = 800}
    }
}

-- Register the context menu
RegisterNetEvent('qb-kungfu:client:openMenu', function()
    local menu = {
        {
            header = "Kung Fu Controls",
            isMenuHeader = true
        },
        {
            header = "Toggle Kung Fu Mode",
            txt = "Activate/Deactivate Kung Fu",
            icon = "fa-solid fa-hand-fist",
            params = {
                event = "qb-kungfu:client:toggleKungFu"
            }
        },
        {
            header = "Kick Force",
            txt = "Adjust kick power",
            icon = "fa-solid fa-bolt",
            params = {
                event = "qb-kungfu:client:kickForceMenu"
            }
        },
        {
            header = "Combat Style",
            txt = "Choose your fighting style",
            icon = "fa-solid fa-user-ninja",
            params = {
                event = "qb-kungfu:client:combatStyleMenu"
            }
        },
        {
            header = "Show Tutorial",
            txt = "Display kung fu controls",
            icon = "fa-solid fa-book",
            params = {
                event = "qb-kungfu:client:showTutorial"
            }
        }
    }
    TriggerEvent('qb-menu:client:openMenu', menu)
end)

-- Kick Force Submenu
RegisterNetEvent('qb-kungfu:client:kickForceMenu', function()
    local menu = {
        {
            header = "Kick Force",
            isMenuHeader = true
        },
        {
            header = "Normal",
            txt = "Set kick force to normal",
            icon = "fa-solid fa-bolt",
            params = {
                event = "qb-kungfu:client:setKickForce",
                args = 15.0
            }
        },
        {
            header = "Strong",
            txt = "Set kick force to strong",
            icon = "fa-solid fa-bolt",
            params = {
                event = "qb-kungfu:client:setKickForce",
                args = 24.0
            }
        },
        {
            header = "Extreme",
            txt = "Set kick force to extreme",
            icon = "fa-solid fa-bolt",
            params = {
                event = "qb-kungfu:client:setKickForce",
                args = 35.0
            }
        }
    }
    TriggerEvent('qb-menu:client:openMenu', menu)
end)

-- Combat Style Submenu
RegisterNetEvent('qb-kungfu:client:combatStyleMenu', function()
    local menu = {
        {
            header = "Combat Style",
            isMenuHeader = true
        },
        {
            header = "Traditional",
            txt = "Set combat style to traditional",
            icon = "fa-solid fa-user-ninja",
            params = {
                event = "qb-kungfu:client:setCombatStyle",
                args = 'Traditional'
            }
        },
        {
            header = "Street",
            txt = "Set combat style to street",
            icon = "fa-solid fa-user-ninja",
            params = {
                event = "qb-kungfu:client:setCombatStyle",
                args = 'Street'
            }
        },
        {
            header = "Mixed",
            txt = "Set combat style to mixed",
            icon = "fa-solid fa-user-ninja",
            params = {
                event = "qb-kungfu:client:setCombatStyle",
                args = 'Mixed'
            }
        }
    }
    TriggerEvent('qb-menu:client:openMenu', menu)
end)

-- Function to toggle kung fu mode
RegisterNetEvent('qb-kungfu:client:toggleKungFu', function()
    if IsPedInAnyVehicle(PlayerPedId(), false) then
        QBCore.Functions.Notify('Cannot activate while in a vehicle', 'error')
        return
    end

    isKungFuActive = not isKungFuActive

    if isKungFuActive then
        QBCore.Functions.Notify('Kung Fu Mode Activated', 'success')
        -- Visual effect to show activation
        AnimpostfxPlay("FocusIn", 800, false)
    else
        QBCore.Functions.Notify('Kung Fu Mode Deactivated', 'error')
        AnimpostfxStop("FocusIn")
    end
end)

-- Function to set kick force
RegisterNetEvent('qb-kungfu:client:setKickForce', function(force)
    kickForce = force
    QBCore.Functions.Notify('Kick Force Set to ' .. (force == 15.0 and 'Normal' or force == 24.0 and 'Strong' or 'Extreme'), 'info')
end)

-- Function to set combat style
RegisterNetEvent('qb-kungfu:client:setCombatStyle', function(style)
    currentCombatStyle = style
    QBCore.Functions.Notify('Combat Style Changed to ' .. style, 'info')
end)

-- Command to toggle kung fu mode
RegisterCommand('kungfu', function()
    TriggerEvent('qb-kungfu:client:openMenu')
end)

-- Function to show tutorial
function ShowTutorial()
    local tutorialText = [[
        <strong>Kung Fu Controls Tutorial</strong><br>
        <br>
        <strong>Activating Kung Fu Mode:</strong><br>
        - Press <strong>[F5]</strong> to toggle Kung Fu Mode on or off.<br>
        - Kung Fu Mode cannot be activated while in a vehicle.<br>
        <br>
        <strong>Performing Kicks:</strong><br>
        - Press <strong>[RMB]</strong> to target an enemy and perform a kick.<br>
        - The kick force can be adjusted in the menu (Normal, Strong, Extreme).<br>
        <br>
        <strong>Performing Punches:</strong><br>
        - Press <strong>[LMB]</strong> to perform enhanced punches.<br>
        - Hold <strong>[SHIFT]</strong> + <strong>[LMB]</strong> for power strikes.<br>
        <br>
        <strong>Special Moves:</strong><br>
        - Press <strong>[SPACE] + [F]</strong> to perform a flying kick.<br>
        - Press <strong>[RMB] + [E]</strong> to perform a grapple attack.<br>
        <br>
        <strong>Combat Styles:</strong><br>
        - Choose your fighting style (Traditional, Street, Mixed) from the menu.<br>
        <br>
        <strong>Environmental Effects:</strong><br>
        - Kicked enemies may cause environmental impacts, such as wall damage or vehicle damage.<br>
        <br>
        <strong>Note:</strong> Ensure you are not in a vehicle to use Kung Fu Mode effectively.
    ]]

    -- Notify player
    QBCore.Functions.Notify('Displaying tutorial...', 'info')

    -- Force close any existing UI first
    if tutorialDisplayed then
        exports['qb-core']:HideText()
        Wait(100)
    end

    -- Display the tutorial with a persistent UI
    exports['qb-core']:DrawText(tutorialText, 'left')

    -- Set flag to prevent multiple instances
    tutorialDisplayed = true

    -- Auto-close after 15 seconds
    SetTimeout(15000, function()
        exports['qb-core']:HideText()
        tutorialDisplayed = false
    end)
end

RegisterNetEvent('qb-kungfu:client:showTutorial', function()
    ShowTutorial()
end)

-- Play kick animation with randomization
local function PlayKickAnimation(ped)
    local kickData = kickAnimations[currentCombatStyle][math.random(1, #kickAnimations[currentCombatStyle])]
    if not QBCore.Functions.RequestAnimDict(kickData.dict) then return false, 0 end

    TaskPlayAnim(ped, kickData.dict, kickData.anim, 8.0, -8.0, 1000, 0, 0, false, false, false)
    return true, kickData.waitTime
end

-- Environmental impact detection and effects
local function HandleEnvironmentalImpact(targetPed)
    CreateThread(function()
        local startPos = GetEntityCoords(targetPed)
        local startTime = GetGameTimer()
        local hasImpacted = false

        while GetGameTimer() - startTime < 2000 do
            Wait(50)
            if not DoesEntityExist(targetPed) then return end

            local currentPos = GetEntityCoords(targetPed)
            local velocity = GetEntityVelocity(targetPed)
            local speed = GetEntitySpeed(targetPed)

            -- Check for wall impact
            local ray = StartShapeTestRay(currentPos.x, currentPos.y, currentPos.z,
                                         currentPos.x + velocity.x, currentPos.y + velocity.y, currentPos.z + velocity.z,
                                         1, targetPed, 0)
            local _, hit, hitCoords, _, hitEntity = GetShapeTestResult(ray)

            if hit and not hasImpacted and speed > impactDamageThreshold then
                hasImpacted = true

                -- Wall impact effect
                if not IsEntityAVehicle(hitEntity) then
                    PlaySoundFromCoord(-1, sounds.realistic_impact, hitCoords.x, hitCoords.y, hitCoords.z, "HACKING_MOVEMENT_SOUNDS", true, 5, false)

                    -- Add blood splatter to wall
                    AddDecal(5, hitCoords.x, hitCoords.y, hitCoords.z, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.5, 0.5, 0.0, 0, 0, 0, 0, 0, 0, 0, 0)

                    -- Extra damage on wall impact
                    ApplyDamageToPed(targetPed, 20, false)

                -- Vehicle impact and damage
                elseif IsEntityAVehicle(hitEntity) and vehicleDamageOnImpact then
                    local vehicleCoords = GetEntityCoords(hitEntity)
                    local damageIntensity = speed * 1.5

                    -- Create a dent in the vehicle at impact point
                    SetVehicleDamage(hitEntity,
                        hitCoords.x - vehicleCoords.x,
                        hitCoords.y - vehicleCoords.y,
                        hitCoords.z - vehicleCoords.z,
                        damageIntensity, 10.0, true)

                    -- Apply force to vehicle from impact
                    ApplyForceToEntity(hitEntity, 1,
                        velocity.x * 2, velocity.y * 2, velocity.z * 0.2,
                        0, 0, 0, 0, false, true, true, false, true)

                    -- Sound effect for vehicle impact
                    PlaySoundFromEntity(-1, sounds.impact, hitEntity, "DLC_HEIST_HACKING_SNAKE_SOUNDS", true, 0)

                    -- Damage ped more on vehicle impact
                    ApplyDamageToPed(targetPed, 25, false)
                end

                -- Camera shake on impact
                ShakeGameplayCam("SMALL_EXPLOSION_SHAKE", 0.3)
            end
        end
    end)
end

-- Enhanced kick target function
local function KickTarget(targetPed)
    if cooldown then return end
    if IsPedInAnyVehicle(PlayerPedId(), false) then return end

    local ped = PlayerPedId()
    local pedPos = GetEntityCoords(ped)
    local targetPos = GetEntityCoords(targetPed)

    -- Face target before kicking
    local angle = GetHeadingFromVector_2d(targetPos.x - pedPos.x, targetPos.y - pedPos.y)
    SetEntityHeading(ped, angle)

    -- Play the kick animation
    local success, waitTime = PlayKickAnimation(ped)
    if not success then
        QBCore.Functions.Notify('Failed to load animation', 'error')
        return
    end

    -- Play kick sound
    PlaySoundFrontend(-1, sounds.kick, "WEAPON_UNARMED", true)

    -- Wait for the right moment in the kick
    Wait(waitTime)

    -- Calculate direction vector
    local dx = targetPos.x - pedPos.x
    local dy = targetPos.y - pedPos.y
    local dz = targetPos.z - pedPos.z
    local length = math.sqrt(dx * dx + dy * dy + dz * dz)
    local nx = dx / length
    local ny = dy / length

    -- Put target in ragdoll state
    SetPedToRagdoll(targetPed, ragdollTime, ragdollTime, 0, true, true, false)

    -- Apply force to knocked ped (more brutal)
    ApplyForceToEntity(targetPed, 1,
        nx * kickForce,
        ny * kickForce,
        4.5,  -- Slightly higher vertical force for more dramatic effect
        0.0, 0.0, 0.0, 0, false, true, true, false, true)

    -- Apply damage
    ApplyDamageToPed(targetPed, 15, false)

    -- Check for wall/vehicle impacts
    if environmentalImpactEffect then
        HandleEnvironmentalImpact(targetPed)
    end

    -- Cooldown
    cooldown = true
    SetTimeout(cooldownTime, function()
        cooldown = false
    end)

    -- Trigger server event for hit registration
    TriggerServerEvent('qb-kungfu:server:hitRegistered', NetworkGetNetworkIdFromEntity(targetPed))

    -- Add motion blur effect for dramatic impact
    AnimpostfxPlay("FocusOut", 300, false)
    SetTimeout(300, function()
        AnimpostfxStop("FocusOut")
    end)
end

-- Function to handle enhanced punches
local function EnhancePunchDamage()
    if not isKungFuActive then return end
    if IsPedInAnyVehicle(PlayerPedId(), false) then return end

    -- This will enhance all punches when kung fu is active
    SetWeaponDamageModifierThisFrame(GetHashKey("WEAPON_UNARMED"), punchDamageMultiplier)

    -- Add visual feedback when punching
    if IsControlJustPressed(0, 24) then -- Left mouse button (punch)
        -- Slight camera shake on punch
        ShakeGameplayCam("SMALL_EXPLOSION_SHAKE", 0.1)

        -- Add particle effects on punches
        local ped = PlayerPedId()
        local coords = GetOffsetFromEntityInWorldCoords(ped, 0.0, 0.5, 0.0)

        -- Only show effects if we hit something
        local ray = StartShapeTestRay(GetEntityCoords(ped),
                                      GetOffsetFromEntityInWorldCoords(ped, 0.0, 1.0, 0.0),
                                      1, ped, 0)
        local _, hit = GetShapeTestResult(ray)

        if hit then
            -- Impact effect
            UseParticleFxAssetNextCall("core")
            StartParticleFxNonLoopedAtCoord("ent_dst_dust", coords.x, coords.y, coords.z, 0.0, 0.0, 0.0, 1.0, false, false, false)

            -- Special kung fu sound on impact
            PlaySoundFrontend(-1, sounds.realistic_impact, "WEAPON_UNARMED", true)
        end
    end
end

-- Flying kick ability
local function AttemptFlyingKick()
    if not isKungFuActive or cooldown then return end
    if IsPedInAnyVehicle(PlayerPedId(), false) then return end

    -- Trigger flying kick when space+F is pressed (jump + melee)
    if IsControlPressed(0, 22) and IsControlJustPressed(0, 23) then
        local ped = PlayerPedId()

        -- Find target in front
        local coords = GetEntityCoords(ped)
        local forward = GetEntityForwardVector(ped)
        local targetCoords = vector3(coords.x + forward.x * 4.0, coords.y + forward.y * 4.0, coords.z)
        local closestPed = QBCore.Functions.GetClosestPed(targetCoords, 5.0, true)

        if closestPed then
            -- Advanced flying kick animation
            local dict = "melee@unarmed@streamed_variations"
            local anim = "plyr_takedown_front_slap"

            if QBCore.Functions.RequestAnimDict(dict) then
                -- Apply forward momentum
                local targetPos = GetEntityCoords(closestPed)
                local angle = GetHeadingFromVector_2d(targetPos.x - coords.x, targetPos.y - coords.y)
                SetEntityHeading(ped, angle)

                -- Launch player forward
                SetPedToRagdoll(ped, 500, 500, 0, true, true, false)
                ApplyForceToEntity(ped, 1, forward.x * 12.0, forward.y * 12.0, 2.5, 0.0, 0.0, 0.0, 0, false, true, true, false, true)

                -- After short flight, play kick animation and apply damage
                SetTimeout(300, function()
                    ClearPedTasks(ped)
                    TaskPlayAnim(ped, dict, anim, 8.0, -8.0, 1000, 0, 0, false, false, false)

                    -- Wait for impact
                    SetTimeout(500, function()
                        if DoesEntityExist(closestPed) and not IsPedDeadOrDying(closestPed) then
                            -- Double damage for flying kick
                            local targetPos = GetEntityCoords(closestPed)
                            local kickDir = vector3(targetPos.x - coords.x, targetPos.y - coords.y, 0.0)
                            local length = #kickDir
                            kickDir = vector3(kickDir.x/length, kickDir.y/length, 0.0)

                            -- Ragdoll and apply force
                            SetPedToRagdoll(closestPed, ragdollTime * 1.5, ragdollTime * 1.5, 0, true, true, false)
                            ApplyForceToEntity(closestPed, 1,
                                kickDir.x * (kickForce * 1.5),
                                kickDir.y * (kickForce * 1.5),
                                5.0, -- Higher vertical force for flying kick
                                0.0, 0.0, 0.0, 0, false, true, true, false, true)

                            -- Apply extra damage
                            ApplyDamageToPed(closestPed, 25, false)

                            -- Handle environmental impacts
                            HandleEnvironmentalImpact(closestPed)

                            -- Screen effect for impact
                            ShakeGameplayCam("MEDIUM_EXPLOSION_SHAKE", 0.5)
                            AnimpostfxPlay("FocusOut", 500, false)

                            -- Cooldown
                            cooldown = true
                            SetTimeout(cooldownTime * 2, function() -- Longer cooldown for flying kick
                                cooldown = false
                            end)
                        end
                    end)
                end)
            end
        end
    end
end

-- Main loop for kung fu actions
CreateThread(function()
    while true do
        if isKungFuActive then
            local ped = PlayerPedId()

            -- Don't allow kung fu in vehicles
            if IsPedInAnyVehicle(ped, false) then
                if isKungFuActive then
                    isKungFuActive = false
                    QBCore.Functions.Notify('Deactivated while in vehicle', 'error')
                    AnimpostfxStop("FocusIn")
                end
                Wait(1000) -- Check less frequently when in vehicle
            else
                -- Standard kick with right mouse button
                if IsControlPressed(0, 25) then -- RMB
                    local coords = GetEntityCoords(ped)
                    local closestPed = QBCore.Functions.GetClosestPed(coords, kickRange, true) -- true to include players
                    if closestPed and not IsPedDeadOrDying(closestPed) then
                        KickTarget(closestPed)
                    end
                end

                -- Enhanced punch damage
                EnhancePunchDamage()

                -- Flying kick ability check
                AttemptFlyingKick()

                -- Visual feedback for active kung fu mode (subtle pulse effect)
                if not AnimpostfxIsRunning("FocusIn") and isKungFuActive then
                    AnimpostfxPlay("FocusIn", 1000, false)
                end

                Wait(0) -- Check every frame when kung fu is active and not in vehicle
            end
        else
            Wait(500) -- Check less frequently when kung fu is not active
        end
    end
end)

-- Enhanced particle effects for impacts
local function CreateImpactEffect(coords)
    -- Blood splatter effect
    UseParticleFxAssetNextCall("core")
    StartParticleFxNonLoopedAtCoord("blood_stab", coords.x, coords.y, coords.z, 0.0, 0.0, 0.0, 0.5, false, false, false)

    -- Impact dust effect
    UseParticleFxAssetNextCall("core")
    StartParticleFxNonLoopedAtCoord("ent_dst_dust", coords.x, coords.y, coords.z, 0.0, 0.0, 0.0, 1.0, false, false, false)
end

-- Add grapple ability - Modified with small impact delay
RegisterCommand('grapple', function()
    if not isKungFuActive then return end
    if IsPedInAnyVehicle(PlayerPedId(), false) then return end
    if cooldown then return end

    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    local closestPed = QBCore.Functions.GetClosestPed(coords, 1.5, true)

    if closestPed and not IsPedDeadOrDying(closestPed) then
        -- Request animation dictionary
        local dict = "melee@unarmed@streamed_variations"
        local anim = "plyr_takedown_front_headbutt"

        if QBCore.Functions.RequestAnimDict(dict) then
            -- Face target
            local targetPos = GetEntityCoords(closestPed)
            local angle = GetHeadingFromVector_2d(targetPos.x - coords.x, targetPos.y - coords.y)
            SetEntityHeading(ped, angle)

            -- Play grapple animation
            TaskPlayAnim(ped, dict, anim, 8.0, -8.0, 3000, 0, 0, false, false, false)

            -- Play grapple struggle sound
            PlaySoundFromEntity(-1, sounds.grapple_struggle, ped, "WEAPON_BAT", true, 0)

            -- Small delay for impact (100-200ms)
            SetTimeout(250, function()
                -- Create impact effect at target location
                CreateImpactEffect(targetPos)

                -- Play impact sound
                PlaySoundFromEntity(-1, sounds.bone_crack, closestPed, "VEHICLES_HORNS_SIREN_1", true, 0)

                -- Camera shake for impact
                ShakeGameplayCam("SMALL_EXPLOSION_SHAKE", 0.3)

                -- Ragdoll effect
                SetPedToRagdoll(closestPed, 3000, 3000, 0, true, true, false)

                -- Calculate push direction
                local pushDir = vector3(targetPos.x - coords.x, targetPos.y - coords.y, 0.0)
                local length = #pushDir
                pushDir = vector3(pushDir.x/length, pushDir.y/length, 0.0)

                -- Apply force
                local pushForce = 15.0
                ApplyForceToEntity(closestPed, 1,
                    pushDir.x * pushForce,
                    pushDir.y * pushForce,
                    2.0, -- More vertical force for dramatic effect
                    0.0, 0.0, 0.0, 0, false, true, true, false, true)

                -- Add damage
                ApplyDamageToPed(closestPed, 20, false)

                -- Handle environmental impacts
                HandleEnvironmentalImpact(closestPed)
            end)

            -- Set cooldown
            cooldown = true
            SetTimeout(cooldownTime * 1.5, function()
                cooldown = false
            end)
        end
    end
end)

-- Key binding for grapple (RMB + E)
RegisterKeyMapping('grapple', 'Perform a grapple attack', 'keyboard', 'e')

-- Integrate with qb-target
CreateThread(function()
    exports['qb-target']:AddTargetModel(`a_m_m_eastsa_02`, {
        options = {
            {
                type = "client",
                event = "qb-kungfu:client:kickTarget",
                icon = "fa-solid fa-hand-fist",
                label = "Kung Fu Kick",
                canInteract = function(entity, distance)
                    return isKungFuActive and not cooldown and distance <= kickRange and not IsPedInAnyVehicle(PlayerPedId(), false)
                end
            },
            {
                type = "client",
                event = "qb-kungfu:client:grappleTarget",
                icon = "fa-solid fa-hands",
                label = "Kung Fu Grapple",
                canInteract = function(entity, distance)
                    return isKungFuActive and not cooldown and distance <= 1.5 and not IsPedInAnyVehicle(PlayerPedId(), false)
                end
            }
        },
        distance = 2.5
    })
end)

RegisterNetEvent('qb-kungfu:client:kickTarget', function(entity)
    KickTarget(entity)
end)

RegisterNetEvent('qb-kungfu:client:grappleTarget', function(entity)
    ExecuteCommand('grapple')
end)

-- Add chat command for tutorial
local tutorialDisplayed = false
RegisterCommand('kftutorial', function()
    ShowTutorial()
end, false)

-- Print message when resource starts
AddEventHandler('onResourceStart', function(resourceName)
    if (GetCurrentResourceName() == resourceName) then
        print('Kung Fu script loaded! Type /kftutorial to view controls or /kungfu to open the menu.')
    end
end)
