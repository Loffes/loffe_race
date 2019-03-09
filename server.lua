ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

AddEventHandler('playerDropped', function()
    local _source = source
    TriggerClientEvent('loffe_race:end_race_cl', _source)
end)

local readyPlayers = {}

local online_race_leaderboard = {}

local online_race_in_progress = {}

RegisterServerEvent('loffe_race:online_race_update')
AddEventHandler('loffe_race:online_race_update', function(race, player, position)
    for i=1, #online_race_leaderboard do
        if online_race_leaderboard[i].R == race then
            if online_race_leaderboard[i][race].p == player then
                TriggerClientEvent('loffe_race:print', source, online_race_leaderboard[i][race].checkpoints)
                online_race_leaderboard[i][race].checkpoints = position
            end
        end
    end
end)

RegisterServerEvent('loffe_race:end_online_race')
AddEventHandler('loffe_race:end_online_race', function(race)
    for i=1, #online_race_in_progress do
        if online_race_in_progress[i].R == race then
            online_race_in_progress[i].R = false
        end
    end
    for i=1, #online_race_leaderboard do
        if online_race_leaderboard[i].R == race then
            online_race_leaderboard[i].R = false
        end
    end
end)

RegisterServerEvent('loffe_race:get_online_race_position')
AddEventHandler('loffe_race:get_online_race_position', function(race)
    local _source = source

    for i=1, Config.OnlineRace[race].Players do
        for x=1, #online_race_leaderboard do
            if online_race_leaderboard[x].R == race then
                TriggerClientEvent('loffe_race:get_online_race_position_client', _source, race, online_race_leaderboard[x][race].checkpoints, online_race_leaderboard[x][race].p)
            end
        end
    end
end)


RegisterServerEvent('loffe_race:ready_online_race')
AddEventHandler('loffe_race:ready_online_race', function(race)
    local _source = source
    local can_start = true
    for i=1, #online_race_in_progress do
        if online_race_in_progress[i].R == race then
            can_start = false
        end
    end
    if can_start then
        local steam = GetPlayerIdentifiers(_source)[1]
        local is_source_ready = false
        for i=1, #readyPlayers do
            if readyPlayers[i]['r'].source == _source then
                readyPlayers[i]['r'].Race = race
                is_source_ready = true
            end
        end
        if not is_source_ready then
            table.insert(readyPlayers, {['r'] = {Race = race, source = _source}})
        end
        local ready = 0
        for i=1, #readyPlayers do
            Wait(0)
            if readyPlayers[i]['r'].Race ~= false then
                if readyPlayers[i]['r'].Race == race then
                    ready = ready + 1
                end
            end
        end
        local position = 1
        if ready == Config.OnlineRace[race].Players then
            for i=1, Config.OnlineRace[race].Players do
                local data = {R = race, [race] = {checkpoints = 0, p = i}}
                table.insert(online_race_leaderboard, data)
            end
            for i=1, #readyPlayers do
                if readyPlayers[i]['r'].Race ~= false then
                    if readyPlayers[i]['r'].Race == race then
                        table.insert(online_race_in_progress, {R = race})
                        TriggerClientEvent('loffe_race:start_online_race', readyPlayers[i]['r'].source, race, position)
                        position = position + 1
                    end
                end
            end
        end
    else
        TriggerClientEvent('loffe_race:onlinerace_cantstart', _source)
    end
end)

RegisterServerEvent('loffe_race:countdown')
AddEventHandler('loffe_race:countdown', function()
    local _source = source
    TriggerClientEvent('loffe_race:scaleform_showfreemodemessage', _source, '3', '', 0.6)
    Wait(1175)
    TriggerClientEvent('loffe_race:scaleform_showfreemodemessage', _source, '2', '', 0.6)
    Wait(1175)
    TriggerClientEvent('loffe_race:scaleform_showfreemodemessage', _source, '1', '', 0.55)
    Wait(1100)
    TriggerClientEvent('loffe_race:scaleform_showfreemodemessage', _source, 'KÖR!', '', 0.4)
end)


RegisterServerEvent('loffe_race:not_ready_online_race')
AddEventHandler('loffe_race:not_ready_online_race', function(race)
    local _source = source
    local steam = GetPlayerIdentifiers(_source)[1]
    for i=1, #readyPlayers do
        Wait(0)
        if readyPlayers[i]['r'].Race ~= false then
            if readyPlayers[i]['r'].source == _source then
                readyPlayers[i]['r'].Race = {false}
            end
        end
    end
end)

local offlineRace = true

RegisterServerEvent('loffe_race:offlineRace_sv')
AddEventHandler('loffe_race:offlineRace_sv', function(type)
    if type == 'can_i_start' then
        TriggerClientEvent('loffe_race:offlineRace_cl', source, offlineRace)
    else
        offlineRace = not offlineRace
    end
end)
