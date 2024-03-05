local HttpService = game:GetService("HttpService")

local Artifacts = require(game.ReplicatedStorage.ModuleScripts.Artifacts)

local function CoolDown(Player, PlayerStats, Artifact)
	game.ReplicatedStorage.RemoteEvents.PopUp:FireClient(Player, Artifact) -- PopUp 
	wait(PlayerStats.SearchCoolDown) -- Players CoolDown
	PlayerStats.Searching = false
	Player.Information.PlayerStats.Value = HttpService:JSONEncode(PlayerStats) -- Put before cooldown
end

game.ReplicatedStorage.RemoteEvents.Search.OnServerEvent:Connect(function(Player)
	-- Starts Cooldown
	-- Roll between 1 and 10000
	local PlayerStats = HttpService:JSONDecode(Player.Information.PlayerStats.Value)
	
	if PlayerStats.Searching == false then
		PlayerStats.Searching = true
		Player.Information.PlayerStats.Value = HttpService:JSONEncode(PlayerStats)
		-- Searching
		repeat
			local ArtifactsTable = {}
			local Roll = math.random(1,10000)
			local Tier = 0
			if Roll >= 1 and Roll <= 7000 then -- T1 70%
				Tier = 1
			elseif Roll >= 7001 and Roll <= 9000 then -- T2 20%
				Tier = 2
			elseif Roll >= 9001 and Roll <= 9800 then -- T3 8%
				Tier = 3
			elseif Roll >= 9801 and Roll <= 9950 then -- T4 1.5%
				Tier = 4
			elseif Roll >= 9951 and Roll <= 9985 then -- T5 0.35%
				Tier = 5
			elseif Roll >= 9986 and Roll <= 10000 then -- JP 0.15%
				Tier = 6
			end
			for i, v in pairs(Artifacts) do
				if v.Tier == Tier then
					if v.Biome == "Everywhere" or v.Biome == PlayerStats.Biome then
						table.insert(ArtifactsTable, i)
					end
				end
			end
			if #ArtifactsTable >= 1 then -- If 1 or more Artifacts Exist In That Tier
				local Roll = math.random(1, #ArtifactsTable)
				-- Go through Artifacts table and roll between the amount of artifacts that are in it
				
				local UsedSlots = {}
				for i, v in pairs(Player.ArtifactInventory:GetChildren()) do
					local Slot = v.Name
					table.insert(UsedSlots, Slot)
				end
				-- local Roll = math.random(1,10000)
				-- Check if player has an artifact equipped that gives chance for a higher power
				-- Add in the chance to add +1 Power
				local NewInformation = Artifacts[ArtifactsTable[Roll]]
				for FirstCount = 1, PlayerStats.UnlockedPages do
					for SecondCount = 1, 16 do
						local Slot = "P"..FirstCount.."ArtifactSlot"..SecondCount
						if not table.find(UsedSlots, Slot) then
							NewInformation.Slot = Slot
							local Information = Instance.new("StringValue")
							Information.Value = HttpService:JSONEncode(Artifacts[ArtifactsTable[Roll]])
							Information.Parent = Player.ArtifactInventory
							Information.Name = Slot
							CoolDown(Player, PlayerStats, ArtifactsTable[Roll])
							return
						end
					end
				end
			else
				print(Tier)
				print("Reroll")
			end
		until #ArtifactsTable >= 1 
		-- Searching
	end
end)