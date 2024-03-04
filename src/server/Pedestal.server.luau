local HttpService = game:GetService("HttpService")
local ProximityPromptService = game:GetService("ProximityPromptService")

game.ReplicatedStorage.RemoteEvents.Pedestal.EquipArtifact.OnServerEvent:Connect(function(Player, Pedestal, ArtifactSlot) -- Sent from EquipArtifact
	local ArtifactInventory = Player.ArtifactInventory
	local Pedestals = game.Workspace.PlayerBases:FindFirstChild(Player.Name).Pedestals
	if ArtifactSlot ~= "" then
		local Artifact = ArtifactInventory:FindFirstChild(ArtifactSlot)
		local ArtifactInformation = HttpService:JSONDecode(Artifact.Value)
		if ArtifactInventory:FindFirstChild(Pedestal.Name) then
			local PedestalArtifact = ArtifactInventory:FindFirstChild(Pedestal.Name)
			local PedestalInformation = HttpService:JSONDecode(PedestalArtifact.Value)
			
			PedestalArtifact.Name = ArtifactSlot
			Artifact.Name = Pedestal.Name
			PedestalInformation.Slot = ArtifactSlot
			ArtifactInformation.Slot = Pedestal.Name
			PedestalArtifact.Value = HttpService:JSONEncode(PedestalInformation)
			Artifact.Value = HttpService:JSONEncode(ArtifactInformation)
			
			return
		else
			if ArtifactInventory:FindFirstChild(ArtifactSlot) then
				Artifact.Name = Pedestal.Name
				ArtifactInformation.Slot = Pedestal.Name
				Artifact.Value = HttpService:JSONEncode(ArtifactInformation)
			end
		end
		Pedestals[Pedestal.Name].ArtifactImage.ArtifactImage.Image = ArtifactInformation.ImageID
	end
end)

game.ReplicatedStorage.RemoteEvents.Pedestal.UnEquipArtifact.OnServerEvent:Connect(function(Player, Pedestal)
	local PlayerStats = HttpService:JSONDecode(Player.Information.PlayerStats.Value)
	local UsedSlots = {}
	for i, v in pairs(Player.ArtifactInventory:GetChildren()) do
		local Slot = v.Name
		table.insert(UsedSlots, Slot)
	end
	for FirstCount = 1, 2 do -- 2 is the amount of pages the player has
		for SecondCount = 1, 16 do
			if not table.find(UsedSlots, "P"..FirstCount.."ArtifactSlot"..SecondCount) then
				local Pedestals = game.Workspace.PlayerBases:FindFirstChild(Player.Name).Pedestals
				local Artifact = Player.ArtifactInventory:FindFirstChild(Pedestal.Name)
				local NewArtifactInformation = HttpService:JSONDecode(Artifact.Value)
				NewArtifactInformation.Slot = "P"..FirstCount.."ArtifactSlot"..SecondCount
				Artifact.Name = "P"..FirstCount.."ArtifactSlot"..SecondCount
				Artifact.Value = HttpService:JSONEncode(NewArtifactInformation)
				Pedestals[Pedestal.Name].ArtifactImage.ArtifactImage.Image = ""
				return
			end
		end
	end
end)