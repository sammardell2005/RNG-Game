local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local ProximityPromptService = game:GetService("ProximityPromptService")
local Debris = game:GetService("Debris")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local RunService = game:GetService("RunService")

local GameInformationMS = require(game.ReplicatedStorage.ModuleScripts.GameInformation)
local ArtifactsMS = require(game.ReplicatedStorage.ModuleScripts.Artifacts)
local BiomeInfoMS = require(game.ReplicatedStorage.ModuleScripts.BiomeInfo)
local BadgesMS = require(game.ReplicatedStorage.ModuleScripts.Badges)

local MusicFolder = game.ReplicatedStorage.Music

local TinyTavern = workspace.Hub.TinyTavern
local TTNPC = TinyTavern.NPC
local TTNPCHumanoid = TTNPC:WaitForChild("Humanoid")
local PreviousChoice = nil

local Player = game.Players.LocalPlayer
local Mouse = game.Players.LocalPlayer:GetMouse()

game.ReplicatedFirst:RemoveDefaultLoadingScreen()

local Checker = Player:WaitForChild("Checker")
repeat
	wait()
until Checker.Value == true

local Inventory = Player:WaitForChild("Information").Inventory
local SavedStats = Player:WaitForChild("Information").SavedStats
local UnSavedStats = Player:WaitForChild("Information").UnSavedStats
local SavedSettings = Player:WaitForChild("Information").SavedSettings
local Biome = Player:WaitForChild("Information").Biome
local Searching = Player:WaitForChild("Information").Searching
local AutoSearch = Player:WaitForChild("Information").AutoSearch
local ArtifactStorage = Player:WaitForChild("Information").ArtifactStorage
local Camera = workspace.CurrentCamera

local MoveCamera

local LastPrompt

local MaxPedestalAmount = 14

local SliderStep = 0.01

local FillerImageID = "rbxassetid://16746904022"

local SearchUI = Player.PlayerGui:WaitForChild("SearchUI")
local SearchButtonUI = SearchUI.Holder.SearchButton
local SearchCooldownUI = SearchButtonUI.Cooldown
local PopOutDebug = false
local AutoSearchButtonUI = SearchUI.Holder.AutoSearchButton

local InventoryButtonUI = Player.PlayerGui:WaitForChild("SideButtonsUI").Holder.InventoryButton
local InventoryUI = Player.PlayerGui:WaitForChild("InventoryUI")
local IArtifactsHolder = InventoryUI.Holder.ArtifactsHolder
local IArtifacts = IArtifactsHolder.Pages
local IPageIndicators = IArtifactsHolder.PageIndicators
local QuickStoreButton = IArtifactsHolder:WaitForChild("QuickStoreButton")
local QuickStoreWarning = IArtifactsHolder:WaitForChild("QuickStoreWarning")
local StoreAllButton = IArtifactsHolder:WaitForChild("StoreAllButton")
local ArtifactInformation = InventoryUI.Holder:WaitForChild("ArtifactInformation")
local InformationHolder = ArtifactInformation:WaitForChild("InformationHolder")
local InventoryStatsHolder = InventoryUI.Holder:WaitForChild("PlayerStats").PlayerStatsHolder
local Confirming = false
local StoreAllTimer = 0

local ArtifactStorageUI = InventoryUI.Holder.ArtifactStorage

local ArtifactSelectingUI = Player.PlayerGui:WaitForChild("ArtifactSelectingUI")
local ASCurrentArtifact = ArtifactSelectingUI.CurrentArtifact
local ASHolderUI = ArtifactSelectingUI.Holder
local ASArtifacts = ASHolderUI.ArtifactsHolder.Pages
local ASArtifactPageIndicators = ASHolderUI.ArtifactsHolder.PageIndicators
local ASPedestalInformation = ASHolderUI.PedestalInformation
local ASPedestalText = ASPedestalInformation.InformationHolder.InformationText
local ASButtons = ASPedestalInformation.InformationHolder.Buttons
local ASEquip = ASButtons.Equip
local ASUnEquip = ASButtons.UnEquip
local ASClose = ASButtons.Close
local ASArtifactText = ASHolderUI.ArtifactInformation.InformationHolder.InformationText

local PedestalSelectionUI = Player.PlayerGui:WaitForChild("PedestalSelection")
local PSCurrentPedestal = PedestalSelectionUI.CurrentPedestal
local NextButton = PedestalSelectionUI.Holder.NextButton
local PreviousButton = PedestalSelectionUI.Holder.PreviousButton
local UnlockButton = PedestalSelectionUI.Holder.ButtonHolder.UnlockButton
local PedestalSelectionSelectButton = PedestalSelectionUI.Holder.ButtonHolder.SelectButton
local PedestalSelectionUpgradeButton = PedestalSelectionUI.Holder.ButtonHolder.UpgradeButton
local PedestalSelectionUnlockButton = PedestalSelectionUI.Holder.ButtonHolder.UnlockButton

local PopUpUI = Player.PlayerGui:WaitForChild("PopUp")
local PopUpHolderUI = PopUpUI.Holder

local TavernUI = Player.PlayerGui:WaitForChild("TavernUI")
local Dialogue = TavernUI.Holder.Dialogue
local DialogueHolder = Dialogue.DialogueHolder
local DialogueOptionsHolder = Dialogue.OptionsHolder
local BadgeHolder = TavernUI.Holder.BadgeHolder
local BadgePages = BadgeHolder.Pages
local BadgePageLayout = BadgePages.UIPageLayout
local BadgePageIndicators = BadgeHolder.PageIndicators

local OptionsButtonUI = Player.PlayerGui:WaitForChild("SideButtonsUI").Holder.OptionsButton
local OptionsUI = Player.PlayerGui:WaitForChild("OptionsUI")
local Options = OptionsUI.Holder.OptionsHolder.Options
local MusicMuteButton = Options.Audio.MusicMute.Button
local MusicVolumeSlider = Options.Audio.MusicVolume.Slider
local HoldingMusicVolumeSlider = false
local EffectsMuteButton = Options.Audio.EffectsMute.Button
local EffectsVolumeSlider = Options.Audio.EffectsVolume.Slider
local HoldingEffectsVolumeSlider = false

local ArtifactIndexButtonUI = Player.PlayerGui:WaitForChild("SideButtonsUI").Holder.ArtifactIndexButton
local ArtifactIndexUI = Player.PlayerGui:WaitForChild("ArtifactIndexUI")

local InformationButtonUI = Player.PlayerGui:WaitForChild("SideButtonsUI").Holder.InformationButton
local InformationUI = Player.PlayerGui:WaitForChild("InformationUI")
local InformationUIHolder = InformationUI:WaitForChild("Holder")

local OwnerUIButton = Player.PlayerGui:WaitForChild("SideButtonsUI").Holder.OwnerUIButton
local OwnerUI = Player.PlayerGui:WaitForChild("OwnerUI")
local ResetDataDebug = false
-- References

-- Functions
function Snap(Number, Factor)
	if Factor == 0 then
		return Number
	else
		return math.floor(Number/Factor+0.5)*Factor
	end
end

function BackToCharacter()
	if UnSavedStats.Value ~= "" then
		local UnSavedStatsValue = HttpService:JSONDecode(UnSavedStats.Value)
		Player.Character.Humanoid.WalkSpeed = UnSavedStatsValue["Walk Speed"]
	else
		Player.Character.Humanoid.WalkSpeed = 16
	end
	Camera.CameraSubject = workspace[Player.Name].Humanoid
	Camera.CameraType = Enum.CameraType.Track
	CharactersVisible()
	if LastPrompt ~= nil then
		LastPrompt.Enabled = true
	end
end

function CharactersVisible()
	--Player.Character.HumanoidRootPart.Anchored = false -- Not needed??? maybe delete 
	for i, v in pairs(game.Players:GetChildren()) do
		for i, c in pairs(v.Character:GetDescendants()) do
			if c:IsA("BasePart") and c.Name ~= "HumanoidRootPart" or c:IsA("Decal") then
				c.Transparency = 0
			end
		end
		v.Character:WaitForChild("HumanoidRootPart").NameTag.Enabled = true
	end
	-- Make Name Tags and Faces Visible
end

function CharactersInvisible()
	Player.Character.Humanoid.WalkSpeed = 0
	for i, v in pairs(game.Players:GetChildren()) do
		for i, c in pairs(v.Character:GetDescendants()) do
			if c:IsA("BasePart") or c:IsA("Decal") then
				c.Transparency = 1
			end
		end
		v.Character:WaitForChild("HumanoidRootPart").NameTag.Enabled = false
	end
	-- Make Name Tags and Faces Invisible
end

function UpdatePortals()
	local SavedStatsValue = HttpService:JSONDecode(SavedStats.Value)

	-- Portals
	for i, v in pairs(BiomeInfoMS) do
		if v.UnlockAmount then
			local Portal = v.BiomePortal:WaitForChild("Portal")
			if SavedStatsValue["Total Artifacts Found"] >= v.UnlockAmount then
				Portal:FindFirstChild("FrontGui").Enabled = true
				Portal:FindFirstChild("BackGui").Enabled = true
				v.BiomePortal:WaitForChild("PortalUI").Text.Text = i
				-- Make Portal Unlocked
			else
				Portal:FindFirstChild("FrontGui").Enabled = false
				Portal:FindFirstChild("BackGui").Enabled = false
				v.BiomePortal:WaitForChild("PortalUI").Text.Text = tostring(SavedStatsValue["Total Artifacts Found"].." / "..v.UnlockAmount)
				-- Update Unlock Number Above Portal
			end
		end
	end
end

function ChangePage(PagesHolder, PageIndicator)
	local Page = PagesHolder:FindFirstChild(PageIndicator.Name)
	for i, v in pairs(PageIndicator.Parent:GetChildren()) do
		if v:IsA("Text Button") then
			v.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		end
	end
	PageIndicator.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	PagesHolder:FindFirstChild("UIPageLayout"):JumpTo(Page)
end

function ResetPage(PagesHolder, PageIndicators)
	local Page
	for i, v in pairs(PagesHolder:GetChildren()) do
		if v:IsA("Frame") then
			if v.LayoutOrder == 1 then
				if v.Visible == true then
					PagesHolder:FindFirstChild("UIPageLayout"):JumpTo(v)
				end
				Page = v
			end
		end
	end
	for i, v in pairs(PageIndicators:GetChildren()) do
		if v:IsA("Frame") then
			v.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		end
	end
	PageIndicators:FindFirstChild(Page.Name).BackgroundColor3 = Color3.fromRGB(0, 0, 0)
end

function CloseAndResetAllUI(BTC)
	if BTC == true then
		BackToCharacter()
	end
	if MoveCamera then
		MoveCamera:Cancel()
	end
	CloseInventoryUI()
	DisableStoreButtons()
	CloseOptionsUI()
	ClosePedestalUI()
	CloseArtifactSelection()
	CloseDialogueUI()
	CloseBadgeUI()
	CloseArtifactIndexUI()
	CloseInformationUI()
	CloseOwnerUI()
end

function Search()
	local UnSavedStatsValue = HttpService:JSONDecode(Player.Information.UnSavedStats.Value)
	if Searching.Value == false then
		local UsedSlots = {}
		for i, v in pairs(Inventory:GetChildren()) do
			if not string.find(v.Name, "Pedestal") then
				local Slot = v.Name
				table.insert(UsedSlots, Slot)
			end
		end
		if #UsedSlots == UnSavedStatsValue["Unlocked Pages"]*16 then -- Inventory is full
			local NewWarning = game.ReplicatedStorage.GuiStuff.SearchUI.Warning:Clone()
			NewWarning.Parent = SearchUI.Holder
			Debris:AddItem(NewWarning, 3)
		else
			game.ReplicatedStorage.RemoteEvents.Search.Search:FireServer()
		end
	end
end

function UpdateSearch()
	if Searching.Value == false then
		SearchButtonUI.BackgroundColor3 = Color3.new(0.333333, 1, 0.498039)
		SearchButtonUI.Keybind.TextColor3 = Color3.new(0.333333, 1, 0.498039)
	else
		SearchButtonUI.BackgroundColor3 = Color3.new(1, 0.486275, 0.486275)
		SearchButtonUI.Keybind.TextColor3 = Color3.new(1, 0.486275, 0.486275)
	end
end

function SearchCooldown()
	local UnSavedStatsValue = HttpService:JSONDecode(Player.Information.UnSavedStats.Value)
	SearchCooldownUI.Size = UDim2.new(1,0,-1,0)
	local Info = TweenInfo.new(UnSavedStatsValue["Search Cooldown"])
	local NewTween = TweenService:Create(SearchCooldownUI, Info, {Size = UDim2.new(1,0,0,0)})
	NewTween:Play()
	SearchButtonUI.Keybind.UIGradient.Offset = Vector2.new(0,-0.5)
	local GradientTween = TweenService:Create(SearchButtonUI.Keybind.UIGradient, Info, {Offset = Vector2.new(0,0.5)})
	GradientTween:Play()
end

function AutoSearchF()
	game.ReplicatedStorage.RemoteEvents.Search.AutoSearch:FireServer()
end

function UpdateAutoSearch()
	local SavedStatsValue = HttpService:JSONDecode(SavedStats.Value)
	if SavedStatsValue["Total Artifacts Found"] >= GameInformationMS["Auto Search Unlock"] then
		AutoSearchButtonUI.PadLock.Visible = false
		AutoSearchButtonUI.Shade.Visible = false
		AutoSearchButtonUI["Unlock Amount"].Visible = false
		if AutoSearch.Value == false then
			-- Sets it to false
			AutoSearchButtonUI.BackgroundColor3 = Color3.fromRGB(255, 98, 98)
		else
			-- Sets it to true
			AutoSearchButtonUI.BackgroundColor3 = Color3.fromRGB(85, 255, 127)
			Search()
		end
	else
		AutoSearchButtonUI["Unlock Amount"].Text = SavedStatsValue["Total Artifacts Found"].." / "..GameInformationMS["Auto Search Unlock"]
	end
end

function UpdateProbabilities()
	if Player.Information.UnSavedStats.Value ~= "" then
		local UnSavedStatsValue = HttpService:JSONDecode(Player.Information.UnSavedStats.Value)
		local PercentDivide = (UnSavedStatsValue.RollAmount/100)
		SearchUI.Holder.Probabilities.Text = "Tier 1 Artifact Chance : "..UnSavedStatsValue.Tier1Roll/PercentDivide.."%".."\n"
		SearchUI.Holder.Probabilities.Text = SearchUI.Holder.Probabilities.Text.."Tier 2 Artifact Chance : "..UnSavedStatsValue.Tier2Roll/PercentDivide.."%".."\n"
		SearchUI.Holder.Probabilities.Text = SearchUI.Holder.Probabilities.Text.."Tier 3 Artifact Chance : "..UnSavedStatsValue.Tier3Roll/PercentDivide.."%".."\n"
		SearchUI.Holder.Probabilities.Text = SearchUI.Holder.Probabilities.Text.."Tier 4 Artifact Chance : "..UnSavedStatsValue.Tier4Roll/PercentDivide.."%".."\n"
		SearchUI.Holder.Probabilities.Text = SearchUI.Holder.Probabilities.Text.."Tier 5 Artifact Chance : "..UnSavedStatsValue.Tier5Roll/PercentDivide.."%"
	end
end

-- Inventory
function OpenInventoryUI()
	if InventoryUI.Holder.Visible == false then
		CloseAndResetAllUI(true)
		InventoryButtonUI.Shade.Visible = true
		InventoryButtonUI.Keybind.TextColor3 = Color3.fromRGB(153, 153, 153)
		InventoryUI.Holder.Visible = true
		Player.Character.HumanoidRootPart.Anchored = false
	else
		CloseInventoryUI()
	end
end

function CloseInventoryUI()
	local MousePos = UserInputService:GetMouseLocation() - GuiService:GetGuiInset()
	local Guis = Player:WaitForChild("PlayerGui"):GetGuiObjectsAtPosition(MousePos.X,MousePos.Y)
	if not table.find(Guis, InventoryButtonUI.Button) then
		InventoryButtonUI.Shade.Visible = false
		InventoryButtonUI.Keybind.TextColor3 = Color3.fromRGB(255, 255, 255)
	end
	InventoryUI.Holder.Visible = false
	ResetPage(IArtifacts, IPageIndicators)
	UnSelectArtifact()
end

function DisableStoreButtons()
	QuickStoreButton.BackgroundColor3 = Color3.new(1, 1, 1) -- Customization Needs to be checked here instead eventually !!!
	InventoryUI.Storing.Value = false
	QuickStoreWarning.Visible = false
	
	StoreAllButton.BackgroundColor3 = Color3.new(1, 1, 1) -- Customization Needs to be checked here instead eventually !!!
	StoreAllButton.Text = "Store".."\n".."All"
	Confirming = false
end

function UpdateInventoryUI()
	if UnSavedStats.Value ~= "" then
		local SavedStatsValue = HttpService:JSONDecode(SavedStats.Value)
		local UnSavedStatsValue = HttpService:JSONDecode(UnSavedStats.Value)
		local UsedSlots = {"UIGridLayout", "UICorner", "UIGradient", "UIStroke", "DraggableItems"}
		for i, v in pairs(Inventory:GetChildren()) do
			local SavedInformation = HttpService:JSONDecode(v.Value)
			local StaticInformation = ArtifactsMS[HttpService:JSONDecode(v.Value).Name]
			local PowerLevel = SavedInformation.PowerLevel
			local Slot = v.Name
			local ImageID
			if StaticInformation.ImageID then
				ImageID = StaticInformation.ImageID
			end
			for FirstCount = 1, UnSavedStatsValue["Unlocked Pages"] do -- 2 is the amount of pages the player has
				local Page = IArtifacts["Page"..FirstCount]
				if Page:FindFirstChild(Slot) then
					local CurrentSlot = Page:FindFirstChild(Slot)
					if ImageID == "" or ImageID == nil then -- Sets the Image
						CurrentSlot.ItemImage.Image = FillerImageID -- Filler
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
		for FirstCount = 1, GameInformationMS["Max Pages"] do
			local Page = IArtifacts["Page"..FirstCount]
			IArtifacts:FindFirstChild("Page"..FirstCount).Visible = true
			for SecondCount = 1, 16 do -- Reset All Slot UI
				local CurrentSlot = Page:FindFirstChild("P"..FirstCount.."ArtifactSlot"..SecondCount)
				if not table.find(UsedSlots, CurrentSlot.Name) then
					CurrentSlot.ItemImage.Image = ""
					CurrentSlot.PowerLevel.Text = ""
				end
			end

			if FirstCount > UnSavedStatsValue["Unlocked Pages"] then -- If Not Unlocked Then Hide
				Page.Visible = false
				IPageIndicators:FindFirstChild(Page.Name).Visible = false
			elseif FirstCount <= UnSavedStatsValue["Unlocked Pages"] then
				Page.Visible = true
				IPageIndicators:FindFirstChild(Page.Name).Visible = true
			end
		end
		for i, v in pairs(IPageIndicators:GetChildren()) do
			if v:IsA("TextButton") then
				v.BackgroundColor3 = Color3.new(1, 1, 1)
			end
		end
		IPageIndicators:FindFirstChild(IArtifacts.UIPageLayout.CurrentPage.Name).BackgroundColor3 = Color3.new(0, 0, 0)
		InventoryStatsHolder["Total Artifacts Found"].Amount.Text = SavedStatsValue["Total Artifacts Found"]
		InventoryStatsHolder["Search Cooldown"].Amount.Text = UnSavedStatsValue["Search Cooldown"]
		InventoryStatsHolder["Walk Speed"].Amount.Text = UnSavedStatsValue["Walk Speed"]
		InventoryStatsHolder["Jump Power"].Amount.Text = UnSavedStatsValue["Jump Power"]
		-- Updates Artifact Storage
		local ArtifactStorageValue = HttpService:JSONDecode(ArtifactStorage.Value)
		for i, v in pairs(ArtifactStorageUI.ArtifactStorage:GetChildren()) do
			if SavedStatsValue["Artifacts Found"] ~= nil then
				if v:IsA("Frame") and table.find(SavedStatsValue["Artifacts Found"], v.Name) then
					v.Visible = true
					if not ArtifactStorageValue[v.Name] then
						v.ArtifactAmount.Text = "0"
					else
						v.ArtifactAmount.Text = ArtifactStorageValue[v.Name]
					end
				elseif v:IsA("Frame") then
					v.Visible = false
					if not ArtifactStorageValue[v.Name] then
						v.ArtifactAmount.Text = "0"
					else
						v.ArtifactAmount.Text = ArtifactStorageValue[v.Name]
					end
				end
			end
		end
		-- Updates Artifact Storage
	end
end

function UnSelectArtifact()
	InformationHolder.InformationText.Text = "Nothing Selected"
	InformationHolder["Storing Button"].Visible = false
	InformationHolder["Storing Information"].Visible = false
end
-- Inventory

-- Pedestals and Artifact Selection
function OpenPedestalUI()
	if PedestalSelectionUI.Holder.Visible == false then
		CloseAndResetAllUI(false)
		
		local Pedestals = workspace.PlayerBases:FindFirstChild(Player.Name).Pedestals
		local Focus = Pedestals:FindFirstChild("Pedestal1").Pedestal
		local CameraPart = Focus.CFrame * CFrame.new(Vector3.new(7,5,0))

		Camera.CameraType = Enum.CameraType.Scriptable
		MoveCamera = TweenService:Create(Camera, TweenInfo.new(0.5), {["CFrame"] = CFrame.new(CameraPart.Position, Focus.Position)})
		MoveCamera:Play()

		PedestalSelectionUI.Button.Shade.Visible = true
		PedestalSelectionUI.Button.Keybind.TextColor3 = Color3.fromRGB(153, 153, 153)
		PedestalSelectionUI.Holder.Visible = true
		PedestalSelectionUI.Button.Button.Text = "Close"

		for i, v in pairs(Pedestals:GetChildren()) do
			if string.find(v.Name, "Pedestal") then
				v.Selected.Transparency = 1
			end
		end

		CharactersInvisible()

		Pedestals.Pedestal1.Selected.Transparency = 0
		PSCurrentPedestal.Value = Pedestals.Pedestal1

	else
		CloseAndResetAllUI(true)
	end
	UnSelectArtifact()
end

function ClosePedestalUI()
	if PSCurrentPedestal.Value ~= nil then
		PSCurrentPedestal.Value.Selected.Transparency = 1
		PSCurrentPedestal.Value = nil
	end

	local MousePos = UserInputService:GetMouseLocation() - GuiService:GetGuiInset()
	local Guis = Player:WaitForChild("PlayerGui"):GetGuiObjectsAtPosition(MousePos.X,MousePos.Y)
	if not table.find(Guis, PedestalSelectionUI.Button.Button) then
		PedestalSelectionUI.Button.Shade.Visible = false
		PedestalSelectionUI.Button.Keybind.TextColor3 = Color3.fromRGB(255, 255, 255)
	end
	PedestalSelectionUI.Holder.Visible = false
	PedestalSelectionUI.Button.Button.Text = "Pedestals"

	PedestalSelectionSelectButton.Visible = true
	PedestalSelectionUpgradeButton.Visible = true
	PedestalSelectionUnlockButton.Visible = false
	-- Reset Select and Upgrade and Unlock when player closes the pedestal selection menu
	--Player.Character:WaitForChild("HumanoidRootPart").Anchored = false -- Not Needed???
end

function CloseArtifactSelection()
	ArtifactSelectingUI.CurrentArtifact.Value = ""
	ArtifactSelectingUI.Holder.Visible = false

	Player.Character.HumanoidRootPart.Anchored = false
end

function UpdateArtifactSelectionUI()
	if UnSavedStats.Value ~= "" then
		local UnSavedStatsValue = HttpService:JSONDecode(UnSavedStats.Value)
		local UsedSlots = {"UIGridLayout", "UICorner", "UIGradient", "UIStroke", "DraggableItems"}
		for i, v in pairs(Player:WaitForChild("Information").Inventory:GetChildren()) do
			local SavedInformation = HttpService:JSONDecode(v.Value)
			local StaticInformation = ArtifactsMS[HttpService:JSONDecode(v.Value).Name]
			local PowerLevel = SavedInformation.PowerLevel
			local Slot = v.Name
			local ImageID
			if StaticInformation.ImageID then
				ImageID = StaticInformation.ImageID
			end
			for FirstCount = 1, UnSavedStatsValue["Unlocked Pages"] do -- 2 is the amount of pages the player has
				local Page = ASArtifacts["Page"..FirstCount]
				if Page:FindFirstChild(Slot) then
					local CurrentSlot = Page:FindFirstChild(Slot)
					if ImageID == "" or ImageID == nil then -- Sets the Image
						CurrentSlot.ItemImage.Image = FillerImageID
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
		for FirstCount = 1, GameInformationMS["Max Pages"] do -- 2 is the amount of pages the player has
			local Page = ASArtifacts["Page"..FirstCount]
			for SecondCount = 1, 16 do
				local CurrentSlot = Page:FindFirstChild("P"..FirstCount.."ArtifactSlot"..SecondCount)
				if not table.find(UsedSlots, CurrentSlot.Name) then
					CurrentSlot.ItemImage.Image = ""
					CurrentSlot.PowerLevel.Text = ""
				end
			end
			if FirstCount > UnSavedStatsValue["Unlocked Pages"] then -- If Not Unlocked Then Hide
				Page.Visible = false
				ASArtifactPageIndicators:FindFirstChild(Page.Name).Visible = false
			elseif FirstCount <= UnSavedStatsValue["Unlocked Pages"] then
				Page.Visible = true
				ASArtifactPageIndicators:FindFirstChild(Page.Name).Visible = true
			end
		end
		if ASCurrentArtifact.Value == "" then
			ASEquip.Visible = false
			ASArtifactText.Text = "Nothing Selected"
		else
			ASEquip.Visible = true
		end

		-- Pedistal Stuff

		if PSCurrentPedestal.Value ~= nil then
			if Inventory:FindFirstChild(PSCurrentPedestal.Value.Name) then -- Check if there is anything inside of the current pedistal
				local PedestalInformation = HttpService:JSONDecode(Inventory:FindFirstChild(PSCurrentPedestal.Value.Name).Value)
				local ArtifactInformation = ArtifactsMS[PedestalInformation.Name]
				
				local PowerLevel
				if PedestalInformation.PowerLevel == 0 then
					PowerLevel = 1
				else
					PowerLevel = PedestalInformation.PowerLevel
				end
				
				ASUnEquip.Visible = true
				ASPedestalText.Text = "Name : "..PedestalInformation.Name.."\n"
				ASPedestalText.Text = ASPedestalText.Text.."Tier : "..PedestalInformation.Tier.."\n"
				ASPedestalText.Text = ASPedestalText.Text.."Power Level : "..PedestalInformation.PowerLevel.."\n"
				
				if ArtifactInformation.BuffAmount ~= 0 then
					local BuffAmount = ArtifactInformation.BuffAmount
					if ArtifactInformation.Buff == "Increases Players Movement Speed By " then
						BuffAmount = ArtifactInformation.BuffAmount*(0.25*PowerLevel)
					elseif string.find(ArtifactInformation.Buff, "Artifact Chance") then
						BuffAmount = ArtifactInformation.BuffAmount*PowerLevel -- Add Power Level To This
					end

					ASPedestalText.Text = ASPedestalText.Text.."Buff : "..ArtifactInformation.Buff..tostring(BuffAmount)
					if ArtifactInformation.IsPercentage == true then
						ASPedestalText.Text = ASPedestalText.Text.."%".."\n\n"
					else
						ASPedestalText.Text = ASPedestalText.Text.."\n\n"
					end
				else
					ASPedestalText.Text = ASPedestalText.Text.."Buff : "..ArtifactInformation.Buff.."\n\n"
				end
			else
				ASUnEquip.Visible = false
				ASPedestalText.Text = "Nothing Equipped"
			end
		end
		-- Pedestal Stuff

		-- Page Indicator Stuff
		for i, v in pairs(ASArtifactPageIndicators:GetChildren()) do
			if v:IsA("TextButton") then
				v.BackgroundColor3 = Color3.new(1, 1, 1)
			end
		end
		ASArtifactPageIndicators:FindFirstChild(ASArtifacts.UIPageLayout.CurrentPage.Name).BackgroundColor3 = Color3.new(0, 0, 0)
		-- Page Indicator Stuff
	end
end
-- Pedestals and Artifact Selection

-- Tavern
function PlayTavernAnimation(Choice)
	if Choice ~= PreviousChoice then
		local OldAnimator = TTNPCHumanoid.Animator
		OldAnimator:Destroy()
		local NewAnimator = Instance.new("Animator")
		NewAnimator.Parent = TTNPCHumanoid
		local Animation = NewAnimator:LoadAnimation(TTNPC:FindFirstChild(Choice))
		Animation:Play()
		PreviousChoice = Choice
	end
end

function CloseDialogueUI()
	Dialogue.Visible = false
	DialogueHolder.Dialogue.Visible = true
	DialogueOptionsHolder.Visible = false
end

function OpenBadgeUI()
	CloseAndResetAllUI(false)
	BadgeHolder.Visible = true
	PlayTavernAnimation("Idle") -- Change these eventually
end

function CloseBadgeUI()
	BadgeHolder.Visible = false
	ResetPage(BadgePages, BadgePageIndicators)
	PlayTavernAnimation("Idle") -- Change these eventually
end

function UpdateBadgeUI()
	local SavedStatsValue = HttpService:JSONDecode(SavedStats.Value)
	for i, v in pairs(BadgePages:GetChildren()) do
		if v:IsA("Frame") then
			local ArtifactStorageValue = HttpService:JSONDecode(ArtifactStorage.Value)
			local Complete = true
			if BadgesMS[v.Name].Information.Biome ~= "Nothing" then
				if SavedStatsValue["Total Artifacts Found"] >= BiomeInfoMS[BadgesMS[v.Name].Information.Biome].UnlockAmount and BiomeInfoMS[BadgesMS[v.Name].Information.Biome].UnlockAmount ~= -1 then
					BadgePages:FindFirstChild(v.Name).Visible = true
					BadgePageIndicators:FindFirstChild(v.Name).Visible = true
				else
					BadgePages:FindFirstChild(v.Name).Visible = false
					BadgePageIndicators:FindFirstChild(v.Name).Visible = false
				end
			else
				BadgePages:FindFirstChild(v.Name).Visible = false
				BadgePageIndicators:FindFirstChild(v.Name).Visible = false
			end
			for u, c in pairs(v.RequirementsHolder.Requirements:GetChildren()) do
				if c:IsA("Frame") then
					if ArtifactStorageValue[c.Name] then
						c.Red.ArtifactAmount.Text = tostring(ArtifactStorageValue[c.Name].." / "..BadgesMS[v.Name][c.Name])
						if ArtifactStorageValue[c.Name] > BadgesMS[v.Name][c.Name] then
							c.Red.Green.Size = UDim2.new(1,0,1,0)
						else
							c.Red.Green.Size = UDim2.new(ArtifactStorageValue[c.Name]/BadgesMS[v.Name][c.Name],0,1,0)
						end
					else
						c.Red.ArtifactAmount.Text = tostring("0 / "..BadgesMS[v.Name][c.Name])
						c.Red.Green.Size = UDim2.new(0,0,1,0)
					end
					if ArtifactStorageValue[c.Name] then
						if ArtifactStorageValue[c.Name] < BadgesMS[v.Name][c.Name] then
							Complete = false
						end
					else
						Complete = false
					end
					if Complete == true then
						v["Claim Button"].BackgroundColor3 = Color3.new(0.333333, 1, 0.498039)
					else
						v["Claim Button"].BackgroundColor3 = Color3.new(0.529412, 0.529412, 0.529412)
					end
				end
			end
			if SavedStatsValue["Equipped Badge"] == v.Name then
				-- Change the claim button to an unequip button
				v["Claim Button"].Text = "Unequip"
				v["Claim Button"].BackgroundColor3 = Color3.new(1, 0.415686, 0.415686)
			elseif table.find(SavedStatsValue.Badges, v.Name) then
				-- Change the claim button to an equip button
				v["Claim Button"].Text = "Equip"
				v["Claim Button"].BackgroundColor3 = Color3.new(0.333333, 1, 0.498039)
			end
		end
	end
	for i, v in pairs(BadgePageIndicators:GetChildren()) do
		if v:IsA("TextButton") then
			v.BackgroundColor3 = Color3.new(1, 1, 1)
		end
	end
	if BadgePageIndicators:FindFirstChild(BadgePageLayout.CurrentPage.Name) then
		BadgePageIndicators:FindFirstChild(BadgePageLayout.CurrentPage.Name).BackgroundColor3 = Color3.new(0, 0, 0)
	end
end
-- Tavern

function OpenOptionsUI()
	if OptionsUI.Holder.Visible == false then
		CloseAndResetAllUI(true)
		
		OptionsButtonUI.Shade.Visible = true
		OptionsButtonUI.Keybind.TextColor3 = Color3.fromRGB(153, 153, 153)
		OptionsUI.Holder.Visible = true
		
	else
		CloseOptionsUI()
	end
end

function CloseOptionsUI()
	local MousePos = UserInputService:GetMouseLocation() - GuiService:GetGuiInset()
	local Guis = Player:WaitForChild("PlayerGui"):GetGuiObjectsAtPosition(MousePos.X,MousePos.Y)
	if not table.find(Guis, OptionsButtonUI.Button) then
		OptionsButtonUI.Shade.Visible = false
		OptionsButtonUI.Keybind.TextColor3 = Color3.fromRGB(255, 255, 255)
	end
	OptionsUI.Holder.Visible = false
end

function UpdateMusic()
	local SavedSettingsValue = HttpService:JSONDecode(SavedSettings.Value)
	if SavedSettingsValue["Music Playing"] == true then
		if BiomeInfoMS[Biome.Value] and BiomeInfoMS[Biome.Value].Music then
			if not BiomeInfoMS[Biome.Value].Music.isPlaying then
				for i, v in pairs(MusicFolder:GetChildren()) do
					v:Pause()
				end
				BiomeInfoMS[Biome.Value].Music:Resume()
			end
		else
			MusicFolder.Graffiti:Resume()
		end
		MusicMuteButton.BackgroundColor3 = Color3.fromRGB(85, 255, 127)
		MusicMuteButton.Text = "UnMuted"
	else
		for i, v in pairs(MusicFolder:GetChildren()) do
			v:Pause()
		end
		MusicMuteButton.BackgroundColor3 = Color3.fromRGB(255, 98, 98)
		MusicMuteButton.Text = "Muted"
	end
	for i, v in pairs(MusicFolder:GetChildren()) do
		v.Volume = SavedSettingsValue["Music Volume"]
	end
	MusicVolumeSlider.Button.Position = UDim2.new(SavedSettingsValue["Music Volume"]*2, 0, 0.5, 0)
	
	if SavedSettingsValue["Effects Muted"] == true then
		EffectsMuteButton.BackgroundColor3 = Color3.fromRGB(255, 98, 98)
		EffectsMuteButton.Text = "Muted"
		for i, v in pairs(game.Players:GetChildren()) do
			local Character = v.Character
			for u, c in pairs(Character:WaitForChild("HumanoidRootPart"):GetChildren()) do
				if c:IsA("Sound") then
					c.Volume = 0
				end
			end
		end
		-- Make all player sound effects volume 0 within humanoidrootpart
	else
		-- Make all player sound effects volume SavedStatsValue["Effects Volume"] within humanoidrootpart
		EffectsMuteButton.BackgroundColor3 = Color3.fromRGB(85, 255, 127)
		EffectsMuteButton.Text = "UnMuted"
		for i, v in pairs(game.Players:GetPlayers()) do
			local Character = v.Character
			for u, c in pairs(Character:WaitForChild("HumanoidRootPart"):GetChildren()) do
				if c:IsA("Sound") then
					c.Volume = SavedSettingsValue["Effects Volume"]
				end
			end
		end
	end
	EffectsVolumeSlider.Button.Position = UDim2.new(SavedSettingsValue["Effects Volume"]*2, 0, 0.5, 0)
end

function OpenArtifactIndexUI()
	if ArtifactIndexUI.Holder.Visible == false then
		CloseAndResetAllUI(true)

		ArtifactIndexButtonUI.Shade.Visible = true
		ArtifactIndexButtonUI.Keybind.TextColor3 = Color3.fromRGB(153, 153, 153)
		ArtifactIndexUI.Holder.Visible = true

	else
		CloseArtifactIndexUI()
	end
end

function CloseArtifactIndexUI()
	local MousePos = UserInputService:GetMouseLocation() - GuiService:GetGuiInset()
	local Guis = Player:WaitForChild("PlayerGui"):GetGuiObjectsAtPosition(MousePos.X,MousePos.Y)
	if not table.find(Guis, ArtifactIndexButtonUI) then
		ArtifactIndexButtonUI.Shade.Visible = false
		ArtifactIndexButtonUI.Keybind.TextColor3 = Color3.fromRGB(255, 255, 255)
	end
	ArtifactIndexUI.Holder.Visible = false
	ResetPage(ArtifactIndexUI.Holder.Pages, ArtifactIndexUI.Holder.PageIndicators)
end

function UpdateArtifactIndexUI()
	local SavedStatsValue = HttpService:JSONDecode(SavedStats.Value)
	local ArtifactStorageValue = HttpService:JSONDecode(ArtifactStorage.Value)
	for i, v in pairs(ArtifactsMS) do -- Adds The Artifacts To The Biomes In Artifact Index
		for u, c in pairs(v.Biomes) do
			if SavedStatsValue["Artifacts Found"] ~= nil then
				if ArtifactIndexUI.Holder.Pages:FindFirstChild(c) then
					if table.find(SavedStatsValue["Artifacts Found"], i) then
						local Artifact = ArtifactIndexUI.Holder.Pages:FindFirstChild(c).Artifacts[i]
						Artifact.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
						Artifact.ArtifactImage.ImageColor3 = Color3.fromRGB(255, 255, 255)
						Artifact.PadLockIcon.Visible = false
					else
						local Artifact = ArtifactIndexUI.Holder.Pages:FindFirstChild(c).Artifacts[i]
						Artifact.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
						Artifact.ArtifactImage.ImageColor3 = Color3.fromRGB(0, 0, 0)
						Artifact.PadLockIcon.Visible = true
					end
				elseif c == "Everywhere" then
					if table.find(SavedStatsValue["Artifacts Found"], i) then
						for y, x in pairs(ArtifactIndexUI.Holder.Pages:GetChildren()) do
							if x:IsA("Frame") then
								local Artifact = x.Artifacts[i]
								Artifact.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
								Artifact.ArtifactImage.ImageColor3 = Color3.fromRGB(255, 255, 255)
								Artifact.PadLockIcon.Visible = false
							end
						end
					else
						for y, x in pairs(ArtifactIndexUI.Holder.Pages:GetChildren()) do
							if x:IsA("Frame") then
								local Artifact = x.Artifacts[i]
								Artifact.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
								Artifact.ArtifactImage.ImageColor3 = Color3.fromRGB(0, 0, 0)
								Artifact.PadLockIcon.Visible = true
							end
						end
					end
				end
			end
		end
	end
end

function OpenInformationUI()
	if InformationUIHolder.Visible == false then
		CloseAndResetAllUI(true)
		
		InformationButtonUI.Shade.Visible = true
		InformationButtonUI.Keybind.TextColor3 = Color3.fromRGB(153, 153, 153)
		InformationUIHolder.Visible = true

	else
		CloseInformationUI()
	end
end

function CloseInformationUI()
	local MousePos = UserInputService:GetMouseLocation() - GuiService:GetGuiInset()
	local Guis = Player:WaitForChild("PlayerGui"):GetGuiObjectsAtPosition(MousePos.X,MousePos.Y)
	if not table.find(Guis, InformationButtonUI) then
		InformationButtonUI.Shade.Visible = false
		InformationButtonUI.Keybind.TextColor3 = Color3.fromRGB(255, 255, 255)
	end
	InformationUIHolder.Visible = false
	ResetPage(InformationUIHolder.Pages, InformationUIHolder.PageIndicators)
end

function UpdateInformationUI()
	local Page = InformationUIHolder.Pages.UIPageLayout.CurrentPage
	for i, v in pairs(InformationUIHolder.PageIndicators:GetChildren()) do
		if v:IsA("TextButton") then
			v.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		end
	end
	InformationUIHolder.PageIndicators:FindFirstChild(Page.Name).BackgroundColor3 = Color3.fromRGB(0, 0, 0)
end

function OpenOwnerUI()
	if OwnerUI.Holder.Visible == false then
		CloseAndResetAllUI(true)

		OwnerUIButton.Shade.Visible = true
		OwnerUIButton.Keybind.TextColor3 = Color3.fromRGB(153, 153, 153)
		OwnerUI.Holder.Visible = true

	else
		CloseOwnerUI()
	end
end

function CloseOwnerUI()
	local MousePos = UserInputService:GetMouseLocation() - GuiService:GetGuiInset()
	local Guis = Player:WaitForChild("PlayerGui"):GetGuiObjectsAtPosition(MousePos.X,MousePos.Y)
	if not table.find(Guis, OwnerUIButton) then
		OwnerUIButton.Shade.Visible = false
		OwnerUIButton.Keybind.TextColor3 = Color3.fromRGB(255, 255, 255)
	end
	OwnerUI.Holder.Visible = false
	--ResetPage(InformationUIHolder.Pages, InformationUIHolder.PageIndicators)
end

function ResetData()
	if ResetDataDebug == false then
		ResetDataDebug = true
		game.ReplicatedStorage.RemoteEvents.Owner.ResetData:FireServer(OwnerUI.Holder.ResetData.Holder.Player.Text)
		local Cooldown = OwnerUI.Holder.ResetData.Holder.Confirm.Cooldown
		Cooldown.Size = UDim2.new(1,0,-1,0)
		local Info = TweenInfo.new(0.5)
		local NewTween = TweenService:Create(Cooldown, Info, {Size = UDim2.new(1,0,0,0)})
		NewTween:Play()
		NewTween.Completed:Wait()
		ResetDataDebug = false
	end
end

function UpdateScrollBars()
	local MouseViewSizeX = Mouse.ViewSizeX
	for i, v in pairs(BadgePages:GetChildren()) do
		if v:IsA("Frame") then
			v:FindFirstChild("RequirementsHolder").Requirements.ScrollBarThickness = MouseViewSizeX/128
		end
	end
end

function TravelToBiome()
	SearchUI.Holder.Visible = true
	PedestalSelectionUI.Button.Visible = false
end

function TravelToHub()
	SearchUI.Holder.Visible = false
	PedestalSelectionUI.Button.Visible = false
end

function TravelToHome()
	SearchUI.Holder.Visible = false
	PedestalSelectionUI.Button.Visible = true
end

function UpdateAll()
	UpdateBadgeUI()
	UpdateInventoryUI()
	UpdateArtifactSelectionUI()
	UpdatePortals()
	UpdateMusic()
	UpdateProbabilities()
	UpdateSearch()
	UpdateAutoSearch()
	UpdateScrollBars()
	UpdateInformationUI()
	UpdateArtifactIndexUI()
end

-- Functions

-- Events

game.ReplicatedStorage.RemoteEvents.MoveItem.OnClientEvent:Connect(UpdateAll)
game.ReplicatedStorage.RemoteEvents.UpdateAllUI.OnClientEvent:Connect(UpdateAll)
SavedStats.Changed:Connect(UpdateAll)
UnSavedStats.Changed:Connect(UpdateAll)
SavedSettings.Changed:Connect(UpdateAll)
ArtifactStorage.Changed:Connect(UpdateAll)
Biome.Changed:Connect(UpdateAll)

Searching.Changed:Connect(UpdateSearch)
SearchButtonUI.Button.MouseButton1Click:Connect(Search)
game.ReplicatedStorage.RemoteEvents.Search.Search.OnClientEvent:Connect(SearchCooldown)
AutoSearch.Changed:Connect(UpdateAutoSearch)
AutoSearchButtonUI.Button.MouseButton1Click:Connect(AutoSearchF)

InventoryButtonUI.Button.MouseButton1Click:Connect(OpenInventoryUI) -- Open Artifact Inventory
InventoryUI.Holder.Changed:Connect(UpdateInventoryUI)
IArtifacts.UIPageLayout.Changed:Connect(UpdateInventoryUI)

PSCurrentPedestal.Changed:Connect(UpdateArtifactSelectionUI)
ASCurrentArtifact.Changed:Connect(UpdateArtifactSelectionUI)
ASHolderUI.Changed:Connect(UpdateArtifactSelectionUI)
ASArtifacts.UIPageLayout.Changed:Connect(UpdateArtifactSelectionUI)

BadgePageLayout.Changed:Connect(UpdateBadgeUI)

OptionsButtonUI.Button.MouseButton1Click:Connect(OpenOptionsUI)

ArtifactIndexButtonUI.Button.MouseButton1Click:Connect(OpenArtifactIndexUI)

InformationButtonUI.Button.MouseButton1Click:Connect(OpenInformationUI)
InformationUI.Holder.Pages.UIPageLayout.Changed:Connect(UpdateInformationUI)

OwnerUIButton.Button.MouseButton1Click:Connect(OpenOwnerUI)
OwnerUI.Holder.ResetData.Holder.Confirm.MouseButton1Click:Connect(ResetData)

Mouse.Changed:Connect(UpdateScrollBars)


-- Events

-- Runs when the script loads this far
CloseAndResetAllUI(true)
TravelToHub()
UpdateAll()
SearchUI.Holder.Probabilities.Position = UDim2.new(1.161, 0, 0.981, 0)
SearchUI.Holder.Probabilities.PopOutHolder.PopOut.Rotation = 90
BadgePageIndicators:FindFirstChild(BadgePageLayout.CurrentPage.Name).BackgroundColor3 = Color3.new(0, 0, 0)
PlayTavernAnimation("Idle")

-- Runs when the script loads this far

game.Players.PlayerAdded:Connect(function() -- Make Character Invisible When They Join If Selecting Pedestal
	if Camera.CameraSubject ~= workspace[Player.Name].Humanoid then
		CharactersInvisible()
	end
end)

game.ReplicatedStorage.RemoteEvents.PopUp.OnClientEvent:Connect(function(ArtifactName)
	local NewPopUp = game.ReplicatedStorage.GuiStuff.AddedArtifact:Clone()
	NewPopUp.Parent = PopUpHolderUI
	NewPopUp.ArtifactName.Text = ArtifactName
	NewPopUp.Size = UDim2.new(0.25, 0, 0.025, 0)
	if ArtifactsMS[ArtifactName].ImageID ~= nil and ArtifactsMS[ArtifactName].ImageID ~= "" then
		NewPopUp.ImageHolder.ArtifactImage.Image = ArtifactsMS[ArtifactName].ImageID
	else
		NewPopUp.ImageHolder.ArtifactImage.Image = FillerImageID -- Filler Item
	end
	local NewTween1 = TweenService:Create(NewPopUp, TweenInfo.new(0.2), {Size = UDim2.new(1, 0, 0.19, 0)})
	NewTween1:Play()
	local NewTween2 = TweenService:Create(NewPopUp, TweenInfo.new(0.2), {Size = UDim2.new(0.875, 0, 0.127, 0)})
	NewTween2:Play()
	Debris:AddItem(NewPopUp, 5)
end)

UserInputService.InputBegan:Connect(function(Input, Event) -- Keybinds
	local SavedStatsValue = HttpService:JSONDecode(Player.Information.SavedStats.Value)
	local UnSavedStatsValue
	if Player.Information.UnSavedStats.Value ~= "" then
		UnSavedStatsValue = HttpService:JSONDecode(Player.Information.UnSavedStats.Value)
	end
	if not UserInputService:GetFocusedTextBox() then
		if Input.KeyCode == Enum.KeyCode.E then
			OpenInventoryUI()
		elseif Input.KeyCode == Enum.KeyCode.F and Biome.Value == "Home" then
			OpenPedestalUI()
		elseif Input.KeyCode == Enum.KeyCode.F and Biome.Value ~= "Home" and Biome.Value ~= "Hub" then
			Search()
		elseif Input.KeyCode == Enum.KeyCode.O then
			OpenOptionsUI()
		elseif Input.KeyCode == Enum.KeyCode.I then
			OpenArtifactIndexUI()
		elseif Input.KeyCode == Enum.KeyCode.H then
			OpenInformationUI()
		end
	end
end)

UserInputService.InputEnded:Connect(function(Input, Event)
	if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
		HoldingMusicVolumeSlider = false
		HoldingEffectsVolumeSlider = false
	end
end)

Biome.Changed:Connect(function()
	CloseAndResetAllUI(true)
	if Biome.Value == "Home" then
		TravelToHome()
	elseif Biome.Value == "Hub" then
		TravelToHub()
	else
		TravelToBiome()
	end
	UpdateBadgeUI()
end)

SearchUI.Holder.Probabilities.PopOutHolder.PopOut.MouseButton1Click:Connect(function()
	local ShowTween = TweenService:Create(SearchUI.Holder.Probabilities, TweenInfo.new(0.1), {Position = UDim2.new(0.995, 0, 0.981, 0)})
	local HideTween = TweenService:Create(SearchUI.Holder.Probabilities, TweenInfo.new(0.1), {Position = UDim2.new(1.161, 0, 0.981, 0)})
	if PopOutDebug == false then
		PopOutDebug = true
		if SearchUI.Holder.Probabilities.Position == UDim2.new(0.995, 0, 0.981, 0) then
			HideTween:Play()
			SearchUI.Holder.Probabilities.PopOutHolder.PopOut.Rotation = 90
			HideTween.Completed:Wait()
		else
			ShowTween:Play()
			SearchUI.Holder.Probabilities.PopOutHolder.PopOut.Rotation = 270
			ShowTween.Completed:Wait()
		end
		PopOutDebug = false
	end
end)

-- Artifact Inventory
InventoryButtonUI.MouseEnter:Connect(function()
	InventoryButtonUI.Shade.Visible = true
	InventoryButtonUI.Keybind.TextColor3 = Color3.fromRGB(153, 153, 153)
end)

InventoryButtonUI.MouseLeave:Connect(function()
	if InventoryUI.Holder.Visible == false then
		InventoryButtonUI.Shade.Visible = false
		InventoryButtonUI.Keybind.TextColor3 = Color3.fromRGB(255, 255, 255)
	end
end)

QuickStoreButton.MouseButton1Click:Connect(function() -- Quick Scrap
	if InventoryUI.Storing.Value == false then
		QuickStoreButton.BackgroundColor3 = Color3.new(1, 0.384314, 0.384314) 
		InventoryUI.Storing.Value = true
		QuickStoreWarning.Visible = true
	else
		QuickStoreButton.BackgroundColor3 = Color3.new(1, 1, 1) -- Customization Needs to be checked here instead eventually !!!
		InventoryUI.Storing.Value = false
		QuickStoreWarning.Visible = false
	end
	UnSelectArtifact()
end)

StoreAllButton.MouseButton1Click:Connect(function()
	if Confirming == true then
		for i, v in pairs(Inventory:GetChildren()) do
			if not string.find(v.Name, "Pedestal") then
				game.ReplicatedStorage.RemoteEvents.StoreArtifact:FireServer(v.Name)
			end
		end
		StoreAllButton.BackgroundColor3 = Color3.new(1, 1, 1) -- Customization Needs to be checked here instead eventually !!!
		StoreAllButton.Text = "Store".."\n".."All"
		Confirming = false
	else
		StoreAllButton.BackgroundColor3 = Color3.new(1, 0.384314, 0.384314)
		StoreAllButton.Text = "Confirm"
		Confirming = true
		if not UserInputService.MouseEnabled then
			StoreAllTimer = 5
			repeat
				StoreAllTimer -= 1
				wait(1)
			until StoreAllTimer == 0 or StoreAllButton.MouseButton1Click
			StoreAllTimer = 0
			StoreAllButton.BackgroundColor3 = Color3.new(1, 1, 1) -- Customization Needs to be checked here instead eventually !!!
			StoreAllButton.Text = "Store".."\n".."All"
			Confirming = false
		end
		UnSelectArtifact()
	end
end)

StoreAllButton.MouseLeave:Connect(function()
	if UserInputService.MouseEnabled then
		StoreAllButton.BackgroundColor3 = Color3.new(1, 1, 1) -- Customization Needs to be checked here instead eventually !!!
		StoreAllButton.Text = "Store".."\n".."All"
		Confirming = false
	end
end)

InformationHolder["Storing Button"].MouseButton1Click:Connect(function()
	UnSelectArtifact()
	game.ReplicatedStorage.RemoteEvents.StoreArtifact:FireServer(InventoryUI.SelectedArtifact.Value)
end)
-- Artifact Inventory

-- Artifact Selecting
ASEquip.MouseButton1Click:Connect(function() -- Equip Button Clicked In ArtifactSelecting
	local Artifact = Inventory:FindFirstChild(ASCurrentArtifact.Value)
	local ArtifactInformation = HttpService:JSONDecode(Artifact.Value)
	for i, v in pairs(Inventory:GetChildren()) do
		if string.find(v.Name, "Pedestal") then
			local CheckedInformation = HttpService:JSONDecode(v.Value)
			if CheckedInformation.Name == ArtifactInformation.Name and PSCurrentPedestal.Value.Name ~= v.Name then
				local NewWarning = game.ReplicatedStorage.GuiStuff.Selections.Warning:Clone()
				NewWarning.Parent = ASHolderUI
				Debris:AddItem(NewWarning, 3)
				return
			end
		end
	end
	game.ReplicatedStorage.RemoteEvents.Pedestal.EquipArtifact:FireServer(PSCurrentPedestal.Value, ASCurrentArtifact.Value)
	ASCurrentArtifact.Value = ""
end)

ASUnEquip.MouseButton1Click:Connect(function() -- UnEquip Button Clicked In ArtifactSelecting
	game.ReplicatedStorage.RemoteEvents.Pedestal.UnEquipArtifact:FireServer(PSCurrentPedestal.Value)
	ASCurrentArtifact.Value = ""
end)

ASClose.MouseButton1Click:Connect(function()
	CloseArtifactSelection()
end) -- Close Button Clicked In ArtifactSelecting

-- Artifact Selecting

-- Pedestal Selection
PedestalSelectionUI.Button.MouseEnter:Connect(function()
	PedestalSelectionUI.Button.Shade.Visible = true
	PedestalSelectionUI.Button.Keybind.TextColor3 = Color3.fromRGB(153, 153, 153)
end)

PedestalSelectionUI.Button.MouseLeave:Connect(function()
	if PedestalSelectionUI.Holder.Visible == false then
		PedestalSelectionUI.Button.Shade.Visible = false
		PedestalSelectionUI.Button.Keybind.TextColor3 = Color3.fromRGB(255, 255, 255)
	end
end)

PedestalSelectionUI.Button.Button.MouseButton1Click:Connect(function() -- Change this to just an event ???
	OpenPedestalUI()
end)

PedestalSelectionSelectButton.MouseButton1Click:Connect(function()
	ArtifactSelectingUI.Holder.Visible = true
end)

PedestalSelectionUpgradeButton.MouseButton1Click:Connect(function()

end)

NextButton.MouseButton1Click:Connect(function()
	local SavedStatsValue = HttpService:JSONDecode(SavedStats.Value)

	local Pedestals = workspace.PlayerBases:FindFirstChild(Player.Name).Pedestals
	local NextPedestalNumber = tonumber(PSCurrentPedestal.Value.Name:match("%d+"))

	if NextPedestalNumber ~= nil then
		if NextPedestalNumber == GameInformationMS["Max Pedestals"] or NextPedestalNumber == SavedStatsValue["Unlocked Pedestals"] + 1 then-- If we add more pedestals this line will need to be changed
			NextPedestalNumber = 0
		end
		if NextPedestalNumber + 1 > SavedStatsValue["Unlocked Pedestals"] then
			CloseArtifactSelection()
			UnlockButton.Visible = true
			PedestalSelectionSelectButton.Visible = false
			PedestalSelectionUpgradeButton.Visible = false
		else
			UnlockButton.Visible = false
			PedestalSelectionSelectButton.Visible = true
			PedestalSelectionUpgradeButton.Visible = true
		end

		local NextPedestal = Pedestals:FindFirstChild("Pedestal"..(NextPedestalNumber + 1)).Pedestal

		NextPedestal.Parent:FindFirstChild("Selected").Transparency = 0
		if PSCurrentPedestal.Value ~= nil then
			PSCurrentPedestal.Value:FindFirstChild("Selected").Transparency = 1
		end
		PSCurrentPedestal.Value = NextPedestal.Parent

		local Focus = NextPedestal
		local CameraPart = Focus.CFrame * CFrame.new(Vector3.new(7,5,0))

		Camera.CameraType = Enum.CameraType.Scriptable
		MoveCamera = TweenService:Create(Camera, TweenInfo.new(0.5), {["CFrame"] = CFrame.new(CameraPart.Position, Focus.Position)})
		MoveCamera:Play()
	end
end)

PreviousButton.MouseButton1Click:Connect(function()
	local SavedStatsValue = HttpService:JSONDecode(SavedStats.Value)

	local Pedestals = workspace.PlayerBases:FindFirstChild(Player.Name).Pedestals
	local PreviousPedestalNumber = tonumber(PSCurrentPedestal.Value.Name:match("%d+"))

	if PreviousPedestalNumber ~= nil then
		if PreviousPedestalNumber == 1 then
			if SavedStatsValue["Unlocked Pedestals"] < GameInformationMS["Max Pedestals"] then
				PreviousPedestalNumber = SavedStatsValue["Unlocked Pedestals"] + 2
			else
				PreviousPedestalNumber = SavedStatsValue["Unlocked Pedestals"] + 1
			end
		end
		if PreviousPedestalNumber - 1 > SavedStatsValue["Unlocked Pedestals"] then -- If the current pedestal number is higher than the unlocked amount
			UnlockButton.Visible = true
			CloseArtifactSelection()
			PedestalSelectionSelectButton.Visible = false
			PedestalSelectionUpgradeButton.Visible = false
		else
			UnlockButton.Visible = false
			PedestalSelectionSelectButton.Visible = true
			PedestalSelectionUpgradeButton.Visible = true
		end

		local PreviousPedestal = Pedestals:FindFirstChild("Pedestal"..(PreviousPedestalNumber - 1)).Pedestal

		PreviousPedestal.Parent:FindFirstChild("Selected").Transparency = 0
		if PSCurrentPedestal.Value ~= nil then
			PSCurrentPedestal.Value:FindFirstChild("Selected").Transparency = 1
		end
		PSCurrentPedestal.Value = PreviousPedestal.Parent

		local Focus = PreviousPedestal
		local CameraPart = Focus.CFrame * CFrame.new(Vector3.new(7,5,0))

		Camera.CameraType = Enum.CameraType.Scriptable
		MoveCamera = TweenService:Create(Camera, TweenInfo.new(0.5), {["CFrame"] = CFrame.new(CameraPart.Position, Focus.Position)})
		MoveCamera:Play()
	end
end)
-- Pedestal Selection

-- Artifact Index UI
ArtifactIndexButtonUI.MouseEnter:Connect(function()
	ArtifactIndexButtonUI.Shade.Visible = true
	ArtifactIndexButtonUI.Keybind.TextColor3 = Color3.fromRGB(153, 153, 153)
end)

ArtifactIndexButtonUI.MouseLeave:Connect(function()
	if ArtifactIndexUI.Holder.Visible == false then
		ArtifactIndexButtonUI.Shade.Visible = false
		ArtifactIndexButtonUI.Keybind.TextColor3 = Color3.fromRGB(255, 255, 255)
	end
end)

-- Information UI
InformationButtonUI.MouseEnter:Connect(function()
	InformationButtonUI.Shade.Visible = true
	InformationButtonUI.Keybind.TextColor3 = Color3.fromRGB(153, 153, 153)
end)

InformationButtonUI.MouseLeave:Connect(function()
	if InformationUIHolder.Visible == false then
		InformationButtonUI.Shade.Visible = false
		InformationButtonUI.Keybind.TextColor3 = Color3.fromRGB(255, 255, 255)
	end
end)

-- Tavern UI
ProximityPromptService.PromptTriggered:Connect(function(Prompt)
	if Prompt.Name == "TavernKeep" then
		CloseAndResetAllUI(false)
		CharactersInvisible()
		--Player.Character.HumanoidRootPart.Anchored = true -- Not Needed???
		LastPrompt = Prompt
		Prompt.Enabled = false
		local Focus = Prompt.Parent.Parent:FindFirstChild("NPC").Head
		local CameraPart = Focus.CFrame * CFrame.new(Vector3.new(0,0,-5.5))
		Camera.CameraType = Enum.CameraType.Scriptable
		MoveCamera = TweenService:Create(Camera, TweenInfo.new(0.5), {["CFrame"] = CFrame.new(CameraPart.Position, Focus.Position)})
		MoveCamera:Play()
		Dialogue.Visible = true
		local Text = "Welcome to my Tiny Tavern what can I do for you today?"
		for i = 1,#Text,1 do
			DialogueHolder.Dialogue.Text = string.sub(Text,1,i)
			wait(0.02)
		end
	end
end)

DialogueHolder.Dialogue.MouseButton1Click:Connect(function()
	DialogueHolder.Dialogue.Visible = false
	DialogueOptionsHolder.Visible = true
end)

DialogueOptionsHolder.Close.MouseButton1Click:Connect(function()
	CloseAndResetAllUI(true)
end)

DialogueOptionsHolder.OpenBadgeClaim.MouseButton1Click:Connect(function()
	OpenBadgeUI()
end)

BadgeHolder.Close.MouseButton1Click:Connect(function()
	CloseAndResetAllUI(true)
end)

-- Detect when artifact storage changes and then update the requirements

-- Tavern UI

-- Options UI
OptionsButtonUI.MouseEnter:Connect(function()
	OptionsButtonUI.Shade.Visible = true
	OptionsButtonUI.Keybind.TextColor3 = Color3.fromRGB(153, 153, 153)
end)

OptionsButtonUI.MouseLeave:Connect(function()
	if OptionsUI.Holder.Visible == false then
		OptionsButtonUI.Shade.Visible = false
		OptionsButtonUI.Keybind.TextColor3 = Color3.fromRGB(255, 255, 255)
	end
end)

MusicMuteButton.MouseButton1Click:Connect(function()
	local SavedSettingsValue = HttpService:JSONDecode(SavedSettings.Value)
	if SavedSettingsValue["Music Playing"] == false then
		game.ReplicatedStorage.RemoteEvents.Options.Music:FireServer("Music Playing", true)
	else
		game.ReplicatedStorage.RemoteEvents.Options.Music:FireServer("Music Playing", false)
	end
end)

MusicVolumeSlider.Button.MouseButton1Down:Connect(function()
	HoldingMusicVolumeSlider = true
end)

EffectsMuteButton.MouseButton1Click:Connect(function() -- Edit this
	local SavedSettingsValue = HttpService:JSONDecode(SavedSettings.Value)
	if SavedSettingsValue["Effects Muted"] == false then
		game.ReplicatedStorage.RemoteEvents.Options.Music:FireServer("Effects Muted", true)
	else
		game.ReplicatedStorage.RemoteEvents.Options.Music:FireServer("Effects Muted", false)
	end
end)

EffectsVolumeSlider.Button.MouseButton1Down:Connect(function()
	HoldingEffectsVolumeSlider = true
end)
-- Options UI

-- Owner UI
OwnerUIButton.MouseEnter:Connect(function()
	OwnerUIButton.Shade.Visible = true
	OwnerUIButton.Keybind.TextColor3 = Color3.fromRGB(153, 153, 153)
end)

OwnerUIButton.MouseLeave:Connect(function()
	if OwnerUI.Holder.Visible == false then
		OwnerUIButton.Shade.Visible = false
		OwnerUIButton.Keybind.TextColor3 = Color3.fromRGB(255, 255, 255)
	end
end)

RunService.RenderStepped:Connect(function()
	local MousePosition = UserInputService:GetMouseLocation().X
	if HoldingMusicVolumeSlider == true then
		local ButtonPosition = MusicVolumeSlider.Button.Position
		local SliderSize = MusicVolumeSlider.AbsoluteSize.X
		local SliderPosition = MusicVolumeSlider.AbsolutePosition.X
		local Position = Snap((MousePosition-SliderPosition)/SliderSize, SliderStep)
		local Percentage = math.clamp(Position, 0, 1)
		game.ReplicatedStorage.RemoteEvents.Options.Music:FireServer("Music Volume", Percentage/2)
	end
	if HoldingEffectsVolumeSlider == true then
		local ButtonPosition = EffectsVolumeSlider.Button.Position
		local SliderSize = EffectsVolumeSlider.AbsoluteSize.X
		local SliderPosition = EffectsVolumeSlider.AbsolutePosition.X
		local Position = Snap((MousePosition-SliderPosition)/SliderSize, SliderStep)
		local Percentage = math.clamp(Position, 0, 1)
		game.ReplicatedStorage.RemoteEvents.Options.Music:FireServer("Effects Volume", Percentage/2)
	end
end)