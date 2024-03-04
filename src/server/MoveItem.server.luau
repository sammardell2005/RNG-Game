local HTTPService = game:GetService("HttpService")

local function DefineSlots(Player, SelectedSlot, RecievingSlot)
	local SelectedItem
	local RecievingItem
	for i, v in pairs(Player.ArtifactInventory:GetChildren()) do
		local Slot = HTTPService:JSONDecode(v.Value).Slot
		if Slot == SelectedSlot then
			SelectedItem = v
		elseif Slot == RecievingSlot then
			RecievingItem = v
		end
	end
	return SelectedItem, RecievingItem
end

local function DefineInfo(Player, SelectedItem, RecieveingItem)
	local SelectedItemInfo
	local RecievingItemInfo
	if SelectedItem then
		SelectedItemInfo = HTTPService:JSONDecode(SelectedItem.Value)
	end
	if RecieveingItem then
		RecievingItemInfo = HTTPService:JSONDecode(RecieveingItem.Value)
	end
	return SelectedItemInfo, RecievingItemInfo
end

local function SwapSlots(Player, SelectedSlot, SelectedItem, SelectedItemInfo, RecievingSlot, RecievingItem, RecievingItemInfo)
	if SelectedItem then
		SelectedItemInfo.Slot = RecievingSlot
		SelectedItem.Value = HTTPService:JSONEncode(SelectedItemInfo)
		SelectedItem.Name = RecievingSlot
	end
	if RecievingItem then
		RecievingItemInfo.Slot = SelectedSlot
		RecievingItem.Value = HTTPService:JSONEncode(RecievingItemInfo)
		RecievingItem.Name = SelectedSlot
	end
	game.ReplicatedStorage.RemoteEvents.MoveItem:FireClient(Player, RecievingSlot, SelectedItemInfo) -- Figure out what this does then write it here
end


game.ReplicatedStorage.RemoteEvents.MoveItem.OnServerEvent:Connect(function(Player, SelectedSlot, RecievingSlot)
	local SelectedItem, RecievingItem = DefineSlots(Player, SelectedSlot, RecievingSlot)
	local SelectedItemInfo, RecievingItemInfo = DefineInfo(Player, SelectedItem, RecievingItem)
	SwapSlots(Player, SelectedSlot, SelectedItem, SelectedItemInfo, RecievingSlot, RecievingItem, RecievingItemInfo)
end)