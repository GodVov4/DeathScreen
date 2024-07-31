RegisterCommand('car', function (source, args)
    local vehicleName = args[1] or 'voltic2'  -- or pariah voltic2 reever

    if not IsModelInCdimage(vehicleName) or not IsModelAVehicle(vehicleName) then
        TriggerEvent('chat:addMessage', {args = {vehicleName .. ' is not a vehicle'}})
        return
    end

    RequestModel(vehicleName)
    while not HasModelLoaded(vehicleName) do
        Wait(10)
    end

    local playerPed = PlayerPedId()
    local pos = GetEntityCoords(playerPed)
    local heading = GetEntityHeading(playerPed)
    local vehicle = CreateVehicle(vehicleName, pos.x, pos.y, pos.z, heading, true, false)

    SetPedIntoVehicle(playerPed, vehicle, -1)
    SetModelAsNoLongerNeeded(vehicle)

    TriggerEvent('chat:addMessage', {args = {vehicleName .. ' spawned'}})

    GiveWeaponToPed(playerPed, GetHashKey("WEAPON_PISTOL"), 100, false, true)
    GiveWeaponToPed(playerPed, GetHashKey("WEAPON_RAILGUN"), 100, false, true)
    GiveWeaponToPed(playerPed, GetHashKey("WEAPON_ASSAULTRIFLE_MK2"), 100, false, true)
    GiveWeaponToPed(playerPed, GetHashKey("WEAPON_STUNGUN_MP"), 100, false, true)
    GiveWeaponToPed(playerPed, GetHashKey("WEAPON_RPG"), 100, false, true)

end, false)