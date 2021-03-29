ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

RegisterServerEvent('esx_clotheshop:saveOutfit')
AddEventHandler('esx_clotheshop:saveOutfit', function(label, skin)
	ESX.RunCustomFunction("anti_ddos", source, 'esx_clotheshop:saveOutfit', {label = label, skin = skin})
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)

	TriggerEvent('esx_datastore:getDataStore', 'property', xPlayer.identifier, function(store)
		local dressing = store.get('dressing')

		if dressing == nil then
			dressing = {}
		end

		table.insert(dressing, {
			label = label,
			skin  = skin
		})

		store.set('dressing', dressing)
	end)
end)

ESX.RegisterServerCallback('esx_clotheshop:buyClothes', function(source, cb, SType)
	ESX.RunCustomFunction("anti_ddos", source, 'esx_clotheshop:buyClothes', {SType = SType})
	local xPlayer = ESX.GetPlayerFromId(source)
	
	if SType == 1 then
		if xPlayer.getMoney() >= Config.BarbarPrice then
			xPlayer.removeMoney(Config.BarbarPrice)
			TriggerClientEvent("pNotify:SendNotification", source, { text = _U('you_paid', Config.BarbarPrice), type = "success", timeout = 5000, layout = "bottomCenter"})
			cb(true)
		else
			cb(false)
		end
	elseif SType == 2 then
		if xPlayer.getMoney() >= Config.MaskPrice then
			xPlayer.removeMoney(Config.MaskPrice)
			TriggerClientEvent("pNotify:SendNotification", source, { text = _U('you_paid', Config.MaskPrice), type = "success", timeout = 5000, layout = "bottomCenter"})
			cb(true)
		else
			cb(false)
		end
	else
		if xPlayer.getMoney() >= Config.ClothPrice then
			xPlayer.removeMoney(Config.ClothPrice)
			TriggerClientEvent("pNotify:SendNotification", source, { text = _U('you_paid', Config.ClothPrice), type = "success", timeout = 5000, layout = "bottomCenter"})
			cb(true)
		else
			cb(false)
		end
	end
end)

ESX.RegisterServerCallback('esx_clotheshop:checkPropertyDataStore', function(source, cb)
	ESX.RunCustomFunction("anti_ddos", source, 'esx_clotheshop:checkPropertyDataStore', {})
	local xPlayer = ESX.GetPlayerFromId(source)
	local foundStore = false
	
	if xPlayer == nil then
		return
	end
	
	TriggerEvent('esx_datastore:getDataStore', 'property', xPlayer.identifier, function(store)
		foundStore = true
	end)

	cb(foundStore)
end)
