local HttpService = game:GetService("HttpService")
local ProximityPromptService = game:GetService("ProximityPromptService")

local GameInformationMS = require(game.ReplicatedStorage.ModuleScripts.GameInformation)
local ArtifactsMS = require(game.ReplicatedStorage.ModuleScripts.Artifacts)

local function CheckEquippedArtifacts(Player)
	local ArtifactInventory = Player.Information.Inventory
	local UnSavedStats = Player.Information.UnSavedStats
	
	local BaseStats = {}
	for i, v in pairs(GameInformationMS["Base UnSaved Stats"]) do
		BaseStats[i] = v
	end
	
	local RollAmount = BaseStats.RollAmount -- Will roll between 1 and this amount
	local Divide = 100 -- Amount to divide by to get the % of the buff amount
	
	for i, v in pairs(ArtifactInventory:GetChildren()) do
		if string.find(v.Name, "Pedestal") then
			local ItemInformation = HttpService:JSONDecode(v.Value)
			local ArtifactInformation = ArtifactsMS[ItemInformation.Name]
			local PowerLevel
			if ItemInformation.PowerLevel == 0 then
				PowerLevel = 1
			else
				PowerLevel = ItemInformation.PowerLevel
			end
			if ArtifactInformation.Buff == "None" then
				-- Hidden Buff???
			elseif ArtifactInformation.Buff == "Increase Artifacts Sell Price By " then
				
			elseif ArtifactInformation.Buff == "Increases Players Movement Speed By " then
				BaseStats["Walk Speed"] += BaseStats["Walk Speed"]*(ArtifactInformation.BuffAmount/Divide)*(0.25*PowerLevel)
			elseif ArtifactInformation.Buff == "Adds a new page to your Artifact Inventory" then
				-- Increase players unlocked pages amount
				local RoundedNumber = math.floor(PowerLevel/5)
				BaseStats["Unlocked Pages"] += 1+RoundedNumber
			elseif ArtifactInformation.Buff == "Decreases The CoolDown For Searching By " then
				BaseStats["Search Cooldown"] -= ArtifactInformation.BuffAmount*PowerLevel
			elseif ArtifactInformation.Buff == "Increase Tier 1 Artifact Chance By " then
				-- 0.01% is 1 ,0.1% is 10 ,1% is 100 ,10% is 1000
				-- x0.1 is 10% ,x0.01 is 1% ,x0.001 is 0.1%
				
				-- to give tier1roll 1% more luck do
				-- Add 100 to tier1roll
				-- subtract 100 from tier2roll
				local Amount = RollAmount*(ArtifactInformation.BuffAmount/Divide)*PowerLevel
				BaseStats.Tier1Roll += Amount
				BaseStats.Tier2Roll -= Amount
			elseif ArtifactInformation.Buff == "Increase Tier 2 Artifact Chance By " then
				-- to give tier2roll 1% more luck do
				-- add 100 to tier2roll
				-- subtract 100 from tier1roll
				local Amount = RollAmount*(ArtifactInformation.BuffAmount/Divide)*PowerLevel
				BaseStats.Tier1Roll -= Amount -- Check if Tier1Roll is bigger than Amount
				BaseStats.Tier2Roll += Amount
			elseif ArtifactInformation.Buff == "Increase Tier 3 Artifact Chance By " then
				-- to give tier3roll 1% more luck do
				-- subtract 75 from tier1roll
				-- subtract 25 from tier2roll
				-- add 100 to tier3roll
				local Amount = RollAmount*(ArtifactInformation.BuffAmount/Divide)*PowerLevel
				BaseStats.Tier1Roll -= (Amount/4)*3
				BaseStats.Tier2Roll -= (Amount/4)
				BaseStats.Tier3Roll += Amount
			elseif ArtifactInformation.Buff == "Increase Tier 4 Artifact Chance By " then
				-- to give tier4roll 1% more luck do
				-- subtract 75 from tier1roll
				-- subtract 25 from tier2roll
				-- add 100 to tier4roll
				local Amount = RollAmount*(ArtifactInformation.BuffAmount/Divide)*PowerLevel
				BaseStats.Tier1Roll -= (Amount/4)*3
				BaseStats.Tier2Roll -= (Amount/4)
				BaseStats.Tier4Roll += Amount
			elseif ArtifactInformation.Buff == "Increase Tier 5 Artifact Chance By " then
				-- to give tier5roll 1% more luck do
				-- subtract 75 from tier1roll
				-- subtract 25 from tier2roll
				-- add 100 to tier5roll
				local Amount = RollAmount*(ArtifactInformation.BuffAmount/Divide)*PowerLevel
				BaseStats.Tier1Roll -= (Amount/4)*3
				BaseStats.Tier2Roll -= (Amount/4)
				BaseStats.Tier5Roll += Amount
			elseif ArtifactInformation.Buff == "Increase JackPot Artifact Chance By " then
				local Amount = RollAmount*(ArtifactInformation.BuffAmount/Divide)*PowerLevel
				BaseStats.Tier1Roll -= (Amount/4)*3
				BaseStats.Tier2Roll -= (Amount/4)
			end
		end
	end
	Player.Character.Humanoid.WalkSpeed = BaseStats["Walk Speed"]
	Player.Character.Humanoid.JumpPower = BaseStats["Jump Power"]
	UnSavedStats.Value = HttpService:JSONEncode(BaseStats)
	game.ReplicatedStorage.RemoteEvents.UpdateAllUI:FireClient(Player)
end

game.Players.PlayerAdded:Connect(function(Player)
	repeat
		wait()
	until Player:WaitForChild("Checker").Value == true
	CheckEquippedArtifacts(Player)
end)

game.ReplicatedStorage.RemoteEvents.Pedestal.EquipArtifact.OnServerEvent:Connect(function(Player, Pedestal, ArtifactSlot) -- Sent from GUI Script
	local Inventory = Player.Information.Inventory
	local Pedestals = game.Workspace.PlayerBases:FindFirstChild(Player.Name).Pedestals
	if ArtifactSlot ~= "" then -- Check if player has selected an artifact
		local Artifact = Inventory:FindFirstChild(ArtifactSlot)
		local ArtifactInformation = HttpService:JSONDecode(Artifact.Value)
		for i, v in pairs(Inventory:GetChildren()) do
			if string.find(v.Name, "Pedestal") then
				local CheckedInformation = HttpService:JSONDecode(v.Value)
				if CheckedInformation.Name == ArtifactInformation.Name and Pedestal.Name ~= v.Name then
					return
				end
			end
		end
		if Inventory:FindFirstChild(Pedestal.Name) then -- if the player has an artifact in the pedestal already
			local PedestalArtifact = Inventory:FindFirstChild(Pedestal.Name)
			local PedestalInformation = HttpService:JSONDecode(PedestalArtifact.Value)
			
			PedestalArtifact.Name = ArtifactSlot
			Artifact.Name = Pedestal.Name
			PedestalInformation.Slot = ArtifactSlot
			ArtifactInformation.Slot = Pedestal.Name
			PedestalArtifact.Value = HttpService:JSONEncode(PedestalInformation)
			Artifact.Value = HttpService:JSONEncode(ArtifactInformation)
			-- Maybe change the gui looks in here???
		else
			if Inventory:FindFirstChild(ArtifactSlot) then
				Artifact.Name = Pedestal.Name
				ArtifactInformation.Slot = Pedestal.Name
				Artifact.Value = HttpService:JSONEncode(ArtifactInformation)
			end
		end
		if ArtifactInformation.ImageID ~= nil or ArtifactInformation.ImageID ~= "" then
			Pedestals[Pedestal.Name].ArtifactImage.ArtifactImage.Image = ArtifactInformation.ImageID
		else
			Pedestals[Pedestal.Name].ArtifactImage.ArtifactImage.Image = "rbxassetid://16746904022" -- Filler Image
		end
		CheckEquippedArtifacts(Player)
	end
end)

game.ReplicatedStorage.RemoteEvents.Pedestal.UnEquipArtifact.OnServerEvent:Connect(function(Player, Pedestal)
	local Inventory = Player.Information.Inventory
	local UsedSlots = {}
	for i, v in pairs(Inventory:GetChildren()) do
		local Slot = v.Name
		table.insert(UsedSlots, Slot)
	end
	for FirstCount = 1, 2 do -- Change the 2 to the amount of pages the player has
		for SecondCount = 1, 16 do
			if not table.find(UsedSlots, "P"..FirstCount.."ArtifactSlot"..SecondCount) then
				local Pedestals = game.Workspace.PlayerBases:FindFirstChild(Player.Name).Pedestals
				local Artifact = Inventory:FindFirstChild(Pedestal.Name)
				local NewArtifactInformation = HttpService:JSONDecode(Artifact.Value)
				NewArtifactInformation.Slot = "P"..FirstCount.."ArtifactSlot"..SecondCount
				Artifact.Name = "P"..FirstCount.."ArtifactSlot"..SecondCount
				Artifact.Value = HttpService:JSONEncode(NewArtifactInformation)
				--Artifact.Parent = Player.ArtifactInventory
				-- Move Item Back To Inventory In Specific Slot
				Pedestals[Pedestal.Name].ArtifactImage.ArtifactImage.Image = ""
				CheckEquippedArtifacts(Player)
				return
			end
		end
	end
end)