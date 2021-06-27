local blip = false

cachedData = {}
PlayerData = {}
action = ""
inCekilmis = false
inMeslek = false

PantCore = nil
Citizen.CreateThread(function()
    while PantCore == nil do
        TriggerEvent('PantCore:GetObject', function(obj) PantCore = obj end)
        Citizen.Wait(200)
	end
	PlayerData = PantCore.Functions.GetPlayerData()
end)  

RegisterNetEvent('PantCore:Client:OnPlayerLoaded')
AddEventHandler('PantCore:Client:OnPlayerLoaded', function()
	PlayerData = PantCore.Functions.GetPlayerData()
end)

RegisterNetEvent('PantCore:Client:OnJobUpdate')
AddEventHandler('PantCore:Client:OnJobUpdate', function(newJob)
	PlayerData.job = newJob
end)

RegisterNetEvent("ld-garaj:blipAcKapa")
AddEventHandler("ld-garaj:blipAcKapa", function()
	if blip then
		pasifblip()
		blip = false
	else
		aktifblip()
		blip = true
	end
end)

local aktifblipler = {}

function aktifblip()
	local bliplist = {}
	for garage, garageData in pairs(Config.Garages) do
		local tip = garageData["tip"]
		if tip == "menu" then
			table.insert(bliplist, {
				sprite = 357, 
				display = 2, 
				scale = 0.45, 
				colour = 77, 
				name = "Garaj", 
				cords  = { garageData["blip"]["x"],  garageData["blip"]["y"]},
			})
		elseif tip == "meslek-motor-arac" and garageData["job"] == PlayerData.job.name then
			table.insert(bliplist, {
				sprite = 357, 
				display = 2, 
				scale = 0.45, 
				colour = 77, 
				name = "Motorcu Garajı", 
				cords  = { garageData["blip"]["x"],  garageData["blip"]["y"]},
			})
		elseif tip == "meslek-mafia-arac" and garageData["job"] == PlayerData.job.name then
			table.insert(bliplist, {
				sprite = 357, 
				display = 2, 
				scale = 0.45, 
				colour = 77, 
				name = "Özel Güvenlik Garajı", 
				cords  = { garageData["blip"]["x"],  garageData["blip"]["y"]},
			})
		elseif tip == "meslek-ems-arac" and garageData["job"] == PlayerData.job.name then
			table.insert(bliplist, {
				sprite = 357, 
				display = 2, 
				scale = 0.45, 
				colour = 77, 
				name = "EMS Garajı", 
				cords  = { garageData["blip"]["x"],  garageData["blip"]["y"]},
			})
		elseif tip == "meslek-policesivil-arac" and garageData["job"] == PlayerData.job.name then
			table.insert(bliplist, {
				sprite = 357, 
				display = 2, 
				scale = 0.45, 
				colour = 77, 
				name = "Sivil PD Garajı", 
				cords  = { garageData["blip"]["x"],  garageData["blip"]["y"]},
			})
		elseif tip == "meslek-polis-arac" and garageData["job"] == PlayerData.job.name then
			table.insert(bliplist, {
				sprite = 357, 
				display = 2, 
				scale = 0.45, 
				colour = 77, 
				name = "PD Garajı", 
				cords  = { garageData["blip"]["x"],  garageData["blip"]["y"]},
			})
		elseif tip == "cekilmis" then
			table.insert(bliplist, {
				sprite = 67, 
				display = 2, 
				scale = 0.45, 
				colour = 49, 
				name = "Çekilmiş Araçlar", 
				cords = { garageData["blip"]["x"],  garageData["blip"]["y"]},
			})
		elseif tip == "bot" then
			table.insert(bliplist, {
				sprite = 356, 
				display = 2, 
				scale = 0.45, 
				colour = 77, 
				name = "Bot/Tekne Garajı", 
				cords = { garageData["blip"]["x"],  garageData["blip"]["y"]},
			})
		elseif tip == "cekilmis-bot" then
			table.insert(bliplist, {
				sprite = 410, 
				display = 2,
				scale = 0.45, 
				colour = 49, 
				name = "Çekilmiş Bot/Tekne Araçları", 
				cords = { garageData["blip"]["x"],  garageData["blip"]["y"]},
			})
		elseif tip == "ucak" then
			table.insert(bliplist, {
				sprite = 360, 
				display = 2, 
				scale = 0.45, 
				colour = 77, 
				name = "Helikopter/Uçak Garajı", 
				cords = { garageData["blip"]["x"],  garageData["blip"]["y"]},
			})
		elseif tip == "meslek-police-heli" and garageData["job"] == PlayerData.job.name then
			table.insert(bliplist, {
				sprite = 360, 
				display = 2, 
				scale = 0.45, 
				colour = 77, 
				name = "PD Helikopter Garajı", 
				cords = { garageData["blip"]["x"],  garageData["blip"]["y"]},
			})
		elseif tip == "meslek-ems-heli" and garageData["job"] == PlayerData.job.name then
			table.insert(bliplist, {
				sprite = 360, 
				display = 2, 
				scale = 0.45, 
				colour = 77, 
				name = "EMS Helikopter Garajı", 
				cords = { garageData["blip"]["x"],  garageData["blip"]["y"]},
			})
		elseif tip == "cekilmis-ucak" then
			table.insert(bliplist, {
				sprite = 481, 
				display = 2, 
				scale = 0.45, 
				colour = 49, 
				name = "Çekilmiş Helikopter/Uçak Araçları", 
				cords = { garageData["blip"]["x"],  garageData["blip"]["y"]},
			})

		elseif tip == "meslek-police-bot" then
			if PlayerData.job and PlayerData.job.name == garageData["job"] then
				table.insert(bliplist, {
					sprite = 356, 
					display = 2, 
					scale = 0.45, 
					colour = 38, 
					name = "Polis Bot/Tekne Garajı", 
					cords = { garageData["blip"]["x"],  garageData["blip"]["y"]},
				})
			end
		elseif tip == "meslek-ems-bot" then
			if PlayerData.job and PlayerData.job.name == garageData["job"] then
				table.insert(bliplist, {
					sprite = 356, 
					display = 2, 
					scale = 0.45, 
					colour = 38, 
					name = "EMS Bot/Tekne Garajı", 
					cords = { garageData["blip"]["x"],  garageData["blip"]["y"]},
				})
			end
		elseif tip == "meslek-wn-heli" and garageData["job"] == PlayerData.job.name then
			table.insert(bliplist, {
				sprite = 360, 
				display = 2, 
				scale = 0.45, 
				colour = 77, 
				name = "Weazel News Helikopter Garajı", 
				cords = { garageData["blip"]["x"],  garageData["blip"]["y"]},
			})
		elseif tip == "meslek-wn-arac" and garageData["job"] == PlayerData.job.name then
			table.insert(bliplist, {
				sprite = 357, 
				display = 2, 
				scale = 0.45, 
				colour = 77, 
				name = "Weazel News Garajı", 
				cords  = { garageData["blip"]["x"],  garageData["blip"]["y"]},
			})
		end
	end

	for i=1, #bliplist, 1 do
		blipOlustur(bliplist[i].cords, bliplist[i].name, bliplist[i].sprite, bliplist[i].colour, bliplist[i].scale, bliplist[i].display)
	end
end

function blipOlustur(coords, text, sprite, color, scale, display)
	local blip = AddBlipForCoord(table.unpack(coords))

	SetBlipSprite(blip, sprite)
	SetBlipDisplay(blip, display)
	SetBlipScale (blip, 0.5)
	SetBlipColour(blip, color)
	SetBlipAsShortRange(blip, true)
	BeginTextCommandSetBlipName("STRING")
	AddTextComponentString(text)
	EndTextCommandSetBlipName(blip)
	table.insert(aktifblipler, blip)
end

function pasifblip()
	for i=1, #aktifblipler do
		RemoveBlip(aktifblipler[i])	
	end

	for i=1, #aktifblipler do
		table.remove(aktifblipler)		
	end
end

exports('checkgarage', function()
	local found = false
	local inCar = false

	inCekilmis = false
	inMeslek = false

	if PlayerData.job == nil then PlayerData = PantCore.Functions.GetPlayerData() end
	for garage, garageData in pairs(Config.Garages) do
		if garageData["zone"]:isPointInside(GetEntityCoords(PlayerPedId())) then
			if garageData["job"] then
				job = garageData["job"]
			else
				job = PlayerData.job.name
			end
			if job == PlayerData.job.name then
				found = true
				
				if IsPedInAnyVehicle(PlayerPedId()) then
					action = "vehicle"
					inCar = true
				else
					action = garageData["tip"]
				end
				cachedData["currentGarage"] = tostring(garage)

				if string.match(garageData["tip"], 'cekilmis') then inCekilmis = true end
				if string.match(garageData["tip"], 'meslek') then inMeslek = true end
				if inCar and inCekilmis then return false end
			end
		end
	end
	return found
end)

RegisterNetEvent("ld-garaj:open")
AddEventHandler("ld-garaj:open", function()
	if not exports["pant-base"]:soygun() then 
		PantCore.Functions.TriggerCallback('ld-garaj:fatura', function(fatura)
			local vergiToplam = 0
			for _, ftr in pairs(fatura) do
				if ftr.label == "Vergi" then
					vergiToplam = ftr.amount
				end
			end
			
			if #fatura > 4 then
				PantCore.Functions.Notify('You can\'t use free parking because you have five and more than five unpaid bills! Your Total Bill: ' .. #fatura)
			elseif vergiToplam >= 1000 then
				PantCore.Functions.Notify("$"..vergiToplam.. ' You Can\'t Use The Free Garage Service Because You Have Unpaid Tax!')
			else
				HandleAction(action)
			end

			while not Menu.hidden do 
				Menu.renderGUI()
				if IsControlJustPressed(1, 177) and not Menu.hidden then
					CloseMenu()
					PlaySound(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", 0, 0, 1)
				end
				Citizen.Wait(1)
			end

		end)
	else
		PantCore.Functions.Notify("You can't use your garage right now because you were involved in a robbery", "error", 15000)
	end
end)