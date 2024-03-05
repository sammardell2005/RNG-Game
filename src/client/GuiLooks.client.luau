local Player = game.Players.LocalPlayer
local HttpService = game:GetService("HttpService")

local Holder = Player.PlayerGui:WaitForChild("ArtifactInventory").Holder
local ArtifactsHolder = Holder.Artifacts.ArtifactsHolder
local PlayerStats = Holder.PlayerStats.PlayerStatsHolder.PlayerStatsText

local Debug = false

while true do
	if Debug == false then
		Debug = true
		local PlayerInformation = HttpService:JSONDecode(Player:WaitForChild("Information").PlayerStats.Value)
		local UsedSlots = {"UIGridLayout", "UICorner", "UIGradient", "UIStroke", "DraggableItems"}
		for i, v in pairs(Player:WaitForChild("ArtifactInventory"):GetChildren()) do
			local ItemInformation = HttpService:JSONDecode(v.Value)
			local Slot = ItemInformation.Slot
			local PowerLevel = ItemInformation.PowerLevel
			local ImageID = ItemInformation.ImageID

			for FirstCount = 1, PlayerInformation.UnlockedPages do
				local Page = ArtifactsHolder["Page"..FirstCount]
				if Page:FindFirstChild(Slot) then
					local CurrentSlot = Page:FindFirstChild(Slot)
					if ImageID == nil then -- Sets the Image
						CurrentSlot.ItemImage.Image = ""
					else
						CurrentSlot.ItemImage.Image = ImageID
					end
					if PowerLevel > 0 then -- Sets the Power Level
						CurrentSlot.PowerLevel.Text = "+"..PowerLevel
					else
						CurrentSlot.PowerLevel.Text = ""
					end
				end
			end
			table.insert(UsedSlots, Slot)
		end
		for FirstCount = 1, PlayerInformation.UnlockedPages do
			local Page = ArtifactsHolder["Page"..FirstCount]
			for SecondCount = 1, 16 do
				local CurrentSlot = Page:FindFirstChild("P"..FirstCount.."ArtifactSlot"..SecondCount)
				if not table.find(UsedSlots, CurrentSlot.Name) then
					CurrentSlot.ItemImage.Image = ""
					CurrentSlot.PowerLevel.Text = ""
				end
			end
		end
		if PlayerInformation.UnlockedPages ~= nil then
			for i, v in pairs(ArtifactsHolder:GetChildren()) do
				if string.match(v.Name, "Page") then
					if tonumber(v.Name:match("%d+")) ~= nil then
						if tonumber(v.Name:match("%d+")) > PlayerInformation.UnlockedPages then
							v.Visible = false
						end
					end
				end
			end
			for Count = 1, PlayerInformation.UnlockedPages do
				ArtifactsHolder:FindFirstChild("Page"..Count).Visible = true
			end
		end
		Debug = false
	end
	wait(0.1)
end