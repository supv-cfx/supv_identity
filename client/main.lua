if not lib then return error("ox_lib not loaded", 2) end

lib.locale()

local playerIdentity, moment <const> = nil, exports['supv_convert-unix']

local function FirstToUpper(str)
    str = str:lower()
    return str:gsub("^%l", string.upper)
end

local function OpenRegister(needReset)

    if type(playerIdentity) == 'table' and needReset then
        for k in pairs(needReset) do
            playerIdentity[k] = nil
        end
    else
        playerIdentity = {}  
    end

    local input = lib.inputDialog(locale('title'), {
        {type = 'input', label = locale('lastname'), required = true, default = playerIdentity.lastname},
        {type = 'input', label = locale('firstname'), required = true, default = playerIdentity.firstname},
        {type = 'select', label = locale('sex'), required = true, options = {{value = 'M', label = locale('male')}, {value = 'F', label = locale('female')}}, default = playerIdentity.sex},
        {type = 'slider', label = locale('height'), required = true, min = Config.height.min, max = Config.height.max, default = playerIdentity.height},
        {type = 'date', label = locale('dob'), required = true, icon = {'far', 'calendar'}, format = Config.format_date, default = playerIdentity.dob}
    }, {allowCancel = false})

    if not input then OpenRegister() end

    playerIdentity = {
        lastname = #input[1] > 1 and FirstToUpper(input[1]),
        firstname = #input[2] > 1 and FirstToUpper(input[2]),
        sex = input[3],
        height = input[4],
        dateofbirth = input[5]
    }

    if not playerIdentity.lastname or not playerIdentity.firstname then OpenRegister() end

    playerIdentity.dateofbirth = moment:ConvertUnixTime(playerIdentity.dateofbirth, Config.format_date)

    if playerIdentity.dateofbirth and type(playerIdentity.dateofbirth) == 'string' then
        TriggerServerEvent('supv_identity:server:validRegister', playerIdentity)
    end
end

RegisterNetEvent('supv_identity:client:showRegister', OpenRegister)
RegisterNetEvent('supv_identity:client:setPlayerData', function(identity)
    ESX.SetPlayerData('name', ('%s %s'):format(identity.firstname, identity.lastname))
    ESX.SetPlayerData('firstname', identity.firstname)
    ESX.SetPlayerData('lastname', identity.lastname)
    ESX.SetPlayerData('dateofbirth', identity.dateofbirth)
    ESX.SetPlayerData('sex', identity.sex)
    ESX.SetPlayerData('height', identity.height)

    TriggerEvent('esx_skin:playerRegistered') -- event: for init skin of your player

    playerIdentity = nil
end)