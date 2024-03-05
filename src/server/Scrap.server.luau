local HttpService = game:GetService("HttpService")
game.ReplicatedStorage.RemoteEvents.Scrap.OnServerEvent:Connect(function(Player, ArtifactSlot)
	-- Find Artifact in the players artifact inventory
	-- Give the player the amount of scrap it should give depending on power level
	-- Remove artifact from players inventory
	local PlayerStats = HttpService:JSONDecode(Player.Information.PlayerStats.Value)
	
	local ArtifactInventory = Player.ArtifactInventory
	local Artifact = ArtifactInventory:FindFirstChild(ArtifactSlot)
	if Artifact then
		local ArtifactInformation = HttpService:JSONDecode(Artifact.Value)
		if PlayerStats[ArtifactInformation.Material] then
			PlayerStats[ArtifactInformation.Material] += ArtifactInformation.MaterialAmount*(ArtifactInformation.PowerLevel+1)
		else
			PlayerStats[ArtifactInformation.Material] = ArtifactInformation.MaterialAmount*(ArtifactInformation.PowerLevel+1)
		end
		Player.Information.PlayerStats.Value = HttpService:JSONEncode(PlayerStats)
		Artifact:Destroy()
	end
end)