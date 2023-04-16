local playerIdentity, alreadyRegistered = {}, {}

-- assert(os.setlocale('fr_FR')) -- not need this for now
if ESX and ESX.GetConfig().Multichar then return error("This script isn't available now with multichar", 2) end

local server <const> = require 'config.server'
local shared <const> = require 'config.shared'

local function SetIdentity(xPlayer, saveDatabase)
    if not alreadyRegistered[xPlayer.identifier] then return end
    local identity = playerIdentity[xPlayer.identifier] or false
    xPlayer.setName(('%s %s'):format(identity.firstname, identity.lastname))
    xPlayer.set('firstname', identity.firstname)
    xPlayer.set('lastname', identity.lastname)
    xPlayer.set('dateofbirth', identity.dateofbirth)
    xPlayer.set('sex', identity.sex)
    xPlayer.set('height', identity.height)
    
    TriggerClientEvent('supv_identity:client:setPlayerData', xPlayer.source, identity)

    if saveDatabase then
        local update <const> = MySQL.update.await('UPDATE users SET firstname = ?, lastname = ?, dateofbirth = ?, sex = ?, height = ? WHERE identifier = ?', {identity.firstname, identity.lastname, identity.dateofbirth, identity.sex, identity.height, xPlayer.identifier})
        if not update then
            error(("Player %s not update in database"):format(xPlayer.identifier), 2)
        end
    end

    playerIdentity[xPlayer.identifier] = nil
end

local function CheckIdentity(xPlayer)
    local result = MySQL.single.await('SELECT firstname, lastname, dateofbirth, sex, height FROM users WHERE identifier = ?', {xPlayer.identifier})
    if not result or #result.firstname < 2 or #result.lastname < 2 or result.dateofbirth == '' or #result.sex < 1 or result.height < 120 then
        alreadyRegistered[xPlayer.identifier] = false
        return false
    end

    playerIdentity[xPlayer.identifier] = {
        firstname = result.firstname,
        lastname = result.lastname,
        dateofbirth = result.dateofbirth,
        sex = result.sex,
        height = result.height
    }

    alreadyRegistered[xPlayer.identifier] = true
    TriggerClientEvent('supv_identity:client:setPlayerData', xPlayer.source, playerIdentity[xPlayer.identifier])
    return true
end

AddEventHandler('playerConnecting', function(playerName, setKickReason, deferrals)
    local _source = source
    local identifier = ESX.GetIdentifier(_source)
    local result = MySQL.single.await('SELECT firstname, lastname, dateofbirth, sex, height FROM users WHERE identifier = ?', {identifier})
    if not result or #result.firstname < 2 or #result.lastname < 2 or result.dateofbirth == '' or #result.sex < 1 or result.height < 120 then
        alreadyRegistered[identifier] = false
        return deferrals.done()
    end

    playerIdentity[identifier] = {
        firstname = result.firstname,
        lastname = result.lastname,
        dateofbirth = result.dateofbirth,
        sex = result.sex,
        height = result.height
    }

    alreadyRegistered[identifier] = true

    deferrals.done()
end)

AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    while not ESX do Wait(500) end Wait(500)
    
    local xPlayers = ESX.GetExtendedPlayers()

    if #xPlayers < 1 then return end

    for i = 1, #xPlayers do
        local xPlayer = xPlayers[i]
        if CheckIdentity(xPlayer) then
            SetIdentity(xPlayer)
        else
            TriggerClientEvent('supv_identity:client:showRegister', xPlayer.source)
        end
    end
end)

RegisterNetEvent('supv_identity:server:validRegister', function(identity)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)

    if xPlayer then
        local bypass = false for i = 1, #server.command.authorized do if server.command.authorized[i] == xPlayer.group then bypass = true end end
        if not bypass and alreadyRegistered[xPlayer.identifier] then return xPlayer.kick("You are already registered! (cheat!)") end
        
        playerIdentity[xPlayer.identifier] = {
            firstname = identity.firstname,
            lastname = identity.lastname,
            dateofbirth = identity.dateofbirth,
            sex = identity.sex,
            height = identity.height
        }

        local year, reset = playerIdentity[xPlayer.identifier].dateofbirth:gsub('../../', ''), {}
        year = tonumber(year)
        
        if (year < shared.dob.min) or (year > shared.dob.max) then
            reset.dateofbirth = true
        end

        if next(reset) then
            return TriggerClientEvent('supv_identity:client:showRegister', xPlayer.source, reset)
        end

        if GetResourceState('illenium-appearance') ~= 'missing' then
            TriggerClientEvent('esx_skin:resetFirstSpawn', xPlayer.source)
        end
    
        alreadyRegistered[xPlayer.identifier] = true
        SetIdentity(xPlayer, true)
    end
end)

RegisterNetEvent('esx:playerLoaded', function(playerId, xPlayer)
    local identity = playerIdentity[xPlayer.identifier] or false

    if identity and alreadyRegistered[xPlayer.identifier] then
        xPlayer.setName(('%s %s'):format(identity.firstname, identity.lastname))
        xPlayer.set('firstname', identity.firstname)
        xPlayer.set('lastname', identity.lastname)
        xPlayer.set('dateofbirth', identity.dateofbirth)
        xPlayer.set('sex', identity.sex)
        xPlayer.set('height', identity.height)
        
        TriggerClientEvent('supv_identity:client:setPlayerData', xPlayer.source, identity)

        playerIdentity[xPlayer.identifier] = nil
    else
        TriggerClientEvent('supv_identity:client:showRegister', xPlayer.source)
    end
end)