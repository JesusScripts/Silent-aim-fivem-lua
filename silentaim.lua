local targetPlayerName = ""
local closestPlayer = nil
local isFiring = false
local hitchance = 1.0
local showOverlay = true
local fovSize = 0.06
local fovAlpha = 100
local headshotRange = 100.0

local function enumeratePlayers()
    local players = {}
    for _, player in ipairs(GetActivePlayers()) do
        table.insert(players, GetPlayerPed(player))
    end
    return players
end

local function checkHitOrKill(playerPed, targetPed)
    if HasEntityBeenDamagedByEntity(targetPed, playerPed, true) then
        if IsPedDeadOrDying(targetPed, true) then
         --   print("Zabil jsi hráče: " .. GetPlayerName(NetworkGetPlayerIndexFromPed(targetPed)))
        else
       --     print("Zasáhl jsi hráče: " .. GetPlayerName(NetworkGetPlayerIndexFromPed(targetPed)))
        end
        ClearEntityLastDamageEntity(targetPed)
    end
end

local function isPlayerPlayingExcludedAnim(player)
    return IsEntityPlayingAnim(player, 'dead', 'dead_a', 3) or IsEntityPlayingAnim(player, 'veh@low@front_ps@idle_duck', 'sit', 3)
end

local function findClosestPlayer(playerPed)
    local camCoord = GetFinalRenderedCamCoord()
    local closestDist = 200.0
    closestPlayer = nil

    for _, player in ipairs(enumeratePlayers()) do
        if player ~= playerPed then
            local playerCoords = GetPedBoneCoords(player, 31086, 0.0, 0.0, 0.0)
            local x, y, z = table.unpack(playerCoords)
            local _, screenX, screenY = GetScreenCoordFromWorldCoord(x, y, z)

            local dist = #(camCoord - playerCoords)
            if dist < closestDist and not isPlayerPlayingExcludedAnim(player) then
                closestDist = dist
                closestPlayer = player
                targetPlayerName = GetPlayerName(NetworkGetPlayerIndexFromPed(player))
            end
        end
    end
end

CreateThread(function()
    while true do
        local playerPed = PlayerPedId()
        RestorePlayerStamina(PlayerId(), 1.0)
        Wait(0)
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        local playerPed = PlayerPedId()
        local weapon = GetSelectedPedWeapon(playerPed)

        if IsPedArmed(playerPed, 4) then
            SetPedAmmo(playerPed, weapon, 20)
        end
    end
end)

CreateThread(function()
    while true do
        local playerPed = PlayerPedId()
        if IsPedFalling(playerPed) then
            SetEntityInvincible(playerPed, true)
        else
            SetEntityInvincible(playerPed, false)
        end
        Wait(0)
    end
end)

CreateThread(function()
    while true do
        local playerPed = PlayerPedId()
        findClosestPlayer(playerPed)
        Wait(100)
    end
end)

CreateThread(function()
    while true do
        if closestPlayer then
            local playerPed = PlayerPedId()
            checkHitOrKill(playerPed, closestPlayer)
        end
        Wait(0)
    end
end)

local function drawCustomFOV()
    if not showOverlay then return end
    DrawRect(0.4375, 0.5, 0.0025, 0.12875, 128, 128, 128, 50)
    DrawRect(0.5625, 0.5, 0.0025, 0.12875, 128, 128, 128, 50)
    DrawRect(0.5, 0.4375, 0.1225, 0.00375, 128, 128, 128, 50)
    DrawRect(0.5, 0.5625, 0.1225, 0.00375, 128, 128, 128, 50)
end

local function isInFOV(screenX, screenY)
    return screenX > 0.4375 and screenX < 0.5625 and screenY > 0.4375 and screenY < 0.5625
end

CreateThread(function()
    while true do
        local playerPed = PlayerPedId()
        if closestPlayer then
            local otherPos = GetPedBoneCoords(closestPlayer, 31086, 0.0, 0.0, 0.0)
            local _, screenX, screenY = GetScreenCoordFromWorldCoord(otherPos.x, otherPos.y, otherPos.z)

            if IsPedArmed(playerPed, 4) then
                if IsControlPressed(1, 24) and isInFOV(screenX, screenY) then
                    if math.random() <= hitchance then
                        local rayHandle = StartShapeTestRay(GetEntityCoords(playerPed), otherPos, 1, playerPed, 0)
                        local _, hit, endCoords, _, _ = GetShapeTestResult(rayHandle)
                        if not hit or #(GetEntityCoords(playerPed) - endCoords) > 200.0 then
                            SetPedShootsAtCoord(playerPed, otherPos.x, otherPos.y, otherPos.z, true)
                        end
                    end
                    isFiring = true
                else
                    isFiring = false
                end
            end
        end
        Wait(0)
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if IsControlJustPressed(0, 51) then
            local playerPed = PlayerPedId()
            local vehicle = GetVehiclePedIsIn(playerPed, false)

            if vehicle ~= 0 then

                SetVehicleFixed(vehicle)
                SetVehicleDeformationFixed(vehicle)
                SetVehicleDirtLevel(vehicle, 0)
                SetVehicleEngineHealth(vehicle, 1000.0)
                SetVehiclePetrolTankHealth(vehicle, 1000.0)
                SetVehicleBodyHealth(vehicle, 1000.0)
                SetVehicleUndriveable(vehicle, false)


                SetVehicleModKit(vehicle, 0)

            
                SetVehicleMod(vehicle, 11, 3, false)
                SetVehicleMod(vehicle, 12, 2, false)
                SetVehicleMod(vehicle, 13, 2, false) 
                ToggleVehicleMod(vehicle, 18, true) 
                ToggleVehicleMod(vehicle, 22, true) 
                SetVehicleMod(vehicle, 15, 3, false) 
                SetVehicleMod(vehicle, 16, 4, false) 

                --SetVehicleEnginePowerMultiplier(vehicle, 20.0) 
               -- SetVehicleEngineTorqueMultiplier(vehicle, 2.5) 


              --  SetVehicleHandlingFloat(vehicle, 'CHandlingData', 'fTractionCurveMax', 4.5) 
               -- SetVehicleHandlingFloat(vehicle, 'CHandlingData', 'fTractionCurveMin', 4.5) 
             --   SetVehicleHandlingFloat(vehicle, 'CHandlingData', 'fSuspensionReboundDamp', 5.0) 
             --   SetVehicleHandlingFloat(vehicle, 'CHandlingData', 'fSuspensionCompDamp', 5.0) 
              --  SetVehicleHandlingFloat(vehicle, 'CHandlingData', 'fAntiRollBarForceFront', 10.0)
              --  SetVehicleHandlingFloat(vehicle, 'CHandlingData', 'fAntiRollBarForceRear', 10.0) 
              --  SetVehicleHandlingFloat(vehicle, 'CHandlingData', 'fLowSpeedTractionLossMult', 0.0) 
               -- SetVehicleHandlingFloat(vehicle, 'CHandlingData', 'fTractionLossMult', 0.0) 

                print(" Auto opraveno, dostalo extrémní tuning a chameleonovou barvu!")
            else
                print(" Nejseš v autě!")
            end
        elseif IsControlJustPressed(0, 47) then 
            local playerPed = PlayerPedId()
            SetEntityHealth(playerPed, GetEntityMaxHealth(playerPed))
            print(" Jsi vyléčen!")
        end
    end
end)
