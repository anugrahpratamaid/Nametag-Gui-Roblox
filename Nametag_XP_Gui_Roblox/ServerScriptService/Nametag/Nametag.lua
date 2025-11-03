local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local config = require(script.NametagConfig)
local NametagTemplate = ReplicatedStorage.GUI:WaitForChild("Nametag")
-- Datastore
local DSS = game:GetService("DataStoreService")
local levelStore = DSS:GetDataStore("PlayerLevel")
local XPStore = DSS:GetDataStore("PlayerXP")
local requiredXPStore = DSS:GetDataStore("PlayerRequiredXP")

local function createLevelNametag(player, character)
	--if player:GetAttribute("NametagVisible") == false then return end
	local head = character:FindFirstChild("Head")
	if not head then return end

	-- Hapus tag lama jika ada
	local old = character:FindFirstChild("Nametag")
	if old then old:Destroy() end
	
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if humanoid then
		humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
	end

	local tag = NametagTemplate:Clone()
	tag.Name = "Nametag"
	tag.Adornee = head
	tag.Parent = character

	local leaderstats = player:FindFirstChild("leaderstats")
	local level = leaderstats and leaderstats:FindFirstChild("Level") and leaderstats.Level.Value or 0
	local levelColor = config.getLevelColor(level)
	local titleText = config.getTitle(level)

	-- Set Username
	local usernameLabel = tag.Main:FindFirstChild("Name"):FindFirstChild("Username")
	if usernameLabel then
		usernameLabel.Text = player.DisplayName
	end

	-- Set Level
	local levelLabel = tag.Main:FindFirstChild("Frame"):FindFirstChild("Level")
	if levelLabel then
		levelLabel.Text = tostring(level)
		levelLabel.TextColor3 = levelColor
	end

	-- Set Title
	local titleLabel = tag.Main:FindFirstChild("Title")
	if titleLabel then
		titleLabel.Text = titleText
		titleLabel.TextColor3 = levelColor
		
	end

	-- XP bar update
	local xpFill = tag.Main:FindFirstChild("BackgroundXP"):FindFirstChild("XPBar")
	local xpText = tag.Main:FindFirstChild("BackgroundXP"):FindFirstChild("LevelXPText")

	local function updateXPBar()
		local xp = player:FindFirstChild("XP")
		local reqXP = player:FindFirstChild("RequiredXP")
		if xp and reqXP and reqXP.Value > 0 then
			local ratio = math.clamp(xp.Value / reqXP.Value, 0, 1)
			if xpFill then
				TweenService:Create(xpFill, TweenInfo.new(0.3), {
					Size = UDim2.new(ratio, 0, 1, 0)
				}):Play()
			end
			if xpText then
				xpText.Text = string.format("%d / %d XP", xp.Value, reqXP.Value)
			end
		end
	end

	-- Listener xp change
	if player:FindFirstChild("XP") then
		player.XP:GetPropertyChangedSignal("Value"):Connect(updateXPBar)
	end
	if player:FindFirstChild("RequiredXP") then
		player.RequiredXP:GetPropertyChangedSignal("Value"):Connect(updateXPBar)
	end
	updateXPBar()

	-- Listener perubahan Level
	if leaderstats and leaderstats:FindFirstChild("Level") then
		leaderstats.Level:GetPropertyChangedSignal("Value"):Connect(function()
			local newLevel = leaderstats.Level.Value
			local newColor = config.getLevelColor(newLevel)
			local newTitle = config.getTitle(newLevel)

			if levelLabel then
				levelLabel.Text = tostring(newLevel)
				levelLabel.TextColor3 = newColor
			end
			if titleLabel then
				titleLabel.Text = newTitle
				titleLabel.TextColor3 = newColor
			end
		end)
	end
end
-- Player Setup
Players.PlayerAdded:Connect(function(player)
	if player:GetAttribute("NametagVisible") == nil then
		player:SetAttribute("NametagVisible", true)
	end
	
	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = player

	local level = Instance.new("NumberValue")
	level.Name = "Level"
	level.Value = 1
	level.Parent = leaderstats

	local XP = Instance.new("NumberValue")
	XP.Name = "XP"
	XP.Value = 0
	XP.Parent = player

	local requiredXP = Instance.new("NumberValue")
	requiredXP.Name = "RequiredXP"
	requiredXP.Value = 100
	requiredXP.Parent = player
	
	pcall(function()
		local savedLevel = levelStore:GetAsync(player.UserId)
		local savedXP = XPStore:GetAsync(player.UserId)
		local savedRequiredXP = requiredXPStore:GetAsync(player.UserId)

		if savedLevel then
			level.Value = savedLevel
		end
		if savedXP then
			XP.Value = savedXP
		end
		if savedRequiredXP then
			requiredXP.Value = savedRequiredXP
		end
	end)
	
	XP.Changed:Connect(function()
		if XP.Value >= requiredXP.Value then
			XP.Value -= requiredXP.Value
			level.Value += 1
			requiredXP.Value = math.ceil(100 * (level.Value ^ 0.495))
		end
	end)
	
	player.CharacterAdded:Connect(function(char)
		task.wait(1)
		createLevelNametag(player, char)
		if player.Character then
			createLevelNametag(player, char)
		end

		player:GetAttributeChangedSignal("NametagVisible"):Connect(function()
			createLevelNametag(player, player.Character)
		end)
	end)
end)

Players.PlayerRemoving:Connect(function(player)
	local leaderstats = player:FindFirstChild("leaderstats")
	local XP = player:FindFirstChild("XP")
	local requiredXP = player:FindFirstChild("RequiredXP")
	local level = leaderstats and leaderstats:FindFirstChild("Level")

	if level and XP and requiredXP then
		pcall(function()
			levelStore:SetAsync(player.UserId, level.Value)
			XPStore:SetAsync(player.UserId, XP.Value)
			requiredXPStore:SetAsync(player.UserId, requiredXP.Value)
		end)
	else
		warn("Failed saved data for: " .. player.Name)
	end
end)

---- RemoteEvent toggle visibility
--local ToggleNametagEvent = Instance.new("RemoteEvent")
--ToggleNametagEvent.Name = "ToggleNametagEvent"
--ToggleNametagEvent.Parent = ReplicatedStorage

--ToggleNametagEvent.OnServerEvent:Connect(function(player)
--	player:SetAttribute("NametagVisible", not player:GetAttribute("NametagVisible"))
--end)
