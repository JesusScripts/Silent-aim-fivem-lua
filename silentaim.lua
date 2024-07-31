local targetPlayerName = ""
local closestPlayer = nil
local isFiring = false
local hitchance = 0.8
local showOverlay = true
local AntiCheats = {
    VAC = false,
    ChocoHax = false,
    BadgerAC = false,
    ATG = false,
    TigoAC = false,
    FiveGuard = false
}

local deadAnimDict = 'dead'
local deadAnim = 'dead_a'
local inVehicleDuckDict = 'veh@low@front_ps@idle_duck'
local inVehicleDuckAnim = 'sit'

local function GetResources()
    local resources = {}
    for i = 0, GetNumResources() - 1 do
        resources[i + 1] = GetResourceByFindIndex(i)
    end
    return resources
end

function FindACResource()
    PushNotification("Searching for Servers Anticheat", 1000)
    local Resources = GetResources()

    for i = 1, #Resources do
        local curres = Resources[i]
        for k, v in pairs({'fxmanifest.lua', '__resource.lua'}) do
            local data = LoadResourceFile(curres, v)

            if data ~= nil then
                for line in data:gmatch("([^\n]*)\n?") do
                    local FinishedString = line:gsub("client_script", "")
                    FinishedString = FinishedString:gsub(" ", "")
                    FinishedString = FinishedString:gsub('"', "")
                    FinishedString = FinishedString:gsub("'", "")

                    local NiceSource = LoadResourceFile(curres, FinishedString)

                    if NiceSource ~= nil and string.find(NiceSource, "This file was obfuscated using PSU Obfuscator 4.0.A") then
                        if AntiCheats.VAC == false then
                            PushNotification("VAC Detected in " .. curres, 1000)
                        end
                        AntiCheats.VAC = true
                    elseif NiceSource ~= nil and string.find(NiceSource, "he is so lonely") then
                        if AntiCheats.VAC == false then
                            PushNotification("VAC Detected in " .. curres, 1000)
                        end
                        AntiCheats.VAC = true
                    elseif NiceSource ~= nil and string.find(NiceSource, "Vyast") then
                        if AntiCheats.VAC == false then
                            PushNotification("VAC Detected in " .. curres, 1000)
                        end
                        AntiCheats.VAC = true
                    end

                    if tonumber(FinishedString) then
                        if AntiCheats.ChocoHax == false then
                            PushNotification("ChocoHax Detected in " .. curres, 1000)
                        end
                        AntiCheats.ChocoHax = true
                    end
                end
            end

            if data and type(data) == 'string' and string.find(data, 'acloader.lua') and string.find(data, 'Enumerators.lua') then
                PushNotification("Badger Anticheat Detected in " .. curres, 1000)
                AntiCheats.BadgerAC = true
            end

            if data and type(data) == 'string' and string.find(data, 'client_config.lua') then
                PushNotification("ATG Detected Detected in " .. curres, 1000)
                AntiCheats.ATG = true
            end

            if data and type(data) == 'string' and string.find(data, 'clientconfig.lua') and string.find('blacklistedmodels.lua') then
                PushNotification("ChocoHax Detected in " .. curres, 1000)
                AntiCheats.ChocoHax = true
            end

            if data and type(data) == 'string' and string.find(data, 'acloader.lua') then
                if not AntiCheats.BadgerAC then
                    PushNotification("Badger Anticheat Detected in " .. curres, 1000)
                end
                AntiCheats.BadgerAC = true
            end

            if data and type(data) == 'string' and string.find(data, "Badger's Official Anticheat") then
                PushNotification("Badger Anticheat Detected in " .. curres, 1000)
                AntiCheats.BadgerAC = true
            end

            if data and type(data) == 'string' and string.find(data, 'TigoAntiCheat.net.dll') then
                PushNotification("Tigo Detected in " .. curres, 1000)
                AntiCheats.TigoAC = true
            end

            -- Detekce FiveGuard
            if data and type(data) == 'string' and string.find(data, "ac 'fg'") then
                PushNotification("FiveGuard Detected in " .. curres, 1000)
                AntiCheats.FiveGuard = true
            end
        end
        Wait(10)
    end
end

function PushNotification(message, duration)
    SetNotificationTextEntry("STRING")
    AddTextComponentString(message)
    DrawNotification(false, true)
    Citizen.Wait(duration)
end

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
            print("Zabil jsi hráče: " .. GetPlayerName(NetworkGetPlayerIndexFromPed(targetPed)))
        else
            print("Zasáhl jsi hráče: " .. GetPlayerName(NetworkGetPlayerIndexFromPed(targetPed)))
        end
        ClearEntityLastDamageEntity(targetPed)
    end
end

local function drawTargetPlayerName(name, isVisible)
    if not showOverlay then return end

    local text = name
    if isVisible then
        text = text .. " (Visible)"
    else
        text = text .. " (Not Visible)"
    end

    SetTextFont(0)
    SetTextProportional(1)
    SetTextScale(0.0, 0.5)
    SetTextColour(255, 255, 255, 255)
    SetTextDropshadow(0, 0, 0, 0, 255)
    SetTextEdge(2, 0, 0, 0, 150)
    SetTextDropShadow()
    SetTextOutline()
    SetTextEntry("STRING")
    AddTextComponentString(text)
    DrawText(0.9, 0.1)
end

local function drawFOV()
    if not showOverlay then return end

    if not HasStreamedTextureDictLoaded("mpmissmarkers256") then
        RequestStreamedTextureDict("mpmissmarkers256", true)
        while not HasStreamedTextureDictLoaded("mpmissmarkers256") do
            Wait(0)
        end
    end
    DrawSprite("mpmissmarkers256", "corona_shade", 0.5, 0.5, 0.1, 0.18, 0.0, 255, 255, 255, 100)
end

local function isPlayerPlayingExcludedAnim(player)
    return IsEntityPlayingAnim(player, deadAnimDict, deadAnim, 3) or IsEntityPlayingAnim(player, inVehicleDuckDict, inVehicleDuckAnim, 3)
end

local function findClosestPlayer(playerPed)
    local camCoord = GetFinalRenderedCamCoord()
    local closestDist = 200.0
    closestPlayer = nil
    local isVisible = false

    for _, player in ipairs(enumeratePlayers()) do
        if player ~= playerPed then
            local playerCoords = GetPedBoneCoords(player, 31086, 0.0, 0.0, 0.0)
            local x, y, z = table.unpack(playerCoords)
            local _, screenX, screenY = GetScreenCoordFromWorldCoord(x, y, z)

            local dist = #(camCoord - playerCoords)
            if dist < closestDist and screenX > 0.4 and screenX < 0.6 and screenY > 0.4 and screenY < 0.6 and not isPlayerPlayingExcludedAnim(player) then
                closestDist = dist
                closestPlayer = player
                isVisible = HasEntityClearLosToEntity(playerPed, player, 17)
            end
        end
    end

    if closestPlayer then
        local playerName = GetPlayerName(NetworkGetPlayerIndexFromPed(closestPlayer))
        targetPlayerName = "Míříš na hráče: " .. playerName
    else
        targetPlayerName = ""
        isVisible = false
    end

    return isVisible
end

local function setWeaponAccuracy()
    local playerPed = PlayerPedId()
    local weaponHash = GetSelectedPedWeapon(playerPed)
end

CreateThread(function()
    FindACResource()
end)

CreateThread(function()
    while true do
        local playerPed = PlayerPedId()
        local isVisible = findClosestPlayer(playerPed)
        Wait(100)
        drawTargetPlayerName(targetPlayerName, isVisible)
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

CreateThread(function()
    while true do
        drawFOV()
        Wait(0)
    end
end)

CreateThread(function()
    while true do
        setWeaponAccuracy()
        if closestPlayer then
            local playerPed = PlayerPedId()
            local otherPos = GetPedBoneCoords(closestPlayer, 31086, 0.0, 0.0, 0.0)

            DrawMarker(2, otherPos.x, otherPos.y, otherPos.z + 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.2, 0.2, 0.2, 255, 255, 0, 100, false, true, 2, nil, nil, false)

            if IsPedArmed(playerPed, 4) then
                if IsControlPressed(1, 24) then
                    if math.random() <= hitchance then
                        SetPedShootsAtCoord(playerPed, otherPos.x, otherPos.y, otherPos.z, true)
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
