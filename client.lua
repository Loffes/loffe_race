ESX = nil

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
end)

local ready_state = false

local in_online_race = false

local showCoords = false

RegisterCommand("coords", function(source)
    showCoords = not showCoords
	while showCoords do
        Wait(1)
        if not cinema then
        local entityCoords = GetEntityCoords(GetPlayerPed(-1))
            SetTextFont(4)

            SetTextProportional(0)

            SetTextScale(0.8, 0.8)

            BeginTextCommandDisplayText("STRING")

            AddTextComponentSubstringPlayerName('~g~ X  = ~w~' .. round2(entityCoords.x, 2) .. '~g~ Y = ~w~' .. round2(entityCoords.y, 2) .. '~g~ Z  =~w~ ' .. round2(entityCoords.z-0.85, 2) ..  '~g~ H =~w~ ' .. math.ceil(GetEntityHeading(GetPlayerPed(-1))))

            EndTextCommandDisplayText(0.656, 0.00)
        end
	end
end, false)

Citizen.CreateThread(function()
    for k,v in pairs(Config.OnlineRace) do
        blip = AddBlipForCoord(v.Start.x, v.Start.y, v.Start.z)
        SetBlipSprite(blip, 315)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(v.Players .. ' spelar race')
        EndTextCommandSetBlipName(blip)
    end
    for k,v in pairs(Config.OfflineRace) do
        blip = AddBlipForCoord(v.Start.x, v.Start.y, v.Start.z)
        SetBlipSprite(blip, 315)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString('NPC Race')
        EndTextCommandSetBlipName(blip)
    end
end)

function round2(num, numDecimalPlaces)
  return tonumber(string.format("%." .. (numDecimalPlaces or 0) .. "f", num))
end

local canRace = true

RegisterNetEvent('loffe_race:offlineRace_cl')
AddEventHandler('loffe_race:offlineRace_cl', function(can_or_not)
    canRace = can_or_not
end)

RegisterNetEvent('loffe_race:print')
AddEventHandler('loffe_race:print', function(what)
    print(what)
end)

local online_race_leaderboard = {}

RegisterNetEvent('loffe_race:get_online_race_position_client')
AddEventHandler('loffe_race:get_online_race_position_client', function(race, data, player)
    online_race_leaderboard[player][race][player].checkpoint = data
end)

RegisterNetEvent('loffe_race:scaleform_showfreemodemessage')
AddEventHandler('loffe_race:scaleform_showfreemodemessage', function(title, msg, time)
    local s = time
    local scaleform = ESX.Scaleform.Utils.RequestScaleformMovie('MP_BIG_MESSAGE_FREEMODE')

    BeginScaleformMovieMethod(scaleform, 'SHOW_SHARD_WASTED_MP_MESSAGE')
	PushScaleformMovieMethodParameterString(title)
	PushScaleformMovieMethodParameterString(msg)
	EndScaleformMovieMethod()

	while s > 0 do
		Citizen.Wait(1)
		s = s - 0.01

		DrawScaleformMovieFullscreen(scaleform, 255, 255, 255, 255)
	end

    SetScaleformMovieAsNoLongerNeeded(scaleform)
end)

RegisterNetEvent('loffe_race:onlinerace_cantstart')
AddEventHandler('loffe_race:onlinerace_cantstart', function()
    ready_state = false
    ESX.ShowNotification('Någon annan kör redan detta racet, vänta tills de är klara!')
end)

RegisterNetEvent('loffe_race:start_online_race')
AddEventHandler('loffe_race:start_online_race', function(_race, position)
    local race = _race
    TriggerServerEvent('loffe_race:not_ready_online_race', race)
    in_online_race = true
    ready_state = false
    local pP = PlayerPedId()
    FreezeEntityPosition(pP, false)
    local playerVehicle = {}
    if Config.OnlineRace[race].Type == 'event' then
        local vehicle_hash = GetHashKey(Config.OnlineRace[race].Vehicle)
        RequestModel(vehicle_hash)
        while not HasModelLoaded(vehicle_hash) do
            Wait(0)
        end
        local sL = Config.OnlineRace[race].StartLine[position]
        playerVehicle = CreateVehicle(vehicle_hash, sL.x, sL.y, sL.z, sL.h, true, true)
        TaskWarpPedIntoVehicle(pP, playerVehicle, -1)
    else
        if(IsPedInAnyVehicle(pP, false) and GetPedInVehicleSeat(GetVehiclePedIsIn(pP, false), -1) == pP) then
            playerVehicle = GetVehiclePedIsIn(pP, false)
            local sl = Config.OnlineRace[race].StartLine[position]
            SetEntityCoords(playerVehicle, sl.x, sl.y, sl.z)
            SetEntityHeading(playerVehicle, sl.h)
            TaskWarpPedIntoVehicle(pP, playerVehicle, -1)
        end
    end

    FreezeEntityPosition(playerVehicle, true)
    PlaySoundFrontend(-1, '5S', 'MP_MISSION_COUNTDOWN_SOUNDSET', true)
    Wait(550)
    TriggerServerEvent('loffe_race:countdown')
    Wait(3300)
    FreezeEntityPosition(playerVehicle, false)

    local currentCheckpoint = 0

    local blips = {}

    for i=1, Config.OnlineRace[race].NumberOfZones do
        Wait(0)
        local v = Config.OnlineRace[race].Zones[i]
        local blip = AddBlipForCoord(v.x, v.y, v.z-5)
        if i == Config.OnlineRace[race].NumberOfZones then
            SetBlipSprite(blip, 38)
        else
            SetBlipSprite(blip, 164)
        end
        table.insert(blips, {[i] = {Blip = blip}})
    end

    local faketimer = 0
    local row_in_table = 1

    online_race_leaderboard = {}

    for i=1, Config.OnlineRace[race].Players do
        table.insert(online_race_leaderboard, {[race] = {[i] = {checkpoint = 0}}})
    end

    local fail_reason = {}

    local isRacing = true
    while isRacing do
        Wait(1)

        --[[for i=1, #number do
            if online_race_leaderboard[row_in_table][race][i].checkpoint == Config.OnlineRace[race].NumberOfZones then
                winner = i
                isRacing = false
            end
        end]]
        local checkpoints = Config.OnlineRace[race].NumberOfZones
        for i=1, #online_race_leaderboard do
            if online_race_leaderboard[i][race][i].checkpoint == checkpoints then
                winner = i
                isRacing = false
            end
        end

        faketimer = faketimer + 1

        if faketimer == 5 then
            TriggerServerEvent('loffe_race:get_online_race_position', race)
            faketimer = 0
        end

        drawTxt('Leaderboard:', 0.07, 0.24, 0.4)

        drawTxt('Du: checkpoint ' .. online_race_leaderboard[position][race][position].checkpoint, 0.07, 0.28, 0.4)
        local txt_position = 0.32
        for i=1, Config.OnlineRace[race].Players do
            if i ~= position then
                drawTxt('Motståndare ' .. i .. ': checkpoint ' .. online_race_leaderboard[i][race][i].checkpoint, 0.07, txt_position, 0.3)
                txt_position = txt_position + 0.04
            end
        end

        local v = {}
        if currentCheckpoint < Config.OnlineRace[race].NumberOfZones then
            v = Config.OnlineRace[race].Zones[currentCheckpoint+1]
            DrawMarker(6, v.x, v.y, v.z+2.0, 0.0, 0.0, 0.0, 0, 0.0, 0.0, 3.0, 3.0, 3.0, 241, 244, 66, 255, false, true, 2, false, false, false, false)
            SetBlipColour(blips[currentCheckpoint+1][currentCheckpoint+1].Blip, 2)
            if currentCheckpoint+1 == Config.OnlineRace[race].NumberOfZones then
                DrawMarker(5, v.x, v.y, v.z+2.0, 0.0, 0.0, 0.0, 0, 0.0, 0.0, 3.0, 3.0, 3.0, 241, 244, 66, 255, false, true, 2, false, false, false, false)
            else
                DrawMarker(21, v.x, v.y, v.z+2.0, 0.0, 0.0, 0.0, 0, 0.0, 0.0, 1.5, 1.5, 1.0, 241, 244, 66, 200, false, true, 2, false, false, false, false)
            end
        end

        local coords = GetEntityCoords(PlayerPedId())

        if not IsPedInAnyVehicle(PlayerPedId(), false) then
            DeleteCheckpoint(CheckPoint)
            fail_reason = 'fall_off'
            isRacing = false
        end

        if GetDistanceBetweenCoords(coords, v.x, v.y, v.z, true) < 8.0 then
            currentCheckpoint = currentCheckpoint + 1
            TriggerServerEvent('loffe_race:online_race_update', race, position, currentCheckpoint)
            RemoveBlip(blips[currentCheckpoint][currentCheckpoint].Blip)
            if currentCheckpoint < Config.OnlineRace[race].NumberOfZones then
            end
            PlaySoundFrontend(-1, "RACE_PLACED", "HUD_AWARDS")
        end        
    end
    if online_race_leaderboard[position][race][position].checkpoint == Config.OnlineRace[race].NumberOfZones then
        ESX.ShowNotification('Bra jobbat! Du ~g~vann~s~!')
        TriggerServerEvent('loffe_race:end_online_race', race)
    elseif fail_reason == 'fall_off' then
        ESX.ShowNotification('Din sopa! Du hoppade ut ur fordonet!')
        TriggerServerEvent('loffe_race:end_online_race', race)
    else
        ESX.ShowNotification('Din sopa! Du ~r~förlorade~s~!')
        TriggerServerEvent('loffe_race:end_online_race', race)
    end
    for i=1, #blips do
        if DoesBlipExist(blips[i][i].Blip) then
            RemoveBlip(blips[i][i].Blip)
        end
    end
    blips = {}
    if Config.OnlineRace[race].Type == 'event' then
        SetEntityAsMissionEntity(playerVehicle, true, true)
        DeleteVehicle(playerVehicle)
        print('hej')
        if Config.TPBack then
            SetEntityCoords(pP, Config.OnlineRace[race].Start.x, Config.OnlineRace[race].Start.y, Config.OnlineRace[race].Start.z)
        end
    end
    TriggerServerEvent('loffe_race:online_race_update', race, position, 0)
    ready_state = false
    in_online_race = false
end)

Citizen.CreateThread(function()
    while true do
        TriggerServerEvent('loffe_race:offlineRace_sv', 'can_i_start')
        Wait(1000)
    end
end)

RegisterCommand("test_loffe", function(source, args)
    TriggerServerEvent('loffe_race:ready_online_race', 'hej')
end, false)

Citizen.CreateThread(function()
    while true do
        Wait(0)
        for k, c in pairs(Config.OfflineRace) do
            local ped = PlayerPedId()
            local coords = GetEntityCoords(ped)
            local v = c['Start']
            if GetDistanceBetweenCoords(coords, v.x, v.y, v.z, true) < 50.0 then
                DrawMarker(27, v.x, v.y, v.z, 0.0, 0.0, 0.0, 0, 0.0, 0.0, 1.5, 1.5, 1.5, 50, 255, 50, 150, false, true, 2, false, false, false, false)
                if GetDistanceBetweenCoords(coords, v.x, v.y, v.z, true) < 2.0 then
                    BeginTextCommandDisplayHelp('STRING')
                    AddTextComponentSubstringPlayerName(Config.Strings['start_npc'])
                    EndTextCommandDisplayHelp(0, false, true, -1)
                    if IsControlJustReleased(0, 38) then
                        TriggerServerEvent('loffe_race:offlineRace_sv', 'can_i_start')
                        Wait(100)
                        if canRace then
                            TriggerServerEvent('loffe_race:offlineRace_sv', 'start')
                            startNPCRace(k)
                        else
                            ESX.ShowNotification('Du kan inte starta ett race nu då någon annan redan kör ett!')
                        end
                    end
                end
            end
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Wait(0)
        for k, c in pairs(Config.OnlineRace) do
            local ped = PlayerPedId()
            local coords = GetEntityCoords(ped)
            local v = c.Start
            local raceReady = 0
            if GetDistanceBetweenCoords(coords, v.x, v.y, v.z, true) < 50.0 and not in_online_race then
                DrawMarker(27, v.x, v.y, v.z, 0.0, 0.0, 0.0, 0, 0.0, 0.0, c.Size, c.Size, 1.5, 50, 255, 50, 150, false, true, 2, false, false, false, false)
                if GetDistanceBetweenCoords(coords, v.x, v.y, v.z, true) < c.Size + 0.2 then
                    BeginTextCommandDisplayHelp('STRING')
                    if ready_state then
                        AddTextComponentSubstringPlayerName(Config.Strings['stop_online'])
                    else
                        AddTextComponentSubstringPlayerName(c.Text)
                    end
                    EndTextCommandDisplayHelp(0, false, true, -1)
                    if IsControlJustReleased(0, 38) then
                        if(IsPedInAnyVehicle(ped, false) and GetPedInVehicleSeat(GetVehiclePedIsIn(ped, false), -1) == ped) or c.Type == 'event' then
                                ready_state = not ready_state
                                if ready_state then
                                    ready_state = false
                                    raceReady = k
                                    ESX.UI.Menu.Open(
                                    'default', GetCurrentResourceName(), '_ready_online',
                                    {
                                        title    = 'Starta race mot ' .. c.Players-1 .. ' andra spelare?',
                                        align = 'bottom-right',
                                        elements = {
                                            {label = 'Ja', value = 'yes'},
                                            {label = 'Nej', value = 'no'}
                                        }
                                    },
                                    function(data, menu)
                                        if data.current.value == 'yes' then
                                            TriggerServerEvent('loffe_race:ready_online_race', k)
                                            menu.close()
                                            ready_state = true
                                        elseif data.current.value == 'no' then
                                            menu.close()
                                            ready_state = false
                                        end
                                    end,
                                    function(data, menu)
                                        menu.close()
                                    end
                                )
                                else
                                    TriggerServerEvent('loffe_race:not_ready_online_race', k)
                                end
                        else
                            ESX.ShowNotification('Du måste köra ett fordon!')
                        end
                    end
                end
            else
                if ready_state == true then
                    if k == raceReady then
                        ready_state = false
                        ESX.ShowNotification('Du tog dig för långt bort från racet och du är därför inte redo längre!')
                        TriggerServerEvent('loffe_race:not_ready_online_race', k)
                    end
                end
            end
            if not IsPedInAnyVehicle(PlayerPedId()) and ready_state and c.Type == 'street_race' then
                if k == raceReady then
                    ready_state = false
                    TriggerServerEvent('loffe_race:not_ready_online_race', k)
                    ESX.ShowNotification('Du måste vara i ett fordon! Du är därför inte redo längre.')
                end
            end
        end
    end
end)

function startNPCRace(number)
    local NPCVehicles = {}
    local NPCs = {}
    local Leaderboard = {}
    local position = 1

    for i=1, #Config.OfflineRace[number].StartLine.NPC, 1 do
        Wait(5)
        local vehicle_hash = GetHashKey(Config.OfflineRace[number].Vehicle)
        RequestModel(vehicle_hash)
        while not HasModelLoaded(vehicle_hash) do
            Wait(0)
        end   

        local sL = Config.OfflineRace[number].StartLine.NPC[i]
        local pedVehicle = CreateVehicle(vehicle_hash, sL.x, sL.y, sL.z, sL.h, true, false)
        SetVehicleMod(pedVehicle, 13, 5, false)
        ToggleVehicleMod(vehicle,  18, true)
        local ped_hash = 1813637474
        RequestModel(ped_hash)
        while not HasModelLoaded(ped_hash) do
            Wait(0)
        end
        
        local ped = CreatePed(4, ped_hash, 0.0, 0.0, 0.0, true, true)
        TaskWarpPedIntoVehicle(ped, pedVehicle, -1)
        table.insert(NPCs, {[i] = {npc = ped}})
        table.insert(NPCVehicles, {[i] = {vehicle = pedVehicle}})
    end

    local vehicle_hash = GetHashKey(Config.OfflineRace[number].Vehicle)
    RequestModel(vehicle_hash)
	while not HasModelLoaded(vehicle_hash) do
		Wait(0)
    end

    local sL = Config.OfflineRace[number].StartLine.Player
    local pP = PlayerPedId()
    local playerVehicle = CreateVehicle(vehicle_hash, sL.x, sL.y, sL.z, sL.h, true, false)
    TaskWarpPedIntoVehicle(pP, playerVehicle, -1)
    local locked_speed = GetVehicleMaxSpeed(GetEntityModel(playerVehicle))/3.6 - 15/3.6 -- 15km/h  långsammare än maxhastighet
    SetEntityMaxSpeed(playerVehicle, locked_speed) -- annars är det 99% att man vinner mot npcer

    Wait(500)
    for i=1, 4 do
        Wait(5)
        local vehicle = NPCVehicles[i][i].vehicle
        local ped = NPCs[i][i].npc
        local lastZone = Config.OfflineRace[number].Zones[Config.OfflineRace[number].NumberOfZones]
        FreezeEntityPosition(vehicle, true)
        TaskVehicleDriveToCoord(ped, vehicle, lastZone.x, lastZone.y, lastZone.z, GetVehicleMaxSpeed(vehicle), 0, -1848994066, 262144, 10.0)
        SetDriveTaskDrivingStyle(ped, 262144)       
        SetPedKeepTask(ped, true)
    end
    PlaySoundFrontend(-1, '5S', 'MP_MISSION_COUNTDOWN_SOUNDSET', true)
    Wait(550)
    local sec = 4
    local countingDown = true
    while countingDown do
        Wait(0)
        FreezeEntityPosition(GetVehiclePedIsUsing(PlayerPedId()), true)
        sec = sec - 1
        if sec == 2 then
            ESX.Scaleform.ShowFreemodeMessage(sec, '', 0.55)
        else
            ESX.Scaleform.ShowFreemodeMessage(sec, '', 0.45)
        end
        if sec == 1 then
        for i=1, 4 do
            local vehicle = NPCVehicles[i][i].vehicle
            FreezeEntityPosition(vehicle, false)
        end -- npc får försprång så de har en chans
            ESX.Scaleform.ShowFreemodeMessage('KÖR!!!', '', 0.4)
            FreezeEntityPosition(GetVehiclePedIsUsing(PlayerPedId()), false)
            countingDown = false
        end
    end

    local currentCheckpoint = 0
    for i=1, 4 do
        Wait(5)
        local ped = NPCs[i][i].npc
        table.insert(Leaderboard, {[i] = {checkpoint = 0}})
    end
    table.insert(Leaderboard, {[5] = {checkpoint = 0}})

    local blips = {}

    for i=1, Config.OfflineRace[number].NumberOfZones do
        Wait(0)
        local v = Config.OfflineRace[number].Zones[i]
        local blip = AddBlipForCoord(v.x, v.y, v.z+5)
        SetBlipColour(blip, 11)
        if i == Config.OfflineRace[number].NumberOfZones then
            SetBlipSprite(blip, 38)
        else
            SetBlipSprite(blip, 128)
        end
        table.insert(blips, {[i] = {Blip = blip}})
    end

    while currentCheckpoint < Config.OfflineRace[number].NumberOfZones do
        Wait(0)
        local v = {}
        v = Config.OfflineRace[number].Zones[currentCheckpoint+1]
        DrawMarker(6, v.x, v.y, v.z+2.0, 0.0, 0.0, 0.0, 0, 0.0, 0.0, 3.0, 3.0, 3.0, 241, 244, 66, 255, false, true, 2, false, false, false, false)
        if currentCheckpoint+1 == Config.OfflineRace[number].NumberOfZones then
            DrawMarker(5, v.x, v.y, v.z+2.0, 0.0, 0.0, 0.0, 0, 0.0, 0.0, 3.0, 3.0, 3.0, 241, 244, 66, 255, false, true, 2, false, false, false, false)
        else
            DrawMarker(21, v.x, v.y, v.z+2.0, 0.0, 0.0, 0.0, 0, 0.0, 0.0, 1.5, 1.5, 1.0, 241, 244, 66, 200, false, true, 2, false, false, false, false)
        end
        local me = PlayerPedId()
        local coords = GetEntityCoords(me)

        drawTxt('Leaderboard:', 0.07, 0.24, 0.4)

        drawTxt('Du: checkpoint ' .. Leaderboard[5][5].checkpoint, 0.07, 0.28, 0.4)
        drawTxt('NPC 1: checkpoint ' .. Leaderboard[1][1].checkpoint, 0.07, 0.32, 0.4)
        drawTxt('NPC 2: checkpoint ' .. Leaderboard[2][2].checkpoint, 0.07, 0.36, 0.4)
        drawTxt('NPC 3: checkpoint ' .. Leaderboard[3][3].checkpoint, 0.07, 0.4, 0.4)
        drawTxt('NPC 4: checkpoint ' .. Leaderboard[4][4].checkpoint, 0.07, 0.44, 0.4)

        -- kolla om npc kör in i checkpoint / mål
        for i=1, 4 do
            if Leaderboard[i][i].checkpoint < 11 then
                local ped = NPCs[i][i].npc
                local npcCoords = GetEntityCoords(ped)
                local npcCheckpoint = Leaderboard[i][i].checkpoint
                local lastZone = Config.OfflineRace[number].Zones[npcCheckpoint+1]
                if GetDistanceBetweenCoords(npcCoords, lastZone.x, lastZone.y, lastZone.z, true) < 8.0 then
                    Leaderboard[i][i].checkpoint = npcCheckpoint + 1
                end
                if Leaderboard[i][i].checkpoint == Config.OfflineRace[number].NumberOfZones then
                    DeleteEntity(NPCs[i][i].npc)
                    DeleteVehicle(NPCVehicles[i][i].vehicle)
                    position = position + 1
                end
            end
        end
        

        if GetDistanceBetweenCoords(coords, v.x, v.y, v.z, true) < 8.0 then
            currentCheckpoint = currentCheckpoint + 1
            RemoveBlip(blips[currentCheckpoint][currentCheckpoint].Blip)
            if currentCheckpoint < Config.OfflineRace[number].NumberOfZones then
                SetBlipRoute(blips[currentCheckpoint+1][currentCheckpoint+1].Blip, true)
                SetBlipRouteColour(blips[currentCheckpoint+1][currentCheckpoint+1].Blip, 11)
                Leaderboard[5][5].checkpoint = currentCheckpoint
            end
            PlaySoundFrontend(-1, "RACE_PLACED", "HUD_AWARDS")
        end        
        if not IsPedInAnyVehicle(PlayerPedId(), false) then
            DeleteVehicle(playerVehicle)
            DeleteCheckpoint(CheckPoint)
            position = 'falled_off'
            currentCheckpoint = Config.OnlineRace[number].NumberOfZones
        end
    end
    for i=1, 4 do
        Wait(5)
        DeleteEntity(NPCs[i][i].npc)
        DeleteVehicle(NPCVehicles[i][i].vehicle)
    end
    if position == 'falled_off' then
        ESX.ShowNotification('Aj! Du ramlade av crossen och ~r~förlorade ~s~därmed racet! ')
    else
        ESX.ShowNotification('Bra jobbat! Du kom på plats: ~g~' .. position .. ' ~s~av 5!')
    end
    TriggerServerEvent('loffe_race:offlineRace_sv', 'stop')
    DeleteVehicle(playerVehicle)
    if Config.TPBack then
        SetEntityCoords(PlayerPedId(), Config.OfflineRace[number].Start.x, Config.OfflineRace[number].Start.y, Config.OfflineRace[number].Start.z)
    end
end

function drawTxt(text, x, y, scale)
	SetTextFont(8)
	SetTextProportional(0)
	SetTextScale(scale, scale)
	SetTextColour(255, 255, 255, 255)
	SetTextEdge(1, 0, 0, 0, 255)
	SetTextDropShadow()
	SetTextCentre(1)
	SetTextEntry("STRING")
	AddTextComponentString(text)
    DrawText(x, y)
    DrawRect(0.0, 0.36, 0.3, 0.25, 71, 71, 71, 75)
end