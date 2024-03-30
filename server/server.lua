local playerInjury = {}

function GetCharsInjuries(source)
    return playerInjury[source]
end

RegisterServerEvent('ohio_wounds:SyncWounds')
AddEventHandler('ohio_wounds:SyncWounds', function(data)
    playerInjury[source] = data
end)

AddEventHandler('onResourceStart', function(resourceName)
	if (GetCurrentResourceName() ~= resourceName) then
		return
	end
	print('^8 '..resourceName..'^2 succesfully loaded^7')
end)