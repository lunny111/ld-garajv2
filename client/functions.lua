local UcakCekilmis = exports["pant-base"]:itemPrice('UcakCekilmis')
local BotCekilmis = exports["pant-base"]:itemPrice('BotCekilmis')
local AracCekilmis = exports["pant-base"]:itemPrice('AracCekilmis')
local localVehicle = nil

openJobMenu = function(vehicles, action)
    Menu.hidden = false
    ClearMenu()
    Menu.addButton("GARAJ", false, false)
    Menu.addButton("Araçlarım", "OpenGarageMenu", false, action)
    Menu.addButton("Araç Satın Al", "buyVehicle", false, vehicles)
    Menu.ready = true
end

buyVehicle = function(vehicles)
    Menu.hidden = false
    ClearMenu()
    for key, vehicleData in ipairs(vehicles) do
        Menu.addButton(vehicleData.label , "buyVehicleServer", vehicleData, vehicleData, false, "$"..vehicleData.price )
    end
    Menu.addButton("KAPAT", "CloseMenu", false)
    Menu.ready = true
end

buyVehicleServer = function(vehicleData)
    TriggerServerEvent("ld-garajv2:buy-car", vehicleData, PantCore.Functions.GetVehicleProperties(localVehicle))
end

spawnLocalVeh = function(vehicleData)
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local playerheading = GetEntityHeading(playerPed) - 100
    local spawnpoint = GetOffsetFromEntityInWorldCoords(playerPed, 0.0, 4.0, 0.5)
    WaitForVehicleToLoad(vehicleData.model)
    PantCore.Functions.SpawnVehicle(vehicleData.model, function(veh)
        if DoesEntityExist(localVehicle) then
            DeleteEntity(localVehicle)
        end
        localVehicle = veh    
        SetEntityCollision(localVehicle, false, false)
        FreezeEntityPosition(localVehicle, true)
        SetVehicleLivery(localVehicle, vehicleData.livery)
        if vehicleData.tint then
            SetVehicleModKit(localVehicle, 0)
            SetVehicleWindowTint(localVehicle, vehicleData.tint)
        end
    end, {x=spawnpoint.x, y=spawnpoint.y, z=playerCoords.z-1.0, h=playerheading}, false) -- coords, isnetwork
end

Citizen.CreateThread(function()
    while true do 
        Citizen.Wait(1)
        if DoesEntityExist(localVehicle) then
            local playerPed = PlayerPedId()
            local playerCoords = GetEntityCoords(playerPed)
            local playerheading = GetEntityHeading(playerPed) - 100
            local spawnpoint = GetOffsetFromEntityInWorldCoords(playerPed, 0.0, 4.0, 0.5)
            SetEntityCoords(localVehicle, spawnpoint.x, spawnpoint.y, playerCoords.z-1.0)
            SetEntityHeading(localVehicle, playerheading)
        else
            Citizen.Wait(1000)
        end
    end
end)

function WaitForVehicleToLoad(modelHash)
	modelHash = (type(modelHash) == 'number' and modelHash or GetHashKey(modelHash))

	if not HasModelLoaded(modelHash) then
		RequestModel(modelHash)

		BeginTextCommandBusyspinnerOn('STRING')
		AddTextComponentSubstringPlayerName("Araç Görüntüsü Yükleniyor Lütfen Bekleyiniz")
		EndTextCommandBusyspinnerOn(4)

		while not HasModelLoaded(modelHash) do
			Citizen.Wait(0)
			DisableAllControlActions(0)
		end

		BusyspinnerOff()
	end
end

OpenGarageMenu = function(durum)
    local currentGarage = cachedData["currentGarage"]
    if not currentGarage then return end

    Menu.hidden = false
    ClearMenu()
    PantCore.Functions.TriggerCallback("garage:fetchPlayerVehicles", function(fetchedVehicles)
        local aracimYok = true

        if durum == "cekilmis" then
            baslik = "Çekilmis Araçlarım / Çekim Ücreti $" .. AracCekilmis
        elseif durum == "cekilmis-bot" then
            baslik = "Çekilmis Araçlarım / Çekim Ücreti $" .. BotCekilmis
        elseif durum == "cekilmis-ucak" then
            baslik = "Çekilmis Araçlarım / Çekim Ücreti $" .. UcakCekilmis
        else
            baslik = "Araçlarım (Garaj "..cachedData["currentGarage"]..")"
        end

        for key, vehicleData in ipairs(fetchedVehicles) do
            local vehicleProps = json.decode(vehicleData.vehicle)

            if key == 1 then
                Menu.addButton(baslik, false, false)
            end
                
            local aracAdi = GetLabelText(GetDisplayNameFromVehicleModel(vehicleProps.model))
            local plaka = vehicleProps.plate
            local bodyCani = " Gövde : 100%"
            local motorCani = " Motor : 100%"

            if vehicleProps.bodyHealth ~= nil then
                bodyCani = " Gövde : " .. vehicleProps.bodyHealth / 10 .. "%"
            end

            if vehicleProps.engineHealth ~= nil then
                bodyCani = " Gövde : " .. vehicleProps.engineHealth / 10 .. "%"
            end

            -- p1: Sol Menü Ana Yazı - name
            -- P2: Enter Func - func
            -- P3: Arrow Func. - func2
            -- P4: Enter Func data 1 - args
            -- P5: Enter Func data 2 - args2
            -- P6: Sol Menü orta ufak yazı - extra
            -- P7,P8: Sağ manü değerler
            if vehicleData.garaj == nil then 
                garajNoData = cachedData["currentGarage"]
            else
                garajNoData = vehicleData.garaj
            end

            Menu.addButton(aracAdi, "SpawnVehicle", false, vehicleProps, durum, plaka, motorCani, bodyCani, garajNoData)
            aracimYok = false
        end

        if aracimYok then
            Menu.addButton("Herhangi Bir Aracın Yok!", "CloseMenu", false)
        end

        Menu.addButton("KAPAT", "CloseMenu", false)
        Menu.ready = true
    end, durum)
end

SpawnVehicle = function(vehicleProps, durum, garajNoData)
    if garajNoData == cachedData["currentGarage"] or inCekilmis or inMeslek then
        local playerPed = PlayerPedId()
        local spawnpoint = GetEntityCoords(playerPed) 
        local spawnheading = GetEntityHeading(playerPed)
        if Config.Garages[tonumber(cachedData["currentGarage"])]["sPosition"] then
            spawnpoint = Config.Garages[tonumber(cachedData["currentGarage"])]["sPosition"]
            spawnheading = Config.Garages[tonumber(cachedData["currentGarage"])]["sHeading"]
        end
        
        if not PantCore.Functions.IsSpawnPointClear(spawnpoint, 3.0) then 
            PantCore.Functions.Notify("Unable to Eject Vehicle due to Nearby Vehicle.")
            return
        end

        WaitForModel(vehicleProps["model"])
        
        local gameVehicles = PantCore.Functions.GetVehicles()
    
        for i = 1, #gameVehicles do
            local vehicle = gameVehicles[i]
            if DoesEntityExist(vehicle) then
                if PantCore.Shared.Trim(GetVehicleNumberPlateText(vehicle)) == PantCore.Shared.Trim(vehicleProps["plate"]) then
                    PantCore.Functions.Notify("Your Car Is Already Somewhere!.")
                    return
                end
            end
        end
    
        PantCore.Functions.SpawnVehicle(vehicleProps["model"], function(yourVehicle)
         
            PantCore.Functions.SetVehicleProperties(yourVehicle, vehicleProps)
    
            NetworkFadeInEntity(yourVehicle, true, true)
    
            SetModelAsNoLongerNeeded(vehicleProps["model"])
    
            TaskWarpPedIntoVehicle(PlayerPedId(), yourVehicle, -1)
    
            SetVehicleHasBeenOwnedByPlayer(yourVehicle, true)
            local id = NetworkGetNetworkIdFromEntity(yourVehicle)
            SetNetworkIdCanMigrate(id, true)
    
            PantCore.Functions.Notify("You pulled your car out of your garage.")
    
            if durum == "cekilmis" then
                TriggerServerEvent("ld-garaj:arac-cekilmistemi", cachedData["currentGarage"], vehicleProps["plate"], 0, AracCekilmis)
            elseif durum == "cekilmis-bot" then
                TriggerServerEvent("ld-garaj:arac-cekilmistemi", cachedData["currentGarage"], vehicleProps["plate"], 0, BotCekilmis)
            elseif durum == "cekilmis-ucak" then
                TriggerServerEvent("ld-garaj:arac-cekilmistemi", cachedData["currentGarage"], vehicleProps["plate"], 0, UcakCekilmis)
            else
                TriggerServerEvent("ld-garaj:arac-cekilmistemi", cachedData["currentGarage"], vehicleProps["plate"], 0)
            end
    
            TriggerEvent("x-hotwire:give-keys", yourVehicle)
            CloseMenu()
            while not GetIsVehicleEngineRunning(yourVehicle) do Citizen.Wait(100) end
            Citizen.Wait(100)
            if durum == "cekilmis" or durum == "cekilmis-bot" or durum == "cekilmis-ucak" or durum == "cekilmis-ucak" or durum == "bot" then
                SetVehicleFuelLevel(yourVehicle, 25.0)
                DecorSetFloat(yourVehicle, "_FUEL_LEVEL", 25.0)
                repairCar(yourVehicle)
            else
                SetVehicleFuelLevel(yourVehicle, vehicleProps["fuelLevel"]+0.0)
                DecorSetFloat(yourVehicle, "_FUEL_LEVEL", vehicleProps["fuelLevel"]+0.0)
            end
        end, {x=spawnpoint.x, y=spawnpoint.y, z=spawnpoint.z, h=spawnheading}, true) -- coords, isnetwork
    else
        PantCore.Functions.Notify("Your Car's Not In This Garage! The Garage Where The Car Was Found Was Marked On GPS!", "error")
        local coords = Config.Garages[tonumber(garajNoData)]["blip"]
        SetNewWaypoint(coords.x, coords.y)
    end
end

function repairCar(yourVehicle)
    SetVehicleFixed(yourVehicle)
    SetVehicleDeformationFixed(yourVehicle)
    SetVehicleUndriveable(yourVehicle, false)
end

local active = false
PutInVehicle = function()
    if not active then
        active = true
        local vehicle = GetVehiclePedIsUsing(PlayerPedId())

        local dogruArac = false
        local data = nil
        local garajTip = Config.Garages[tonumber(cachedData["currentGarage"])]["tip"]
        if garajTip == "meslek-polis-arac" then
            data = Config.policeVehicle
        elseif garajTip == "meslek-ems-arac" then
            data = Config.emsVehicle
        elseif garajTip == "meslek-ems-heli" then
            data = Config.emsHeli
        elseif garajTip == "meslek-police-heli" then
            data = Config.policeHeli
        elseif garajTip == "meslek-motor-arac" then
            data = Config.motorVehicle
        elseif garajTip == "meslek-mafia-arac" then
            data = Config.mafiaVehicle
        elseif garajTip == "meslek-unemployed-arac" then
            data = Config.jobVehicle
        elseif garajTip == "meslek-police-bot" then
            data = Config.policeBoat
        elseif garajTip == "meslek-ems-bot" then
            data = Config.emsBoat
        elseif garajTip == "meslek-night-arac" then
            data = Config.nightVehicle
        elseif garajTip == "meslek-policesivil-arac" then
            data = Config.sivilpd
        elseif garajTip == "meslek-wn-arac" then
            data = Config.wnVehicle
        elseif garajTip == "meslek-wn-heli" then
            data = Config.wnHeli
        end
        if data then
            for i=1, #data do
                if IsVehicleModel(vehicle, GetHashKey(data[i].model)) then
                    dogruArac = true  
                    break
                end
            end
        else
            dogruArac = true
        end

        if not dogruArac then
            PantCore.Functions.Notify('You Can\'t Put This Car In A Job Garage!', 'error')
            active = false
            return
        end

        if DoesEntityExist(vehicle) then
            for i=1, GetVehicleModelNumberOfSeats(GetEntityModel(vehicle)) do
                if i ~= 1 then
                    if not IsVehicleSeatFree(vehicle, i-2) then 
                        PantCore.Functions.Notify('You Can\'t Put It In The Garage When There Are Others In The Car.')
                        active = false
                        return
                    end
                end
            end

            local vehicleProps = PantCore.Functions.GetVehicleProperties(vehicle)

            PantCore.Functions.TriggerCallback("garage:validateVehicle", function(valid)
                if valid then                
                    NetworkRequestControlOfEntity(vehicle)

                    local timeout = 0
        
                    while timeout < 1000 and not NetworkHasControlOfEntity(vehicle) do
                        Citizen.Wait(100)
                        timeout = timeout + 100
                    end

                    TaskLeaveVehicle(PlayerPedId(), vehicle, 0)
                    while IsPedInVehicle(PlayerPedId(), vehicle, true) do
                        Citizen.Wait(0)
                    end
        
                    Citizen.Wait(500)
        
                    NetworkFadeOutEntity(vehicle, true, true)
        
                    Citizen.Wait(100)        
        
                    SetEntityAsMissionEntity(vehicle, true, true)
                    DeleteVehicle(vehicle)
                    DeleteEntity(vehicle)

                    PantCore.Functions.Notify("Did You Park The Vehicle.")
                    TriggerServerEvent("ld-garaj:arac-cekilmistemi", cachedData["currentGarage"], vehicleProps["plate"], 1)
                else
                    PantCore.Functions.Notify("You Can't Put A Car In A Garage That's Not Yours.")
                end
                active = false
            end, vehicleProps, cachedData["currentGarage"])
        end
    end
end

HandleAction = function(action)
    if action == "vehicle" then
        if inCekilmis then
            PantCore.Functions.Notify("You Can't Park Cars For Towed Ones!", "error")
        else
            PutInVehicle()
        end
    elseif action == "meslek-polis-arac" then
        openJobMenu(Config.policeVehicle, action)
    elseif action == "meslek-ems-arac" then
        openJobMenu(Config.emsVehicle, action)
    elseif action == "meslek-ems-heli" then
        openJobMenu(Config.emsHeli, action)
    elseif action == "meslek-police-heli" then
        openJobMenu(Config.policeHeli, action)
    elseif action == "meslek-motor-arac" then
        openJobMenu(Config.motorVehicle, action)
    elseif action == "meslek-mafia-arac" then
        openJobMenu(Config.mafiaVehicle, action)
    elseif action == "meslek-unemployed-arac" then
        openJobMenu(Config.jobVehicle, action)
    elseif action == "meslek-police-bot" then
        openJobMenu(Config.policeBoat, action)
    elseif action == "meslek-ems-bot" then
        openJobMenu(Config.emsBoat, action)
    elseif action == "meslek-night-arac" then
        if PlayerData.job.boss then
            openJobMenu(Config.nightVehicle, action)
        else
            PantCore.Functions.Notify("You are not boss", "error")
        end
    elseif action == "meslek-policesivil-arac" then
        if PlayerData.job.boss then
            openJobMenu(Config.sivilpd, action)
        else
            PantCore.Functions.Notify("Your Rank Is Not Enough!", "error")
        end
    elseif action == "meslek-wn-arac" then
        openJobMenu(Config.wnVehicle, action)
    elseif action == "meslek-wn-heli" then
        openJobMenu(Config.wnHeli, action)
    else
        OpenGarageMenu(action)
    end
end

PlayAnimation = function(ped, dict, anim, settings)
	if dict then
        Citizen.CreateThread(function()
            RequestAnimDict(dict)

            while not HasAnimDictLoaded(dict) do
                Citizen.Wait(100)
            end

            if settings == nil then
                TaskPlayAnim(ped, dict, anim, 1.0, -1.0, 1.0, 0, 0, 0, 0, 0)
            else 
                local speed = 1.0
                local speedMultiplier = -1.0
                local duration = 1.0
                local flag = 0
                local playbackRate = 0

                if settings["speed"] then
                    speed = settings["speed"]
                end

                if settings["speedMultiplier"] then
                    speedMultiplier = settings["speedMultiplier"]
                end

                if settings["duration"] then
                    duration = settings["duration"]
                end

                if settings["flag"] then
                    flag = settings["flag"]
                end

                if settings["playbackRate"] then
                    playbackRate = settings["playbackRate"]
                end

                TaskPlayAnim(ped, dict, anim, speed, speedMultiplier, duration, flag, playbackRate, 0, 0, 0)
            end
      
            RemoveAnimDict(dict)
		end)
	else
		TaskStartScenarioInPlace(ped, anim, 0, true)
	end
end

WaitForModel = function(model)
    local DrawScreenText = function(text, red, green, blue, alpha)
        SetTextFont(4)
        SetTextScale(0.0, 0.5)
        SetTextColour(red, green, blue, alpha)
        SetTextDropshadow(0, 0, 0, 0, 255)
        SetTextEdge(1, 0, 0, 0, 255)
        SetTextDropShadow()
        SetTextOutline()
        SetTextCentre(true)
    
        BeginTextCommandDisplayText("STRING")
        AddTextComponentSubstringPlayerName(text)
        EndTextCommandDisplayText(0.5, 0.5)
    end

    if not IsModelValid(model) then
        return PantCore.Functions.Notify("There Is No Such Model Vehicle In The Game.")
    end

	if not HasModelLoaded(model) then
		RequestModel(model)
	end
	
	while not HasModelLoaded(model) do
		Citizen.Wait(0)

		DrawScreenText("Araç Yükleniyor " .. GetLabelText(GetDisplayNameFromVehicleModel(model)) .. "...", 255, 255, 255, 150)
	end
end

function CloseMenu()
    Menu.hidden = true
    if DoesEntityExist(localVehicle) then
		DeleteEntity(localVehicle)
	end
end