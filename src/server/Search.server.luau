local HttpService = game:GetService("HttpService")

local Artifacts = require(game.ReplicatedStorage.ModuleScripts.Artifacts)

local Biomes = {"Hub", "Home"}

function CoolDown(Player, UnSavedStatsValue, Searching, Artifact)
	local Biome = Player.Information.Biome
	local AutoSearch = Player.Information.AutoSearch
	if Artifact then
		game.ReplicatedStorage.RemoteEvents.PopUp:FireClient(Player, Artifact) -- PopUp
		game.ReplicatedStorage.RemoteEvents.Search.Search:FireClient(Player)
	end
	wait(UnSavedStatsValue["Search Cooldown"]) -- Players CoolDown
	Searching.Value = false
	if Artifact and AutoSearch.Value == true and not table.find(Biomes, Biome.Value) then
		Search(Player)
	end
end

function Search(Player)
	-- Starts Cooldown
	-- Roll between 1 and 10000
	local UnSavedStats = Player.Information.UnSavedStats
	local UnSavedStatsValue = HttpService:JSONDecode(UnSavedStats.Value)
	local Searching = Player.Information.Searching
	local Biome = Player.Information.Biome
	local Inventory = Player.Information.Inventory

	if Searching.Value == false then
		local UsedSlots = {}
		for i, v in pairs(Inventory:GetChildren()) do
			if not string.find(v.Name, "Pedestal") then
				local Slot = v.Name
				table.insert(UsedSlots, Slot)
			end
		end
		
		if #UsedSlots ~= UnSavedStatsValue["Unlocked Pages"]*16 then
		
			Searching.Value = true
			-- Searching
			repeat
				local ArtifactsTable = {}
				local Roll = math.random(1,UnSavedStatsValue.RollAmount)
				local Tier = 0
				local Tier1RollValue = UnSavedStatsValue.Tier1Roll
				local Tier2RollValue = Tier1RollValue+UnSavedStatsValue.Tier2Roll
				local Tier3RollValue = Tier2RollValue+UnSavedStatsValue.Tier3Roll
				local Tier4RollValue = Tier3RollValue+UnSavedStatsValue.Tier4Roll
				local Tier5RollValue = Tier4RollValue+UnSavedStatsValue.Tier5Roll
				if Roll >= 1 and Roll <= Tier1RollValue then -- T1 70% -- Roll between 1 and Tier1Roll in player stats 71 -0.75 -75 69.25%
					Tier = 1
				elseif Roll >= Tier1RollValue+1 and Roll <= Tier2RollValue then -- T2 20% -- Roll between Tier1Roll+1 and Tier2Roll in player stats 19 -0.25 -25 19.75%
					Tier = 2
				elseif Roll >= Tier2RollValue+1 and Roll <= Tier3RollValue then -- T3 8% -- Roll between Tier2Roll+1 and Tier3Roll in player stats 8
					Tier = 3
				elseif Roll >= Tier3RollValue+1 and Roll <= Tier4RollValue then -- T4 1.5% -- Roll between Tier3Roll+1 and Tier4Roll in player stats 1.5 2.5%
					Tier = 4
				elseif Roll >= Tier4RollValue+1 and Roll <= Tier5RollValue then -- T5 0.35% -- Roll between Tier4Roll+1 and Tier5Roll in player stats 0.35
					Tier = 5
				elseif Roll >= Tier5RollValue+1 and Roll <= UnSavedStatsValue.RollAmount then -- JP 0.15% -- Roll between Tier5Roll+1 and Tier6Roll in player stats 0.15
					Tier = 6
				end
				for i, v in pairs(Artifacts) do
					if v.Tier == Tier then
						if table.find(v.Biomes, "Everywhere") or table.find(v.Biomes, Biome.Value) then
							table.insert(ArtifactsTable, i)
						end
					end
				end
				if #ArtifactsTable >= 1 then -- If 1 or more Artifacts Exist In That Tier
					local Roll = math.random(1, #ArtifactsTable)
					-- Go through Artifacts table and roll between the amount of artifacts that are in it

					-- local Roll = math.random(1,10000)
					-- Check if player has an artifact equipped that gives chance for a higher power
					-- Add in the chance to add +1 Power
					local NewInformation = Artifacts[ArtifactsTable[Roll]]
					NewInformation.PowerLevel = 0 -- Change to the power level it needs to be
					for FirstCount = 1, UnSavedStatsValue["Unlocked Pages"] do
						for SecondCount = 1, 16 do
							local Slot = "P"..FirstCount.."ArtifactSlot"..SecondCount
							if not table.find(UsedSlots, Slot) then
								local Information = Instance.new("StringValue")
								Information.Value = HttpService:JSONEncode(NewInformation)
								Information.Parent = Inventory
								Information.Name = Slot
								local SavedStats = Player.Information.SavedStats
								local SavedStatsValue = HttpService:JSONDecode(SavedStats.Value)
								if not table.find(SavedStatsValue["Artifacts Found"], NewInformation.Name) then
									table.insert(SavedStatsValue["Artifacts Found"], NewInformation.Name)
								end
								SavedStatsValue["Total Artifacts Found"] += 1
								SavedStats.Value = HttpService:JSONEncode(SavedStatsValue)
								CoolDown(Player, UnSavedStatsValue, Searching, ArtifactsTable[Roll])
								return
							end
						end
					end
					CoolDown(Player, UnSavedStatsValue, Searching)
				else
					print(Tier)
					print("Reroll")
				end
			until #ArtifactsTable >= 1
			-- Searching
		end
	end
end

game.ReplicatedStorage.RemoteEvents.Search.Search.OnServerEvent:Connect(function(Player)
	Search(Player)
end)

game.ReplicatedStorage.BindableEvents.AutoSearch.Event:Connect(function(Player)
	Search(Player)
end)