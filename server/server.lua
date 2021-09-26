ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

RegisterServerEvent('mume_hunting:giveMeat')
AddEventHandler('mume_hunting:giveMeat', function(amount)
    local xPlayer = ESX.GetPlayerFromId(source)

    if amount >= 2 then
        xPlayer.addInventoryItem('meat', 1)
    elseif amount >= 8 then
        xPlayer.addInventoryItem('meat', 2)
    elseif amount >= 14 then
        xPlayer.addInventoryItem('meat', 3)
    end
end)

RegisterServerEvent('mume_hunting:sellMeat')
AddEventHandler('mume_hunting:sellMeat', function()
    local xPlayer = ESX.GetPlayerFromId(source)

    local price = 125

    local meatCount = xPlayer.getInventoryItem('meat').count

    if meatCount > 0 then
        xPlayer.addMoney(meatCount * price)

        xPlayer.removeInventoryItem('meat', meatCount)
        xPlayer.triggerEvent('esx:giveAnimation')
        TriggerClientEvent('esx:showNotification', xPlayer.source, 'You earned $' .. price * meatCount .. ' by selling ' .. meatCount .. ' pieces of meat')
    else
        TriggerClientEvent('esx:showNotification', xPlayer.source, 'You don\'t have any meat. Kill some deer to obtain meat.')
    end
        
end)

ESX.RegisterServerCallback("mume_hunting-ip:checkMeat", function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)

    local meatCount = xPlayer.getInventoryItem('meat').count

    if meatCount > 0 then
        cb(true)
    else
        cb(false)
    end
    
end)