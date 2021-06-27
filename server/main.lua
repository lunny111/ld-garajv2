PantCore = nil

TriggerEvent('PantCore:GetObject', function(obj) PantCore = obj end)

Citizen.CreateThread(function()
	Citizen.Wait(1000)
	exports.ghmattimysql:execute('UPDATE owned_vehicles SET stored = true WHERE stored = @stored', {
		['@stored'] = false
	}, function (rowsChanged)
	end)
end)

PantCore.Functions.CreateCallback('ld-garaj:fatura', function(source, cb)
	local xPlayer = PantCore.Functions.GetPlayer(source)
	local fatura = nil

	exports.ghmattimysql:execute('SELECT * FROM billing WHERE citizenid = @citizenid', {
		['@citizenid'] = xPlayer.PlayerData.citizenid
	}, function(data)
		cb(data)
	end)
end)

RegisterServerEvent("ld-garajv2:buy-car")
AddEventHandler("ld-garajv2:buy-car", function(vehicleData, vehicle)
	local xPlayer = PantCore.Functions.GetPlayer(source)
	local price = vehicleData.price
	if xPlayer.PlayerData.money.bank >= price then
		if xPlayer.Functions.RemoveMoney("bank", price) then			
			exports.ghmattimysql:execute('INSERT INTO owned_vehicles (owner, vehicle, plate, type, job, `stored`) VALUES (@owner, @vehicle, @plate, @type, @job, @stored)', {
				['@owner'] = xPlayer.PlayerData.citizenid,
				['@vehicle'] = json.encode(vehicle),
				['@plate'] = vehicle.plate,
				['@type'] = vehicleData.type,
				['@job'] = xPlayer.PlayerData.job.name,
				['@stored'] = true
			},function (rowsChanged)
				
			end)
			TriggerClientEvent('PantCore:Notify', xPlayer.PlayerData.source,  vehicleData.label.." İsminde bir araç satın aldınız", "success")
		end
	else
		TriggerClientEvent('PantCore:Notify',  xPlayer.PlayerData.source,  "Yeterli Paranız Yok", "error")
	end
end)


PantCore.Functions.CreateCallback("garage:fetchPlayerVehicles", function(source, callback, durum) 
	local player = PantCore.Functions.GetPlayer(source)
	print("durum" ..durum)
	if player then
		if durum == "menu" then
			sqlQuery = [[
				SELECT
					vehicle
				FROM
					owned_vehicles
				WHERE
					owner = @cid and stored = '1' and type = 'car'
			]]
				
		elseif durum == "cekilmis" then
			sqlQuery = [[
				SELECT
					vehicle
				FROM
					owned_vehicles
				WHERE
					owner = @cid and stored = '0' and type = 'car'
			]]

		elseif durum == "bot" then
			sqlQuery = [[
				SELECT
					vehicle
				FROM
					owned_vehicles
				WHERE
					owner = @cid and stored = '1' and type = 'boat'
			]]
			
		elseif durum == "cekilmis-bot" then
			sqlQuery = [[
				SELECT
					vehicle
				FROM
					owned_vehicles
				WHERE
					owner = @cid and stored = '0' and type = 'boat'
			]]

		elseif durum == "ucak" then
			sqlQuery = [[
				SELECT
					vehicle
				FROM
					owned_vehicles
				WHERE
					owner = @cid and stored = '1' and type = 'helicopter'
			]]

		elseif durum == "cekilmis-ucak" then
			sqlQuery = [[
				SELECT
					vehicle
				FROM
					owned_vehicles
				WHERE
					owner = @cid and stored = '0' and type = 'helicopter'
			]]

		elseif durum == "meslek-polis-arac" then
			sqlQuery = [[
				SELECT
					vehicle
				FROM
					owned_vehicles
				WHERE
					owner = @cid and stored = '1' and type = 'car' and job = 'police'
			]]

		elseif durum == "meslek-ems-arac" then
			sqlQuery = [[
				SELECT
					vehicle
				FROM
					owned_vehicles
				WHERE
					owner = @cid and stored = '1' and type = 'car' and job = 'ambulance'
			]]
		elseif durum == "meslek-ems-heli" then
			sqlQuery = [[
				SELECT
					vehicle
				FROM
					owned_vehicles
				WHERE
					owner = @cid and stored = '1' and type = 'helicopter' and job = 'ambulance'
			]]
		elseif durum == "meslek-police-heli" then
			sqlQuery = [[
				SELECT
					vehicle
				FROM
					owned_vehicles
				WHERE
					owner = @cid and stored = '1' and type = 'helicopter' and job = 'police'
			]]
		elseif durum == "meslek-mafia-heli" then
			sqlQuery = [[
				SELECT
					vehicle
				FROM
					owned_vehicles
				WHERE
					owner = @cid and stored = '1' and type = 'car' and job = 'mafia'
			]]
		elseif durum == "meslek-unemployed-arac" then
			sqlQuery = [[
				SELECT
					vehicle
				FROM
					owned_vehicles
				WHERE
					owner = @cid and stored = '1' and type = 'car' and job = 'unemployed'
			]]
		elseif durum == "meslek-police-bot" then
			sqlQuery = [[
				SELECT
					vehicle
				FROM
					owned_vehicles
				WHERE
					owner = @cid and stored = '1' and type = 'boat' and job = 'police'
			]]
		elseif durum == "meslek-ems-bot" then
			sqlQuery = [[
				SELECT
					vehicle
				FROM
					owned_vehicles
				WHERE
					owner = @cid and stored = '1' and type = 'boat' and job = 'ambulance'
			]]
		elseif durum == "meslek-night-arac" then
			sqlQuery = [[
				SELECT
					vehicle
				FROM
					owned_vehicles
				WHERE
					owner = @cid and stored = '1' and type = 'car' and job = 'night'
			]]
		elseif durum == "meslek-policesivil-arac" then
			sqlQuery = [[
				SELECT
					vehicle
				FROM
					owned_vehicles
				WHERE
					owner = @cid and stored = '1' and type = 'car' and job = 'offpolice'
			]]
			
		end
		
		
		exports.ghmattimysql:execute(sqlQuery, {
			["@cid"] = player.PlayerData.citizenid
		}, function(result)
			callback(result)
			print(json.encode(result.vehicle))
		end)
	else
		callback(false)
	end
end)

PantCore.Functions.CreateCallback("garage:validateVehicle", function(source, callback, vehicleProps, valid)
	local player = PantCore.Functions.GetPlayer(source)
	if player then
		local sqlQuery = [[
			SELECT
				owner
			FROM
				owned_vehicles
			WHERE
				plate = @plate
		]]

		exports.ghmattimysql:execute(sqlQuery, {
			["@plate"] = vehicleProps["plate"]
		}, function(responses)
			if responses[1] then
				UpdateGarage(vehicleProps, garage)
				callback(true)
			else
				callback(false)
			end
		end)
	else
		callback(false)
	end
end)

RegisterServerEvent('ld-garaj:arac-cekilmistemi')
AddEventHandler('ld-garaj:arac-cekilmistemi', function(garajTip, plate, durum, fiyat)

	local _source = source
	local xPlayer = PantCore.Functions.GetPlayer(_source)
	if fiyat ~= nil then
		TriggerClientEvent('PantCore:Notify', xPlayer.PlayerData.source,  fiyat.. "$ Karşılığında aracını aldın", "error")
		xPlayer.Functions.RemoveMoney('bank', fiyat)
	end

	exports.ghmattimysql:execute('UPDATE owned_vehicles SET stored = @stored WHERE plate = @plate', {
		['@plate'] = plate,
		['@stored'] = durum
	})
end)