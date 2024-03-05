local DataStoreService = game:GetService("DataStoreService")
local myDataStore = DataStoreService:GetDataStore("TestDataStore1")

local HttpService = game:GetService("HttpService")

local Artifacts = require(game.ReplicatedStorage.ModuleScripts.Artifacts)
local Materials = require(game.ReplicatedStorage.ModuleScripts.Materials)

local Portals = game.Workspace.Portals
local PlayerPortals = Portals.PlayerPortals
local PlayerBases = game.Workspace.PlayerBases

local BasePortalColour = Color3.fromRGB(99, 95, 98)

-- Stats
local NewPlayerStats = {
	Searching = false;
	SearchCoolDown = 0.1;
	Biome = "Plains";
	BiomesUnlocked = {"Plains"};
	UnlockedPages = 1;
	UnlockedPedestals = 2;
}
-- Stats

local NewPlayerBase = {
	PortalColour = {255, 255, 255};
	BaseHousing = "Castle";
	BaseSurrounding = "Plains";
}

local NewPlayerSettings = {

}

game.Players.PlayerAdded:Connect(function(Player)
	
	-- Other Stuff
	for i, v in pairs(Materials) do
		local NewMaterial = game.ReplicatedStorage.GUIStuff.Material:Clone()
		NewMaterial.Parent = Player.PlayerGui:WaitForChild("MaterialInventory").Holder.Materials
		NewMaterial.Name = i
		NewMaterial.MaterialName.Text = i
		NewMaterial.MaterialAmount.Text = 0
		NewMaterial.LayoutOrder = v.Index
		if v.ImageID ~= nil then
			NewMaterial.MaterialImage.Image = v.ImageID
		end
	end
	
	-- Artifact Inventory
	local MaxPages = 5
	
	for Count = 1, MaxPages do -- 5 is the max amount of pages a player can have
		local NewPage = game.ReplicatedStorage.GUIStuff.Page:Clone()
		NewPage.Name = "Page"..Count
		NewPage.Parent = Player.PlayerGui:WaitForChild("ArtifactInventory").Holder.Artifacts.ArtifactsHolder
		
		local NewPage = game.ReplicatedStorage.GUIStuff.Page:Clone()
		NewPage.Name = "Page"..Count
		NewPage.Parent = Player.PlayerGui:WaitForChild("ArtifactSelecting").Holder.Artifacts.ArtifactsHolder
	end
	for FirstCount = 1,16 do
		for SecondCount = 1, MaxPages do -- 2 is the amount of pages you want to fill
			local NewSlot = game.ReplicatedStorage.GUIStuff.Slot:Clone()
			NewSlot.Name = "P"..SecondCount.."ArtifactSlot"..FirstCount
			NewSlot.Parent = Player.PlayerGui:WaitForChild("ArtifactInventory").Holder.Artifacts.ArtifactsHolder["Page"..SecondCount]
		end
		
		for SecondCount = 1, MaxPages do -- 2 is the amount of pages you want to fill
			local NewSlot = game.ReplicatedStorage.GUIStuff.SelectingSlot:Clone()
			NewSlot.Name = "P"..SecondCount.."ArtifactSlot"..FirstCount
			NewSlot.Parent = Player.PlayerGui:WaitForChild("ArtifactSelecting").Holder.Artifacts.ArtifactsHolder["Page"..SecondCount]
		end
	end
	
	-- Other Stuff
	
	-- Data Save

	-- Inventory
	local ArtifactInventory = Instance.new("Folder")
	ArtifactInventory.Parent = Player
	ArtifactInventory.Name = "ArtifactInventory"
	-- Inventory

	-- Information
	local Information = Instance.new("Folder")
	Information.Name = "Information"
	Information.Parent = Player

	local PlayerStats = Instance.new("StringValue")
	PlayerStats.Name = "PlayerStats"
	PlayerStats.Parent = Information
	PlayerStats.Value = HttpService:JSONEncode(NewPlayerStats)
	
	local PlayerBase = Instance.new("StringValue")
	PlayerBase.Name = "PlayerBase"
	PlayerBase.Parent = Information
	PlayerBase.Value = HttpService:JSONEncode(NewPlayerBase)
	
	local TeleportedFrom = Instance.new("ObjectValue")
	TeleportedFrom.Name = "TeleportedFrom"
	TeleportedFrom.Parent = Information
	-- Information

	-- Settings
	local PlayerSettings = Instance.new("StringValue")
	PlayerSettings.Name = "PlayerSettings"
	PlayerSettings.Parent = Player
	PlayerSettings.Value = HttpService:JSONEncode(NewPlayerSettings)
	-- Settings

	local PlayerID = "Player_"..Player.UserId

	local PlayerData

	local success, errormessage = pcall(function()

		PlayerData = myDataStore:GetAsync(PlayerID)

	end)

	if success then
		if PlayerData then
			if PlayerData.PlayerStats then
				PlayerStats.Value = PlayerData.PlayerStats
			end
		end
		repeat
			wait(0.1)
		until Player.CharacterAdded

		game.ReplicatedStorage.RemoteEvents.PlayerDataLoaded:FireClient(Player)
		--game.ReplicatedStorage.BindableEvents.PlayerDataLoaded:Fire(Player)
		
		-- Player Data Loaded
		
		local NewPlayerStats = HttpService:JSONDecode(PlayerStats.Value)
		NewPlayerStats.Searching = false
		NewPlayerStats.SearchCoolDown = 0.1
		PlayerStats.Value = HttpService:JSONEncode(NewPlayerStats)
		
		local BaseStats = HttpService:JSONDecode(PlayerBase.Value)
		
		-- Player Portal
		if not PlayerPortals:FindFirstChild("PlayerPortal") then
			for i, v in pairs(PlayerBases:GetChildren()) do
				if not game.Players:FindFirstChild(v.Name) then
					v.Name = "PlayerPortal"
				end
			end
		end
		local NewPlayerPortal = PlayerPortals:FindFirstChild("PlayerPortal")
		NewPlayerPortal.Name = Player.Name
		for i, v in pairs(NewPlayerPortal.Colour:GetChildren()) do -- Change Portal Colour
			v.Color = Color3.fromRGB(unpack(BaseStats.PortalColour))
		end
		NewPlayerPortal.Portal.CanTouch = true
		for i, v in pairs(NewPlayerPortal.Portal:GetChildren()) do
			if v.Name == "SurfaceGui" then
				v.Enabled = true
			end
		end
		
		-- Player Base
		if not PlayerBases:FindFirstChild("PlayerBase") then
			for i, v in pairs(PlayerBases:GetChildren()) do
				if not game.Players:FindFirstChild(v.Name) then
					v.Name = "PlayerBase"
				end
			end
		end
		local NewPlayerBase = PlayerBases:FindFirstChild("PlayerBase")
		NewPlayerBase.Name = Player.Name
		for i, v in pairs(NewPlayerBase["Hub Portal"].Colour:GetChildren()) do -- Change Portal Colour
			v.Color = Color3.fromRGB(unpack(BaseStats.PortalColour))
		end
		
		-- Player Pedestals
		for i, v in pairs(NewPlayerBase.Pedestals:GetChildren()) do
			if string.find(v.Name, "Pedestal") then
				local PedestalNumber = tonumber(v.Name:match("%d+"))
				if PedestalNumber <= NewPlayerStats.UnlockedPedestals then
					v.Pedestal.Transparency = 0
				else
					v.Pedestal.Transparency = 1
				end
				local Artifact = Player.ArtifactInventory:FindFirstChild(v.Name)
				if Artifact then
					local ArtifactInformation = HttpService:JSONDecode(Artifact.Value)
					v.ArtifactImage.ArtifactImage.Image = ArtifactInformation.ImageID
				end
			end
		end
	else
		--Player:Kick()
	end


end)

game.Players.PlayerRemoving:Connect(function(Player)
	local PlayerID = "Player_"..Player.UserId

	local PlayerData = {

		-- Stats
		--PlayerStats = Player.Information.PlayerStats.Value;
	}

	local success, errormessage = pcall(function()
		myDataStore:SetAsync(PlayerID,PlayerData)
	end)

	if success then
		print("Data Successfully Saved")
		
		-- Player Portal
		local PlayerPortal = PlayerPortals:FindFirstChild(Player.Name)
		PlayerPortal.Name = "PlayerPortal"
		for i, v in pairs(PlayerPortal.Colour:GetChildren()) do
			v.Color = BasePortalColour
		end
		for i, v in pairs(PlayerPortal.Portal:GetChildren()) do
			if v.Name == "SurfaceGui" then
				v.Enabled = true
			end
		end
		
		-- Player Base
		local PlayerBase = PlayerBases:FindFirstChild(Player.Name)
		PlayerBase.Name = "PlayerBase"
		for i, v in pairs(PlayerBase["Hub Portal"].Colour:GetChildren()) do
			v.Color = BasePortalColour
		end
	else
		print("There Was An Error")
		warn(errormessage)
	end

end)

game.Players.PlayerAdded:Connect(function(Player)
	local DEBUG = false
	while true do
		wait(0.1)
		if DEBUG == false then
			DEBUG = true
			wait(60)
			local PlayerID = "Player_"..Player.UserId

			local PlayerData = {

				-- Stats
				PlayerStats = Player.Information.PlayerStats.Value;
			}

			local success, errormessage = pcall(function()
				myDataStore:SetAsync(PlayerID,PlayerData)
			end)

			if success then
				print("Data Successfully Saved")
			else
				print("There Was An Error")
				warn(errormessage)
			end
		end
		DEBUG = false
	end
end)