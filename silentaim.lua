local targetPlayerName = ""
local closestPlayer = nil
local isFiring = false
local hitchance = 0.50
local showOverlay = true
local fovSize = 0.06
local fovAlpha = 100
local headshotRange = 34.0

local AntiCheats = {
    VAC = false,
    ChocoHax = false,
    BadgerAC = false,
    ATG = false,
    TigoAC = false,
}

local deadAnimDict = 'dead'
local deadAnim = 'dead_a'
local inVehicleDuckDict = 'veh@low@front_ps@idle_duck'
local inVehicleDuckAnim = 'sit'

local betterFightConfig = {
    -- Pistol
    { hash = WEAPON_PISTOL, damageMultiplier = 1.00},
    { hash = WEAPON_PISTOL_MK2, damageMultiplier = 1.00},
    { hash = WEAPON_COMBATPISTOL, damageMultiplier = 1.00},
    { hash = WEAPON_APPISTOL, damageMultiplier = 1.00},
    { hash = WEAPON_STUNGUN, damageMultiplier = 1.00},
    { hash = WEAPON_PISTOL50, damageMultiplier = 1.00},
    { hash = WEAPON_SNSPISTOL, damageMultiplier = 1.00},
    { hash = WEAPON_SNSPISTOL_MK2, damageMultiplier = 1.00},
    { hash = WEAPON_HEAVYPISTOL, damageMultiplier = 1.00},
    { hash = WEAPON_VINTAGEPISTOL, damageMultiplier = 1.00},
    { hash = WEAPON_FLAREGUN, damageMultiplier = 1.00},
    { hash = WEAPON_MARKSMANPISTOL, damageMultiplier = 1.00},
    { hash = WEAPON_REVOLVER, damageMultiplier = 1.00},
    { hash = WEAPON_REVOLVER_MK2, damageMultiplier = 1.00},
    { hash = WEAPON_DOUBLEACTION, damageMultiplier = 1.00},
    { hash = WEAPON_RAYPISTOL, damageMultiplier = 1.00},
    { hash = WEAPON_CERAMICPISTOL, damageMultiplier = 1.00},
    { hash = WEAPON_NAVYREVOLVER, damageMultiplier = 1.00},
    { hash = WEAPON_GADGETPISTOL, damageMultiplier = 1.00},
    -- Submachine Guns
    { hash = WEAPON_MICROSMG, damageMultiplier = 1.00},
    { hash = WEAPON_SMG, damageMultiplier = 1.00},
    { hash = WEAPON_SMG_MK2, damageMultiplier = 1.00},
    { hash = WEAPON_ASSAULTMG, damageMultiplier = 1.00},
    { hash = WEAPON_COMBATPDW, damageMultiplier = 1.00},
    { hash = WEAPON_MACHINEPISTOL, damageMultiplier = 1.00},
    { hash = WEAPON_MINISMG, damageMultiplier = 1.00},
    { hash = WEAPON_RAYCARBINE, damageMultiplier = 1.00},
    -- Assault Rifles
    { hash = WEAPON_ASSAULTRIFLE, damageMultiplier = 1.00},
    { hash = WEAPON_ASSAULTRIFLE_MK2, damageMultiplier = 1.00},
    { hash = WEAPON_CARBINERIFLE, damageMultiplier = 1.00},
    { hash = WEAPON_CARBINERIFLE_MK2, damageMultiplier = 1.00},
    { hash = WEAPON_ADVANCEDRIFLE, damageMultiplier = 1.00},
    { hash = WEAPON_SPECIALCARBINE, damageMultiplier = 1.00},
    { hash = WEAPON_SPECIALCARBINE_MK2, damageMultiplier = 1.00},
    { hash = WEAPON_BULLPUPRIFLE, damageMultiplier = 1.00},
    { hash = WEAPON_BULLPUPRIFLE_MK2, damageMultiplier = 1.00},
    { hash = WEAPON_COMPACTRIFLE, damageMultiplier = 1.00},
    { hash = WEAPON_MILITARYRIFLE, damageMultiplier = 1.00},
    -- Light Machine Guns
    { hash = WEAPON_MG, damageMultiplier = 1.00},
    { hash = WEAPON_COMBATMG, damageMultiplier = 1.00},
    { hash = WEAPON_COMBATMG_MK2, damageMultiplier = 1.00},
    { hash = WEAPON_GUSENBERG, damageMultiplier = 1.00},
    -- Sniper Rifles
    { hash = WEAPON_SNIPERRIFLE, damageMultiplier = 1.00},
    { hash = WEAPON_HEAVYSNIPER, damageMultiplier = 1.00},
    { hash = WEAPON_HEAVYSNIPER_MK2, damageMultiplier = 1.00},
    { hash = WEAPON_MARKSMANRIFLE, damageMultiplier = 1.00},
    { hash = WEAPON_MARKSMANRIFLE_MK2, damageMultiplier = 1.00},
    -- Heavy Weapons
    { hash = WEAPON_RPG, damageMultiplier = 1.00},
    { hash = WEAPON_GRENADELAUNCHER, damageMultiplier = 1.00},
    { hash = WEAPON_GRENADELAUNCHER_SMOKE, damageMultiplier = 1.00},
    { hash = WEAPON_MINIGUN, damageMultiplier = 1.00},
    { hash = WEAPON_FIREWORK, damageMultiplier = 1.00},
    { hash = WEAPON_RAILGUN, damageMultiplier = 1.00},
    { hash = WEAPON_HOMINGLAUNCHER, damageMultiplier = 1.00},
    { hash = WEAPON_COMPACTLAUNCHER, damageMultiplier = 1.00},
    { hash = WEAPON_RAYMINIGUN, damageMultiplier = 1.00},
    -- Melee
    { hash = WEAPON_UNARMED, damageMultiplier = 0.25},
    { hash = WEAPON_DAGGER, damageMultiplier = 0.25},
    { hash = WEAPON_BAT, damageMultiplier = 0.25},
    { hash = WEAPON_BOTTLE, damageMultiplier = 0.25},
    { hash = WEAPON_CROWBAR, damageMultiplier = 0.25},
    { hash = WEAPON_FLASHLIGHT, damageMultiplier = 0.25},
    { hash = WEAPON_GOLFCLUB, damageMultiplier = 0.25},
    { hash = WEAPON_HAMMER, damageMultiplier = 0.25},
    { hash = WEAPON_HATCHET, damageMultiplier = 0.25},
    { hash = WEAPON_KNUCKLE, damageMultiplier = 0.25},
    { hash = WEAPON_KNIFE, damageMultiplier = 0.25},
    { hash = WEAPON_MACHETE, damageMultiplier = 0.25},
    { hash = WEAPON_SWITCHBLADE, damageMultiplier = 0.25},
    { hash = WEAPON_NIGHTSTICK, damageMultiplier = 0.25},
    { hash = WEAPON_WRENCH, damageMultiplier = 0.25},
    { hash = WEAPON_BATTLEAXE, damageMultiplier = 0.25},
    { hash = WEAPON_POOLCUE, damageMultiplier = 0.25},
    { hash = WEAPON_STONE_HATCHET, damageMultiplier = 0.25},
}

local function setWeaponDamageMultiplier(playerPed, targetPed)
    local weaponHash = GetSelectedPedWeapon(playerPed)
    for _, weapon in ipairs(betterFightConfig) do
        if weapon.hash == weaponHash then
            local playerCoords = GetEntityCoords(playerPed)
            local targetCoords = GetEntityCoords(targetPed)
            local distance = #(playerCoords - targetCoords)
            local success, bone = GetPedLastDamageBone(targetPed)
            if success and bone == 31086 and distance <= headshotRange then
                SetPlayerWeaponDamageModifier(PlayerId(), 10.0)
            else
                SetPlayerWeaponDamageModifier(PlayerId(), weapon.damageMultiplier)
            end
            break
        end
    end
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

local function drawFOV()
    if not showOverlay then return end

    local color = 0

    if not HasStreamedTextureDictLoaded("mpmissmarkers256") then
        RequestStreamedTextureDict("mpmissmarkers256", true)
        while not HasStreamedTextureDictLoaded("mpmissmarkers256") do
            Wait(0)
        end
    end
    DrawSprite("mpmissmarkers256", "corona_shade", 0.5, 0.5, fovSize, fovSize * 1.8, 0.0, 255, 255, 255, color)
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
            if dist < closestDist and (screenX > 0.4 and screenX < 0.6 and screenY > 0.4 and screenY < 0.6 or fovSize == 0) and not isPlayerPlayingExcludedAnim(player) then
                closestDist = dist
                closestPlayer = player
                isVisible = HasEntityClearLosToEntity(playerPed, player, 17)
            end
        end
    end

    if closestPlayer then
        targetPlayerName = ""
    else
        targetPlayerName = ""
        isVisible = false
    end

    return isVisible
end

CreateThread(function()
    local playerPed = PlayerPedId()
    SetPlayerStamina(playerPed, 1.0)
end)

CreateThread(function()
    while true do
        local playerPed = PlayerPedId()
        if playerPed then
            SetPedInfiniteAmmoClip(playerPed, true)
            SetPedInfiniteAmmo(playerPed, true, GetSelectedPedWeapon(playerPed))
        end
        Wait(100)
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
        local isVisible = findClosestPlayer(playerPed)
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

CreateThread(function()
    while true do
        drawFOV()
        Wait(0)
    end
end)

CreateThread(function()
    while true do
        local playerPed = PlayerPedId()
        if closestPlayer then
            setWeaponDamageMultiplier(playerPed, closestPlayer)
            local otherPos = GetPedBoneCoords(closestPlayer, 31086, 0.0, 0.0, 0.0)

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

