UpdateGarage = function(vehicleProps, newGarage)
	local sqlQuery = [[
		UPDATE
			owned_vehicles
		SET
			vehicle = @newVehicle
		WHERE
			plate = @plate
	]]

	exports.ghmattimysql:execute(sqlQuery, {
		["@plate"] = vehicleProps["plate"],
		["@newVehicle"] = json.encode(vehicleProps)
	})
end