Menu = {}
Menu.GUI = {}
Menu.buttonCount = 0
Menu.selection = 0
Menu.hidden = true
Menu.ready = false

-- p1: Sol Menü Ana Yazı - name
-- P2: Enter Func - func
-- P3: Arrow Func. - func2
-- P4: Enter Func data 1 - args
-- P5: Enter Func data 2 - args2
-- P6: Sol Menü orta ufak yazı - extra
-- P7,P8: Sağ manü değerler

function Menu.addButton(name,func,func2,args,args2,extra,damages,bodydamages,garaj)
	local yoffset = 0.25
	local xoffset = 0.3
	local xmin = 0.0
	local xmax = 0.15
	local ymin = 0.03
	local ymax = 0.03
	Menu.GUI[Menu.buttonCount+1] = {}
	if extra then
		Menu.GUI[Menu.buttonCount+1]["extra"] = extra
	end

	if garaj then
		Menu.GUI[Menu.buttonCount+1]["garaj"] = garaj
	end

	if damages then
		Menu.GUI[Menu.buttonCount+1]["damages"] = damages
		Menu.GUI[Menu.buttonCount+1]["bodydamages"] = bodydamages
	end

	Menu.GUI[Menu.buttonCount+1]["name"] = name
	Menu.GUI[Menu.buttonCount+1]["func"] = func
	if func2 then
		Menu.GUI[Menu.buttonCount+1]["func2"] = func2
		if not Menu.fristCar then
			Menu.fristCar = true
			if Menu.GUI[Menu.selection +1]["func2"] ~= nil then
				if Menu.GUI[Menu.selection +1]["func2"] then
					spawnLocalVeh(Menu.GUI[Menu.selection +1]["func2"])
				end
			end
		end
	else
		Menu.GUI[Menu.buttonCount+1]["func2"] = false
	end
	Menu.GUI[Menu.buttonCount+1]["args"] = args
	Menu.GUI[Menu.buttonCount+1]["args2"] = args2

	Menu.GUI[Menu.buttonCount+1]["active"] = false
	Menu.GUI[Menu.buttonCount+1]["xmin"] = xmin
	Menu.GUI[Menu.buttonCount+1]["ymin"] = ymin * (Menu.buttonCount + 0.01) +yoffset
	Menu.GUI[Menu.buttonCount+1]["xmax"] = xmax 
	Menu.GUI[Menu.buttonCount+1]["ymax"] = ymax 
	Menu.buttonCount = Menu.buttonCount+1
end

function Menu.updateSelection() 
	if Menu.ready then
		if IsControlJustPressed(1, 173) then 
			Citizen.Wait(50)
			if(Menu.selection < Menu.buttonCount -1 ) then
				Menu.selection = Menu.selection +1
			else
				Menu.selection = 0
			end
			
			if Menu.GUI[Menu.selection +1]["func2"] then
				if Menu.GUI[Menu.selection +1]["func2"] then
					spawnLocalVeh(Menu.GUI[Menu.selection +1]["func2"])
				end
			end
			PlaySound(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", 0, 0, 1)
		elseif IsControlJustPressed(1, 27) then
			Citizen.Wait(50)
			if(Menu.selection > 0)then
				Menu.selection = Menu.selection -1
			else
				Menu.selection = Menu.buttonCount-1
			end
			if Menu.GUI[Menu.selection +1]["func2"] then
				if Menu.GUI[Menu.selection +1]["func2"] then
					spawnLocalVeh(Menu.GUI[Menu.selection +1]["func2"])
				end
			end
			PlaySound(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", 0, 0, 1)
		elseif IsControlJustPressed(1, 18) then
			if Menu.GUI[Menu.selection +1] and Menu.GUI[Menu.selection +1]["func"] then
				MenuCallFunction(Menu.GUI[Menu.selection +1]["func"], Menu.GUI[Menu.selection +1]["args"], Menu.GUI[Menu.selection +1]["args2"], Menu.GUI[Menu.selection +1]["garaj"])
			end
			PlaySound(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", 0, 0, 1)
		end
		local iterator = 0
		for id, settings in ipairs(Menu.GUI) do
			Menu.GUI[id]["active"] = false
			if(iterator == Menu.selection ) then
				Menu.GUI[iterator +1]["active"] = true
			end
			iterator = iterator +1
		end
	end
end

function Menu.renderGUI()
	if not Menu.hidden then
		Menu.renderButtons()
		Menu.updateSelection()
	end
end

function Menu.renderBox(xMin,xMax,yMin,yMax,color1,color2,color3,color4)
	DrawRect(0.7, yMin,0.15, yMax-0.002, color1, color2, color3, color4);
end

function Menu.renderButtons()
	
	local yoffset = 0.5
	local xoffset = 0

	for id, settings in pairs(Menu.GUI) do
		local screen_w = 0
		local screen_h = 0
		screen_w, screen_h =  GetScreenResolution(0, 0)

		local boxColor = {13,11,10,233}
		if settings["garaj"] then
			if cachedData["currentGarage"] == settings["garaj"] and not inCekilmis and not inMeslek then
				boxColor = {44,88,44,230}
			end
		end

		if(settings["active"]) then
			boxColor = {45,45,45,230}
		end

		local left = 0.0
		if inCekilmis or inMeslek then
			left = 0.021
		end

		if settings["extra"] then
			SetTextFont(4)

			SetTextScale(0.34, 0.34)
			SetTextColour(255, 255, 255, 255)
			SetTextEntry("STRING") 
			AddTextComponentString(settings["name"])
			DrawText(0.63, (settings["ymin"] - 0.012 )) 

			SetTextFont(4)
			SetTextScale(0.26, 0.26)
			SetTextColour(255, 255, 255, 255)
			SetTextEntry("STRING") 
			AddTextComponentString(settings["extra"])
			DrawText(0.718 + left, (settings["ymin"] - 0.009 )) 

			if not inCekilmis and not inMeslek and settings["garaj"] then
				SetTextFont(4)
				SetTextScale(0.26, 0.26)
				SetTextColour(255, 255, 255, 255)
				SetTextEntry("STRING") 
				AddTextComponentString("Garaj "..settings["garaj"])
				DrawText(0.751, (settings["ymin"] - 0.009 )) 
			end

			if settings["damages"] then	
				SetTextFont(4)
				SetTextScale(0.31, 0.31)
				SetTextColour(11, 11, 11, 255)
				SetTextEntry("STRING") 
				AddTextComponentString(settings["damages"])
				DrawText(0.78, (settings["ymin"] - 0.012 )) 

				SetTextFont(4)
				SetTextScale(0.31, 0.31)
				SetTextColour(11, 11, 11, 255)
				SetTextEntry("STRING") 
				AddTextComponentString(settings["bodydamages"])
				DrawText(0.840, (settings["ymin"] - 0.012 )) 

				DrawRect(0.832, settings["ymin"], 0.11, settings["ymax"]-0.002, 255,255,255,199)
				--Global.DrawRect(x, y, width, height, r, g, b, a)
			end
		else
			SetTextFont(4)
			SetTextScale(0.34, 0.34)
			SetTextColour(255, 255, 255, 255)
			SetTextCentre(true)
			SetTextEntry("STRING") 
			AddTextComponentString(settings["name"])
			DrawText(0.7, (settings["ymin"] - 0.012 )) 

		end

		Menu.renderBox(settings["xmin"] ,settings["xmax"], settings["ymin"], settings["ymax"],boxColor[1],boxColor[2],boxColor[3],boxColor[4])

	 end     
end

--------------------------------------------------------------------------------------------------------------------

function ClearMenu()
	--Menu = {}
	Menu.GUI = {}
	Menu.buttonCount = 0
	Menu.selection = 0
	Menu.fristCar = false
	Menu.ready = false
end

function MenuCallFunction(fnc, arg, args2, args3)
	_G[fnc](arg, args2, args3)
end