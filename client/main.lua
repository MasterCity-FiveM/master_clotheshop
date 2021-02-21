local ESX                     = nil
local HasAlreadyEnteredMarker = false
local LastZone                = nil
local CurrentAction           = nil
local CurrentActionMsg        = ''
local CurrentActionData       = {}
local HasPaid                 = false

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
end)

function OpenShopMenu(IsBarbar)
	HasPaid = false
	
	local MenuItems = {
		'tshirt_1',
		'tshirt_2',
		'torso_1',
		'torso_2',
		'decals_1',
		'decals_2',
		'arms',
		'pants_1',
		'pants_2',
		'shoes_1',
		'shoes_2',
		'chain_1',
		'chain_2',
		'helmet_1',
		'helmet_2',
		'glasses_1',
		'glasses_2',
		'bags_1',
		'bags_2'
	}
	local menu_type = 'shop_menu'
	if IsBarbar then
		menu_type = 'barbar_menu'
		MenuItems = {
			'beard_1',
			'beard_2',
			'beard_3',
			'beard_4',
			'hair_1',
			'hair_2',
			'hair_color_1',
			'hair_color_2',
			'eyebrows_1',
			'eyebrows_2',
			'eyebrows_3',
			'eyebrows_4',
			'makeup_1',
			'makeup_2',
			'makeup_3',
			'makeup_4',
			'lipstick_1',
			'lipstick_2',
			'lipstick_3',
			'lipstick_4',
			'ears_1',
			'ears_2',
		}
	end
	
	TriggerEvent('esx_skin:openRestrictedMenu', function(data, menu)
		menu.close()

		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'shop_confirm',
		{
			title = _U('valid_this_purchase'),
			align		= 'top-right',
			elements = {
				{label = _U('no'), value = 'no'},
				{label = _U('yes'), value = 'yes'}
			}
		}, function(data, menu)
			menu.close()

			if data.current.value == 'yes' then
				ESX.TriggerServerCallback('esx_clotheshop:buyClothes', function(bought)
					if bought then
						TriggerEvent('skinchanger:getSkin', function(skin)
							TriggerServerEvent('esx_skin:save', skin)
						end)

						HasPaid = true
						
						if not IsBarbar then
							ESX.TriggerServerCallback('esx_clotheshop:checkPropertyDataStore', function(foundStore)
								if foundStore then
									ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'save_dressing',
									{
										title = _U('save_in_dressing'),
										align		= 'right',
										elements = {
											{label = _U('no'),  value = 'no'},
											{label = _U('yes'), value = 'yes'}
										}
									}, function(data2, menu2)
										menu2.close()

										if data2.current.value == 'yes' then
											ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'outfit_name', {
												title = _U('name_outfit')
											}, function(data3, menu3)
												menu3.close()

												TriggerEvent('skinchanger:getSkin', function(skin)
													TriggerServerEvent('esx_clotheshop:saveOutfit', data3.value, skin)
												end)

												exports.pNotify:SendNotification({text = _U('saved_outfit'), type = "success", timeout = 4000})
											end, function(data3, menu3)
												menu3.close()
											end)
										end
									end)
								end
							end)
						end
					else
						ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin)
							TriggerEvent('skinchanger:loadSkin', skin)
						end)

						exports.pNotify:SendNotification({text = _U('not_enough_money'), type = "error", timeout = 4000})
					end
				end, IsBarbar)
			elseif data.current.value == 'no' then
				ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin)
					TriggerEvent('skinchanger:loadSkin', skin)
				end)
			end

			CurrentAction     = menu_type
			CurrentActionMsg  = _U('press_menu')
			CurrentActionData = {}
		end, function(data, menu)
			ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin)
				TriggerEvent('skinchanger:loadSkin', skin)
			end)
			menu.close()

			CurrentAction     = menu_type
			CurrentActionMsg  = _U('press_menu')
			CurrentActionData = {}
		end)

	end, function(data, menu)
		ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin)
			TriggerEvent('skinchanger:loadSkin', skin)
		end)
		menu.close()

		CurrentAction     = menu_type
		CurrentActionMsg  = _U('press_menu')
		CurrentActionData = {}
	end, MenuItems)

end

AddEventHandler('esx_clotheshop:hasEnteredMarker', function(zone)
print(Config.Zones[zone].stype)
	if Config.Zones[zone].stype == 'barber' then
		CurrentAction     = 'barbar_menu'
		CurrentActionMsg  = _U('press_menu')
		CurrentActionData = {}
	else
		CurrentAction     = 'shop_menu'
		CurrentActionMsg  = _U('press_menu')
		CurrentActionData = {}
	end
		
	if CurrentActionMsg ~= nil then
		exports.pNotify:SendNotification({text = CurrentActionMsg, type = "info", timeout = 3000})
	end
end)

AddEventHandler('esx_clotheshop:hasExitedMarker', function(zone)
	ESX.UI.Menu.CloseAll()
	CurrentAction = nil

	if not HasPaid then
		ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin)
			TriggerEvent('skinchanger:loadSkin', skin)
		end)
	end
end)

-- Create Blips
Citizen.CreateThread(function()
	for i=1, #Config.Shops, 1 do
		if Config.Shops[i].stype == 'cloth' then
			local blip = AddBlipForCoord(Config.Shops[i].x, Config.Shops[i].y, Config.Shops[i].z)

			SetBlipSprite (blip, 366)
			SetBlipDisplay(blip, 4)
			SetBlipScale  (blip, 0.7)
			SetBlipColour (blip, 61)
			SetBlipAsShortRange(blip, true)

			BeginTextCommandSetBlipName("STRING")
			AddTextComponentString(_U('clothes'))
			EndTextCommandSetBlipName(blip)
		else
			local blip = AddBlipForCoord(Config.Shops[i].x, Config.Shops[i].y, Config.Shops[i].z)

			SetBlipSprite (blip, 71)
			SetBlipDisplay(blip, 4)
			SetBlipScale  (blip, 0.8)
			SetBlipColour (blip, 48)
			SetBlipAsShortRange(blip, true)

			BeginTextCommandSetBlipName("STRING")
			AddTextComponentString(_U('barber_blip'))
			EndTextCommandSetBlipName(blip)	
		end
	end
end)

-- Display markers
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(1)
		local letSleep = true
		local isInMarker  = false
		local currentZone = nil
		local coords = GetEntityCoords(PlayerPedId())

		for k,v in pairs(Config.Zones) do
			if(v.Type ~= -1 and GetDistanceBetweenCoords(coords, v.Pos.x, v.Pos.y, v.Pos.z, true) < Config.DrawDistance) then
				letSleep = false
				DrawMarker(v.Type, v.Pos.x, v.Pos.y, v.Pos.z, 0.0, 0.0, 0.0, 0, 0.0, 0.0, v.Size.x, v.Size.y, v.Size.z, v.Color.r, v.Color.g, v.Color.b, 100, false, true, 2, false, false, false, false)
				
				if(GetDistanceBetweenCoords(coords, v.Pos.x, v.Pos.y, v.Pos.z, true) < v.Size.x) then
					isInMarker  = true
					currentZone = k
				end
			end
		end
		
		if (isInMarker and not HasAlreadyEnteredMarker) or (isInMarker and LastZone ~= currentZone) then
			HasAlreadyEnteredMarker = true
			LastZone                = currentZone
			TriggerEvent('esx_clotheshop:hasEnteredMarker', currentZone)
		end

		if not isInMarker and HasAlreadyEnteredMarker then
			HasAlreadyEnteredMarker = false
			TriggerEvent('esx_clotheshop:hasExitedMarker', LastZone)
		end
		
		if letSleep then
			Wait(10000)
		end
	end
end)

RegisterNetEvent('master_keymap:e')
AddEventHandler('master_keymap:e', function() 
	if CurrentAction ~= nil then
		if CurrentAction == 'shop_menu' then
			OpenShopMenu(false)
		elseif CurrentAction == 'barbar_menu' then
			OpenShopMenu(true)
		end
		CurrentAction = nil
	end
end)
