local QBCore = exports['qb-core']:GetCoreObject()

RegisterNetEvent("qb-metro:server:TravelRequest", function(index)
    local src = source
    local _index  = index

    local time = GetTime()
    local minsleft = 5 - (time.m % 5)
    local isWaiting = true
    local cancel = false

    TriggerClientEvent("qb-metro:client:TimeLeft", src, minsleft)

    Citizen.CreateThread(function()
        while IsInZone(src) do
            Citizen.Wait(4000)
            if not isWaiting then
                break
            end
        end
        if isWaiting then
            TriggerClientEvent("qb-metro:client:StayInZone", src)
            cancel = true
        end
    end)

    Citizen.Wait((minsleft - 1) * 60000 + (60 - time.s) * 1000)

    if cancel then
        return
    end

    if Config.UseQBCore then
        local Player = QBCore.Functions.GetPlayer(src)
        Player.Functions.RemoveMoney('cash', Config.QBCorePrice)
    end

    TriggerClientEvent("qb-metro:client:TrainArrival", src)
    Citizen.Wait(800)
    SetEntityCoords(GetPlayerPed(src), (Config.Zones[_index].xyz + vector3(0, 2.5, 0)), false, false, false, false)
    isWaiting = false
end)

function GetTime()
    local timestamp = os.time()
    local m = tonumber(os.date('%M', timestamp))
    local s = tonumber(os.date('%S', timestamp))
    return { m = m, s = s }
end

function IsInZone(src)
    local coords = GetEntityCoords(GetPlayerPed(src))
    for k, v in pairs(Config.Zones) do
        if #(coords - v.xyz) < (v.sizeX / 2) then
            return true
        end
    end
    return false
end