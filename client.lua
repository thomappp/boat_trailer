local ShowNotification = function(text)
    SetNotificationTextEntry("STRING")
    AddTextComponentString(text)
    DrawNotification(true, true)
end

local ShowHelpNotification = function(text)
    BeginTextCommandDisplayHelp("STRING")
    AddTextComponentSubstringPlayerName(text)
    EndTextCommandDisplayHelp(0, false, true, -1)
end

local CanUse = function()

    local PlayerPed = PlayerPedId()
    local PlayerVehicle = GetVehiclePedIsIn(PlayerPed, false)

    if PlayerVehicle == 0 then
        return false, 0, 0, nil
    elseif GetPedInVehicleSeat(PlayerVehicle, -1) ~= PlayerPed then
        return false, 0, 0, nil
    elseif GetVehicleClass(PlayerVehicle) ~= 14 then
        return false, 0, 0, nil
    else

        local Vehicles = GetGamePool("CVehicle")

        for i = 1, #Vehicles do 
            local Vehicle = Vehicles[i]
    
            local VehicleCoords = GetEntityCoords(Vehicle)
            local PlayerCoords = GetEntityCoords(PlayerPedId())
            local Distance = GetDistanceBetweenCoords(PlayerCoords, VehicleCoords, true)
            local VehicleModel = GetEntityModel(Vehicle)
            local VehicleLabel = GetDisplayNameFromVehicleModel(GetEntityModel(PlayerVehicle))

            if Distance < 3.0 and (VehicleModel == GetHashKey(Config.TrailerName)) then
                return true, Vehicle, PlayerVehicle, VehicleLabel
            end
        end

        return false
    end
end

CreateThread(function()
    while true do
        local PlayerWait = 1000

        local CanEnter, Trailer, Boat, VehicleLabel = CanUse()

        if CanEnter then
            PlayerWait = 5

            if IsEntityAttachedToEntity(Boat, Trailer) then
                ShowHelpNotification(("Appuyez sur %s pour décrocher le bateau sur la remorque."):format(Config.ControlName))

                if IsControlJustReleased(0, Config.ControlId) then
                    DetachEntity(Boat, true, true)
                    ShowNotification("~g~Vous avez décroché le bateau de la remorque.")
                end
            else
                ShowHelpNotification(("Appuyez sur %s pour accrocher le bateau sur la remorque."):format(Config.ControlName))

                if IsControlJustReleased(0, Config.ControlId) then
                    local Offset = Config.Boats[VehicleLabel]

                    if Offset then
                        AttachVehicleOnToTrailer(Boat, Trailer, Offset.x, Offset.y, Offset.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, false)
                        ShowNotification("~g~Vous avez accroché le bateau sur la remorque.")
                    else
                        ShowNotification("~r~Vous ne pouvez pas accrocher ce bateau.")
                    end
                end
            end
        end

        Wait(PlayerWait)
    end
end)