local DataStoreService = game:GetService("DataStoreService")
local DataStoreNumber = 0
local OldDataStore = DataStoreService:GetDataStore("TestDataStore1")
local CurrentDataStore = DataStoreService:GetDataStore("DataStore1", tostring(DataStoreNumber))

local HttpService = game:GetService("HttpService")

local GameInformationMS = require(game.ReplicatedStorage.ModuleScripts.GameInformation)
local ArtifactsMS = require(game.ReplicatedStorage.ModuleScripts.Artifacts)
local MaterialsMS = require(game.ReplicatedStorage.ModuleScripts.Materials)
local BiomeInfoMS = require(game.ReplicatedStorage.ModuleScripts.BiomeInfo)
local BadgesMS = require(game.ReplicatedStorage.ModuleScripts.Badges)

local HubPortals = game.Workspace.Hub.Portals
local PlayerPortals = HubPortals.PlayerPortals
local PlayerBases = game.Workspace.PlayerBases

local BasePortalColour = Color3.fromRGB(99, 95, 98)

local UIStuff = game.ReplicatedStorage.GuiStuff
local FillerImageID = "rbxassetid://16746904022"

-- Stats
local NewSavedStats = {
	["Total Artifacts Found"] = 0;
	["Artifacts Found"] = {""};
	["Badges"] = {""};
	["Equipped Badge"] = "";
	["Unlocked Pedestals"] = 2;
}

local NewUnSavedStats = {
	RollAmount = 100000;
	UnlockedPages = 1;
	SearchCoolDown = 0.1;
	JumpPower = 50;
	Tier1Roll = 75050; -- 75.05%
	Tier2Roll = 20000; -- 20%
	Tier3Roll = 4000; -- 4%
	Tier4Roll = 750; -- 0.75%
	Tier5Roll = 150; -- 0.15%
	Tier6Roll = 50; -- 0.05%
}
-- Stats

local NewPlayerBase = {
	PortalColour = {255, 255, 255};
	BaseHousing = "Castle";
	BaseSurrounding = "Plains";
}

local NewSavedSettings = {
	["Music Playing"] = true;
	["Music Volume"] = 0.1;
	["Effects Muted"] = false;
	["Effects Volume"] = 0.1;
}

local DataLoaded = false

game.Players.PlayerAdded:Connect(function(Player)

	local InventoryUI = Player.PlayerGui:WaitForChild("InventoryUI")
	local ArtifactSelectingUI = Player.PlayerGui:WaitForChild("ArtifactSelectingUI")
	local TavernUI = Player.PlayerGui:WaitForChild("TavernUI")
	local ArtifactIndexUI = Player.PlayerGui:WaitForChild("ArtifactIndexUI")

	-- Other Stuff

	-- Artifact Storage
	for i, v in pairs(ArtifactsMS) do -- Artifact Storage GUIs
		local NewArtifact = UIStuff.Inventory.Artifact:Clone()
		NewArtifact.Parent = InventoryUI.Holder.ArtifactStorage.ArtifactStorage
		NewArtifact.Name = i
		NewArtifact.ArtifactName.Text = i
		NewArtifact.ArtifactAmount.Text = 0
		NewArtifact.LayoutOrder = v.Index
		if v.ImageID ~= nil and v.ImageID ~= "" then
			NewArtifact.ImageHolder.ArtifactImage.Image = v.ImageID
		else
			NewArtifact.ImageHolder.ArtifactImage.Image = "rbxassetid://16746904022"
		end
	end
	-- Material Storage
	for i, v in pairs(MaterialsMS) do
		local NewMaterial = UIStuff.Inventory.Material:Clone()
		NewMaterial.Parent = InventoryUI.Holder.Materials.Materials
		NewMaterial.Name = i
		NewMaterial.MaterialName.Text = i
		NewMaterial.MaterialAmount.Text = 0
		NewMaterial.LayoutOrder = v.Index
		if v.ImageID ~= nil then
			NewMaterial.MaterialImage.Image = v.ImageID
		end
	end
	-- Badges
	for i, v in pairs(BadgesMS) do -- Add Badges to the claim badges GUI
		local NewBadge = UIStuff.BadgeGUI.Badge:Clone()
		NewBadge.Parent = TavernUI.Holder.BadgeHolder.Pages
		NewBadge.Name = i
		NewBadge.LayoutOrder = v.Information.Index
		NewBadge.Title.Text = i
		local NewBadgePageIndicator = UIStuff.MultiUI.PageIndicator:Clone()
		NewBadgePageIndicator.Parent = TavernUI.Holder.BadgeHolder.PageIndicators
		NewBadgePageIndicator.Name = i
		NewBadgePageIndicator.LayoutOrder = v.Information.Index
		for y, x in pairs(v) do
			if y ~= "Information" then
				local NewRequirement = UIStuff.BadgeGUI.Requirement:Clone()
				NewRequirement.Parent = NewBadge.RequirementsHolder.Requirements
				NewRequirement.Name = y
				NewRequirement.LayoutOrder = ArtifactsMS[y].Index
				NewRequirement.ZIndex = 4+ArtifactsMS[y].Index
				if ArtifactsMS[y].ImageID ~= "" then
					NewRequirement.ArtifactImage.Image = ArtifactsMS[y].ImageID
				else
					NewRequirement.ArtifactImage.Image = "rbxassetid://16746904022"
				end
			end
		end
	end
	-- NameTag
	local NewNameTag = UIStuff.BadgeGUI.NameTag:Clone()
	NewNameTag.Parent = Player.Character.HumanoidRootPart
	-- NameTag

	-- Inventory
	local MaxPages = GameInformationMS["Max Pages"]

	for Count = 1, MaxPages do -- 5 is the max amount of pages a player can have
		local NewPage = UIStuff.Inventory.Page:Clone()
		NewPage.Name = "Page"..Count
		NewPage.Parent = InventoryUI.Holder.ArtifactsHolder.Pages
		NewPage.LayoutOrder = Count
		local NewPageIndicator = UIStuff.MultiUI.PageIndicator:Clone()
		NewPageIndicator.Name = NewPage.Name
		NewPageIndicator.Parent = InventoryUI.Holder.ArtifactsHolder.PageIndicators

		local NewPage = UIStuff.Inventory.Page:Clone()
		NewPage.Name = "Page"..Count
		NewPage.Parent = ArtifactSelectingUI.Holder.ArtifactsHolder.Pages
		NewPage.LayoutOrder = Count
		local NewPageIndicator = UIStuff.MultiUI.PageIndicator:Clone()
		NewPageIndicator.Name = NewPage.Name
		NewPageIndicator.Parent = ArtifactSelectingUI.Holder.ArtifactsHolder.PageIndicators
	end
	for FirstCount = 1,16 do
		for SecondCount = 1, MaxPages do -- Max Pages is how many pages you want to fill (Inventory)
			local NewSlot = UIStuff.Inventory.Slot:Clone()
			NewSlot.Name = "P"..SecondCount.."ArtifactSlot"..FirstCount
			NewSlot.Parent = InventoryUI.Holder.ArtifactsHolder.Pages["Page"..SecondCount]
		end

		for SecondCount = 1, MaxPages do -- (Artifact Selecting)
			local NewSlot = UIStuff.Selections.SelectingSlot:Clone()
			NewSlot.Name = "P"..SecondCount.."ArtifactSlot"..FirstCount
			NewSlot.Parent = ArtifactSelectingUI.Holder.ArtifactsHolder.Pages["Page"..SecondCount]
		end
	end
	-- Inventory
	
	-- Artifact Index
	for i, v in pairs(BiomeInfoMS) do -- Adds The Biomes To The Artifact Index
		if v["UnlockAmount"] then
			if v["UnlockAmount"] >= 0 then
				local NewPage = UIStuff.ArtifactIndexUI.Page:Clone()
				NewPage.Name = i
				NewPage.LayoutOrder = v.Index
				NewPage.Parent = ArtifactIndexUI.Holder.Pages
				NewPage.Title.Text = i.." Artifacts"
				
				local NewPageIndicator = UIStuff.MultiUI.PageIndicator:Clone()
				NewPageIndicator.Name = i
				NewPageIndicator.LayoutOrder = v.Index
				NewPageIndicator.Parent = ArtifactIndexUI.Holder.PageIndicators
			end
		end
	end
	
	for i, v in pairs(ArtifactsMS) do -- Adds The Artifacts To The Biomes In Artifact Index
		for u, c in pairs(v.Biomes) do
			if ArtifactIndexUI.Holder.Pages:FindFirstChild(c) then
				local NewArtifact = UIStuff.ArtifactIndexUI.Artifact:Clone()
				NewArtifact.Name = i
				NewArtifact.LayoutOrder = v.Index
				NewArtifact.ArtifactImage.Image = v.ImageID
				NewArtifact.Parent = ArtifactIndexUI.Holder.Pages:FindFirstChild(c).Artifacts
			elseif c == "Everywhere" then
				for y, x in pairs(ArtifactIndexUI.Holder.Pages:GetChildren()) do
					if x:IsA("Frame") then
						local NewArtifact = UIStuff.ArtifactIndexUI.Artifact:Clone()
						NewArtifact.Name = i
						NewArtifact.LayoutOrder = v.Index
						NewArtifact.ArtifactImage.Image = v.ImageID
						NewArtifact.Parent = x.Artifacts
					end
				end
			end
		end
	end
	-- Other Stuff

	-- Data Save

	local Information = Instance.new("Folder")
	Information.Name = "Information"
	Information.Parent = Player

	-- Inventory
	local Inventory = Instance.new("Folder")
	Inventory.Parent = Information
	Inventory.Name = "Inventory"
	-- Inventory

	-- Stats

	local SavedStats = Instance.new("StringValue") -- Gets Saved
	SavedStats.Name = "SavedStats"
	SavedStats.Parent = Information
	SavedStats.Value = HttpService:JSONEncode(NewSavedStats)

	local UnSavedStats = Instance.new("StringValue") -- Doesn't Get Saved
	UnSavedStats.Name = "UnSavedStats"
	UnSavedStats.Parent = Information
	
	local SavedSettings = Instance.new("StringValue") -- Gets Saved
	SavedSettings.Name = "SavedSettings"
	SavedSettings.Parent = Information
	SavedSettings.Value = HttpService:JSONEncode(NewSavedSettings)

	-- Stats

	-- Storage

	local MaterialStorage = Instance.new("StringValue")
	MaterialStorage.Name = "MaterialStorage"
	MaterialStorage.Parent = Information
	MaterialStorage.Value = HttpService:JSONEncode({})

	local ArtifactStorage = Instance.new("StringValue")
	ArtifactStorage.Name = "ArtifactStorage"
	ArtifactStorage.Parent = Information
	ArtifactStorage.Value = HttpService:JSONEncode({})

	-- Storage

	-- Base Information

	local PlayerBase = Instance.new("StringValue")
	PlayerBase.Name = "PlayerBase"
	PlayerBase.Parent = Information
	PlayerBase.Value = HttpService:JSONEncode(NewPlayerBase)

	-- Base Information

	-- Extra Information

	local TeleportedFrom = Instance.new("ObjectValue")
	TeleportedFrom.Name = "TeleportedFrom"
	TeleportedFrom.Parent = Information

	local Searching = Instance.new("BoolValue")
	Searching.Name = "Searching"
	Searching.Parent = Information
	Searching.Value = false
	
	local AutoSearch = Instance.new("BoolValue")
	AutoSearch.Name = "AutoSearch"
	AutoSearch.Parent = Information
	AutoSearch.Value = false

	local Biome = Instance.new("StringValue")
	Biome.Name = "Biome"
	Biome.Parent = Information
	Biome.Value = "Hub"
	
	local Checker = Instance.new("BoolValue")
	Checker.Name = "Checker"
	Checker.Parent = Player
	Checker.Value = false

	local PlayerID = "Player_"..Player.UserId

	local PlayerData

	local success, errormessage = pcall(function()
		if not CurrentDataStore:GetAsync(PlayerID) then
			PlayerData = OldDataStore:GetAsync(PlayerID)
		
			--local Repeat = false
			--for Count = 0, DataStoreNumber do
			--	local OldDataStore
			--	if DataStoreService:GetDataStore("DataStore1", tostring(Count)):GetAsync(PlayerID) and Repeat == false then
			--		OldDataStore = DataStoreService:GetDataStore("DataStore1", tostring(Count))
			--	elseif Repeat == false then
			--		Repeat = true
			--		PlayerData = OldDataStore:GetAsync(PlayerID)
			--	end
			--end
			print("Using Old Data")
		else
			PlayerData = CurrentDataStore:GetAsync(PlayerID)
			--OldDataStore:RemoveAsync(PlayerID)
			print("Using Current Data")
		end
	end)

	if success then
		if PlayerData then
			if PlayerData.SavedStats then
				SavedStats.Value = PlayerData.SavedStats
			end
			if PlayerData.SavedSettings then
				SavedSettings.Value = PlayerData.SavedSettings
			end
			if PlayerData.ArtifactStorage then
				ArtifactStorage.Value = PlayerData.ArtifactStorage
			end
			if PlayerData.MaterialStorage then
				MaterialStorage.Value = PlayerData.MaterialStorage
			end
			if PlayerData.Artifacts ~= nil then
				for i, v in pairs(PlayerData.Artifacts) do
					local NewArtifact = Instance.new("StringValue")
					NewArtifact.Parent = Player.Information.Inventory
					NewArtifact.Name = i
					NewArtifact.Value = v
				end
			end
			DataLoaded = true
		end
		repeat
			wait(0.1)
		until Player.CharacterAdded

		-- Player Data Loaded

		local SavedStatsValue = HttpService:JSONDecode(SavedStats.Value)
		local ArtifactStorageValue = HttpService:JSONDecode(ArtifactStorage.Value)
		for i, v in pairs(ArtifactStorageValue) do
			if not table.find(SavedStatsValue["Artifacts Found"], i) then
				table.insert(SavedStatsValue["Artifacts Found"], i)
			end
		end
		for i, v in pairs(Inventory:GetChildren()) do
			local ArtifactInformation = HttpService:JSONDecode(v.Value)
			if not table.find(SavedStatsValue["Artifacts Found"], ArtifactInformation.Name) then
				table.insert(SavedStatsValue["Artifacts Found"], ArtifactInformation.Name)
			end
		end
		local BaseStats = HttpService:JSONDecode(PlayerBase.Value)

		-- Player Portal
		if not PlayerPortals:FindFirstChild("PlayerPortal") then
			for i, v in pairs(PlayerPortals:GetChildren()) do
				if not game.Players:FindFirstChild(v.Name) then
					v.Name = "PlayerPortal"
				end
			end
		end
		local NewPlayerPortal
		if Player.UserId ~= nil then -- 84336073
			NewPlayerPortal = PlayerPortals:FindFirstChild("PlayerPortal")
			NewPlayerPortal.Name = Player.Name
			NewPlayerPortal:WaitForChild("PortalUI").Text.Text = Player.Name
			for i, v in pairs(NewPlayerPortal.Colour:GetChildren()) do -- Change Portal Colour
				v.Color = Color3.fromRGB(unpack(BaseStats.PortalColour))
			end
			NewPlayerPortal.Portal.CanTouch = true
			for i, v in pairs(NewPlayerPortal.Portal:GetChildren()) do
				if v.Name == "SurfaceGui" then
					v.Enabled = true
				end
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
		local NewPlayerBase
		if Player.UserId ~= nil then -- 84336073
			NewPlayerBase = PlayerBases:FindFirstChild("PlayerBase")
			NewPlayerBase.Name = Player.Name
		else
			NewPlayerBase = PlayerBases:FindFirstChild("OwnerBase")
		end
		for i, v in pairs(NewPlayerBase["Hub Portal"].Colour:GetChildren()) do -- Change Portal Colour
			v.Color = Color3.fromRGB(unpack(BaseStats.PortalColour))
		end

		-- Player Pedestals
		for i, v in pairs(NewPlayerBase.Pedestals:GetChildren()) do
			if string.find(v.Name, "Pedestal") then
				local PedestalNumber = tonumber(v.Name:match("%d+"))
				if PedestalNumber <= SavedStatsValue["Unlocked Pedestals"] then
					v.Pedestal.Transparency = 0
					v.Pedestal.CanCollide = true
				else
					v.Pedestal.Transparency = 1
					v.Pedestal.CanCollide = false
				end
				local Artifact = Player.Information.Inventory:FindFirstChild(v.Name)
				if Artifact then
					local ArtifactInformation = HttpService:JSONDecode(Artifact.Value)
					v.ArtifactImage.ArtifactImage.Image = ArtifactInformation.ImageID
				end
			end
		end

		if SavedStatsValue["Equipped Badge"] ~= "" then
			Player.Character.HumanoidRootPart.NameTag.Image.Image = BadgesMS[SavedStatsValue["Equipped Badge"]].Information.ImageID
		end
		
		if Player.UserId == 84336073 then
			Player.PlayerGui:FindFirstChild("SideButtonsUI").Holder.OwnerUIButton.Visible = true
			for i, v in pairs(ArtifactsMS) do
				local NewArtifact = UIStuff.OwnerUI.Artifact:Clone()
				NewArtifact.Name = i
				NewArtifact.LayoutOrder = v.Index
				NewArtifact.ArtifactName.Text = i
				if v.ImageID ~= nil and v.ImageID ~= "" then
					NewArtifact.ImageHolder.ArtifactImage.Image = v.ImageID
				else
					NewArtifact.ImageHolder.ArtifactImage.Image = FillerImageID -- Filler Item
				end
				NewArtifact.Parent = Player.PlayerGui:WaitForChild("OwnerUI").Holder.GiveArtifact.OptionsHolder.Artifacts
			end
		else
			--Player.PlayerGui:FindFirstChild("OwnerUI"):Destroy()
		end
		--game.ReplicatedStorage.RemoteEvents.PlayerDataLoaded:FireClient(Player)
		game.ReplicatedStorage.BindableEvents.PlayerDataLoaded:Fire(Player)
		Checker.Value = true
	else
		--Player:Kick()
	end


end)

game.Players.PlayerRemoving:Connect(function(Player)
	-- Check if anyone is in their base if they are then teleport them back to spawn
	local PlayerID = "Player_"..Player.UserId
	
	local Inventory = Player:FindFirstChild("Information").Inventory
	local ArtifactsTable = {}
	for i, v in pairs(Inventory:GetChildren()) do -- Add Artifacts To PlayerData
		ArtifactsTable[v.Name] = v.Value
	end

	local PlayerData = {

		-- Stats
		SavedStats = Player.Information.SavedStats.Value;
		SavedSettings = Player.Information.SavedSettings.Value;
		ArtifactStorage = Player.Information.ArtifactStorage.Value;
		MaterialStorage = Player.Information.MaterialStorage.Value;
		Artifacts = ArtifactsTable;
	}

	local success, errormessage = pcall(function()
		if DataLoaded == true then
			CurrentDataStore:SetAsync(PlayerID,PlayerData)
		end
	end)

	if success then
		print("Data Successfully Saved")

		-- Player Portal
		local PlayerPortal = PlayerPortals:FindFirstChild(Player.Name)
		if PlayerPortal then
			PlayerPortal.Name = "PlayerPortal"
			PlayerPortal.PortalUI.Text.Text = "Unclaimed Portal"
			for i, v in pairs(PlayerPortal.Colour:GetChildren()) do
				v.Color = BasePortalColour
			end
			PlayerPortal.Portal.CanTouch = false
			for i, v in pairs(PlayerPortal.Portal:GetChildren()) do
				if v.Name == "SurfaceGui" then
					v.Enabled = false
				end
			end
		end

		-- Player Base
		local PlayerBase = PlayerBases:FindFirstChild(Player.Name)
		if PlayerBase then
			PlayerBase.Name = "PlayerBase"
			for i, v in pairs(PlayerBase["Hub Portal"].Colour:GetChildren()) do
				v.Color = BasePortalColour
			end
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

			local Inventory = Player.Information.Inventory
			local ArtifactsTable = {}
			for i, v in pairs(Inventory:GetChildren()) do -- Add Artifacts To PlayerData
				ArtifactsTable[v.Name] = v.Value
			end

			local PlayerData = {

				-- Stats
				SavedStats = Player.Information.SavedStats.Value;
				SavedSettings = Player.Information.SavedSettings.Value;
				ArtifactStorage = Player.Information.ArtifactStorage.Value;
				MaterialStorage = Player.Information.MaterialStorage.Value;
				Artifacts = ArtifactsTable;
			}

			local success, errormessage = pcall(function()
				if DataLoaded == true then
					CurrentDataStore:SetAsync(PlayerID,PlayerData)
				end
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