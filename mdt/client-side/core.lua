-----------------------------------------------------------------------------------------------------------------------------------------
-- VRP
-----------------------------------------------------------------------------------------------------------------------------------------
local Tunnel = module("vrp","lib/Tunnel")
vRPS = Tunnel.getInterface("vRP")
-----------------------------------------------------------------------------------------------------------------------------------------
-- CONNECTION
-----------------------------------------------------------------------------------------------------------------------------------------
Creative = {}
Tunnel.bindInterface("mdt",Creative)
vSERVER = Tunnel.getInterface("mdt")
-----------------------------------------------------------------------------------------------------------------------------------------
-- MDT:OPENED
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("mdt:Opened")
AddEventHandler("mdt:Opened",function(Group)
	local Departmenty = vSERVER.Department(Group)
	if Departmenty then
		SetNuiFocus(true,true)
		TransitionToBlurred(1000)
		SetCursorLocation(0.5,0.5)
		TriggerEvent('dynamic:Close')
		TriggerEvent("hud:Active",false)
		SendNUIMessage({ Action = "Open" })
	end
end)

RegisterCommand('mdt',function(source,Message)
	local Passport = vRP.Passport(source)
	local Departmenty = vSERVER.Department(Group)
	if Departmenty then
		SetNuiFocus(true,true)
		TransitionToBlurred(1000)
		SetCursorLocation(0.5,0.5)
		TriggerEvent('dynamic:Close')
		TriggerEvent("hud:Active",false)
		SendNUIMessage({ Action = "Open" })
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- CLOSE
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("Close",function(Data,Callback)
	SetNuiFocus(false,false)
	SetCursorLocation(0.5,0.5)
	TransitionFromBlurred(1000)
	TriggerEvent("hud:Active",true)

	Callback("Ok")
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- CONFIG
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("Config",function(Data,Callback)
	Callback({
		["MaxReductionFine"] = Config.MaxReductionFine,
		["MaxReductionArrest"] = Config.MaxReductionArrest,
		["OperationsLocations"] = Config.OperationsLocations
	})
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- PENALCODE
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("PenalCode",function(Data,Callback)
	Callback(vSERVER.PenalCode(Data and Data.Mode))
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- CREATEPENALCODE
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("CreatePenalCode",function(Data,Callback)
	Callback(vSERVER.CreatePenalCode(Data.Mode,Data.Data))
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- UPDATEPENALCODE
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("UpdatePenalCode",function(Data,Callback)
	Callback(vSERVER.UpdatePenalCode(Data.Id,Data.Mode,Data.Data))
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- DESTROYPENALCODE
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("DestroyPenalCode",function(Data,Callback)
	Callback(vSERVER.DestroyPenalCode(Data.Id,Data.Mode))
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- ORDERPENALCODE
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("OrderPenalCode",function(Data,Callback)
	Callback(vSERVER.OrderPenalCode(Data.Id,Data.Mode,Data.Direction,Data.Section))
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- PLAYER
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("Player",function(Data,Callback)
	Callback(vSERVER.Player())
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- HOME
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("Home",function(Data,Callback)
	Callback(vSERVER.Home())
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- UPDATEBOARD
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("UpdateBoard",function(Data,Callback)
	Callback(vSERVER.UpdateBoard(Data.Title,Data.Description))
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- SEARCHOFFICER
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("SearchOfficer",function(Data,Callback)
	Callback(vSERVER.SearchOfficer(Data.Search,Data.Division))
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- SEARCHUSER
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("SearchUser",function(Data,Callback)
	Callback(vSERVER.SearchUser(Data.Search,Data.Select))
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- USER
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("User",function(Data,Callback)
	Callback(vSERVER.User(Data.Passport))
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- AVATAR
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("Avatar",function(Data,Callback)
	SetNuiFocus(false,false)
	SetCursorLocation(0.5,0.5)
	TransitionFromBlurred(1000)

	CreateThread(function()
		local Printing = false
		local Passport = Data.Passport
		local Camera = GetFollowPedCamViewMode()
		TriggerEvent("inventory:Buttons",{
			{ "E","Tirar Foto" },
			{ "H","Cancelar" }
		})

		SetFollowPedCamViewMode(4)

		while true do
			Wait(1)

			if GetFollowPedCamViewMode() ~= 4 then
				SetFollowPedCamViewMode(4)
			end

			if IsControlJustPressed(1,38) and not Printing then
				Printing = true

				local Webhook = Config.Upload.Key
				if Config.Upload.Mode == "Fivemanage" then
					Webhook = "https://api.fivemanage.com/api/image?apiKey="..Config.Upload.Key
				end

				exports["screenshot-basic"]:requestScreenshotUpload(Webhook,"files[]",{ quality = 0.75 },function(Data)
					if vRPS.UploadAvatar(Passport,json.decode(Data).attachments[1].url) then
						SendNUIMessage({ Action = "User", Payload = Passport })
						TriggerEvent("inventory:CloseButtons")
						SetFollowPedCamViewMode(Camera)
						SetCursorLocation(0.5,0.5)
						TransitionToBlurred(1000)
						SetNuiFocus(true,true)
					end
				end)

				break
			end

			if IsControlJustPressed(1,74) then
				TriggerEvent("inventory:CloseButtons")
				SetFollowPedCamViewMode(Camera)

				break
			end
		end
	end)

	Callback("Ok")
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- FIREARMS
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("Firearms",function(Data,Callback)
	Callback(vSERVER.Firearms(Data.Passport))
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- FLYINGARMS
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("Flyingarms",function(Data,Callback)
	Callback(vSERVER.Flyingarms(Data.Passport))
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- CLEARRECORD
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("ClearRecord",function(Data,Callback)
	Callback(vSERVER.ClearRecord(Data))
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- CLEARRECORDS
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("ClearRecords",function(Data,Callback)
	Callback(vSERVER.ClearRecords(Data.Passport))
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- RECORD
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("Record",function(Data,Callback)
	Callback(vSERVER.Record(Data))
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- PATROL
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("Patrol",function(Data,Callback)
	Callback(vSERVER.Patrol())
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- GETPATROL
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("GetPatrol",function(Data,Callback)
	Callback(vSERVER.GetPatrol(Data.Id))
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- CREATEPATROL
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("CreatePatrol",function(Data,Callback)
	Callback(vSERVER.CreatePatrol(Data.Car,Data.Unit,Data.Officers))
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- UPDATEPATROL
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("UpdatePatrol",function(Data,Callback)
	Callback(vSERVER.UpdatePatrol(Data.Id,Data.Car,Data.Unit,Data.Officers))
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- DESTROYPATROL
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("DestroyPatrol",function(Data,Callback)
	Callback(vSERVER.DestroyPatrol(Data.Id))
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- OPERATIONS
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("Operations",function(Data,Callback)
	Callback(vSERVER.Operations())
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- GETOPERATION
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("GetOperation",function(Data,Callback)
	Callback(vSERVER.GetOperation(Data.Id))
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- CREATEOPERATION
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("CreateOperation",function(Data,Callback)
	Callback(vSERVER.CreateOperation(Data))
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- UPDATEOPERATION
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("UpdateOperation",function(Data,Callback)
	Callback(vSERVER.UpdateOperation(Data.Id,Data.Location,Data.Radio))
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- DESTROYOPERATION
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("DestroyOperation",function(Data,Callback)
	Callback(vSERVER.DestroyOperation(Data.Id))
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- ESCALATEDOPERATION
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("EscalatedOperation",function(Data,Callback)
	Callback(vSERVER.EscalatedOperation(Data.Id,Data.Mode,Data.Passport))
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- ARRESTRECORDS
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("ArrestRecords",function(Data,Callback)
	Callback(vSERVER.ArrestRecords())
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- ARREST
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("Arrest",function(Data,Callback)
	Callback(vSERVER.Arrest(Data))
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- FINE
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("Fine",function(Data,Callback)
	Callback(vSERVER.Fine(Data))
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- WARNING
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("Warning",function(Data,Callback)
	Callback(vSERVER.Warning(Data))
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- POLICEREPORTS
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("PoliceReports",function(Data,Callback)
	Callback(vSERVER.PoliceReports())
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- GETPOLICEREPORT
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("GetPoliceReport",function(Data,Callback)
	Callback(vSERVER.GetPoliceReport(Data.Id))
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- CREATEPOLICEREPORT
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("CreatePoliceReport",function(Data,Callback)
	Callback(vSERVER.CreatePoliceReport(Data))
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- UPDATEPOLICEREPORT
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("UpdatePoliceReport",function(Data,Callback)
	Callback(vSERVER.UpdatePoliceReport(Data))
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- ARCHIVEPOLICEREPORT
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("ArchivePoliceReport",function(Data,Callback)
	Callback(vSERVER.ArchivePoliceReport(Data.Id))
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- WANTED
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("Wanted",function(Data,Callback)
	Callback(vSERVER.Wanted())
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- GETWANTED
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("GetWanted",function(Data,Callback)
	Callback(vSERVER.GetWanted(Data.Id))
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- CREATEWANTED
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("CreateWanted",function(Data,Callback)
	Callback(vSERVER.CreateWanted(Data))
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- UPDATEWANTED
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("UpdateWanted",function(Data,Callback)
	Callback(vSERVER.UpdateWanted(Data))
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- DESTROYWANTED
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("DestroyWanted",function(Data,Callback)
	Callback(vSERVER.DestroyWanted(Data.Id))
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- SEIZEDVEHICLES
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("SeizedVehicles",function(Data,Callback)
	Callback(vSERVER.SeizedVehicles())
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- MDT:VEHICLE
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("mdt:Vehicle")
AddEventHandler("mdt:Vehicle",function(Passport,Name,Plate,Model)
	CreateThread(function()
		local Printing = false
		local Ped = PlayerPedId()
		local Coords = GetEntityCoords(Ped)
		local Camera = GetFollowPedCamViewMode()
		local MinRoad = GetStreetNameAtCoord(Coords["x"],Coords["y"],Coords["z"])
		local FullRoad = GetStreetNameFromHashKey(MinRoad)

		TriggerEvent("inventory:Buttons",{
			{ "E","Tirar Foto" },
			{ "H","Cancelar" }
		})

		SetFollowPedCamViewMode(4)

		while true do
			Wait(1)

			if GetFollowPedCamViewMode() ~= 4 then
				SetFollowPedCamViewMode(4)
			end

			if IsControlJustPressed(1,38) and not Printing then
				Printing = true

				local Webhook = Config.Upload.Key
				if Config.Upload.Mode == "Fivemanage" then
					Webhook = "https://api.fivemanage.com/api/image?apiKey="..Config.Upload.Key
				end

				exports["screenshot-basic"]:requestScreenshotUpload(Webhook,"files[]",{ quality = 0.75 },function(Data)
					SendNUIMessage({ Action = "SeizedVehicle", Payload = { VehicleName(Model),Plate,Passport,Name,FullRoad,json.decode(Data).attachments[1].url } })
					TriggerEvent("inventory:CloseButtons")
					SetFollowPedCamViewMode(Camera)
					SetCursorLocation(0.5,0.5)
					TransitionToBlurred(1000)
					SetNuiFocus(true,true)
				end)

				break
			end

			if IsControlJustPressed(1,74) then
				TriggerEvent("inventory:CloseButtons")
				SetFollowPedCamViewMode(Camera)

				break
			end
		end
	end)
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- CREATESEIZEDVEHICLE
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("CreateSeizedVehicle",function(Data,Callback)
	SetNuiFocus(false,false)
	SetCursorLocation(0.5,0.5)
	TransitionFromBlurred(1000)
	TriggerEvent("hud:Active",true)

	Callback(vSERVER.CreateSeizedVehicle(Data))
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- MEDALS
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("Medals",function(Data,Callback)
	Callback(vSERVER.Medals())
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- GETMEDAL
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("GetMedal",function(Data,Callback)
	Callback(vSERVER.GetMedal(Data.Id))
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- CREATEMEDAL
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("CreateMedal",function(Data,Callback)
	Callback(vSERVER.CreateMedal(Data))
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- UPDATEMEDAL
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("UpdateMedal",function(Data,Callback)
	Callback(vSERVER.UpdateMedal(Data))
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- ASSIGNMEDAL
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("AssignMedal",function(Data,Callback)
	Callback(vSERVER.AssignMedal(Data))
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- REMOVEMEDAL
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("RemoveMedal",function(Data,Callback)
	Callback(vSERVER.RemoveMedal(Data))
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- DESTROYMEDAL
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("DestroyMedal",function(Data,Callback)
	Callback(vSERVER.DestroyMedal(Data.Id))
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- UNITS
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("Units",function(Data,Callback)
	Callback(vSERVER.Units(Data.Select))
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- GETUNIT
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("GetUnit",function(Data,Callback)
	Callback(vSERVER.GetUnit(Data.Id))
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- CREATEUNIT
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("CreateUnit",function(Data,Callback)
	Callback(vSERVER.CreateUnit(Data))
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- UPDATEUNIT
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("UpdateUnit",function(Data,Callback)
	Callback(vSERVER.UpdateUnit(Data))
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- ASSIGNUNIT
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("AssignUnit",function(Data,Callback)
	Callback(vSERVER.AssignUnit(Data))
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- REMOVEUNIT
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("RemoveUnit",function(Data,Callback)
	Callback(vSERVER.RemoveUnit(Data))
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- DESTROYUNIT
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("DestroyUnit",function(Data,Callback)
	Callback(vSERVER.DestroyUnit(Data.Id))
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- OFFICERS
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("Officers",function(Data,Callback)
	Callback(vSERVER.Officers(Data.Management,Data.Ranking))
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- CREATEOFFICER
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("CreateOfficer",function(Data,Callback)
	Callback(vSERVER.CreateOfficer(Data))
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- HIERARCHYOFFICER
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("HierarchyOfficer",function(Data,Callback)
	Callback(vSERVER.HierarchyOfficer(Data))
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- DISMISSOFFICER
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("DismissOfficer",function(Data,Callback)
	Callback(vSERVER.DismissOfficer(Data))
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- BANK
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("Bank",function(Data,Callback)
	Callback(vSERVER.Bank())
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- DEPOSITBANK
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("DepositBank",function(Data,Callback)
	Callback(vSERVER.DepositBank(Data.Value))
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- WITHDRAWBANK
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("WithdrawBank",function(Data,Callback)
	Callback(vSERVER.WithdrawBank(Data.Value))
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- TRANSFERBANK
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("TransferBank",function(Data,Callback)
	Callback(vSERVER.TransferBank(Data.Passport,Data.Value))
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- MDT:REFRESH
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("mdt:Refresh")
AddEventHandler("mdt:Refresh",function(Name)
	SendNUIMessage({ Action = Name })
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- MDT:NOTIFY
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("mdt:Notify")
AddEventHandler("mdt:Notify",function(Title,Message,Type)
	SendNUIMessage({ Action = "Notify", Payload = { Title,Message,Type } })
end)