local isDown = false
local removedItem = ''

AddEventHandler('itemRemoved', function (item)
    if item then
        removedItem = item.label
    end
end)

function DrawText3D(x, y, z, text)
    SetTextScale(0.5, 0.5)
    SetTextFont(8)
    SetTextProportional(true)
    SetTextColour(255, 255, 255, 255)
    SetTextCentre(true)
    SetTextEntry("STRING")
    AddTextComponentString(text)
    DrawText(x, y)
end 

AddEventHandler('gameEventTriggered', function (name, args)
    local playerPed = PlayerPedId()

    if name == 'CEventNetworkEntityDamage' and args[1] == playerPed and not isDown then
        if args[6] == 1 then
            local timer = Config.Timer
            isDown = true
            exports.spawnmanager:setAutoSpawn(false)

            TriggerEvent('playerDown', playerPed, timer)
            while isDown do
                Wait(100)
            end

            local playerCoords = GetEntityCoords(playerPed)
            local weaponHash = GetSelectedPedWeapon(playerPed)

            if weaponHash and weaponHash ~= `WEAPON_UNARMED` then
                CreateAmbientPickup(GetHashKey('PICKUP_' .. weaponHash), playerCoords.x, playerCoords.y, playerCoords.z, 0, 1, weaponHash, false, true)
                RemoveWeaponFromPed(playerPed, weaponHash)
            end

            TriggerServerEvent('removeRandomItem', Config.StealItem)
            local textRemovedItem = ''
            local textDeathOne = 'Too much time has passed and you have passed out.'
            local textDeathTwo = 'A policeman drove by and took you to the intensive care unit.'
            if #removedItem > 0 then
                textRemovedItem = 'Surely someone stole ~y~' .. tostring(removedItem) .. '~s~ from you.'
            end
            local theEndScreen = true
            while theEndScreen do
                Wait(0)
                DrawRect(0.5, 0.5, 1.0, 1.0, 0, 0, 0, 255)
                DrawText3D(0.5, 0.45, 0.0, textDeathOne)
                DrawText3D(0.5, 0.50, 0.0, textDeathTwo)
                DrawText3D(0.5, 0.55, 0.0, textRemovedItem)
                DrawText3D(0.5, 0.65, 0.0, 'Press [~r~Enter~s~] to continue.')
                if IsControlJustReleased(0, 191) then
                    theEndScreen = false
                end
            end

            ClearTimecycleModifier()
            ClearExtraTimecycleModifier()
            SetNuiFocus(false, false)

            TriggerServerEvent('setPlayerIsDead', true)
            SetEntityHealth(playerPed, 0)

            exports.spawnmanager:setAutoSpawn(true)
            SendNUIMessage({ action = 'stopSound' })
            exports.spawnmanager:forceRespawn()
        end
    end
end)

RegisterNetEvent('playerDown')
AddEventHandler('playerDown', function (playerPed, timer)
    SendNUIMessage({ action = 'playSound' })
    TriggerServerEvent('setPlayerIsDead', false)
    SetEntityHealth(playerPed, 101)
    SetPlayerHealthRechargeMultiplier(PlayerId(), 0.0)
    SetEntityInvincible(playerPed, true)
    SetPlayerInvincible(PlayerId(), true)
    SetEntityProofs(playerPed, true, true, true, true, true, true, true, true)

    SetTimecycleModifier('rply_saturation_neg')
    SetExtraTimecycleModifier('hud_def_blur')
    SetTimecycleModifierStrength(0.5)

    -- PlaySoundFromEntity(-1, "heartbeat", playerPed, "death_screen", false, false)

    Citizen.CreateThread(function ()
        local isHolding = false
        local holdDuration = 1000
        local holdStartTime = nil
        local isCallHelp = false
        local textAmbulance = nil
        while timer > 0 do
            if isCallHelp then
                textAmbulance = 'Ambulance is coming. You are die in ~r~' .. tostring(timer) .. '~s~ second(s).'
            else
                textAmbulance = 'You are die in ~r~' .. tostring(timer) .. '~s~ second(s). Hold [~r~E~s~] to call an ambulance'
            end
            BeginTextCommandPrint('STRING')
            AddTextComponentString(textAmbulance)
            EndTextCommandPrint(timer * 1000, true)

            if IsControlPressed(0, 38) then
                if not isHolding then
                    isHolding = true
                    holdStartTime = GetGameTimer()
                elseif GetGameTimer() - holdStartTime >= holdDuration then
                    TriggerEvent('chat:addMessage', {args = {'timer ' .. timer}})
                    timer = timer + Config.TimerLong - Config.Timer
                    isCallHelp = true
                    isHolding = false
                end
            else
                isHolding = false
            end
            timer = timer - 1
            Citizen.Wait(1000)
        end
        isDown = false
    end)

    local animDict = "combat@damage@writhe"
    RequestAnimDict(animDict)

    while not HasAnimDictLoaded(animDict) do
        Citizen.Wait(100)
    end

    TaskPlayAnim(playerPed, animDict, "writhe_loop", 8.0, -8.0, -1, 1, 0, false, false, false)

    while isDown do
        Citizen.Wait(0)
        local strength = math.abs(math.sin(GetGameTimer() / 1000))
        DrawRect(0.5, 0.5, 1.0, 1.0, 0, 0, 0, math.floor(255 * strength / 4))
    end
end)
