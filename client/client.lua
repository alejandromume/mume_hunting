ESX = nil
local entities = {} 

Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Citizen.Wait(0)
    end
end)

local hasStarted = false
local isInHuntingZone = false
local kills = 0

Citizen.CreateThread(function()

    for _, info in pairs(Config.Markers) do
      blip = AddBlipForCoord(-1133.40, 4948.479, 222.26)
      SetBlipSprite(blip, info.Blip.sprite)
      SetBlipDisplay(blip, 4)
      SetBlipScale(blip, info.Blip.scale)
      SetBlipColour(blip, info.Blip.color)
      SetBlipAsShortRange(blip, true)
	  BeginTextCommandSetBlipName("STRING")
      AddTextComponentString(info.Blip.name)
      EndTextCommandSetBlipName(blip)
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)

        for _,v in pairs(Config.Markers) do

            local dist = #(GetEntityCoords(PlayerPedId()) - vec3(v.Pos.x, v.Pos.y, v.Pos.z))
            local dist2 = #(GetEntityCoords(PlayerPedId()) - vec3(v.HuntingZone.coords.x, v.HuntingZone.coords.y, v.HuntingZone.coords.z))
            local dist3 = #(GetEntityCoords(PlayerPedId()) - vec3(v.SellMeat.coords.x, v.SellMeat.coords.y, v.SellMeat.coords.z))
            
            if dist <= v.Distance then
                
                DrawTxt(vec3(v.Pos.x, v.Pos.y, v.Pos.z + 0.4), Locale["hunting_equipment"], 1.0, 4)

                if IsControlJustPressed(1, 38) then

                    if hasStarted then
                        hasStarted = false
                        RemoveWeaponFromPed(PlayerPedId(), "weapon_musket")
                        RemoveWeaponFromPed(PlayerPedId(), "weapon_knife")
                        
                    else
                        hasStarted = true
                    
                        GiveWeaponToPed(PlayerPedId(), "weapon_musket", 200, false, true)
                        GiveWeaponToPed(PlayerPedId(), "weapon_knife", 1, false, false)
    
                        ESX.ShowNotification(Locale["gps"])
    
                        blipZone = AddBlipForCoord(v.HuntingZone.coords)
                        SetBlipSprite(blipZone, 1)
                        SetBlipRoute(blipZone,  true)
    
                        if not IsPositionOccupied(v.Vehicle.coords, 1.5, false, true, false, false, false, 0, false) then
                            ESX.Game.SpawnVehicle(v.Vehicle.model, v.Vehicle.coords, v.Vehicle.heading)
                        else
                        
                            ESX.ShowNotification(Locale["car_exists"])
                            
                        end  
                    end
                                     
                end
            end

            if dist2 <= 12.0 and hasStarted then

                RemoveBlip(blipZone)

                Z = v.HuntingZone.coords.z + 999.0
                ground, posZ = GetGroundZFor_3dCoord(v.HuntingZone.coords.x + .0, v.HuntingZone.coords.y + .0, Z,1)
                
                RequestModel("a_c_deer")
                while not HasModelLoaded("a_c_deer") or not HasCollisionForModelLoaded("a_c_deer") do
                    Wait(1)
                end
                
                DrawTxt(vec3(v.HuntingZone.coords.x, v.HuntingZone.coords.y, v.HuntingZone.coords.z + 0.4), Locale["start_hunting"], 2.0, 4)

                _sleep = 0

                pedCoords = GetEntityCoords(PlayerPedId())

                if IsControlJustPressed(1, 38) then

                    isInHuntingZone = true
                    ESX.ShowNotification("Find all possible deer and kill them with the weapon")
                    
                    for i=1,30 do
                        Wait(0)
                        
                        ped = CreatePed(28, "a_c_deer", v.HuntingZone.coords.x + math.random(-70,70), v.HuntingZone.coords.y + math.random(-70,70), posZ, math.random(0,359)+.0 , true, true)
                        SetEntityAsMissionEntity(ped, true, true)
                        TaskWanderStandard(ped, 10.0, 10)
                        SetModelAsNoLongerNeeded(ped)
                        SetPedAsNoLongerNeeded(ped)
                        
                        table.insert(entities, ped)

                        Wait(500)
                    end
                                                      
                end
            end

            if dist3 <= v.Distance then

                DrawTxt(vec3(v.SellMeat.coords.x, v.SellMeat.coords.y, v.SellMeat.coords.z + 0.4), Locale["sell_meat"], 1.0, 4)

                if IsControlJustPressed(1, 38) then
                    ESX.TriggerServerCallback("mume_hunting-ip:checkMeat", function(haveMeat)

                        if haveMeat then
                            TriggerServerEvent('mume_hunting:sellMeat')
                        else
                            ESX.ShowNotification(Locale["no_meat"])
                        end

                    end)
                                                      
                end

            end

        end

    end
end)

Citizen.CreateThread(function()
    while true do
        Wait(0)
        for i, ped in pairs(entities) do
            local pedCoords = GetEntityCoords(ped)
            local dist = #(GetEntityCoords(PlayerPedId()) - vec3(pedCoords.x, pedCoords.y, pedCoords.z))

            if dist <= 2.0 then
                if IsPedFatallyInjured(ped) or IsPedDeadOrDying(ped, true) then
                    
                    DrawText3D(GetEntityCoords(ped), Locale["kill"] ,247,124,24)

                    if IsControlJustPressed(1, 38) then

                        kills = kills + 1

                        local amount = math.random(10, 160) / 10
                        
                        TriggerServerEvent('mume_hunting:giveMeat', amount)

                        table.remove(entities, i)

                        LoadAnimDict('amb@medic@standing@kneel@base')
	                    LoadAnimDict('anim@gangops@facility@servers@bodysearch@')

                        TaskPlayAnim(PlayerPedId(), "amb@medic@standing@kneel@base" ,"base" ,8.0, -8.0, -1, 1, 0, false, false, false )
                        TaskPlayAnim(PlayerPedId(), "anim@gangops@facility@servers@bodysearch@" ,"player_search" ,8.0, -8.0, -1, 48, 0, false, false, false )

                        Citizen.Wait(3000)

                        ClearPedTasksImmediately(PlayerPedId())

                        DeleteEntity(ped)                        
                    end
                end
            end 
        end
    end
end)

RegisterNetEvent('esx:giveAnimation')
AddEventHandler('esx:giveAnimation', function()
	local playerPed = PlayerPedId()
	LoadAnimDict('mp_common')
	TaskPlayAnim(playerPed, "mp_common", "givetake1_a", 8.0, 8.0, 2000, 50, 0, false, false, false)
end)

Citizen.CreateThread(function()
    RequestModel(GetHashKey("cs_hunter"))
	
    while not HasModelLoaded(GetHashKey("cs_hunter")) do
        Wait(1)
    end

    RequestModel(GetHashKey("csb_chef"))
	
    while not HasModelLoaded(GetHashKey("csb_chef")) do
        Wait(1)
    end

    for _,v in pairs(Config.Markers) do
        
        local npc = CreatePed(28, "cs_hunter", v.Peds[0].coords.x, v.Peds[0].coords.y, v.Peds[0].coords.z, v.Peds[0].heading , false, true)
        FreezeEntityPosition(npc, true)
        SetEntityInvincible(npc, true)
        SetBlockingOfNonTemporaryEvents(npc, true)

        local npc2 = CreatePed(28, "cs_hunter", v.Peds[1].coords.x, v.Peds[1].coords.y, v.Peds[1].coords.z, v.Peds[1].heading , false, true)
        FreezeEntityPosition(npc2, true)
        SetEntityInvincible(npc2, true)
        SetBlockingOfNonTemporaryEvents(npc2, true)

        local npc3 = CreatePed(28, "csb_chef", v.Peds[2].coords.x, v.Peds[2].coords.y, v.Peds[2].coords.z, v.Peds[2].heading , false, true)
        FreezeEntityPosition(npc3, true)
        SetEntityInvincible(npc3, true)
        SetBlockingOfNonTemporaryEvents(npc3, true)

    end
end)

function LoadAnimDict(dict)
    while (not HasAnimDictLoaded(dict)) do
        RequestAnimDict(dict)
        Citizen.Wait(10)
    end    
end

function DrawTxt(coords, text, size, font)
    local coords = vector3(coords.x, coords.y, coords.z)

    local camCoords = GetGameplayCamCoords()
    local distance = #(coords - camCoords)

    if not size then size = 1 end
    if not font then font = 0 end

    local scale = (size / distance) * 2
    local fov = (1 / GetGameplayCamFov()) * 100
    scale = scale * fov

    SetTextScale(0.0 * scale, 0.55 * scale)
    SetTextFont(font)
    SetTextColour(255, 255, 255, 215)
    SetTextDropshadow(0, 0, 0, 0, 255)
    SetTextEdge(2, 0, 0, 0, 150)
    SetTextDropShadow()
    SetTextOutline()
    SetTextEntry("STRING")
    SetTextCentre(true)

    SetDrawOrigin(coords, 0)
    BeginTextCommandDisplayText('STRING')
    AddTextComponentSubstringPlayerName(text)
    EndTextCommandDisplayText(0.0, 0.0)
    ClearDrawOrigin()
end

function DrawText3D(position, text, r,g,b) 
    local onScreen,_x,_y=World3dToScreen2d(position.x,position.y,position.z+1)
    local dist = #(GetGameplayCamCoords()-position)
 
    local scale = (1/dist)*2
    local fov = (1/GetGameplayCamFov())*100
    local scale = scale*fov
   
    if onScreen then
        if not useCustomScale then
            SetTextScale(0.0*scale, 0.55*scale)
        else 
            SetTextScale(0.0*scale, customScale)
        end
        SetTextFont(0)
        SetTextProportional(1)
        SetTextColour(r, g, b, 255)
        SetTextDropshadow(0, 0, 0, 0, 255)
        SetTextEdge(2, 0, 0, 0, 150)
        SetTextDropShadow()
        SetTextOutline()
        SetTextEntry("STRING")
        SetTextCentre(1)
        AddTextComponentString(text)
        DrawText(_x,_y)
    end
end
